# **Terraform-PoC**

*This project is part of a personal development plan.*

This will simulate the deployment of an EC2 in a local environment. To achieve this, perform the following steps.

- ## **Requirements**
    - Make
    - Docker & docker-compose

### **Setting up the environment**
```bash
$ cp .env.local.example .env
$ docker-compose up -d
$ make docker-infra
```
The `make docker-infra` command  will get you into the container where the deploy steps will be performed.

### **Starting the deploy**
```bash
$ make deploy
```

### **Testing**
Once the deploy is finished, go to `http://localhost:8080/quotes` to see the output of the deployed project in action.

You can also make an SSH connection to the EC2 machine (AMI) that is running in the local environment, for that, run the following command:
```bash
$ ssh ec2-user@172.20.0.10
```
Use the password: `testec2`

### **Destroying**
To end the deployed infrastructure, run:
```bash
$ cd deployment/terraform; terraform destroy
```

### **Conclusion**
This is one of many other ways to deploy an EC2 instance, and in my opinion there are better ways than this, but it was worth the proof of concept for the knowledge gain. :)
