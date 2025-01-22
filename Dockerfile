FROM maven:3.8.1-jdk-11-slim AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:11-jre-alpine AS production
WORKDIR /app
RUN addgroup --system javauser && adduser -S -s /bin/false -G javauser javauser
COPY --from=build /app/target/multi-stage-java-app-1.0.0.jar /app/app.jar
RUN chown -R javauser:javauser /app
USER javauser
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
