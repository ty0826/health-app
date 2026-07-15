package com.health.service;

import com.health.dto.LoginRequest;
import com.health.dto.RegisterRequest;
import com.health.entity.User;
import com.health.mapper.UserMapper;
import com.health.util.JwtUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserMapper userMapper;

    @Mock
    private JwtUtil jwtUtil;

    private UserService userService;

    @BeforeEach
    void setUp() {
        userService = new UserService();
        ReflectionTestUtils.setField(userService, "userMapper", userMapper);
        ReflectionTestUtils.setField(userService, "jwtUtil", jwtUtil);
    }

    @Test
    void registerStoresBcryptPasswordAndGeneratedHashCanLogin() {
        when(userMapper.selectOne(any())).thenReturn(null);

        RegisterRequest registerRequest = new RegisterRequest();
        registerRequest.setUsername("alice");
        registerRequest.setPassword("StrongPassword123");
        registerRequest.setNickname("Alice");

        userService.register(registerRequest);

        ArgumentCaptor<User> userCaptor = ArgumentCaptor.forClass(User.class);
        verify(userMapper).insert(userCaptor.capture());
        User storedUser = userCaptor.getValue();

        assertNotNull(storedUser.getPassword());
        assertNotEquals(registerRequest.getPassword(), storedUser.getPassword());
        assertTrue(storedUser.getPassword().matches("^\\$2[aby]\\$\\d{2}\\$.{53}$"));

        storedUser.setId(7L);
        when(userMapper.selectOne(any())).thenReturn(storedUser);
        when(jwtUtil.generateToken(7L, "alice")).thenReturn("jwt-token");

        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setUsername("alice");
        loginRequest.setPassword("StrongPassword123");

        Map<String, Object> result = userService.login(loginRequest);

        assertEquals("jwt-token", result.get("token"));
    }

    @Test
    void loginUsesTheSameAuthenticationErrorForUnknownUsers() throws Exception {
        when(userMapper.selectOne(any())).thenReturn(null);

        RuntimeException exception = assertThrows(RuntimeException.class,
                () -> userService.login(loginRequest("missing", "password")));

        assertBusinessError(exception, 401, "用户名或密码错误");
    }

    @Test
    void loginUsesTheSameAuthenticationErrorForWrongPasswords() throws Exception {
        User storedUser = new User();
        storedUser.setId(7L);
        storedUser.setUsername("alice");
        storedUser.setPassword(new BCryptPasswordEncoder().encode("correct-password"));
        when(userMapper.selectOne(any())).thenReturn(storedUser);

        RuntimeException exception = assertThrows(RuntimeException.class,
                () -> userService.login(loginRequest("alice", "wrong-password")));

        assertBusinessError(exception, 401, "用户名或密码错误");
    }

    @Test
    void registerReportsDuplicateUsernamesAsConflict() throws Exception {
        User existing = new User();
        existing.setUsername("alice");
        when(userMapper.selectOne(any())).thenReturn(existing);

        RegisterRequest request = new RegisterRequest();
        request.setUsername("alice");
        request.setPassword("StrongPassword123");
        request.setNickname("Alice");

        RuntimeException exception = assertThrows(RuntimeException.class,
                () -> userService.register(request));

        assertBusinessError(exception, 409, "用户名已存在");
    }

    private LoginRequest loginRequest(String username, String password) {
        LoginRequest request = new LoginRequest();
        request.setUsername(username);
        request.setPassword(password);
        return request;
    }

    private void assertBusinessError(RuntimeException exception, int code, String message) throws Exception {
        assertEquals("BusinessException", exception.getClass().getSimpleName());
        assertEquals(code, exception.getClass().getMethod("getCode").invoke(exception));
        assertEquals(message, exception.getMessage());
    }
}
