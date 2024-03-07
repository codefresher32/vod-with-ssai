AWS_REGION?=eu-north-1
TERRAFORM_VERSION=1.6.4
AWS_CLI_IMAGE=amazon/aws-cli
TERRAFORM_IMAGE=hashicorp/terraform:${TERRAFORM_VERSION}
DOCKER_ENV=-e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION -e AWS_PROFILE -e AWS_REGION -e TF_VAR_uploader_ui_port
DOCKER_RUN_MOUNT_OPTIONS=-v ${CURDIR}/:/app -v ${CREDENTIAL_DIR}/:/root/.aws -w /app

define run_docker
	docker run -it --rm ${DOCKER_ENV} ${DOCKER_RUN_MOUNT_OPTIONS}
endef

define get_output
	$(run_docker) ${TERRAFORM_IMAGE} output $(1)
endef

tf-init:
	$(run_docker) ${TERRAFORM_IMAGE} init

tf-plan:
	$(run_docker) ${TERRAFORM_IMAGE} plan

tf-apply:
	$(run_docker) ${TERRAFORM_IMAGE} apply

tf-destroy:
	$(run_docker) ${TERRAFORM_IMAGE} destroy

run-uploader-ui:
	cd uploader-ui && . ~/.nvm/nvm.sh && nvm use && npm start; cd ..