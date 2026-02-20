# Build stage
FROM gradle:4.10-jdk8 AS build
WORKDIR /app

# 1. Copy only the build configuration first
COPY build.gradle settings.gradle ./

# 2. Copy the source code (Avoids copying .git or local .gradle if .dockerignore is present)
COPY src ./src

# 3. Limit Gradle's memory footprint during the build
RUN gradle build --no-daemon -x test \
    -Dorg.gradle.jvmargs="-Xmx1g -XX:MaxMetaspaceSize=256m"

# Run stage
FROM eclipse-temurin:8-jdk-jammy
WORKDIR /app
# Use the wildcard to be safe with version names
COPY --from=build /app/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]