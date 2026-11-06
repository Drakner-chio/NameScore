# NameScore

**Rate the names of other players – and see the community score right in their tooltip, Raider.io style.**

Ever met a *Tankenstein* or a *Xxlegolasxx* and wished you could tell the world what you think? NameScore lets you and your guild rate player names with 1–5 stars and tags. Everyone running the addon sees the average score when hovering over that player.

Made for **World of Warcraft: Forever**.

## Features

- **Tooltip badge** – score from 1 to 10, a rank colored like item quality (from *Poor* to *Legendary*), a score bar, the number of votes and the most popular tags
- **Rating window** – give 1–5 stars and as many tags as you like: *Funny*, *Epic*, *Creative*, *Cringe*
- **No external servers** – votes are shared in-game with your guild and your party/raid
- **ElvUI support** – if ElvUI is installed, NameScore automatically uses its borders, fonts and colors
- **Lightweight** – messages are throttled and invisible in chat

## How to use

Target a player and type `/ns` to open the rating window.

| Command | What it does |
|---|---|
| `/ns` | Open the rating window for your target |
| `/ns 4 funny creative` | Rate your target with 4 stars and tags directly |
| `/ns check Name` | Look up a player's score |
| `/ns sync` | Request votes from your guild and group |

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
