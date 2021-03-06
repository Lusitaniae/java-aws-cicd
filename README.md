
# Java AWS CICD Pipeline Demo [![Build Status](https://travis-ci.com/Lusitaniae/java-aws-cicd.svg?branch=master)](https://travis-ci.com/Lusitaniae/java-aws-cicd)

This project demonstrates a simple CI/CD pipeline for a java application. 

Behind the scenes we're creating a VM which we configure and deploy the app,  and then we take a snapshot which is then deployed without downtime to a live cluster behind an AWS Load Balancer.

You can targert multiple environments using different branches.
1. master: production
2. sta: staging
3. test: testing
4. dev: development

You can skip CI builds by adding `[skip ci]` to your commit message.

## Get Started

### Prerequisites

Create two IAM users with the permissions linked below and export as env variables for local usage.

Packer [(permissions)](https://www.packer.io/docs/builders/amazon.html#iam-task-or-instance-role):
```
export AWS_ACCESS_KEY="abc"
export AWS_SECRET_KEY="xyz"
```
Terraform(Needs full rights to EC2, Auto Scaling, Launch Configuration, ELB, Security Groups, and the S3 bucket below):
```
export AWS_ACCESS_KEY_ID="abc"
export AWS_SECRET_ACCESS_KEY="xyz"
```
Create an S3 bucket named (Terraform state is kept here between CI executions)
```
opstest-terra-state
```

### The fun part

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
make deploy AMIID=ami-xxxxxxxxxxxx ENV=<prod|sta|test|dev>
```

## CI/CD Pipeline

TravisCI is running the show.

On commit and or PR, a pipeline with 2 stages is started.

1. Test
	1.  Test the Java application
2. Deploy
	1. Build AMI using Packer (Ansible does the configuration)
	2. Deploy new AMI to ASG using Terraform.

Deployments are fully online using Blue Green strategy.

New ASG and LC are configured with new AMI and once healthy they replace the original ones in the ELB.

## AWS

The stack consists of

1. Classic Elastic Load Balancer, 
2. Launch Configuration, and 
3. Auto Scaling Group. 

They're configured to span multiple AZs and by configuring min, max, desired accordingly we can achieve HA in case of AZ loss (e.g. 3 min, 9max, 3 desired).

Could be improved by moving instances to a private subnet in the respective AZ to restrict access.

## Others

S3 is used to store Terraform state between executions (from CI or locally).
See required permissions here https://www.terraform.io/docs/backends/types/s3.html#protecting-access-to-workspace-state

Each commit is generating new AMIs, needs lifecycle management tool.
