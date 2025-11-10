//@ts-check

import fs from 'node:fs/promises';
import path from 'node:path';
import puppeteer from 'puppeteer';

const jscompDir = path.join(import.meta.dirname, '..', 'jscomp', 'melstd', 'gen');
const keywordsFile = path.join(jscompDir, 'keywords.list');

async function getBrowserKeywords() {
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });
  const page = await browser.newPage();
  /**
   * @type string[]
   */
  const result = await page.evaluate(`Object.getOwnPropertyNames(window)`);
  await browser.close();
  return result;
}

async function dumpReservedKeywords() {
  const currentContent = await fs.readFile('jscomp/melstd/gen/keywords.list', 'utf8');
  const currentKeywords = new Set(currentContent.split('\n'));
  const browserKeywords = await getBrowserKeywords();
  const newKeywords = new Set(browserKeywords.filter((x) => /^[A-Z]/.test(x)));
  const mergedKeywords = new Set([...currentKeywords, ...newKeywords]);

  await fs.writeFile(
    keywordsFile,
    [...mergedKeywords].sort().join('\n'),
    'utf8',
  );
  console.log(`Wrote ${keywordsFile}`);
}

(async function() {
  await dumpReservedKeywords();
})();
