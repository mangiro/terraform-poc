#!/usr/bin/env bash

LOG_FILE="${PROJECT_FOLDER}/deployment/deploy.log"

COMMIT_HASH=$(git log --pretty=format:%h -n 1)

f_log() {
  echo "$(date -Iseconds) - $@" | tee -a ${LOG_FILE}
}

f_clean() {
	f_log "Cleaning temporary files and directories..."
	rm -f ${PROJECT_FOLDER}/app.zip *.log \
        created-ami-id.txt terraform/tfplan*
	rm -rf .ansible/ terraform/.terraform/ terraform/terraform.tfstate*
	find . -name "*.retry" -exec rm {} \;
}


f_build_ami() {
	if [ -z ${ENV} ]; then
		f_log "ERROR, environment variable ENV not set."
		exit 1
	fi

	if [ -z ${PACKER_USER} ]; then
		f_log "ERROR, environment variable PACKER_USER not set."
		exit 1
	fi

	if [ -z ${PACKER_KEY} ]; then
		f_log "ERROR, environment variable PACKER_KEY not set."
		exit 1
	fi

	BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
	SOURCE_DIR=$(dirname $PWD)

	f_log "Calling Packer build, configured variables:"
	f_log "  commit_hash=${COMMIT_HASH}"
	f_log "  branch_name=${BRANCH_NAME}"
  	f_log "  username=${PACKER_USER}"
	f_log "  private_key=${PACKER_KEY}"
  	f_log "  source_dir=${SOURCE_DIR}"
  	f_log "  project_folder=${PROJECT_FOLDER}"
    f_log "  var_file=ami-builder/environments/${ENV}.vars.json"

	export PACKER_LOG=1
	export PACKER_LOG_PATH=packer.log

    packer build \
		-color=false \
		-var "commit_hash=${COMMIT_HASH}" \
		-var "branch_name=${BRANCH_NAME}" \
  		-var "username=${PACKER_USER}" \
		-var "private_key=${PACKER_KEY}" \
  		-var "source_dir=${SOURCE_DIR}" \
		-var "project_folder=${PROJECT_FOLDER}" \
        -var-file="ami-builder/environments/${ENV}.vars.json" \
  		ami-builder/ami.json

	if [ $? -eq 0 ]; then
        echo ami-$(docker images --filter=reference=terraform-poc --format "{{.ID}}") > created-ami-id.txt
		f_log "AMI building completed, created $(cat created-ami-id.txt)"
		exit 0
	else
		f_log "ERROR, Packer failed while building AMI, aborting..."
		exit 1
	fi
}

f_deploy_ami() {
	if [ -z ${ENV} ]; then
		f_log "ERROR, environment variable ENV not set."
		exit 1
	fi

	export TF_LOG=WARN
	export TF_LOG_PATH=../terraform.log

	f_log "Trying to initialize Terraform..."

	cd terraform && \
		terraform init  -no-color && \
		terraform get -no-color && \
		terraform workspace select ${ENV} -no-color \
			|| terraform workspace new ${ENV}

	LOG_FILE="../deploy.log"

	if [ $? -eq 0 ]; then
		f_log "Terraform successfully initialized!"
	else
		f_log "ERROR, Terraform failed, aborting..."
		exit 1
	fi

	if [ -z ${AMI} ]; then
		export AMI=$(cat ../created-ami-id.txt)
	fi

	f_log "Calling Terraform plan, configured variables:"
	f_log "  var-file=environments/${ENV}.tfvars"
	f_log "  terraform_poc_ami=${AMI}"
	f_log "  out=tfplan-${ENV}-${AMI}"

	terraform plan \
		-no-color \
		-var-file=environments/${ENV}.tfvars \
		-var terraform_poc_ami=${AMI} \
		-var commit_hash=${COMMIT_HASH} \
		-out=tfplan-${ENV}-${AMI} \
		-input=false

	if [ $? -eq 1 ]; then
		f_log "ERROR, Terraform failed, aborting..."
		exit 1
	fi

	f_log "Calling Terraform apply on tf-plan-${ENV}-${AMI}"

	terraform apply "tfplan-${ENV}-${AMI}"

	if [ $? -eq 0 ]; then
		docker exec -it terraform-poc-${ENV}-${COMMIT_HASH} service sshd start
		f_log "Terraform successfully applied changes, ${AMI} deployed."
	else
		f_log "ERROR, Terraform failed, aborting..."
		exit 1
	fi
}

case "$1" in
	build-ami)
		f_build_ami
	;;

	deploy-ami)
		f_deploy_ami
	;;

	clean)
		f_clean
	;;

	*)
		echo "usage: deploy.sh build-ami|deploy-ami|clean"
		exit 0
	;;

esac
