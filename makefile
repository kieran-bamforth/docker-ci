run:
	cd jenkins && docker-compose up

build: 
	cd jenkins && docker build -t docker-ci-jenkins .
