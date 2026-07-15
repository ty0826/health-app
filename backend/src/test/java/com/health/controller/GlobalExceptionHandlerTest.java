package com.health.controller;

import com.health.dto.RegisterRequest;
import com.health.exception.BusinessException;
import com.health.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.test.web.servlet.setup.StandaloneMockMvcBuilder;
import org.springframework.test.util.ReflectionTestUtils;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class GlobalExceptionHandlerTest {

    private MockMvc mockMvc;
    private UserService userService;

    @BeforeEach
    void setUp() {
        userService = mock(UserService.class);
        UserController controller = new UserController();
        ReflectionTestUtils.setField(controller, "userService", userService);
        StandaloneMockMvcBuilder builder = MockMvcBuilders.standaloneSetup(controller);
        attachGlobalHandlerWhenAvailable(builder);
        mockMvc = builder.build();
    }

    @Test
    void mapsBusinessExceptionsToTheirHttpStatusAndResultCode() throws Exception {
        doThrow(new BusinessException(409, "用户名已存在"))
                .when(userService).register(any(RegisterRequest.class));

        mockMvc.perform(post("/api/user/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(validRegistration()))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value(409))
                .andExpect(jsonPath("$.message").value("用户名已存在"));
    }

    @Test
    void hidesUnexpectedExceptionDetails() throws Exception {
        doThrow(new RuntimeException("database password leaked"))
                .when(userService).register(any(RegisterRequest.class));

        mockMvc.perform(post("/api/user/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(validRegistration()))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.code").value(500))
                .andExpect(jsonPath("$.message").value("系统内部错误"));
    }

    private String validRegistration() {
        return "{\"username\":\"alice\",\"password\":\"StrongPassword123\",\"nickname\":\"Alice\"}";
    }

    private void attachGlobalHandlerWhenAvailable(StandaloneMockMvcBuilder builder) {
        try {
            Object handler = Class.forName("com.health.exception.GlobalExceptionHandler")
                    .getDeclaredConstructor().newInstance();
            builder.setControllerAdvice(handler);
        } catch (ReflectiveOperationException ignored) {
            // The RED phase intentionally runs before the handler exists.
        }
    }
}
