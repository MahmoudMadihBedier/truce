const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const context = await browser.newContext({
    viewport: { width: 390, height: 844 }, // iPhone 13/14 size
    userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1'
  });
  const page = await context.newPage();

  // We are testing the web build of the Flutter app
  try {
    console.log('Navigating to app...');
    await page.goto('http://localhost:3000', { waitUntil: 'networkidle' });

    // Wait for the splash screen to finish (it usually takes 2-3 seconds)
    console.log('Waiting for splash screen...');
    await page.waitForTimeout(3000);

    // Take screenshot of home page
    await page.screenshot({ path: 'home_page.png' });
    console.log('Screenshot saved to home_page.png');

    // Check for overflow (though hard to see in screenshot, we look for red bars or layout shifts)
    // In Flutter web, overflows often manifest as console errors or visual yellow/black bars.

    // Test Category clicking
    console.log('Clicking Groceries category...');
    const categoryChip = page.getByText('Groceries', { exact: false });
    if (await categoryChip.isVisible()) {
        await categoryChip.click();
        await page.waitForTimeout(2000);
        await page.screenshot({ path: 'category_filtered.png' });
    }

  } catch (e) {
    console.error('UI Verification failed:', e);
  } finally {
    await browser.close();
  }
})();
