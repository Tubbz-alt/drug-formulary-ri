FROM hapiproject/hapi:base as build-hapi

ARG HAPI_FHIR_URL=https://github.com/jamesagnew/hapi-fhir/
ARG HAPI_FHIR_BRANCH=master
ARG HAPI_FHIR_STARTER_URL=https://github.com/hapifhir/hapi-fhir-jpaserver-starter/
ARG HAPI_FHIR_STARTER_BRANCH=master

RUN git clone --branch ${HAPI_FHIR_BRANCH} ${HAPI_FHIR_URL}
WORKDIR /tmp/hapi-fhir/
RUN /tmp/apache-maven-3.6.2/bin/mvn dependency:resolve
RUN /tmp/apache-maven-3.6.2/bin/mvn install -DskipTests

WORKDIR /tmp
# RUN git clone --branch ${HAPI_FHIR_STARTER_BRANCH} ${HAPI_FHIR_STARTER_URL}
COPY pom.xml hapi-fhir-jpaserver-starter/pom.xml
COPY src hapi-fhir-jpaserver-starter/src

WORKDIR /tmp/hapi-fhir-jpaserver-starter
RUN /tmp/apache-maven-3.6.2/bin/mvn clean install -DskipTests

FROM tomcat:9-jre11

RUN mkdir -p /data/hapi/lucenefiles && chmod 775 /data/hapi/lucenefiles
RUN rm -rf /usr/local/tomcat/webapps/ROOT
COPY --from=build-hapi /tmp/hapi-fhir-jpaserver-starter/target/root.war /usr/local/tomcat/webapps/ROOT.war
COPY ./data /usr/local/tomcat/target

EXPOSE 8080

CMD ["catalina.sh", "run"]