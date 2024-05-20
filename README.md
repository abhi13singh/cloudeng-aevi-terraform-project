# Cloudeng-aevi-terraform-ECS-project
A set of Terraform templates used for provisioning a multi-tier Dockerized API service stacks on AWS ECS Fargate.

**A high-level architecture diagram of the project**
![architecture](https://github.com/abhi13singh/cloudeng-aevi-terraform-project/assets/159575057/4700e94d-cff1-4cac-8979-71ec5621a44d)

In this project, terraform templates have been created to design and implement a secure and scalable infrastructure to expose a Dockerized API service.

The API service runs on port 80 (HTTP) within the container, but the public endpoint utilizes HTTPS (port 443). AWS Application Load Balancer (ALB) has been used which recieves the internet traffic on port 443, and route it to the API service running as container inside ECS cluster.

The service is utilizing an S3 service in read-only mode, to retrieve files from S3 Bucket

The service is utilizing an RDS DB service, which is in a separate cluster in another account, for both reading and writing (both read and write access). AWS VPC Peering service has been used, along with proper IAM execution role and policies for ECS task, for cross-account VPC connection

