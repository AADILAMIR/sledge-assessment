const assert = require("node:assert/strict");
const { describe, test } = require("node:test");
const request = require("supertest");
const { createApp } = require("../src/app");

describe("Express API", () => {
  test("GET /health returns 200", async () => {
    const app = createApp({
      loadSecretsFn: async () => ({ bucketName: "test-bucket", apiKey: "x" }),
      createPresignedGetUrlFn: async () => "https://example.com/signed",
    });

    const res = await request(app).get("/health");
    assert.equal(res.status, 200);
    assert.deepEqual(res.body, { status: "ok" });
  });

  test("GET /files/:key returns a presigned URL", async () => {
    const app = createApp({
      loadSecretsFn: async () => ({ bucketName: "test-bucket", apiKey: "x" }),
      createPresignedGetUrlFn: async (bucket, key) =>
        `https://example.com/${bucket}/${key}?X-Amz-Signature=fake`,
    });

    const res = await request(app)
      .get("/files/reports/a.pdf")
      .set("x-api-key", "x");
    assert.equal(res.status, 200);
    assert.equal(res.body.key, "reports/a.pdf");
    assert.match(res.body.url, /X-Amz-Signature=fake/);
    assert.equal(res.body.expiresInSeconds, 300);
  });

  test("GET /files/:key rejects an invalid API key", async () => {
    const app = createApp({
      loadSecretsFn: async () => ({ bucketName: "test-bucket", apiKey: "x" }),
      createPresignedGetUrlFn: async () => "https://example.com/signed",
    });

    const res = await request(app).get("/files/reports/a.pdf");
    assert.equal(res.status, 401);
    assert.deepEqual(res.body, { error: "unauthorized" });
  });
});
