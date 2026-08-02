FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Copies the clean demo-workshop.war artifact explicitly from target space
COPY target/demo-workshop.war app.war

# Create and lock down permissions to non-root account for Trivy Compliance
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.war"]
