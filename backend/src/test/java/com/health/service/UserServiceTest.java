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

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
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
}
