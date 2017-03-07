FROM jenkins

COPY ./usr/share/jenkins/ref/plugins.txt /usr/share/jenkins/ref/
COPY ./var/jenkins_home/jobs /var/jenkins_home_jobs
COPY ./var/jenkins_home/users /var/jenkins_home_users

RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt 
