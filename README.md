# Cloudeng-aevi-terraform-ECS-project
A set of Terraform templates used for provisioning a multi-tier Dockerized API service stacks on AWS ECS Fargate.

**A high-level architecture diagram of the project**
![architecture](https://github.com/abhi13singh/cloudeng-aevi-terraform-project/assets/159575057/4700e94d-cff1-4cac-8979-71ec5621a44d)

In this project, terraform templates have been created to design and implement a secure and scalable infrastructure to expose a Dockerized API service.

The API service runs on port 80 (HTTP) within the container, but the public endpoint utilizes HTTPS (port 443). AWS Application Load Balancer (ALB) has been used which recieves the internet traffic on port 443, and route it to the API service running as container inside ECS cluster.

The service is utilizing an S3 service in read-only mode, to retrieve files from S3 Bucket
The service is utilizing an RDS DB service, which is in a separate cluster in another account, for both reading and writing (both read and write access). AWS VPC Peering service has been used, along with proper IAM execution role and policies for ECS task, for cross-account VPC connection.

Also, as a bonus, the project includes a solution which manages the application's logging messages ('non-frequent short INFO messages' and 'frequent long DEBUG messages'). It utilizes CloudWatch Log Groups, CloudWatch Log Metrics and Subscription filters for INFO and DEBUG messages. Its using two Lambda functions, with propser IAM roles/policies:
1. info_processor --> for processing INFO messages for easy and frequent access
2. debug_processor --> for processing DEBUG messages to store in S3 bucket

The python scripts for both the lambda functions are saved in the same project directory.

**NOTE:** The templates are used for managing infrastructure concerns only, and not for managing application concerns like deploying the actual application images and environment variables on top of this infrastructure.


## **Components**

**remote-state_resources**

The components to store and lock terraform statefile

| Name | Description | Optional |
|------|-------------|:---:|
| [backend-resources.tf][bs] | S3 bucket to store and DynamoDB table to lock terraform state  |  |


**main_resources**

The components to implement the multi-tier app stacks

| Name | Description | Optional |
|------|-------------|:----:|
| [providers.tf][edm] | Terrform remote backend state, AWS provider |  |
| [ecs.tf][ede] | ECS Cluster, Service, Task Definition, Auto-scaling group, CloudWatch Log Group |  |
| [alb.tf][edl] | ALB, Target Group |  |
| [acm.tf][edn] | A public SSL certificate request from acm |  |
| [variables.tf][edlhttp] | Variables | Yes |
| [vpc.tf][edlhttps] | VPC, public and private subnets, route tables, IGW, NAT gateway |  |
| [dashboard.tf][edd] | CloudWatch dashboard: CPU, memory, and HTTP-related metrics | Yes |
| [ecs-role.tf][edr] | IAM role and policies for ECS task execution  | Yes |
| [cicd.tf][edc] | IAM user that can be used by CI/CD systems | Yes |
| [autoscale-perf.tf][edap] | Performance-based auto scaling | Yes |
| [autoscale-time.tf][edat] | Time-based auto scaling | Yes |
| [logs-logzio.tf][edll] | Ship container logs to logz.io | Yes |
| [secretsmanager.tf][edsm] | Add a Secrets Manager secret with a CMK KMS key. Also gives app role and ECS task definition role access to read secrets from Secrets Manager | Yes |
| [secrets-sidecar.tf][ssc] | Adds a task definition configuration for deploying your app along with a sidecar container that writes your secrets manager secret to a file. Note that this is dependent upon opting in to `secretsmanager.tf`. | Yes |
| [ssm-parameters.tf][ssm] | Add a CMK KMS key for use with SSM Parameter Store. Also gives ECS task definition role access to read secrets from parameter store. | Yes |
| [ecs-event-stream.tf][ees] | Add an ECS event log dashboard | Yes |
