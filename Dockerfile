# Use the same image for building AND running (it's already cached!)
FROM eclipse-temurin:21-jdk-jammy AS build
WORKDIR /app

# Copy ONLY the wrapper files first
COPY gradlew .
COPY gradle gradle
COPY build.gradle ./

# Copy source
COPY src ./src

# Use the wrapper with a strict memory limit to avoid spikes
RUN ./gradlew build --no-daemon -x test -Dorg.gradle.jvmargs="-Xmx2g"

# Final Stage
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
