package com.health.mapper;

import com.health.entity.HealthData;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_CLASS)
@Sql(statements = {
        "DROP TABLE IF EXISTS health_data",
        "CREATE TABLE health_data (id BIGINT AUTO_INCREMENT PRIMARY KEY, user_id BIGINT NOT NULL, record_date DATE NOT NULL, steps INT, deleted INT DEFAULT 0)",
        "INSERT INTO health_data (user_id, record_date, steps, deleted) VALUES (1, '2026-07-15', 8000, 0)",
        "INSERT INTO health_data (user_id, record_date, steps, deleted) VALUES (2, '2026-07-15', 3000, 0)"
})
class HealthDataMapperIsolationTest {

    @Autowired
    private HealthDataMapper healthDataMapper;

    @Test
    void dateRangeQueriesOnlyReturnTheRequestedUsersRecords() {
        List<HealthData> records = healthDataMapper.selectByDateRange(1L, LocalDate.of(2026, 7, 1));

        assertEquals(1, records.size());
        assertEquals(Long.valueOf(1L), records.get(0).getUserId());
        assertEquals(Integer.valueOf(8000), records.get(0).getSteps());
    }

    @Test
    void singleDateQueriesCannotReadAnotherUsersRecord() {
        HealthData record = healthDataMapper.selectByUserAndDate(2L, LocalDate.of(2026, 7, 15));

        assertEquals(Long.valueOf(2L), record.getUserId());
        assertEquals(Integer.valueOf(3000), record.getSteps());
    }
}
