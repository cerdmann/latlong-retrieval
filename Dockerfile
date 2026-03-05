# Use the same image for building AND running
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
COPY build/libs/*[!-plain].jar ./

ENTRYPOINT ["sh", "-c", "java -jar /app/*.jar"]
