-- NameScore localization: English is the default, German overrides for deDE clients
local _, ns = ...

local L = {
    NOT_RATED       = "not rated yet",
    TOO_FEW         = "too few votes (%d/%d)",
    VOTE            = "vote",
    VOTES           = "votes",
    STAR            = "star",
    STARS           = "stars",
    YOURS           = "you: %s",
    SUBMIT          = "Submit",
    DELETE          = "Delete",
    CURRENT         = "Current: %s",
    NO_TARGET       = "Target a player or pet first.",
    NO_GUILD        = "Your target is not in a guild.",
    NO_SELF         = "Rating your own name doesn't count. ;)",
    NO_SELF_GUILD   = "Rating your own guild doesn't count. ;)",
    NO_SELF_PET     = "Rating your own pet doesn't count. ;)",
    NO_VOTE         = "You haven't rated %s yet.",
    VOTE_DELETED    = "%s: your vote was deleted.",
    STARS_RANGE     = "Please give 0.5 to 5 stars in half steps.",
    RATED           = "%s: %s %s given. New score: %s",
    DECIMAL         = ".",
    PET_DISPLAY     = "%s (pet of %s)",
    GUILD_LABEL     = "Guild",
    SYNC_REQUESTED  = "Sync requested – votes from your guild and group will arrive shortly.",
    MIN_SET         = "Scores are now shown from %d votes.",
    TOOLTIP_ERROR   = "Tooltip error (shown once, please report on GitHub):",
    MENU_RATE       = "Rate name",
    MENU_RATE_GUILD = "Rate guild",

    HELP_HEADER     = "Commands:",
    HELP_OPEN       = "/ns – open the rating window for your target (player or pet)",
    HELP_RATE       = "/ns <0.5-5> [funny epic creative cringe] – rate your target directly",
    HELP_GUILD      = "/ns guild – rate your target's guild",
    HELP_DELETE     = "/ns delete [guild] – delete your vote for your target (or its guild)",
    HELP_CHECK      = "/ns check <name> – look up a player's score",
    HELP_HALL       = "/ns top – open the hall of fame",
    HELP_OPTIONS    = "/ns options – open the settings",
    HELP_MINIMAP    = "/ns minimap – show/hide the minimap button",
    HELP_SYNC       = "/ns sync – request votes from your guild and group",

    HALL_TITLE      = "NameScore – Hall of Fame",
    TAB_TOP         = "Top",
    TAB_FLOP        = "Flop",
    TAB_MINE        = "Mine",
    HALL_EMPTY      = "Nothing here yet.",
    HALL_FOOTER     = "Only names with at least %d votes · %d votes known",
    HALL_FOOTER_MINE = "Click a name to change your vote",

    OPT_BADGE       = "Show score in tooltips",
    OPT_BADGE_TIP   = "Shows the NameScore badge when you hover over players and pets, and the guild score next to the guild name.",
    OPT_OWN         = "Show your own vote",
    OPT_OWN_TIP     = "Shows your own stars in the tooltip, so you can see who you already rated.",
    OPT_MIN         = "Votes needed for a score",
    OPT_MIN_TIP     = "A score and rank are only shown once a name has at least this many votes. Fairer, because a single vote can't decide alone.",
    OPT_ELVUI       = "ElvUI / EllesmereUI style",
    OPT_ELVUI_TIP   = "Use the look of ElvUI or EllesmereUI for NameScore windows if one of them is installed. Takes effect after /reload.",
    OPT_MINIMAP     = "Minimap button",
    OPT_MINIMAP_TIP = "Shows the NameScore button at the minimap. Left-click opens the hall of fame, right-click the settings.",
    MM_LEFT         = "Left-click: hall of fame",
    MM_RIGHT        = "Right-click: settings",
    MM_VOTES        = "%d votes known",

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
    L.NOT_RATED       = "noch nicht bewertet"
    L.TOO_FEW         = "zu wenig Stimmen (%d/%d)"
    L.VOTE            = "Stimme"
    L.VOTES           = "Stimmen"
    L.STAR            = "Stern"
    L.STARS           = "Sterne"
    L.YOURS           = "du: %s"
    L.SUBMIT          = "Senden"
    L.DELETE          = "Löschen"
    L.CURRENT         = "Aktuell: %s"
    L.NO_TARGET       = "Ziele zuerst einen Spieler oder Begleiter an."
    L.NO_GUILD        = "Dein Ziel ist in keiner Gilde."
    L.NO_SELF         = "Den eigenen Namen bewerten zählt nicht. ;)"
    L.NO_SELF_GUILD   = "Die eigene Gilde bewerten zählt nicht. ;)"
    L.NO_SELF_PET     = "Den eigenen Begleiter bewerten zählt nicht. ;)"
    L.NO_VOTE         = "Du hast %s noch nicht bewertet."
    L.VOTE_DELETED    = "%s: deine Stimme wurde gelöscht."
    L.STARS_RANGE     = "Bitte 0,5 bis 5 Sterne in halben Schritten vergeben."
    L.RATED           = "%s: %s %s vergeben. Neuer Score: %s"
    L.DECIMAL         = ","
    L.PET_DISPLAY     = "%s (Begleiter von %s)"
    L.GUILD_LABEL     = "Gilde"
    L.SYNC_REQUESTED  = "Sync angefragt – Stimmen von Gilde und Gruppe trudeln gleich ein."
    L.MIN_SET         = "Scores werden jetzt ab %d Stimmen angezeigt."
    L.TOOLTIP_ERROR   = "Tooltip-Fehler (wird nur einmal angezeigt, bitte auf GitHub melden):"
    L.MENU_RATE       = "Namen bewerten"
    L.MENU_RATE_GUILD = "Gilde bewerten"

    L.HELP_HEADER     = "Befehle:"
    L.HELP_OPEN       = "/ns – Bewertungsfenster für dein Ziel (Spieler oder Begleiter)"
    L.HELP_RATE       = "/ns <0,5-5> [lustig episch kreativ cringe] – Ziel direkt bewerten"
    L.HELP_GUILD      = "/ns gilde – Gilde deines Ziels bewerten"
    L.HELP_DELETE     = "/ns löschen [gilde] – deine Stimme für dein Ziel (oder seine Gilde) löschen"
    L.HELP_CHECK      = "/ns check <Name> – Score nachschlagen"
    L.HELP_HALL       = "/ns top – Ruhmeshalle öffnen"
    L.HELP_OPTIONS    = "/ns optionen – Einstellungen öffnen"
    L.HELP_MINIMAP    = "/ns minimap – Minimap-Button ein-/ausblenden"
    L.HELP_SYNC       = "/ns sync – Stimmen von Gilde und Gruppe anfragen"

    L.HALL_TITLE      = "NameScore – Ruhmeshalle"
    L.TAB_TOP         = "Top"
    L.TAB_FLOP        = "Flop"
    L.TAB_MINE        = "Meine"
    L.HALL_EMPTY      = "Noch nichts da."
    L.HALL_FOOTER     = "Nur Namen mit mindestens %d Stimmen · %d Stimmen bekannt"
    L.HALL_FOOTER_MINE = "Klick auf einen Namen, um deine Stimme zu ändern"

    L.OPT_BADGE       = "Score in Tooltips anzeigen"
    L.OPT_BADGE_TIP   = "Zeigt das NameScore-Abzeichen bei Spielern und Begleitern sowie den Gilden-Score neben dem Gildennamen."
    L.OPT_OWN         = "Eigene Stimme anzeigen"
    L.OPT_OWN_TIP     = "Zeigt deine eigenen Sterne im Tooltip, damit du siehst, wen du schon bewertet hast."
    L.OPT_MIN         = "Stimmen für einen Score"
    L.OPT_MIN_TIP     = "Score und Rang erscheinen erst, wenn ein Name mindestens so viele Stimmen hat. Fairer, weil eine einzelne Stimme nicht allein entscheidet."
    L.OPT_ELVUI       = "ElvUI- / EllesmereUI-Stil"
    L.OPT_ELVUI_TIP   = "NameScore-Fenster im Look von ElvUI oder EllesmereUI anzeigen, wenn eins davon installiert ist. Wirkt nach /reload."
    L.OPT_MINIMAP     = "Minimap-Button"
    L.OPT_MINIMAP_TIP = "Zeigt den NameScore-Button an der Minimap. Linksklick öffnet die Ruhmeshalle, Rechtsklick die Einstellungen."
    L.MM_LEFT         = "Linksklick: Ruhmeshalle"
    L.MM_RIGHT        = "Rechtsklick: Einstellungen"
    L.MM_VOTES        = "%d Stimmen bekannt"

    L.TAG_lustig      = "Lustig"
    L.TAG_episch      = "Episch"
    L.TAG_kreativ     = "Kreativ"
    L.TAG_cringe      = "Cringe"

    L.RANK_LEGENDARY  = "Legendär"
    L.RANK_EPIC       = "Episch"
    L.RANK_RARE       = "Selten"
    L.RANK_UNCOMMON   = "Ungewöhnlich"
    L.RANK_COMMON     = "Gewöhnlich"
    L.RANK_POOR       = "Schrott"
end

ns.L = L
