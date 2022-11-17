# syntax=docker/dockerfile:1


FROM tomcat:8.5.43-jdk8

COPY  ./target/JSPSample-0.0.1.war /usr/local/tomcat/webapps