![NameScore – every name gets a score](https://raw.githubusercontent.com/Drakner-chio/NameScore/main/docs/images/namescore-1.jpg)

## Rate names. See the score.

Ever met a *Tankenstein*, a guild called *Kein Plan* or a wolf named *Fluffy McFangs* and wished you could tell the world what you think? **NameScore** lets you and your guild rate the names of players, guilds and hunter pets – and shows the community score right in the tooltip, Raider.io style.

- **Score from 1 to 10** with a rank in item quality colors, from *Poor* to *Legendary*
- **Top tags** like *Funny*, *Epic*, *Creative* or *Cringe*
- **Your own vote** in the tooltip, so you know who you already rated
- **Fair:** a score only shows up once a name has at least 2 votes (adjustable)

Made for **World of Warcraft: Forever**.

![Half stars and tags](https://raw.githubusercontent.com/Drakner-chio/NameScore/main/docs/images/namescore-2.jpg)

## Rating takes two clicks

Right-click any player and choose **NameScore → Rate name** (or target them and type `/ns`). Give ½ to 5 stars – click the left half of a star for a half star – and add as many tags as you like. Changed your mind? Open it again and change or delete your vote.

![Guilds and hunter pets](https://raw.githubusercontent.com/Drakner-chio/NameScore/main/docs/images/namescore-3.jpg)

## Guilds and hunter pets

- **Guild names:** right-click a player and choose **Rate guild**. The guild score appears right next to the guild name in every member's tooltip.
- **Hunter pets:** pets (and warlock demons) get their own score. They are stored together with their owner, so not every "Wolfi" shares one score.
- You can't rate yourself, your own guild or your own pet. ;)

![Hall of fame](https://raw.githubusercontent.com/Drakner-chio/NameScore/main/docs/images/namescore-4.jpg)

## Hall of Fame

Type `/ns top` for the best and worst rated names around you – players, guilds and pets – and a list of everything you rated. Click a name to change your vote.

![How sync works](https://raw.githubusercontent.com/Drakner-chio/NameScore/main/docs/images/namescore-5.jpg)

## How sharing works

There are no external servers. Votes travel invisibly through your **guild** and **party/raid** chat – throttled and never visible in the chat window.

- Each player only sends their **own** votes, and the game itself sets the sender – nobody can fake votes on behalf of others.
- When you log in or join a group, NameScore asks the others for their votes. You see votes from guild and group members who are (or were) online at the same time as you.
- Votes older than 6 months are cleaned up automatically.
- WoW: Forever does not allow addon messages in custom chat channels, so there is no cross-guild sync channel.

**Votes are not anonymous.** Each vote is stored with the voter's name to prevent fake votes. In-game NameScore only shows the average and the number of votes, but anyone with the addon could look up who rated whom in the saved variables.

## Commands

| Command | What it does |
|---|---|
| `/ns` | Open the rating window for your target (player or pet) |
| `/ns 3.5 funny creative` | Rate your target with 3.5 stars and tags directly |
| `/ns guild` | Rate your target's guild |
| `/ns delete` | Delete your vote for your target |
| `/ns top` | Open the hall of fame |
| `/ns options` | Open the settings |
| `/ns check Name` | Look up a player's score |
| `/ns sync` | Request votes from your guild and group |

## Settings

Find them in **Options → AddOns → NameScore**: tooltip badge on/off, show your own vote, votes needed for a score, and ElvUI style. If ElvUI is installed, NameScore automatically uses its borders, fonts and colors.

## Language

English and German, following your game client's language. More translations are welcome!

## Keep it fun

NameScore is meant as a bit of fun among friends. There are deliberately no free-text comments, and the lowest rating is called *Cringe* rather than anything nastier. Please don't use scores to mock other players in chat.

## Feedback & source

Found a bug or have an idea? Open an issue on [GitHub](https://github.com/Drakner-chio/NameScore).
