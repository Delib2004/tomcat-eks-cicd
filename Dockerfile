FROM tomcat:9.0-jdk17-temurin

# Remove the default Tomcat sample apps and serve our app at /
RUN rm -rf /usr/local/tomcat/webapps/*
COPY app/ROOT /usr/local/tomcat/webapps/ROOT

EXPOSE 8080
CMD ["catalina.sh", "run"]
