build: 
	cd jenkins && docker build -t docker-ci-jenkins .

infrastructure: 
	aws cloudformation create-stack \
		--stack-name docker-ci \
		--template-body file://infrastructure.yml \
		--capabilities CAPABILITY_IAM

run:
	cd jenkins && docker-compose up
