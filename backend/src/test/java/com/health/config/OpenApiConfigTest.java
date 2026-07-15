package com.health.config;

import org.junit.jupiter.api.Test;

import java.lang.reflect.Method;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

class OpenApiConfigTest {

    @Test
    void documentsTheApiAndJwtBearerAuthentication() throws Exception {
        Class<?> configClass = Class.forName("com.health.config.OpenApiConfig");
        Object config = configClass.getDeclaredConstructor().newInstance();
        Object openApi = configClass.getMethod("healthManagerOpenAPI").invoke(config);

        Object info = openApi.getClass().getMethod("getInfo").invoke(openApi);
        assertEquals("健康管家 API", invoke(info, "getTitle"));
        assertEquals("1.0.0", invoke(info, "getVersion"));

        Object components = invoke(openApi, "getComponents");
        @SuppressWarnings("unchecked")
        Map<String, Object> schemes = (Map<String, Object>) invoke(components, "getSecuritySchemes");
        Object bearer = schemes.get("bearerAuth");
        assertNotNull(bearer);
        assertEquals("http", String.valueOf(invoke(bearer, "getType")));
        assertEquals("bearer", invoke(bearer, "getScheme"));
        assertEquals("JWT", invoke(bearer, "getBearerFormat"));
    }

    private Object invoke(Object target, String methodName) throws Exception {
        Method method = target.getClass().getMethod(methodName);
        return method.invoke(target);
    }
}
