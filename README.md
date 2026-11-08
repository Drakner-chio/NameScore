# NameScore

Community addon for **World of Warcraft: Forever**: rate the names of players, guilds and hunter pets with ½ to 5 stars and tags – the score shows up in the tooltip, Raider.io style.

## Features

- **Tooltip badge:** score (1–10), rank from *Poor* to *Legendary* in item quality colors, score bar, number of votes, the most popular tags and your own vote
- **Guilds:** the guild score appears next to the guild name in the tooltip
- **Hunter pets:** pets (and warlock demons) get their own score, stored together with their owner
- **Fair scores:** a score is only shown once a name has at least 2 votes (adjustable)
- **Rating window:** ½ to 5 stars (half stars allowed) plus any number of tags (Funny, Epic, Creative, Wordplay, Lore, Classic, Cringe); delete your vote any time
- **Right-click menu:** right-click a player or pet and choose *NameScore → Rate name* or *Rate guild*
- **Your own score:** see what others think of your name, guild and pets (`/ns me`)
- **Hall of fame:** best and worst rated names, and everything you rated
- **Minimap button:** left-click for the hall of fame, right-click for settings (also in the addon compartment)
- **Settings** in *Options → AddOns → NameScore*
- **In-game sync:** votes are shared with your guild and party/raid – no external servers
- **ElvUI & EllesmereUI:** NameScore windows automatically match your UI – EllesmereUI via its official skinning API (theme, accent color and font), ElvUI via its skin module
- **Key bindings** for rating your target and the hall of fame
- **Languages:** English, German, French and Spanish

## Commands

| Command | What it does |
|---|---|
| `/ns` | Open the rating window for your target (player or pet) |
| `/ns 3.5 funny creative` | Rate your target with 3.5 stars and tags directly |
| `/ns guild` | Rate your target's guild |
| `/ns delete` / `/ns delete guild` | Delete your vote for your target / its guild |
| `/ns check Name` | Look up a player's score (first name is enough if unique) |
| `/ns top` | Open the hall of fame |
| `/ns me` | What others think of your name, guild and pets |
| `/ns options` | Open the settings |
| `/ns min 1-5` | Votes needed before a score is shown |
| `/ns minimap` | Show/hide the minimap button |
| `/ns badge` / `/ns own` / `/ns elvui` | Toggle tooltip badge / own vote / ElvUI & EllesmereUI style |
| `/ns sync` | Request votes from your guild and group |

Commands and tags also work in German (`/ns gilde`, `/ns löschen`, `/ns optionen`, `/ns ich`, `lustig episch kreativ wortspiel lore klassiker cringe`); tags also in French and Spanish. You can't rate yourself, your own guild or your own pet.

## How sync works

Each player only sends their **own** votes. The game sets the sender of every addon message, so nobody can fake votes on behalf of others. When you log in or join a group, NameScore asks the others for their votes. You see votes from guild and group members who are (or were) online at the same time as you.

Sync only transfers what you don't have yet (since 0.4):

| Step | Message | Meaning |
|---|---|---|
| 1 | `SYN` (guild/group) | "Who has votes for me?" |
| 2 | `HI\|<time>` (whisper) | "My newest own vote is from `<time>`" |
| 3 | `GET\|<since>` (whisper) | Sent only if that is newer than what we have from them |
| 4 | `V\|…` … `END\|<time>\|<more>` | Their own votes since then, oldest first, max 300 per batch |

Per sender NameScore remembers up to when it is complete (`NameScoreDB.sync`). Live votes don't move that mark, so votes missed while offline are never skipped. Clients before 0.4 send `REQ` and still get a full reply.

A deleted vote is sent as score 0, so it also disappears for the others (versions before 0.3 ignore deletions). Votes older than 6 months are removed automatically.

WoW: Forever does not allow addon messages in custom chat channels, so there is no cross-guild sync channel.

**Votes are not anonymous:** each vote is stored with the voter's name to prevent fake votes. In-game NameScore only shows the average and the number of votes, but anyone with the addon could look up who rated whom in the saved variables.

### Keys in the saved data

| Kind | Key |
|---|---|
| Player | `First-Last` |
| Guild | `G:<guild name>` |
| Pet | `P:<owner key>:<pet name>` |

## Installation

Via CurseForge, or manually: download the release zip and extract the `NameScore` folder to `World of Warcraft\<Forever folder>\Interface\AddOns\`.

## Releasing

One click: go to **Actions → Release → Run workflow**, enter a version like `0.3.0` or `0.3.0-beta1` and start it. Versions with `beta` or `alpha` go to CurseForge as test versions.

Alternatively push a tag yourself:

```bash
git tag v0.3.0
git push origin v0.3.0
```

The GitHub Action builds the zip with the [BigWigs Packager](https://github.com/BigWigsMods/packager) and attaches it to a GitHub release. For automatic uploads to CurseForge:

1. Create the project on CurseForge and enter its project ID in `NameScore.toc` (`## X-Curse-Project-ID:`)
2. Create an API token at [CurseForge → API Tokens](https://authors.curseforge.com/account/api-tokens)
3. Save it in the GitHub repo under *Settings → Secrets and variables → Actions* as `CF_API_KEY`

The CurseForge project description is in [`docs/curseforge.md`](docs/curseforge.md), the project logo (400×400) in [`media/icon-400.png`](media/icon-400.png).

## Keep it fun

NameScore is meant as a bit of fun. There are deliberately no free-text comments, and the lowest rating is called *Cringe* rather than anything nastier.

## License

MIT for NameScore's own code. The embedded libraries (LibStub, CallbackHandler, LibDataBroker, LibDBIcon) are added by the release packager and keep their own licenses.
