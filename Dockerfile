# Use the same image for building AND running
FROM eclipse-temurin:21-jdk-jammy AS build
WORKDIR /app

# Copy wrapper files first (for caching)
COPY gradlew .
COPY gradle gradle
COPY build.gradle ./

# Copy source
COPY src ./src

# FIX: Add -Dorg.gradle.daemon=false and lower Xmx slightly to leave room for Kaniko
RUN ./gradlew build --no-daemon -x test \
    -Dorg.gradle.daemon=false \
    -Dorg.gradle.jvmargs="-Xmx1536m"

# Final Stage
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
# Ensure we only grab the actual bootable jar
COPY --from=build /app/build/libs/*[!-plain].jar ./

ENTRYPOINT ["sh", "-c", "java -jar /app/*.jar"]
