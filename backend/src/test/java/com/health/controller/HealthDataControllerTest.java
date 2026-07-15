package com.health.controller;

import com.health.service.HealthDataService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.test.web.servlet.setup.StandaloneMockMvcBuilder;
import org.springframework.test.util.ReflectionTestUtils;

import static org.mockito.Mockito.mock;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class HealthDataControllerTest {

    private MockMvc mockMvc;
    private HealthDataService healthDataService;

    @BeforeEach
    void setUp() {
        healthDataService = mock(HealthDataService.class);
        HealthDataController controller = new HealthDataController();
        ReflectionTestUtils.setField(controller, "healthDataService", healthDataService);
        StandaloneMockMvcBuilder builder = MockMvcBuilders.standaloneSetup(controller);
        attachGlobalHandlerWhenAvailable(builder);
        mockMvc = builder.build();
    }

    @Test
    void rejectsHealthMetricsOutsideSupportedRanges() throws Exception {
        mockMvc.perform(post("/api/health/record")
                        .requestAttr("userId", 7L)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"heartRate\":10,\"mood\":6}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(400));
    }

    @Test
    void rejectsRecordDatesThatDoNotUseIsoFormat() throws Exception {
        mockMvc.perform(post("/api/health/record")
                        .requestAttr("userId", 7L)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"recordDate\":\"15/07/2026\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(400));
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
