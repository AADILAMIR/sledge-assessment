const { S3Client, GetObjectCommand } = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");

const client = new S3Client({
  region: process.env.AWS_REGION || "us-east-1",
});

async function createPresignedGetUrl(bucketName, key, expiresInSeconds = 300) {
  const command = new GetObjectCommand({
    Bucket: bucketName,
    Key: key,
  });

  return getSignedUrl(client, command, { expiresIn: expiresInSeconds });
}

module.exports = { createPresignedGetUrl };
