# Build stage
FROM gradle:4.10-jdk8 AS build
WORKDIR /app

# 1. Copy only the build configuration first
COPY build.gradle settings.gradle ./

# 2. Copy the source code
COPY src ./src

# 3. FIX: Use GRADLE_OPTS to prevent forking a new JVM
# This keeps the memory footprint steady so Harness doesn't kill the pod
RUN GRADLE_OPTS="-Xmx1536m -Xms512m -XX:MaxMetaspaceSize=256m" gradle build --no-daemon -x test

# Run stage
FROM eclipse-temurin:8-jdk-jammy
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
