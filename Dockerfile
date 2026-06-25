# Build stage: Maven + Temurin 26 JDK
FROM maven:3.9.11-eclipse-temurin-26-noble AS build
WORKDIR /workspace

# copy pom and download dependencies to leverage cache
COPY pom.xml .

RUN mvn -B -f pom.xml -DskipTests  dependency:go-offline

# copy source and build the project
COPY . .
RUN mvn -B -DskipTests -Dcheckstyle.skip=true package

# Runtime stage: Temurin 26 JRE
FROM eclipse-temurin:26-jre-noble
WORKDIR /app

# copy the built jar (ajusta el glob si conoces el nombre exacto del artefacto)
COPY --from=build /workspace/target/*.jar app.jar

# defaults: dev profile and port (coincide con src/main/resources/application.properties)
ENV SPRING_PROFILES_ACTIVE=dev
ENV PORT=8096
ENV JAVA_OPTS=""

EXPOSE 8096

ENTRYPOINT ["sh","-c","java $JAVA_OPTS -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE} -Dserver.port=${PORT} -jar /app/app.jar"]
