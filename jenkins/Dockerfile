FROM jenkins

USER root

RUN apt-get update && apt-get install -y \
	docker \
	&& rm -rf /var/lib/apt/lists/*

COPY ./usr/share/jenkins/ref/plugins.txt /usr/share/jenkins/ref/

RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt 

USER jenkins
