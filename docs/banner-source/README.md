# CurseForge banners

Source of the images in `docs/images/`, made the same way as Gatherline's and GearShare's.
Put the fonts (Space Grotesk and Inter, OFL: `npm pack @fontsource-variable/space-grotesk @fontsource-variable/inter`,
the `*-latin-wght-normal.woff2` files) into `fonts/` (not in git), then render each
`.banner` section at 2x, e.g. with Playwright:

```python
page = browser.new_page(device_scale_factor=2)
page.goto("file:///path/to/banners.html")
page.locator("#b1").screenshot(path="namescore-1.png")
```

The banners are illustrations in NameScore's look, not screenshots; player, guild and pet
names and numbers in them are made up.
