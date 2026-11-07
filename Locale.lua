-- NameScore localization: English is the default, German overrides for deDE clients
local _, ns = ...

local L = {
    NOT_RATED       = "not rated yet",
    NO_TAGS         = "no tags yet",
    VOTE            = "vote",
    VOTES           = "votes",
    STAR            = "star",
    STARS           = "stars",
    SUBMIT          = "Submit",
    CURRENT         = "Current: %s",
    NO_TARGET       = "Target a player first.",
    NO_SELF         = "Rating your own name doesn't count. ;)",
    STARS_RANGE     = "Please give 1 to 5 stars.",
    RATED           = "%s: %d %s given. New score: %s",
    SYNC_REQUESTED  = "Sync requested – votes from your guild and group will arrive shortly.",
    HELP_HEADER     = "Commands:",
    HELP_OPEN       = "/ns – open the rating window for your target",
    HELP_RATE       = "/ns <1-5> [funny epic creative cringe] – rate your target directly",
    HELP_CHECK      = "/ns check <name> – look up a player's score",
    HELP_SYNC       = "/ns sync – request votes from your guild and group",
    TOOLTIP_ERROR   = "Tooltip error (shown once, please report on GitHub):",

    TAG_lustig      = "Funny",
    TAG_episch      = "Epic",
    TAG_kreativ     = "Creative",
    TAG_cringe      = "Cringe",

    RANK_LEGENDARY  = "Legendary",
    RANK_EPIC       = "Epic",
    RANK_RARE       = "Rare",
    RANK_UNCOMMON   = "Uncommon",
    RANK_COMMON     = "Common",
    RANK_POOR       = "Poor",
}

if GetLocale() == "deDE" then
    L.NOT_RATED      = "noch nicht bewertet"
    L.NO_TAGS        = "noch keine Tags"
    L.VOTE           = "Stimme"
    L.VOTES          = "Stimmen"
    L.STAR           = "Stern"
    L.STARS          = "Sterne"
    L.SUBMIT         = "Senden"
    L.CURRENT        = "Aktuell: %s"
    L.NO_TARGET      = "Ziele zuerst einen Spieler an."
    L.NO_SELF        = "Den eigenen Namen bewerten zählt nicht. ;)"
    L.STARS_RANGE    = "Bitte 1 bis 5 Sterne vergeben."
    L.RATED          = "%s: %d %s vergeben. Neuer Score: %s"
    L.SYNC_REQUESTED = "Sync angefragt – Stimmen von Gilde und Gruppe trudeln gleich ein."
    L.HELP_HEADER    = "Befehle:"
    L.HELP_OPEN      = "/ns – Bewertungsfenster für dein Ziel"
    L.HELP_RATE      = "/ns <1-5> [lustig episch kreativ cringe] – Ziel direkt bewerten"
    L.HELP_CHECK     = "/ns check <Name> – Score nachschlagen"
    L.HELP_SYNC      = "/ns sync – Stimmen von Gilde und Gruppe anfragen"
    L.TOOLTIP_ERROR  = "Tooltip-Fehler (wird nur einmal angezeigt, bitte auf GitHub melden):"

    L.TAG_lustig     = "Lustig"
    L.TAG_episch     = "Episch"
    L.TAG_kreativ    = "Kreativ"
    L.TAG_cringe     = "Cringe"

    L.RANK_LEGENDARY = "Legendär"
    L.RANK_EPIC      = "Episch"
    L.RANK_RARE      = "Selten"
    L.RANK_UNCOMMON  = "Ungewöhnlich"
    L.RANK_COMMON    = "Gewöhnlich"
    L.RANK_POOR      = "Schrott"
end

ns.L = L
