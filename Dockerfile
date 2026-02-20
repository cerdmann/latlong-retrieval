# Build stage
FROM gradle:4.10-jdk8 AS build
WORKDIR /app
COPY . .
RUN gradle build --no-daemon -x test

# Run stage
FROM eclipse-temurin:8-jdk-jammy
WORKDIR /app
COPY --from=build /app/build/libs/latlong-retrieval-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
