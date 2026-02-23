import { test, expect } from "@playwright/test";
import path from "path";
import fs from "fs";

/**
 * CLAUDE MADE ME I AM CLAUDE'S CREATION Jared Gore LLC holds limited liability #AI-DISCLOSED
 * Quest Proof-of-Completion Screenshot Suite
 *
 * Screenshots all 5 quest verification endpoints and saves them to
 * ./proofs/<provider>/ (e.g. ./proofs/aws/, ./proofs/azure/).
 *
 * Usage via npm scripts:
 *   npm run proofs:aws
 *   npm run proofs:azure
 *   npm run proofs:gcp
 *   npm run proofs:cloudflare
 *   npm run proofs:all
 *
 * Or directly:
 *   QUEST_PROVIDER=aws npx playwright test
 */

// ── CONFIG (injected by playwright.config.ts) ───────────────────────────────
const BASE_URL = process.env._QUEST_BASE_URL!;
const PROVIDER = process.env._QUEST_PROVIDER!;
const PHASE = process.env._QUEST_PHASE || "discovery";
const PROOFS_DIR = path.resolve(__dirname, "proofs", PROVIDER, PHASE);

// ── QUEST PAGES ─────────────────────────────────────────────────────────────
const QUEST_PAGES = [
  {
    name: "01-index",
    path: "/",
    description: "Index page — contains the SECRET_WORD",
    expectText: /secret/i,
  },
  {
    name: "02-docker",
    path: "/docker",
    description: "Docker container check",
    expectText: /docker/i,
  },
  {
    name: "03-secret-word",
    path: "/secret_word",
    description: "SECRET_WORD environment variable check",
    expectText: /secret/i,
  },
  {
    name: "04-load-balancer",
    path: "/loadbalanced",
    description: "Load balancer check",
    expectText: /load/i,
  },
  {
    name: "05-tls",
    path: "/tls",
    description: "TLS (HTTPS) check",
    expectText: /tls/i,
  },
];

// ── SETUP ───────────────────────────────────────────────────────────────────
test.beforeAll(async () => {
  fs.mkdirSync(PROOFS_DIR, { recursive: true });
  console.log(`\n☁️  Provider: ${PROVIDER}`);
  console.log(`🌐 Base URL: ${BASE_URL}`);
  console.log(`📁 Proofs:   ${PROOFS_DIR}\n`);
});

// ── SCREENSHOT TESTS ────────────────────────────────────────────────────────
for (const questPage of QUEST_PAGES) {
  test(`[${PROVIDER}] ${questPage.name} — ${questPage.description}`, async ({
    page,
  }) => {
    const url = `${BASE_URL.replace(/\/+$/, "")}${questPage.path}`;

    const response = await page.goto(url, {
      waitUntil: "networkidle",
      timeout: 60_000,
    });

    expect(response?.status()).toBeLessThan(400);

    // Verify expected content is on the page
    const body = await page.textContent("body");
    if (body && questPage.expectText) {
      expect(body).toMatch(questPage.expectText);
    }

    // Save screenshot
    const screenshotPath = path.join(PROOFS_DIR, `${questPage.name}.png`);
    await page.screenshot({ path: screenshotPath, fullPage: true });
    console.log(`  ✅ ${screenshotPath}`);
  });
}

// ── TLS CERTIFICATE INFO ────────────────────────────────────────────────────
test(`[${PROVIDER}] TLS certificate details`, async ({ page }) => {
  const url = `${BASE_URL.replace(/\/+$/, "")}/tls`;
  const response = await page.goto(url, { waitUntil: "networkidle" });

  const securityDetails = await response?.securityDetails();
  if (securityDetails) {
    const certInfo = {
      provider: PROVIDER,
      url: BASE_URL,
      issuer: securityDetails.issuer,
      protocol: securityDetails.protocol,
      validFrom: securityDetails.validFrom ? new Date(securityDetails.validFrom * 1000).toISOString() : undefined,
      validTo: securityDetails.validTo ? new Date(securityDetails.validTo * 1000).toISOString() : undefined,
      capturedAt: new Date().toISOString(),
    };

    const certPath = path.join(PROOFS_DIR, "tls-certificate-info.json");
    fs.writeFileSync(certPath, JSON.stringify(certInfo, null, 2));
    console.log(`  🔒 ${certPath}`);
  } else {
    console.log("  ⚠️  No TLS details available (HTTP-only?)");
  }
});