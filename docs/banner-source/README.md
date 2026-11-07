# CurseForge banners

Source of the images in `docs/images/`. To change a banner, edit `banners.html`,
put Cinzel and PT Sans (Google Fonts, OFL) into `fonts/` next to it and render each
`.banner` section at 2x, e.g. with Playwright:

```python
page.goto("file:///path/to/banners.html")
page.locator("#b1").screenshot(path="namescore-1.png")
```

Player, guild and pet names in the banners are made up.
