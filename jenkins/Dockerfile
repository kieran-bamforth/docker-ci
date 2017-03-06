FROM jenkins

COPY /usr/share/jenkins/ref/plugins.txt /usr/share/jenkins/ref/
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt 

USER jenkins

