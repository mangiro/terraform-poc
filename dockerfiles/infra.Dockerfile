FROM docker:dind

# Install system dependencies
RUN apk update && apk upgrade --no-cache \
    && apk add --no-cache \
    bash git curl gcc make zip libc-dev openssh sshpass

# Install Packer
RUN wget https://releases.hashicorp.com/packer/1.8.2/packer_1.8.2_linux_amd64.zip
RUN unzip packer_1.8.2_linux_amd64.zip && rm packer_1.8.2_linux_amd64.zip
RUN mv packer /usr/local/bin/

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/1.2.5/terraform_1.2.5_linux_amd64.zip
RUN unzip terraform_1.2.5_linux_amd64.zip && rm terraform_1.2.5_linux_amd64.zip
RUN mv terraform /usr/local/bin/

WORKDIR /usr/infra

# Enable permissions
COPY /deployment/deploy.sh /usr/infra/deployment/
RUN chmod +x /usr/infra/deployment/deploy.sh
RUN git config --global --add safe.directory /usr/infra
