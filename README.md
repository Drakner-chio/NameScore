# NameScore

Community addon for **World of Warcraft: Forever**: rate the names of players, guilds and hunter pets with ½ to 5 stars and tags – the score shows up in the tooltip, Raider.io style.

## Features

- **Tooltip badge:** score (1–10), rank from *Poor* to *Legendary* in item quality colors, score bar, number of votes, the most popular tags and your own vote
- **Guilds:** the guild score appears next to the guild name in the tooltip
- **Hunter pets:** pets (and warlock demons) get their own score, stored together with their owner
- **Fair scores:** a score is only shown once a name has at least 2 votes (adjustable)
- **"Don't rate me":** anyone can opt out – their score disappears for everyone and existing votes for them are deleted
- **Rating window:** ½ to 5 stars (half stars allowed) plus any number of tags (Funny, Epic, Creative, Wordplay, Lore, Classic, Cute, Cringe); delete your vote any time
- **Right-click menu:** right-click a player or pet and choose *NameScore → Rate name* or *Rate guild*
- **Your own score:** see what others think of your name, guild and pets (`/ns me`)
- **Hall of fame:** best and worst rated names, and everything you rated
- **Minimap button:** left-click for the hall of fame, right-click for settings (also in the addon compartment); its tooltip shows how many online guild members use NameScore
- **Settings** in *Options → AddOns → NameScore*
- **In-game sync:** votes are shared with your guild and party/raid – no external servers
- **ElvUI & EllesmereUI:** NameScore windows automatically match your UI – EllesmereUI via its official skinning API (theme, accent color and font), ElvUI via its skin module
- **Badge size:** small (one text line), normal or large
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
| `/ns size small\|normal\|large` | Size of the tooltip badge |
| `/ns badge` / `/ns own` / `/ns elvui` | Toggle tooltip badge / own vote / ElvUI & EllesmereUI style |
| `/ns users` | How many online guild members use NameScore (a number only, no names) |
| `/ns optout` / `/ns optin` | Don't let others rate you and your pets / allow it again |
| `/ns sync` | Request votes from your guild and group |

Commands and tags also work in German (`/ns gilde`, `/ns löschen`, `/ns optionen`, `/ns ich`, `lustig episch kreativ wortspiel lore klassiker süß cringe`); tags also in French and Spanish. You can't rate yourself, your own guild or your own pet.

## How sync works

There are no external servers. Votes travel invisibly through your **guild** and **party/raid** – throttled and never visible in the chat window.

- Each player only sends their **own** votes, and the game itself sets the sender – nobody can fake votes on behalf of others.
- When you log in or join a group, NameScore asks the others for their votes and only fetches what it doesn't have yet. You see votes from guild and group members who are (or were) online at the same time as you.
- A deleted vote disappears for the others too. Votes older than 6 months are cleaned up automatically.
- WoW: Forever does not allow addon messages in custom chat channels, so there is no cross-guild sync channel.

**Votes are not anonymous:** each vote is stored with the voter's name to prevent fake votes. In-game NameScore only shows the average and the number of votes, but anyone with the addon could look up who rated whom in the saved variables.

## Installation

Install NameScore with the CurseForge app or the Wago app, or manually: download the latest release zip from GitHub and extract the `NameScore` folder to `World of Warcraft\<Forever folder>\Interface\AddOns\`.

## Feedback

Found a bug or have an idea? Open an [issue on GitHub](https://github.com/Drakner-chio/NameScore/issues). Working on NameScore yourself? See the [development notes](docs/DEVELOPMENT.md).

## Keep it fun

NameScore rates **names, not people**. There are deliberately no free-text comments, the lowest rating is called *Cringe* rather than anything nastier, and anyone who doesn't want to be rated can opt out with `/ns optout`.

## License

MIT. The embedded libraries (LibStub, CallbackHandler, LibDataBroker, LibDBIcon) keep their own licenses.
