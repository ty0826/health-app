package com.health.migration;

import org.junit.jupiter.api.Test;
import org.springframework.core.io.ClassPathResource;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;

import static org.junit.jupiter.api.Assertions.assertTrue;

class DatabaseMigrationTest {

    @Test
    void uniqueUserDateMigrationRemovesDuplicatesBeforeAddingConstraint() throws Exception {
        ClassPathResource migration = new ClassPathResource(
                "db/migration/V2__health_data_unique_user_date.sql");

        assertTrue(migration.exists(), "Flyway V2 migration must exist");

        String sql = new String(Files.readAllBytes(migration.getFile().toPath()), StandardCharsets.UTF_8);
        assertTrue(sql.contains("DELETE old_row"));
        assertTrue(sql.contains("DROP INDEX idx_user_date"));
        assertTrue(sql.contains("ADD UNIQUE KEY uk_user_date"));
    }
}
