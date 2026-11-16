const express = require("express");
const { loadSecrets } = require("./secrets");
const { createPresignedGetUrl } = require("./s3");

function createApp({
  loadSecretsFn = loadSecrets,
  createPresignedGetUrlFn = createPresignedGetUrl,
} = {}) {
  const app = express();

  app.get("/health", (_req, res) => {
    res.status(200).json({ status: "ok" });
  });

  app.get("/files/*", async (req, res) => {
    try {
      const key = req.params[0];
      if (!key || key.includes("..")) {
        return res.status(400).json({ error: "invalid_key" });
      }

      const secrets = await loadSecretsFn();
      if (!secrets.apiKey || req.get("x-api-key") !== secrets.apiKey) {
        return res.status(401).json({ error: "unauthorized" });
      }

      const url = await createPresignedGetUrlFn(secrets.bucketName, key);

      return res.status(200).json({
        key,
        url,
        expiresInSeconds: 300,
      });
    } catch (err) {
      console.error("presign_failed", err.message);
      return res.status(500).json({ error: "presign_failed" });
    }
  });

  return app;
}

module.exports = { createApp };
