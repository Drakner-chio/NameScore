# NameScore

Community addon for **World of Warcraft: Forever**: rate other players' names with 1–5 stars and tags – the score shows up in their tooltip, Raider.io style.

## Features

- **Tooltip badge:** score (1–10), rank from *Poor* to *Legendary* in item quality colors, score bar, number of votes and the most popular tags
- **Rating window:** 1–5 stars plus any number of tags (Funny, Epic, Creative, Cringe)
- **Right-click menu:** right-click a player (target, party, raid, chat name, guild roster) and choose *NameScore → Rate name*
- **In-game sync:** votes are shared with your guild and party/raid – no external servers
- **ElvUI skin:** if ElvUI is installed, NameScore automatically uses its borders, fonts and colors
- **Languages:** English and German

## Commands

| Command | What it does |
|---|---|
| `/ns` | Open the rating window for your target |
| `/ns 4 funny creative` | Rate your target with 4 stars and tags directly |
| `/ns check Name` | Look up a player's score (first name is enough if unique) |
| `/ns sync` | Request votes from your guild and group |

Tags can be typed in English (`funny epic creative cringe`) or German (`lustig episch kreativ cringe`).

## How sync works

Each player only sends their **own** votes. The game sets the sender of every addon message, so nobody can fake votes on behalf of others. When you log in or join a group, NameScore asks the others for their votes. You see votes from guild and group members who are (or were) online at the same time as you.

WoW: Forever does not allow addon messages in custom chat channels, so there is no cross-guild sync channel.

**Votes are not anonymous:** each vote is stored with the voter's name to prevent fake votes. In-game NameScore only shows the average and the number of votes, but anyone with the addon could look up who rated whom in the saved variables.

## Installation

Via CurseForge, or manually: download the release zip and extract the `NameScore` folder to `World of Warcraft\<Forever folder>\Interface\AddOns\`.

## Releasing

One click: go to **Actions → Release → Run workflow**, enter a version like `0.2.0` or `0.2.0-beta2` and start it. Versions with `beta` or `alpha` go to CurseForge as test versions.

Alternatively push a tag yourself:

```bash
git tag v0.2.0
git push origin v0.2.0
```

The GitHub Action builds the zip with the [BigWigs Packager](https://github.com/BigWigsMods/packager) and attaches it to a GitHub release. For automatic uploads to CurseForge:

1. Create the project on CurseForge and enter its project ID in `NameScore.toc` (`## X-Curse-Project-ID:`)
2. Create an API token at [CurseForge → API Tokens](https://authors.curseforge.com/account/api-tokens)
3. Save it in the GitHub repo under *Settings → Secrets and variables → Actions* as `CF_API_KEY`

The CurseForge project description is in [`docs/curseforge.md`](docs/curseforge.md), the project logo (400×400) in [`media/icon-400.png`](media/icon-400.png).

## Keep it fun

NameScore is meant as a bit of fun. There are deliberately no free-text comments, and the lowest rating is called *Cringe* rather than anything nastier.

## License

MIT
