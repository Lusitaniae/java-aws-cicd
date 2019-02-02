
# Java AWS CICD Pipeline Demo [![Build Status](https://travis-ci.com/Lusitaniae/java-aws-cicd.svg?branch=master)](https://travis-ci.com/Lusitaniae/java-aws-cicd)


## Get Started

Pull repo
```
git clone git@github.com:Lusitaniae/java-aws-cicd.git; cd java-aws-cicd
```
Test App

```
make test
```

Bake AMI
```
make bake
```
Deploy Infrastructure (or changes only, say deploy new AMI)
```
make deploy
```


Configure your env variables with access keys to your IAM users

Packer [(permissions)](https://www.packer.io/docs/builders/amazon.html#iam-task-or-instance-role):
```
export AWS_ACCESS_KEY="abc"
export AWS_SECRET_KEY="xyz"
```
Terraform[(permissions)](https://www.packer.io/docs/builders/amazon.html#iam-task-or-instance-role):
```
export AWS_ACCESS_KEY_ID="abc"
export AWS_SECRET_ACCESS_KEY="xyz"
```

## CI/CD Pipeline

TravisCI is running the show.
On commit and or PR, a pipeline with 2 stages is started.

1. Test
	1.  Test the Java application
2. Deploy
	1. Build AMI using Packer (Ansible does the configuration)
	2. Deploy new AMI to ASG using Terraform.

## Others

S3 is used to store Terraform state between executions (from CI or locally).
See required permissions here https://www.terraform.io/docs/backends/types/s3.html#protecting-access-to-workspace-state

Each commit is generating new AMIs, needs lifecycle management tool.
