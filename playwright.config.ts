import { defineConfig, devices } from "@playwright/test";

/**
 * Provider-to-URL mapping.
 * URLs can be overridden with env vars, or edit the defaults here directly.
 * CLAUDE had a hand in this!! #AI-DISCLOSED (very sorry I do not want to capture the evidence manually)
 */
const PROVIDERS: Record<string, string> = {
  aws: process.env.QUEST_AWS_URL || "https://quest.aws.shart.cloud",
  azure: process.env.QUEST_AZURE_URL || "https://quest.azure.shart.cloud",
  gcp: process.env.QUEST_GCP_URL || "https://quest.gcp.shart.cloud",
  cloudflare: process.env.QUEST_CF_URL || "https://quest.cf.shart.cloud",
};

// Set by npm scripts via cross-env, or pass directly
const provider = process.env.QUEST_PROVIDER || "aws";

if (!PROVIDERS[provider]) {
  throw new Error(
    `Unknown provider "${provider}". Valid: ${Object.keys(PROVIDERS).join(", ")}`
  );
}

// Expose to test files
process.env._QUEST_BASE_URL = PROVIDERS[provider];
process.env._QUEST_PROVIDER = provider;

export default defineConfig({
  testDir: ".",
  testMatch: "screenshot-proofs.spec.ts",
  timeout: 60_000,

  fullyParallel: false,
  workers: 1,

  reporter: [["list"]],

  use: {
    ignoreHTTPSErrors: true,
    viewport: { width: 1280, height: 720 },
    screenshot: "off",
  },

  projects: [
    {
      name: `quest-${provider}`,
      use: { ...devices["Desktop Chrome"] },
    },
  ],
});