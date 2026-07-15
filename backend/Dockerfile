FROM maven:3.9.9-eclipse-temurin-8 AS build

WORKDIR /workspace
COPY pom.xml ./
RUN mvn -B dependency:go-offline

COPY src ./src
RUN mvn -B package -DskipTests

FROM eclipse-temurin:8-jre-alpine

RUN addgroup -S healthapp && adduser -S healthapp -G healthapp
WORKDIR /app
COPY --from=build /workspace/target/health-manager-1.0.0.jar /app/app.jar

USER healthapp
EXPOSE 9999

HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=5 \
  CMD wget -q -O /dev/null http://127.0.0.1:9999/api/system/app-info || exit 1

ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-jar", "/app/app.jar"]
