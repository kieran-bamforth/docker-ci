build: 
	cd jenkins && docker build -t docker-ci-jenkins .

infrastructure-update: 
	aws cloudformation update-stack \
		--stack-name docker-ci \
		--template-body file://infrastructure.yml \
		--capabilities CAPABILITY_IAM

infrastructure: 
	aws cloudformation create-stack \
		--stack-name docker-ci \
		--template-body file://infrastructure.yml \
		--capabilities CAPABILITY_IAM

provision:
	cd ansible && ansible-playbook main.yml -i inventory.py

run:
	cd jenkins && docker-compose up
