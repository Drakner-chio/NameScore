# NameScore – development notes

Everything that is only relevant for working on NameScore. The player-facing
description is the [README](../README.md).

## Releasing

One click: go to **Actions → Release → Run workflow**, enter a version like `0.4.0` or
`0.4.0-beta1` and start it. The workflow creates the tag itself. Versions with `beta`
or `alpha` are uploaded as test versions.

Alternatively push a tag yourself:

```bash
git tag v0.4.0
git push origin v0.4.0
```

The GitHub Action builds the zip with the [BigWigs Packager](https://github.com/BigWigsMods/packager),
fetches the libraries listed under `externals` in `.pkgmeta` and attaches the zip to a
GitHub release. It also uploads to the stores that are set up:

| Store | In `NameScore.toc` | GitHub secret |
|---|---|---|
| CurseForge | `## X-Curse-Project-ID: …` | `CF_API_KEY` ([API tokens](https://authors.curseforge.com/account/api-tokens)) |
| Wago Addons | `## X-Wago-ID: …` | `WAGO_API_TOKEN` (Wago developer dashboard) |

Secrets go into the GitHub repo under *Settings → Secrets and variables → Actions*.

The CurseForge project description is in [`curseforge.md`](curseforge.md), the banner
images in [`images/`](images/) with their source in [`banner-source/`](banner-source/),
the project logo (400×400) in [`../media/icon-400.png`](../media/icon-400.png).

## Sync protocol

All messages use the addon prefix `NAMESCORE`. Each player only sends their **own**
votes; the game sets the sender of every addon message, so votes can't be faked on
behalf of others.

| Message | Meaning |
|---|---|
| `V\|<key>\|<score>\|<tags>\|<time>` | A vote: score 1–10 (half stars), `0` = vote deleted |
| `SYN` (guild/group) | "Who has votes for me?" |
| `HI\|<time>` (whisper) | "My newest own vote is from `<time>`" |
| `GET\|<since>` (whisper) | Sent only if that is newer than what we have from them |
| `END\|<time>\|<more>` (whisper) | All own votes since `<since>` were sent (oldest first, max 300); `more` = 1 if another batch follows |
| `REQ` | Request from clients before 0.4; answered with up to 300 own votes |
| `PING` (guild) / `PONG\|<version>` (whisper) | Counting NameScore users in the guild; only the number is shown, names are kept in memory for the few seconds of a count |
| `OPT\|<0/1>\|<time>` (guild/group, and whispered on `SYN`) | Sender opts out of (1) or back into (0) being rated; newest choice wins. Covers the sender and their pets, not their guild |

Per sender NameScore remembers up to when it is complete (`NameScoreDB.sync`). Live
votes don't move that mark, so votes missed while offline are never skipped.

WoW: Forever does not allow addon messages in custom chat channels, so sync only uses
guild, party/raid and whispers.

## Saved data

`NameScoreDB.votes[key][voter] = { s = 0..10, tags = { [tag] = true }, ts = time }`

| Kind | Key |
|---|---|
| Player | `First-Last` (WoW: Forever surnames, spaces become `-`) |
| Guild | `G:<guild name>` |
| Pet | `P:<owner key>:<pet name>` |

`NameScoreDB.optout[player] = { on = bool, ts = time }` – opt-out choices of others. On receiving an opt-out, clients delete their own votes for that player and their pets.

Tag ids are `lustig episch kreativ wortspiel lore klassiker cute cringe`; older versions
ignore ids they don't know. Votes older than 6 months are removed on login.

## Testing in the game

- New files (textures, Lua files, `Bindings.xml`, libraries) are only picked up after
  restarting WoW; `/reload` is not enough.
- Errors: install BugSack + BugGrabber. Inside dungeons many unit values are *secret
  values*; never do string operations, comparisons or math on them.
