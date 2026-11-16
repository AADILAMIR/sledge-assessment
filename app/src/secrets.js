const {
  SecretsManagerClient,
  GetSecretValueCommand,
} = require("@aws-sdk/client-secrets-manager");

const client = new SecretsManagerClient({
  region: process.env.AWS_REGION || "us-east-1",
});

let cachedSecrets = null;

async function loadSecrets() {
  if (cachedSecrets) {
    return cachedSecrets;
  }

  if (process.env.NODE_ENV === "test") {
    cachedSecrets = {
      bucketName: process.env.S3_BUCKET_NAME || "test-private-bucket",
      apiKey: process.env.API_KEY || "test-api-key",
    };
    return cachedSecrets;
  }

  const secretId = process.env.APP_SECRET_ARN;
  if (!secretId) {
    throw new Error("APP_SECRET_ARN is required outside of test mode");
  }

  const response = await client.send(
    new GetSecretValueCommand({ SecretId: secretId })
  );

  if (!response.SecretString) {
    throw new Error("Secret has no SecretString payload");
  }

  const parsed = JSON.parse(response.SecretString);
  if (!parsed.bucketName) {
    throw new Error("Secret JSON must include bucketName");
  }

  cachedSecrets = {
    bucketName: parsed.bucketName,
    apiKey: parsed.apiKey || "",
  };
  return cachedSecrets;
}

function resetSecretsCache() {
  cachedSecrets = null;
}

module.exports = { loadSecrets, resetSecretsCache };
