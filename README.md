# Sledge DevOps assessment

Terraform and a minimal Express API deployed to ECS Fargate.

The stack includes a private S3 bucket, Secrets Manager, least-privilege IAM,
an ALB 5xx alarm, and GitHub Actions checks before deployment.

## Repository layout

```text
app/            Express API and tests
infra/          Terraform root and modules
  networking/   VPC, subnets, endpoints, and security groups
  storage/      S3, ECR, and Secrets Manager
  core/         ALB, ECS, and IAM
  monitoring/   CloudWatch alarm and SNS topic
```

The `services` map currently contains one `api` entry. Terraform uses the map
for the service-specific ECR repository, secret, task role, ECS service, ALB
target group, and alarm. The `ci.yml` workflow calls `app-pipeline.yml` for
`api`; the reusable workflow derives the environment from the target branch.

## Local checks

```bash
cd app
npm ci
npm test
npm audit

cd ../infra
terraform init -reconfigure
terraform workspace select dev || terraform workspace new dev
terraform fmt -check -recursive
terraform validate
terraform plan -var-file=terraform.tfvars
```

Regenerate the committed plan from the repository root:

```bash
ENVIRONMENT=dev ./scripts/tf-plan-all.sh
```

The script uses the active AWS credentials for provider lookups and replaces
the AWS account ID in `terraform-plan.txt` before saving it.

## Deployment mapping

| Branch | Environment | ECR repository |
| --- | --- | --- |
| `develop` | `dev` | `api-registry-dev` |
| `staging` | `staging` | `api-registry-staging` |
| `main` | `prod` | `api-registry-prod` |

An optional live deployment requires these GitHub Environment variables:

- `AWS_DEPLOY_ROLE_ARN`
- `ECS_CLUSTER`

See [docs/DESIGN.md](docs/DESIGN.md) for design choices and known gaps.
