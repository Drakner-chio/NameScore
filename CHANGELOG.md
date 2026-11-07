# NameScore

## v0.3.0
- **Guild names:** rate a player's guild via right-click (*Rate guild*) or `/ns guild`;
  the guild score appears next to the guild name in the tooltip. Your own guild can't be rated.
- **Hunter pets:** rate other players' pets (and warlock demons); the score shows in the
  pet's tooltip. Pets are stored together with their owner, so two "Wolfi"s don't share a score.
- **Score from 2 votes:** rank and score only appear once a name has at least 2 votes
  (adjustable); before that the tooltip shows "too few votes (1/2)"
- **Your own vote** is shown in the tooltip ("you: 3.5")
- **Delete your vote** with the *Delete* button in the rating window or `/ns delete`;
  the deletion is synced to the others
- **Hall of fame** (`/ns top`): best and worst rated names and your own votes; click a
  name to change your vote
- **Settings** in *Options → AddOns → NameScore* (`/ns options`): tooltip on/off, own vote
  on/off, votes needed for a score, ElvUI style
- Votes older than 6 months are removed automatically to keep sync fast

## v0.2.0
- Rating window with ½ to 5 stars (half stars allowed) and multiple tags (Funny, Epic, Creative, Cringe)
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
