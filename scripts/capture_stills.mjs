import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";
import { createRequire } from "node:module";

const args = parseArgs(process.argv.slice(2));
const source = path.resolve(args.source || "promo.html");
const output = path.resolve(args.output || "artifacts/promo-stills");
const times = String(args.times || "1.5,6.5,7.4,12.8,14.0,15.4,20.5,21.4,25.0,29.5")
  .split(",").map(Number).filter(Number.isFinite);
const chromePath = args.chrome || process.env.CHROME_PATH || "C:/Program Files/Google/Chrome/Application/chrome.exe";
const { chromium } = loadPlaywright();

await fs.mkdir(output, { recursive: true });
const browser = await chromium.launch({
  executablePath: chromePath,
  headless: true,
  args: ["--allow-file-access-from-files", "--disable-gpu", "--hide-scrollbars", "--font-render-hinting=none"],
});

try {
  const page = await browser.newPage({ viewport: { width: 1920, height: 1080 }, deviceScaleFactor: 1 });
  await page.goto(pathToFileURL(source).href, { waitUntil: "load" });
  await page.evaluate(async () => {
    if (window.__PROMO_READY) await window.__PROMO_READY;
    await document.fonts.ready;
  });
  if (!(await page.evaluate(() => typeof window.renderAt === "function"))) {
    throw new Error("Source must define window.renderAt(timeInSeconds)");
  }

  for (const time of times) {
    await page.evaluate((value) => window.renderAt(value), time);
    const name = `frame-${time.toFixed(2).replace(".", "-")}.png`;
    await page.screenshot({ path: path.join(output, name) });
    const { geometry, failures } = await page.evaluate(() => {
      const nodes = Array.from(document.querySelectorAll("[data-qa]"));
      const geometry = Object.fromEntries(nodes.map((node, index) => {
        const rect = node.getBoundingClientRect();
        const key = node.getAttribute("data-qa") || `node-${index}`;
        return [key, { x: rect.x, y: rect.y, width: rect.width, height: rect.height, opacity: getComputedStyle(node).opacity }];
      }));
      const failures = [];
      for (const card of document.querySelectorAll("[data-qa-target]")) {
        const style = getComputedStyle(card);
        if (Number(style.opacity) < 0.05) continue;
        const target = document.getElementById(card.dataset.qaTarget);
        if (!target) { failures.push(`${card.id}: missing target ${card.dataset.qaTarget}`); continue; }
        const cardRect = card.getBoundingClientRect();
        const targetRect = target.getBoundingClientRect();
        if (cardRect.left < -1 || cardRect.top < -1 || cardRect.right > innerWidth + 1 || cardRect.bottom > innerHeight + 1) {
          failures.push(`${card.id}: outside viewport`);
        }
        const arrowLeft = Number.parseFloat(style.getPropertyValue("--arrow-left")) + 12;
        const horizontalError = Math.abs(cardRect.left + arrowLeft - (targetRect.left + targetRect.width / 2));
        if (!Number.isFinite(horizontalError) || horizontalError > 3) failures.push(`${card.id}: arrow error ${horizontalError.toFixed(2)}px`);
      }
      return { geometry, failures };
    });
    process.stdout.write(`${JSON.stringify({ time, file: path.join(output, name), geometry, failures })}\n`);
    if (failures.length > 0) throw new Error(`QA geometry failed at ${time}s: ${failures.join("; ")}`);
  }
} finally {
  await browser.close();
}

function parseArgs(tokens) {
  const result = {};
  for (let index = 0; index < tokens.length; index += 1) {
    const token = tokens[index];
    if (!token.startsWith("--")) continue;
    const key = token.slice(2);
    const value = tokens[index + 1];
    if (!value || value.startsWith("--")) result[key] = true;
    else { result[key] = value; index += 1; }
  }
  return result;
}

function loadPlaywright() {
  const require = createRequire(import.meta.url);
  const candidates = [
    "playwright",
    process.env.CODEX_PLAYWRIGHT_PATH,
    path.join(os.homedir(), ".cache", "codex-runtimes", "codex-primary-runtime", "dependencies", "node", "node_modules", "playwright"),
  ].filter(Boolean);
  for (const candidate of candidates) {
    try { return require(candidate); } catch { /* try next location */ }
  }
  throw new Error("Playwright was not found. Install playwright or set CODEX_PLAYWRIGHT_PATH.");
}
