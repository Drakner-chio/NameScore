# NameScore

**Rate the names of players, guilds and hunter pets – and see the community score right in the tooltip, Raider.io style.**

Ever met a *Tankenstein*, a guild called *Kein Plan* or a wolf named *Fluffy McFangs* and wished you could tell the world what you think? NameScore lets you and your guild rate names with ½ to 5 stars and tags. Everyone running the addon sees the average score when hovering over them.

Made for **World of Warcraft: Forever**.

## Features

- **Tooltip badge** – score from 1 to 10, a rank colored like item quality (from *Poor* to *Legendary*), a score bar, the number of votes, the most popular tags and your own vote
- **Guild names** – rate a player's guild; its score appears right next to the guild name
- **Hunter pets** – rate other players' pets (and warlock demons). Pets are stored with their owner, so not every "Wolfi" shares one score
- **Fair scores** – a score only shows up once a name has at least 2 votes (adjustable)
- **Rating window** – give ½ to 5 stars (half stars allowed) and as many tags as you like: *Funny*, *Epic*, *Creative*, *Cringe*. Changed your mind? Delete your vote any time
- **Right-click menu** – right-click any player or pet and choose *NameScore → Rate name* or *Rate guild*
- **Hall of fame** – the best and worst rated names, and a list of everything you rated
- **Settings** – in *Options → AddOns → NameScore*
- **No external servers** – votes are shared in-game with your guild and your party/raid
- **ElvUI support** – if ElvUI is installed, NameScore automatically uses its borders, fonts and colors
- **Lightweight** – messages are throttled and invisible in chat; old votes are cleaned up automatically

## How to use

Right-click a player or pet and choose *NameScore → Rate name* (or *Rate guild*), or target them and type `/ns`.

| Command | What it does |
|---|---|
| `/ns` | Open the rating window for your target |
| `/ns 3.5 funny creative` | Rate your target with 3.5 stars and tags directly |
| `/ns guild` | Rate your target's guild |
| `/ns delete` | Delete your vote for your target |
| `/ns top` | Open the hall of fame |
| `/ns options` | Open the settings |
| `/ns check Name` | Look up a player's score |
| `/ns sync` | Request votes from your guild and group |

You can't rate yourself, your own guild or your own pet. ;)

## How sharing works

Each player only sends their **own** votes. The game itself sets the sender of every addon message, so nobody can fake votes on behalf of others. When you log in or join a group, NameScore asks the others for their votes. You see votes from guild and group members who are (or were) online at the same time as you.

WoW: Forever does not allow addon messages in custom chat channels, so there is no cross-guild sync channel.

**Votes are not anonymous.** Each vote is stored with the voter's name to prevent fake votes. In-game NameScore only shows the average and the number of votes, but anyone with the addon could look up who rated whom in the saved variables.

## Language

NameScore is available in **English** and **German** and follows your game client's language. More translations are welcome!

## Keep it fun

NameScore is meant as a bit of fun among friends. There are deliberately no free-text comments, and the lowest rating is called *Cringe* rather than anything nastier. Please don't use scores to mock other players in chat.

## Feedback & source

Found a bug or have an idea? Open an issue on [GitHub](https://github.com/Drakner-chio/NameScore).
