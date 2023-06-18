FROM tomcat:8-alpine
LABEL LABEL maintainer="kaiser.andreas@gmail.com"

#Ports
EXPOSE 5200 5100
#ENV
ENV CODEBASE_URL file:/root/Protege_3.5/protege.jar
ENV EAM_VERSION 62

# Install some tools
RUN   apk update \
  &&   apk add ca-certificates wget graphviz \
  &&   update-ca-certificates

# Download essential project files and protege
RUN wget --tries=3 --progress=bar:force:noscroll https://essential-cdn.s3.eu-west-2.amazonaws.com/essential-widgets/essentialinstallupgrade67.jar \
  && wget --tries=3 --progress=bar:force:noscroll https://essential-cdn.s3.eu-west-2.amazonaws.com/viewer/essential_viewer_6181.war \
  && wget --tries=3 --progress=bar:force:noscroll https://essential-cdn.s3-eu-west-2.amazonaws.com/import-utility/essential_import_utility_27.war \
  && wget --tries=3 --progress=bar:force:noscroll https://essential-cdn.s3.eu-west-2.amazonaws.com/import-utility/essentialImportConfig-6.7.eic \
  && wget --tries=3 --progress=bar:force:noscroll https://essential-cdn.s3.eu-west-2.amazonaws.com/protege/install_protege_3.5-Linux64-noJVM.bin

# Copy auto install files to folder
COPY protege-response.txt auto-install.xml ./

# Install tools
RUN chmod u+x install_protege_3.5-Linux64-noJVM.bin \
  && ./install_protege_3.5-Linux64-noJVM.bin -i console -f protege-response.txt \
  && java -jar essentialinstallupgrade67.jar auto-install.xml

RUN rm ./install_protege_3.5-Linux64-noJVM.bin

# Copy data & startup scripts
COPY server/* /opt/essentialAM/server/
COPY repo/* /opt/essentialAM/
COPY startup.sh run_protege_server_fix.sh /

RUN mv essentialImportConfig-6.7.eic /usr/local/tomcat/webapps/
RUN mv essential_viewer_6181.war /usr/local/tomcat/webapps/essential_viewer
RUN mv essential_import_utility_27.war /usr/local/tomcat/webapps/essential_import_utility

#Some Java ENV
#RUN export JAVA_HOME=/usr/lib/jvm/default-jvm/jre/
ENV JAVA_HOME /usr/lib/jvm/default-jvm
WORKDIR /root/Protege_3.5/

#Prepare Filesystem & cleanup install files
RUN chmod +x /startup.sh  \
  && chmod +x /run_protege_server_fix.sh


# Startup the services
CMD ["/startup.sh"]
