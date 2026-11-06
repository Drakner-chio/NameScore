# NameScore

Community-Addon für **World of Warcraft: Forever**: Bewerte die Namen anderer Spieler mit 1–5 Sternen und Tags – der Score erscheint wie bei Raider.io im Tooltip.

## Funktionen

- **Tooltip-Abzeichen:** Score (1–10), Rang von *Schrott* bis *Legendär* in Item-Qualitätsfarben, Balken, Anzahl Stimmen und die häufigsten Tags
- **Bewertungsfenster:** 1–5 Sterne plus beliebig viele Tags (Lustig, Episch, Kreativ, Cringe)
- **In-Game-Sync:** Stimmen werden über Gilde, Gruppe/Raid und einen versteckten Kanal geteilt – ganz ohne externe Server
- **ElvUI-Skin:** Ist ElvUI installiert, übernimmt NameScore automatisch dessen Rahmen, Schrift und Farben

## Befehle

| Befehl | Wirkung |
|---|---|
| `/ns` | Bewertungsfenster für dein Ziel öffnen |
| `/ns 4 lustig kreativ` | Ziel direkt mit 4 Sternen und Tags bewerten |
| `/ns check Name` | Score eines Spielers nachschlagen |
| `/ns sync` | Stimmen von anderen anfragen |
| `/ns kanal` | Öffentlichen Sync-Kanal an/aus |

## Wie der Sync funktioniert

Jeder Spieler verschickt nur seine **eigenen** Stimmen. Der Absender einer Addon-Nachricht wird vom Spiel gesetzt, deshalb kann niemand Stimmen im Namen anderer fälschen. Beim Login und beim Gruppenbeitritt fragt NameScore die anderen nach ihren Stimmen. Man sieht also Stimmen von allen, die gleichzeitig online sind oder waren.

## Installation

Über CurseForge, oder manuell: Release-Zip herunterladen und den Ordner `NameScore` nach `World of Warcraft\<Forever-Ordner>\Interface\AddOns\` entpacken.

## Release erstellen

```bash
git tag v0.2.0
git push origin v0.2.0
```

Die GitHub Action baut das Zip mit dem [BigWigs Packager](https://github.com/BigWigsMods/packager) und hängt es an ein GitHub Release. Für den automatischen Upload zu CurseForge:

1. Projekt auf CurseForge anlegen und die Projekt-ID in `NameScore.toc` eintragen (`## X-Curse-Project-ID:`)
2. API-Token unter [CurseForge → API Tokens](https://authors.curseforge.com/account/api-tokens) erzeugen
3. Im GitHub-Repo unter *Settings → Secrets and variables → Actions* als `CF_API_KEY` speichern

## Fair bleiben

NameScore ist als Spaß gedacht. Es gibt bewusst keine Freitext-Kommentare, und niedrige Scores heißen „Cringe“ statt beleidigend.

## Lizenz

MIT
