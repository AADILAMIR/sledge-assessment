# Design choices and known gaps

## Architecture

The API runs on ECS Fargate in private subnets behind a public Application Load
Balancer. The VPC has private endpoints for ECR, CloudWatch Logs, Secrets
Manager, and S3. A NAT gateway supports other outbound HTTPS traffic.

Terraform workspaces select `dev`, `staging`, or `prod`. The root module keeps
networking, storage, compute, and monitoring in one dependency graph and state.
The `services` map creates service-specific resources; this repository defines
only the assessment API.

## Security

- S3 Block Public Access is enabled and insecure transport is denied.
- The API returns short-lived S3 presigned GET URLs.
- Each application task role can read objects from the private bucket and only
  its own Secrets Manager secret.
- The ECS execution role can pull only the configured ECR repositories and
  write to the configured log groups.
- The GitHub OIDC role can push to the configured repositories, update the
  configured ECS services, and pass only the task and execution roles.
- Resource wildcards are limited to ECR authorization, ECS task-definition
  registration, S3 object keys, and dynamically named CloudWatch log streams.

## CI/CD

The caller workflow maps branches to environments and invokes the reusable API
workflow. Tests, TruffleHog, `npm audit`, the Trivy image scan, and Terraform
validation must pass before the deploy job can run. Images use immutable commit
SHA tags. ECS enables deployment rollback when a revision does not become
healthy.

The first Terraform apply leaves the ECS service at zero tasks because the ECR
repository is empty. After pushing the first image, CI registers a new task
definition and sets the service desired count to one.

## Known gaps

- The ALB has HTTP only; ACM and an HTTPS listener are not configured.
- Terraform state is local; a remote encrypted backend with locking is required
  before team use.
- The SNS topic has no subscription.
- Secrets use a placeholder value that must be replaced outside Terraform.
- Container Insights, autoscaling, WAF, and ALB access logs are not configured.
- A live deployment requires an applied stack and GitHub Environment variables.

## Reproduce the plan

```bash
ENVIRONMENT=dev ./scripts/tf-plan-all.sh
```

The generated text plan redacts the AWS account ID.
