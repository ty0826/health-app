package com.health.service;

import com.health.entity.HealthData;
import com.health.mapper.HealthDataMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class HealthDataServiceTest {

    @Mock
    private HealthDataMapper healthDataMapper;

    private HealthDataService healthDataService;

    @BeforeEach
    void setUp() {
        healthDataService = new HealthDataService();
        ReflectionTestUtils.setField(healthDataService, "healthDataMapper", healthDataMapper);
    }

    @Test
    void statisticsIgnoreMissingValuesInsteadOfTreatingThemAsZero() {
        HealthData complete = record(LocalDate.now().minusDays(1));
        complete.setSteps(8000);
        complete.setHeartRate(72);
        complete.setSleepHours(new BigDecimal("7.5"));
        complete.setWeight(new BigDecimal("65.0"));
        complete.setBloodSugar(new BigDecimal("5.2"));

        HealthData missing = record(LocalDate.now());

        when(healthDataMapper.selectByDateRange(eq(1L), any(LocalDate.class)))
                .thenReturn(Arrays.asList(complete, missing));

        Map<String, Object> stats = healthDataService.getStats(1L, 7);

        assertEquals(8000, stats.get("avgSteps"));
        assertEquals(72, stats.get("avgHeartRate"));
        assertEquals(new BigDecimal("7.5"), stats.get("avgSleepHours"));
        assertEquals(new BigDecimal("65.0"), stats.get("avgWeight"));
        assertEquals(new BigDecimal("5.2"), stats.get("avgBloodSugar"));
    }

    @Test
    void statisticsReturnZeroWhenMetricHasNoValues() {
        when(healthDataMapper.selectByDateRange(eq(1L), any(LocalDate.class)))
                .thenReturn(Collections.singletonList(record(LocalDate.now())));

        Map<String, Object> stats = healthDataService.getStats(1L, 7);

        assertEquals(0, stats.get("avgSteps"));
        assertEquals(0, stats.get("avgHeartRate"));
        assertEquals(BigDecimal.ZERO, stats.get("avgSleepHours"));
        assertEquals(BigDecimal.ZERO, stats.get("avgWeight"));
        assertEquals(BigDecimal.ZERO, stats.get("avgBloodSugar"));
    }

    @Test
    void statisticsRejectDaysOutsideSupportedRange() {
        assertThrows(IllegalArgumentException.class, () -> healthDataService.getStats(1L, 0));
        assertThrows(IllegalArgumentException.class, () -> healthDataService.getStats(1L, 366));
    }

    @Test
    void recordListRejectsInvalidPagination() {
        assertThrows(IllegalArgumentException.class, () -> healthDataService.getRecordList(1L, 0, 20));
        assertThrows(IllegalArgumentException.class, () -> healthDataService.getRecordList(1L, 1, 0));
        assertThrows(IllegalArgumentException.class, () -> healthDataService.getRecordList(1L, 1, 101));
    }

    @Test
    void exportRejectsUnsupportedFormatAndInvalidDays() {
        assertThrows(IllegalArgumentException.class, () -> healthDataService.exportData(1L, 0, "csv"));
        assertThrows(IllegalArgumentException.class, () -> healthDataService.exportData(1L, 30, "xml"));
    }

    private HealthData record(LocalDate date) {
        HealthData data = new HealthData();
        data.setRecordDate(date);
        return data;
    }
}
