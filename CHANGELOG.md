# NameScore

## Unreleased
- `/ns optout` now only switches ratings off and `/ns optin` switches them back on
  (before, `/ns optout` toggled)

## v0.6.0
- **How many in your guild use NameScore:** `/ns users` (German `/ns nutzer`) and the
  minimap button tooltip show e.g. "5 of 23 online guild members use NameScore" –
  a number only, no names. Members on versions before 0.6 are counted separately as
  "older version" if they sent NameScore messages in the guild recently.

## v0.5.0
- **"Don't rate me" (opt-out):** `/ns optout` or *Options → AddOns → NameScore*.
  Everyone with NameScore 0.5 or newer stops showing and accepting ratings of your name
  and your pets, and deletes their votes for you. The tooltip says "doesn't want to be
  rated". Your guild is not affected. You can switch it back on any time.
- **New tag:** Cute (8 tags in total)

## v0.4.0
- **Your own score:** `/ns me` (or the new *Me* tab in the hall of fame) shows what
  others think of your name, your guild and your pets – score, top tags and how many
  votes gave how many stars. Without the names of the voters.
- **New tags:** Wordplay, Lore and Classic (7 tags in total)
- **Key bindings** for "Rate target" and "Open/close hall of fame"
  (*Options → Key Bindings → AddOns → NameScore*)
- **Smarter sync:** only votes you don't have yet are sent. Each player remembers up to
  when it is complete per sender, so nothing missed while offline gets skipped, and
  large vote lists continue in batches of 300. Clients before 0.4 are still answered.
- **Badge size** setting: small (one text line), normal or large
  (*Options → AddOns → NameScore* or `/ns size small|normal|large`)
- **French and Spanish** translations

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
  on/off, votes needed for a score, ElvUI / EllesmereUI style
- Votes older than 6 months are removed automatically to keep sync fast
- **EllesmereUI support:** the rating window and hall of fame follow your EllesmereUI
  theme, accent color and font via its official skinning API
- Hall of fame: names with the same score are sorted by votes, then alphabetically
- **Minimap button:** left-click opens the hall of fame, right-click the settings;
  also in the addon compartment, collected by EllesmereUI's minimap button bar;
  hide it with `/ns minimap` or in the settings
- Own star graphic in the rating window and tooltip (the raid target star looks
  different in WoW: Forever), more compact rating window

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
