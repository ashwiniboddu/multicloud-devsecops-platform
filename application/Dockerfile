FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Update OS packages to latest available patched versions
RUN apk upgrade --no-cache

# Copy application artifact
COPY target/demo-workshop.war app.war

# Create non-root user
RUN addgroup -S spring && \
    adduser -S spring -G spring

# Run application as non-root user
USER spring:spring

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.war"]