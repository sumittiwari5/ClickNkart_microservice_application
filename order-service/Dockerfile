# ---- Build stage ----
FROM maven:3.9.11-eclipse-termin-21 AS builder

# setting working directory.
WORKDIR /app

# copy the maven configuration first so Docker can cache the maven dependecy layer. 
# if the source code changes, dependencies don't need to be downloaded again.
COPY pom.xml . 

# downloading all project dependencies in advance.
# this will speed up the future builds because the Docker can reuse this cached layer.
RUN mvn dependency:go-offline

# copying the application source code to the container.
COPY src ./src

# compiles the application and created the executable spring boot jar file inside the /target directory.
# -DskipTests flag will skip the unit tests results during the build process.
RUN mvn clean package -DskipTests

# ---- Runtime stage ----
FROM eclipse-temurin:21-jre

# setting working directory.
WORKDIR /app

# copying the executable spring boot jar file from the build stage to the runtime stage.
COPY --from=builder /app/target/*.jar app.jar

# order-service will listen on port 8083.
EXPOSE 8083

# start the service when the container launches.
ENTRYPOINT ["java", "-jar", "app.jar"]