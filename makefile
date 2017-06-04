build: get-repo-name
	$(eval REGISTRY_URI := $(shell aws ecr describe-repositories \
		| jq -r '.repositories[] | select (.repositoryName == "$(REPO_NAME)").repositoryUri'))
	cd jenkins && docker build -t $(REGISTRY_URI):latest .

dockerify: 
	export DOCKER_HOST=$(shell aws cloudformation describe-stacks \
		--stack-name docker-ci \
		| jq -r '.Stacks[].Outputs[] | select (.OutputKey == "JenkinsIp").OutputValue'):2376

get-ecr-login: get-repo-name
	$(eval REGISTRY_ID := $(shell aws ecr describe-repositories \
		| jq -r '.repositories[] | select (.repositoryName == "$(REPO_NAME)").registryId'))
	@aws ecr get-login --registry-ids $(REGISTRY_ID)

get-repo-name:
	$(eval REPO_NAME := $(shell aws cloudformation describe-stacks \
		--stack-name docker-ci \
		| jq -r '.Stacks[].Outputs[] | select (.OutputKey == "EcrRepoName").OutputValue'))

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

push: get-repo-name
	$(eval REGISTRY_URI := $(shell aws ecr describe-repositories \
		| jq -r '.repositories[] | select (.repositoryName == "$(REPO_NAME)").repositoryUri'))
	cd jenkins && docker push $(REGISTRY_URI):latest

provision:
	cd ansible && ansible-playbook main.yml -i inventory.py

run:
	cd jenkins && docker-compose up

