package com.health.config;

import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class LocalDatasourceConfigTest {

    @Test
    void localDatasourceCredentialsCanBeOverriddenByEnvironment() throws IOException {
        try (InputStream input = getClass().getClassLoader().getResourceAsStream("application-local.yml")) {
            assertTrue(input != null, "application-local.yml must be available on the classpath");
            String config = new String(readAllBytes(input), StandardCharsets.UTF_8);

            assertTrue(config.contains("username: ${DB_USERNAME:root}"));
            assertTrue(config.contains("password: ${DB_PASSWORD:}"));
            assertFalse(config.contains("password: 123456"));
        }
    }

    private byte[] readAllBytes(InputStream input) throws IOException {
        byte[] buffer = new byte[4096];
        int length;
        java.io.ByteArrayOutputStream output = new java.io.ByteArrayOutputStream();
        while ((length = input.read(buffer)) != -1) {
            output.write(buffer, 0, length);
        }
        return output.toByteArray();
    }
}
