FROM centos:8

# install required packages
RUN yum update -y && \
    yum install -y httpd mod_ssl openssl zip java maven && \
    yum clean all

RUN wget -P /tmp http://sourceforge.net/projects/geoserver/files/GeoServer/2.18.1/geoserver-2.18.1-bin.zip && \
    unzip /tmp/geoserver-2.18.1-bin.zip -d /opt/geoserver && \
    rm /tmp/geoserver-2.18.1-bin.zip

# Create a user & set permission
RUN useradd gis && \
    chown -R gis:gis /opt/geoserver

# Configure Apache HTTPD
RUN echo "SSLProxyEngine on" >> /etc/httpd/conf/httpd.conf && \
    echo "ProxyPass        / http://localhost:8080/" >> /etc/httpd/conf/httpd.conf && \
    echo "ProxyPassReverse / http://localhost:8080/" >> /etc/httpd/conf/httpd.conf && \
    mv /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/welcome.conf.back && \
    chkconfig httpd on

# Create a systemd service for GeoServer
RUN touch /etc/systemd/system/geoserver.service && \
    chmod 664 /etc/systemd/system/geoserver.service && \
    echo "[Unit]\nAfter=network.target\n###\n[Service]\nUser=gis\nGroup=gis\nEnvironment=\"GEOSERVER_HOME=/opt/geoserver\"\nExecStart=/opt/geoserver/bin/startup.sh\n###\n[Install]\nWantedBy=default.target" >> /etc/systemd/system/geoserver.service && \
    systemctl enable geoserver.service && \
    systemctl daemon-reload

# Expose ports
EXPOSE 80 443

# Start Apache HTTPD
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
