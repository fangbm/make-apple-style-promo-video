import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";
import { createRequire } from "node:module";

const args = parseArgs(process.argv.slice(2));
const source = path.resolve(args.source || "promo.html");
const frames = path.resolve(args.frames || "artifacts/promo-frames");
const fps = Number(args.fps || 30);
const duration = Number(args.duration || 31.2);
const width = Number(args.width || 1920);
const height = Number(args.height || 1080);
const quality = Number(args.quality || 95);
const chromePath = args.chrome || process.env.CHROME_PATH || "C:/Program Files/Google/Chrome/Application/chrome.exe";

if (!Number.isFinite(fps) || fps <= 0 || !Number.isFinite(duration) || duration <= 0) {
  throw new Error("fps and duration must be positive numbers");
}

const { chromium } = loadPlaywright();
await fs.access(source);
await fs.rm(frames, { recursive: true, force: true });
await fs.mkdir(frames, { recursive: true });

const browser = await chromium.launch({
  executablePath: chromePath,
  headless: true,
  args: ["--allow-file-access-from-files", "--disable-gpu", "--hide-scrollbars", "--font-render-hinting=none"],
});

try {
  const page = await browser.newPage({ viewport: { width, height }, deviceScaleFactor: 1 });
  await page.goto(pathToFileURL(source).href, { waitUntil: "load" });
  await page.evaluate(async () => {
    if (window.__PROMO_READY) await window.__PROMO_READY;
    await document.fonts.ready;
    await Promise.all(Array.from(document.images).map((img) => img.complete
      ? Promise.resolve()
      : new Promise((resolve) => { img.onload = img.onerror = resolve; })));
  });
  const hasRenderer = await page.evaluate(() => typeof window.renderAt === "function");
  if (!hasRenderer) throw new Error("Source must define window.renderAt(timeInSeconds)");

  const frameCount = Math.ceil(fps * duration);
  for (let frame = 0; frame < frameCount; frame += 1) {
    const time = frame / fps;
    await page.evaluate((value) => window.renderAt(value), time);
    const filename = `frame-${String(frame).padStart(5, "0")}.jpg`;
    await page.screenshot({ path: path.join(frames, filename), type: "jpeg", quality });
    if (frame % fps === 0) process.stdout.write(`Rendered ${Math.floor(time)}s / ${duration.toFixed(1)}s\n`);
  }
  process.stdout.write(`Rendered ${frameCount} frames to ${frames}\n`);
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
