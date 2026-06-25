# Build stage: Maven + Temurin 26 JDK
FROM maven:3.9.11-eclipse-temurin-26-jammy AS build
WORKDIR /workspace

COPY pom.xml .
RUN mvn -B -f pom.xml -DskipTests dependency:go-offline

COPY . .
RUN mvn -B -DskipTests package

FROM eclipse-temurin:26-jre-noble
WORKDIR /app

COPY --from=build /workspace/target/*.jar app.jar

ENV SPRING_PROFILES_ACTIVE=dev
ENV PORT=8096
ENV JAVA_OPTS=""

EXPOSE 8096

ENTRYPOINT ["sh","-c","java $JAVA_OPTS -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE} -Dserver.port=${PORT} -jar /app/app.jar"]
