build: get-registry-uri
	cd jenkins && docker build -t $(REGISTRY_URI):latest .

compose: dockerify get-registry-uri
	cd jenkins && REGISTRY_URI=$(REGISTRY_URI) docker-compose -f docker-compose.live.yml up

dockerify: 
	export DOCKER_HOST=$(shell aws cloudformation describe-stacks \
		--stack-name docker-ci \
		| jq -r '.Stacks[].Outputs[] | select (.OutputKey == "JenkinsIp").OutputValue'):2376

get-ecr-login: get-repo-name
	$(eval REGISTRY_ID := $(shell aws ecr describe-repositories \
		| jq -r '.repositories[] | select (.repositoryName == "$(REPO_NAME)").registryId'))
	@aws ecr get-login --registry-ids $(REGISTRY_ID)

get-jenkins-ip:
	$(eval JENKINS_IP := $(shell aws cloudformation describe-stacks \
		--stack-name docker-ci \
		| jq -r '.Stacks[].Outputs[] | select (.OutputKey == "JenkinsIp").OutputValue'))

get-repo-name:
	$(eval REPO_NAME := $(shell aws cloudformation describe-stacks \
		--stack-name docker-ci \
		| jq -r '.Stacks[].Outputs[] | select (.OutputKey == "EcrRepoName").OutputValue'))

get-registry-uri: get-repo-name
	$(eval REGISTRY_URI := $(shell aws ecr describe-repositories \
		| jq -r '.repositories[] | select (.repositoryName == "$(REPO_NAME)").repositoryUri'))

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

push: get-registry-uri
	cd jenkins && docker push $(REGISTRY_URI):latest

provision:
	cd ansible && ansible-playbook main.yml -i inventory.py

run:
	cd jenkins && docker-compose up

ssh: get-jenkins-ip
	ssh ec2-user@$(JENKINS_IP)
