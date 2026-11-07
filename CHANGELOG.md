# NameScore

## v0.2.0
- Rating window with 1–5 stars and multiple tags (Funny, Epic, Creative, Cringe)
- "Rate name" entry in the right-click menu of players (target, party, raid,
  focus, chat names, guild roster)
- Compact tooltip badge (two lines) with score, rank (Poor to Legendary), score bar and top tags
- Automatic ElvUI skin when ElvUI is installed
- Your own vote is preselected when reopening the rating window
- English and German localization
- Sync only via guild and party/raid (WoW: Forever does not allow addon messages in chat channels)
- Fixed own guild echo being counted as a second vote (WoW: Forever surnames
  arrive as "First Last" or "First-Last" depending on the source)
- Player names are shown with their surname
- `/ns check` also finds players by first name only
- Fixed Lua errors on mouseover in dungeons; tooltip errors are now caught
  and reported once instead of spamming
- Fixed Backdrop.lua error spam in dungeons: the tooltip badge border no
  longer uses BackdropTemplate
