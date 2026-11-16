#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INFRA_DIR="${ROOT}/infra"
ENVIRONMENT="${ENVIRONMENT:-dev}"
OUT="${ROOT}/terraform-plan.txt"
REDACTED_ACCOUNT_ID="123456789012"
TMP_OUT="$(mktemp "${TMPDIR:-/tmp}/sledge-plan.XXXXXX")"
PLAN_FILE="$(mktemp "${TMPDIR:-/tmp}/sledge-tfplan.XXXXXX")"

cleanup() {
  rm -f "$TMP_OUT" "$PLAN_FILE"
}
trap cleanup EXIT

export AWS_REGION="${AWS_REGION:-us-east-1}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-$AWS_REGION}"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

terraform -chdir="$INFRA_DIR" init -input=false -reconfigure
terraform -chdir="$INFRA_DIR" workspace select "$ENVIRONMENT" 2>/dev/null \
  || terraform -chdir="$INFRA_DIR" workspace new "$ENVIRONMENT"
terraform -chdir="$INFRA_DIR" fmt -check -recursive
terraform -chdir="$INFRA_DIR" validate
terraform -chdir="$INFRA_DIR" plan \
  -input=false \
  -refresh=false \
  -var-file=terraform.tfvars \
  -out="$PLAN_FILE"

{
  echo "Terraform composed plan"
  echo "workspace=${ENVIRONMENT}"
  echo "generated=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "aws_account_id=REDACTED"
  echo
  terraform -chdir="$INFRA_DIR" show -no-color "$PLAN_FILE" \
    | sed "s/${ACCOUNT_ID}/${REDACTED_ACCOUNT_ID}/g"
} >"$TMP_OUT"

grep -Eq '^Plan:|^No changes\.' "$TMP_OUT"
mv "$TMP_OUT" "$OUT"

echo "Wrote ${OUT} (AWS account ID redacted)"
