ENV ?= dev
COMPOSE_MODE ?= up

browse: get-jenkins-ip
	open http://$(JENKINS_IP)

build: get-registry-uri
	cd jenkins && docker build -t $(REGISTRY_URI):latest .

compose: get-registry-uri
	cd jenkins && REGISTRY_URI=$(REGISTRY_URI) docker-compose -f docker-compose.$(ENV).yml $(COMPOSE_MODE)

dockerify: 
	export DOCKER_HOST=$(shell aws cloudformation describe-stacks \
		--stack-name docker-ci \
		| jq -r '.Stacks[].Outputs[] | select (.OutputKey == "JenkinsIp").OutputValue'):2376

generate-jenkins-cert: get-jenkins-ip
	$(eval DEST := ./ansible/roles/docker/files)
	$(eval NAME := jenkins)
	openssl genrsa -out $(DEST)/$(NAME).key 2048
	openssl req -subj "/CN=jenkins.kieranbamforth.me" -sha256 -new -key $(DEST)/$(NAME).key -out $(DEST)/$(NAME).csr
	echo subjectAltName = IP:$(JENKINS_IP) > extfile.cnf
	openssl x509 -req -days 365 -sha256 -in $(DEST)/$(NAME).csr \
		-CA ~/src/dotfiles/.ssh/keys/ca/ca.crt \
		-CAkey ~/src/dotfiles/.ssh/keys/ca/ca.key \
		-CAcreateserial \
		-out $(DEST)/$(NAME).crt  \
		-extfile extfile.cnf
	rm extfile.cnf
	rm $(DEST)/$(NAME).csr

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
