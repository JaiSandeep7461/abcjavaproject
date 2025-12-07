# ---------- Build stage ----------
FROM maven:3.9.9-eclipse-temurin-8 AS build

# Set workdir inside the container
WORKDIR /app

# Copy only pom.xml first to cache dependencies
COPY pom.xml .

# Download all dependencies (better layer caching in CI/CD)
RUN mvn -B -q dependency:go-offline

# Now copy source code
COPY src ./src

# Build the WAR file
RUN mvn -B clean package -DskipTests

# ---------- Runtime stage ----------
FROM tomcat:9.0-jdk8-temurin

# Optional: clean default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy generated WAR from builder stage
# If your final WAR name is different, adjust the pattern or exact file
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Expose Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
