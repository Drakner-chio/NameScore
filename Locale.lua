-- NameScore localization: English is the default; German, French and Spanish
-- override it depending on the game client's language.
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
    SYNC_REQUESTED  = "Sync requested – votes from your guild, group and online friends will arrive shortly.",
    MIN_SET         = "Scores are now shown from %d votes.",
    TOOLTIP_ERROR   = "Tooltip error (shown once, please report on GitHub):",
    MENU_RATE       = "Rate name",
    MENU_RATE_GUILD = "Rate guild",

    HELP_HEADER     = "Commands:",
    HELP_OPEN       = "/ns – open the rating window for your target (player or pet)",
    HELP_RATE       = "/ns <0.5-5> [funny epic creative wordplay lore classic cringe] – rate your target directly",
    HELP_GUILD      = "/ns guild – rate your target's guild",
    HELP_DELETE     = "/ns delete [guild] – delete your vote for your target (or its guild)",
    HELP_CHECK      = "/ns check <name> – look up a player's score",
    HELP_HALL       = "/ns top – open the hall of fame",
    HELP_ME         = "/ns me – what others think of your name, guild and pets",
    HELP_OPTIONS    = "/ns options – open the settings",
    HELP_MINIMAP    = "/ns minimap – show/hide the minimap button",
    HELP_SYNC       = "/ns sync – request votes from your guild, group and online friends",

    HALL_TITLE      = "NameScore – Hall of Fame",
    TAB_TOP         = "Top",
    TAB_FLOP        = "Flop",
    TAB_MINE        = "Mine",
    TAB_ME          = "Me",
    HALL_EMPTY      = "Nothing here yet.",
    HALL_FOOTER     = "Only names with at least %d votes · %d votes known",
    HALL_FOOTER_MINE = "Click a name to change your vote",

    ME_TITLE        = "What others think of you:",
    ME_PET          = "Your pet %s",
    ME_FOOTER       = "Counts the votes of everyone you have synced with",

    OPT_BADGE       = "Show score in tooltips",
    OPT_BADGE_TIP   = "Shows the NameScore badge when you hover over players and pets, and the guild score next to the guild name.",
    OPT_OWN         = "Show your own vote",
    OPT_OWN_TIP     = "Shows your own stars in the tooltip, so you can see who you already rated.",
    OPT_SIZE        = "Badge size",
    OPT_SIZE_TIP    = "How big the NameScore badge in the tooltip is. Small shows just one line of text.",
    SIZE_SMALL      = "Small (one line)",
    SIZE_NORMAL     = "Normal",
    SIZE_LARGE      = "Large",
    SIZE_SET        = "Badge size: %s",
    HELP_SIZE       = "/ns size small|normal|large – size of the tooltip badge",
    OPT_MIN         = "Votes needed for a score",
    OPT_MIN_TIP     = "A score and rank are only shown once a name has at least this many votes. Fairer, because a single vote can't decide alone.",
    OPT_ELVUI       = "ElvUI / EllesmereUI style",
    OPT_ELVUI_TIP   = "Use the look of ElvUI or EllesmereUI for NameScore windows if one of them is installed. Takes effect after /reload.",
    OPT_MINIMAP     = "Minimap button",
    OPT_MINIMAP_TIP = "Shows the NameScore button at the minimap. Left-click opens the hall of fame, right-click the settings.",
    MM_LEFT         = "Left-click: hall of fame",
    MM_RIGHT        = "Right-click: settings",
    MM_VOTES        = "%d votes known",

    USERS_RESULT    = "%d of %d online guild members use NameScore",
    USERS_RESULT_NOTOTAL = "%d online guild members use NameScore",
    USERS_OLDER     = " (%d of them with an older version)",
    USERS_NO_GUILD  = "You are not in a guild.",
    USERS_COUNTING  = "Counting NameScore users in your guild…",
    HELP_USERS      = "/ns users – how many online guild members use NameScore (a number only, no names)",
    UPDATE_AVAILABLE = "A newer version of NameScore is available (%s, you have %s). Update it with the CurseForge or Wago app.",
    MM_UPDATE       = "Update available: %s",
    HELP_FRIENDS    = "/ns friends – sync with online friends on/off",
    OPT_FRIENDS     = "Sync with friends",
    OPT_FRIENDS_TIP = "Also exchanges votes invisibly with online friends from your friend list who use NameScore – even if they are in another guild. Nothing about your friends is saved.",
    MM_FRIENDS      = "%d online friends use NameScore",
    TAB_JUDGES      = "Judges",
    JUDGE_RANKUP    = "New judge rank: %s – %d names rated!",
    JUDGE_YOU       = "Your judge rank: %s – %d names rated",
    JUDGE_NONE      = "No judge rank yet – rate your first name!",
    JUDGE_NEXT      = "%d more to %s",
    JUDGE_MAX       = "Highest rank reached – the names fear you.",
    JUDGE_TITLE     = "Top judges:",
    JUDGE_COUNT     = "%d names rated",
    JUDGE_FOOTER    = "Names rated per player · %s",
    MM_JUDGE        = "Judge rank: %s",
    HELP_JUDGES     = "/ns judges – your judge rank and the top judges",
    OPT_JUDGES      = "Show me in the judges list",
    OPT_JUDGES_TIP  = "Shares how many names you rated, so you appear in the judges list of others. Switched off, you disappear from their lists.",
    OPT_JUDGE_TT    = "Judge rank in the tooltip",
    OPT_JUDGE_TT_TIP = "Shows the judge rank of players in their tooltip.",
    JUDGE_H = {
        "Scout of Names", -- 1
        "Grunt of Grammar", -- 5
        "Sergeant of Syllables", -- 10
        "Senior Sergeant of Spelling", -- 20
        "First Sergeant of Surnames", -- 30
        "Stone Guard of Nicknames", -- 40
        "Blood Guard of Puns", -- 50
        "Legionnaire of Letters", -- 75
        "Centurion of Consonants", -- 100
        "Champion of Names", -- 150
        "Lieutenant General of Lore", -- 200
        "General of Nomenclature", -- 250
        "Warlord of Wordplay", -- 500
        "High Warlord of Names", -- 1000
    },
    JUDGE_A = {
        "Private of Pseudonyms", -- 1
        "Corporal of the Alphabet", -- 5
        "Sergeant of Syllables", -- 10
        "Master Sergeant of Spelling", -- 20
        "Sergeant Major of Surnames", -- 30
        "Knight of Nicknames", -- 40
        "Knight-Lieutenant of Puns", -- 50
        "Knight-Captain of Letters", -- 75
        "Knight-Champion of Consonants", -- 100
        "Lieutenant Commander of Names", -- 150
        "Commander of Lore", -- 200
        "Marshal of Nomenclature", -- 250
        "Field Marshal of Wordplay", -- 500
        "Grand Marshal of Names", -- 1000
    },
    BIND_RATE       = "Rate target",
    BIND_HALL       = "Open/close hall of fame",

    TAG_lustig      = "Funny",
    TAG_episch      = "Epic",
    TAG_kreativ     = "Creative",
    TAG_wortspiel   = "Wordplay",
    TAG_lore        = "Lore",
    TAG_klassiker   = "Classic",
    TAG_cute        = "Cute",
    OPTED_OUT_TT    = "doesn't want to be rated",
    OPTED_OUT_RATE  = "%s doesn't want to be rated.",
    OPTOUT_ON       = "You can no longer be rated. Everyone with NameScore 0.5 or newer hides your score and accepts no new ratings. Existing votes are kept and come back if you type /ns optin.",
    OPTOUT_OFF      = "You can be rated again.",
    ME_OPTED_OUT    = "you don't want to be rated",
    HELP_OPTOUT     = "/ns optout – don't let others rate you (and your pets) · /ns optin – allow it again",
    OPTOUT_ALREADY  = "You already can't be rated. Type /ns optin to allow it again.",
    OPTIN_ALREADY   = "You can already be rated. Type /ns optout to turn it off.",
    OPT_OPTOUT      = "Don't rate me",
    OPT_OPTOUT_TIP  = "Others with NameScore 0.5 or newer hide your score and that of your pets and accept no new ratings. Existing votes are kept and come back when you allow ratings again. Your guild is not affected.",
    TAG_cringe      = "Cringe",

    RANK_LEGENDARY  = "Legendary",
    RANK_EPIC       = "Epic",
    RANK_RARE       = "Rare",
    RANK_UNCOMMON   = "Uncommon",
    RANK_COMMON     = "Common",
    RANK_POOR       = "Poor",
}

local LOCALES = {}

LOCALES.deDE = {
    NOT_RATED       = "noch nicht bewertet",
    TOO_FEW         = "zu wenig Stimmen (%d/%d)",
    VOTE            = "Stimme",
    VOTES           = "Stimmen",
    STAR            = "Stern",
    STARS           = "Sterne",
    YOURS           = "du: %s",
    SUBMIT          = "Senden",
    DELETE          = "Löschen",
    CURRENT         = "Aktuell: %s",
    NO_TARGET       = "Ziele zuerst einen Spieler oder Begleiter an.",
    NO_GUILD        = "Dein Ziel ist in keiner Gilde.",
    NO_SELF         = "Den eigenen Namen bewerten zählt nicht. ;)",
    NO_SELF_GUILD   = "Die eigene Gilde bewerten zählt nicht. ;)",
    NO_SELF_PET     = "Den eigenen Begleiter bewerten zählt nicht. ;)",
    NO_VOTE         = "Du hast %s noch nicht bewertet.",
    VOTE_DELETED    = "%s: deine Stimme wurde gelöscht.",
    STARS_RANGE     = "Bitte 0,5 bis 5 Sterne in halben Schritten vergeben.",
    RATED           = "%s: %s %s vergeben. Neuer Score: %s",
    DECIMAL         = ",",
    PET_DISPLAY     = "%s (Begleiter von %s)",
    GUILD_LABEL     = "Gilde",
    SYNC_REQUESTED  = "Sync angefragt – Stimmen von Gilde, Gruppe und Freunden trudeln gleich ein.",
    MIN_SET         = "Scores werden jetzt ab %d Stimmen angezeigt.",
    TOOLTIP_ERROR   = "Tooltip-Fehler (wird nur einmal angezeigt, bitte auf GitHub melden):",
    MENU_RATE       = "Namen bewerten",
    MENU_RATE_GUILD = "Gilde bewerten",

    HELP_HEADER     = "Befehle:",
    HELP_OPEN       = "/ns – Bewertungsfenster für dein Ziel (Spieler oder Begleiter)",
    HELP_RATE       = "/ns <0,5-5> [lustig episch kreativ wortspiel lore klassiker cringe] – Ziel direkt bewerten",
    HELP_GUILD      = "/ns gilde – Gilde deines Ziels bewerten",
    HELP_DELETE     = "/ns löschen [gilde] – deine Stimme für dein Ziel (oder seine Gilde) löschen",
    HELP_CHECK      = "/ns check <Name> – Score nachschlagen",
    HELP_HALL       = "/ns top – Ruhmeshalle öffnen",
    HELP_ME         = "/ns ich – was andere von deinem Namen, deiner Gilde und deinen Begleitern halten",
    HELP_OPTIONS    = "/ns optionen – Einstellungen öffnen",
    HELP_MINIMAP    = "/ns minimap – Minimap-Button ein-/ausblenden",
    HELP_SYNC       = "/ns sync – Stimmen von Gilde, Gruppe und online Freunden anfragen",

    HALL_TITLE      = "NameScore – Ruhmeshalle",
    TAB_TOP         = "Top",
    TAB_FLOP        = "Flop",
    TAB_MINE        = "Meine",
    TAB_ME          = "Ich",
    HALL_EMPTY      = "Noch nichts da.",
    HALL_FOOTER     = "Nur Namen mit mindestens %d Stimmen · %d Stimmen bekannt",
    HALL_FOOTER_MINE = "Klick auf einen Namen, um deine Stimme zu ändern",

    ME_TITLE        = "Was andere von dir halten:",
    ME_PET          = "Dein Begleiter %s",
    ME_FOOTER       = "Zählt die Stimmen aller, mit denen du synchronisiert bist",

    OPT_BADGE       = "Score in Tooltips anzeigen",
    OPT_BADGE_TIP   = "Zeigt das NameScore-Abzeichen bei Spielern und Begleitern sowie den Gilden-Score neben dem Gildennamen.",
    OPT_OWN         = "Eigene Stimme anzeigen",
    OPT_OWN_TIP     = "Zeigt deine eigenen Sterne im Tooltip, damit du siehst, wen du schon bewertet hast.",
    OPT_SIZE        = "Größe des Abzeichens",
    OPT_SIZE_TIP    = "Wie groß das NameScore-Abzeichen im Tooltip ist. Klein zeigt nur eine Textzeile.",
    SIZE_SMALL      = "Klein (eine Zeile)",
    SIZE_NORMAL     = "Normal",
    SIZE_LARGE      = "Groß",
    SIZE_SET        = "Größe des Abzeichens: %s",
    HELP_SIZE       = "/ns größe klein|normal|groß – Größe des Tooltip-Abzeichens",
    OPT_MIN         = "Stimmen für einen Score",
    OPT_MIN_TIP     = "Score und Rang erscheinen erst, wenn ein Name mindestens so viele Stimmen hat. Fairer, weil eine einzelne Stimme nicht allein entscheidet.",
    OPT_ELVUI       = "ElvUI- / EllesmereUI-Stil",
    OPT_ELVUI_TIP   = "NameScore-Fenster im Look von ElvUI oder EllesmereUI anzeigen, wenn eins davon installiert ist. Wirkt nach /reload.",
    OPT_MINIMAP     = "Minimap-Button",
    OPT_MINIMAP_TIP = "Zeigt den NameScore-Button an der Minimap. Linksklick öffnet die Ruhmeshalle, Rechtsklick die Einstellungen.",
    MM_LEFT         = "Linksklick: Ruhmeshalle",
    MM_RIGHT        = "Rechtsklick: Einstellungen",
    MM_VOTES        = "%d Stimmen bekannt",

    USERS_RESULT    = "%d von %d Online-Gildenmitgliedern nutzen NameScore",
    USERS_RESULT_NOTOTAL = "%d Online-Gildenmitglieder nutzen NameScore",
    USERS_OLDER     = " (davon %d mit älterer Version)",
    USERS_NO_GUILD  = "Du bist in keiner Gilde.",
    USERS_COUNTING  = "Zähle NameScore-Nutzer in deiner Gilde …",
    HELP_USERS      = "/ns nutzer – wie viele Online-Gildenmitglieder NameScore nutzen (nur die Zahl, keine Namen)",
    UPDATE_AVAILABLE = "Eine neuere Version von NameScore ist verfügbar (%s, du hast %s). Aktualisiere sie über die CurseForge- oder Wago-App.",
    MM_UPDATE       = "Update verfügbar: %s",
    HELP_FRIENDS    = "/ns freunde – Sync mit online Freunden ein/aus",
    OPT_FRIENDS     = "Mit Freunden synchronisieren",
    OPT_FRIENDS_TIP = "Tauscht Stimmen zusätzlich unsichtbar mit online Freunden aus deiner Freundesliste aus, die NameScore nutzen – auch wenn sie in einer anderen Gilde sind. Über deine Freunde wird nichts gespeichert.",
    MM_FRIENDS      = "%d online Freunde nutzen NameScore",
    TAB_JUDGES      = "Richter",
    JUDGE_RANKUP    = "Neuer Richterrang: %s – %d Namen bewertet!",
    JUDGE_YOU       = "Dein Richterrang: %s – %d Namen bewertet",
    JUDGE_NONE      = "Noch kein Richterrang – bewerte deinen ersten Namen!",
    JUDGE_NEXT      = "Noch %d bis %s",
    JUDGE_MAX       = "Höchster Rang erreicht – die Namen fürchten dich.",
    JUDGE_TITLE     = "Die fleißigsten Richter:",
    JUDGE_COUNT     = "%d Namen bewertet",
    JUDGE_FOOTER    = "Bewertete Namen pro Spieler · %s",
    MM_JUDGE        = "Richterrang: %s",
    HELP_JUDGES     = "/ns richter – dein Richterrang und die fleißigsten Richter",
    OPT_JUDGES      = "In der Richterliste erscheinen",
    OPT_JUDGES_TIP  = "Teilt, wie viele Namen du bewertet hast, damit du in der Richterliste der anderen auftauchst. Ausgeschaltet verschwindest du aus ihren Listen.",
    OPT_JUDGE_TT    = "Richterrang im Tooltip",
    OPT_JUDGE_TT_TIP = "Zeigt den Richterrang von Spielern in ihrem Tooltip.",
    JUDGE_H = {
        "Namensspäher", -- 1
        "Grunzer der Grammatik", -- 5
        "Waffenträger der Silben", -- 10
        "Schlachtrufer der Rechtschreibung", -- 20
        "Rottenmeister der Nachnamen", -- 30
        "Steinwache der Spitznamen", -- 40
        "Blutwache der Wortspiele", -- 50
        "Zornbringer der Lettern", -- 75
        "Klingenmeister der Konsonanten", -- 100
        "Feldherr der Namen", -- 150
        "Sturmreiter der Lore", -- 200
        "Kriegsherr der Nomenklatur", -- 250
        "Kriegsfürst des Wortwitzes", -- 500
        "Oberster Kriegsfürst der Namen", -- 1000
    },
    JUDGE_A = {
        "Namensgefreiter", -- 1
        "Fußknecht der Buchstaben", -- 5
        "Landsknecht der Silben", -- 10
        "Feldwebel der Rechtschreibung", -- 20
        "Fähnrich der Nachnamen", -- 30
        "Leutnant der Spitznamen", -- 40
        "Hauptmann der Wortspiele", -- 50
        "Kürassier der Lettern", -- 75
        "Ritter der Konsonanten", -- 100
        "Feldkommandant der Namen", -- 150
        "Rittmeister der Lore", -- 200
        "Marschall der Nomenklatur", -- 250
        "Feldmarschall des Wortwitzes", -- 500
        "Großmarschall der Namen", -- 1000
    },
    BIND_RATE       = "Ziel bewerten",
    BIND_HALL       = "Ruhmeshalle öffnen/schließen",

    TAG_lustig      = "Lustig",
    TAG_episch      = "Episch",
    TAG_kreativ     = "Kreativ",
    TAG_wortspiel   = "Wortspiel",
    TAG_lore        = "Lore",
    TAG_klassiker   = "Klassiker",
    TAG_cute        = "Süß",
    OPTED_OUT_TT    = "möchte nicht bewertet werden",
    OPTED_OUT_RATE  = "%s möchte nicht bewertet werden.",
    OPTOUT_ON       = "Du kannst nicht mehr bewertet werden. Alle mit NameScore 0.5 oder neuer blenden deinen Score aus und nehmen keine neuen Bewertungen an. Bisherige Stimmen bleiben erhalten und sind mit /ns optin wieder da.",
    OPTOUT_OFF      = "Du kannst wieder bewertet werden.",
    ME_OPTED_OUT    = "du möchtest nicht bewertet werden",
    HELP_OPTOUT     = "/ns optout – dich (und deine Begleiter) nicht bewerten lassen · /ns optin – wieder erlauben",
    OPTOUT_ALREADY  = "Du kannst bereits nicht bewertet werden. Mit /ns optin erlaubst du es wieder.",
    OPTIN_ALREADY   = "Du kannst bereits bewertet werden. Mit /ns optout schaltest du es ab.",
    OPT_OPTOUT      = "Mich nicht bewerten",
    OPT_OPTOUT_TIP  = "Andere mit NameScore 0.5 oder neuer blenden deinen Score und den deiner Begleiter aus und nehmen keine neuen Bewertungen an. Bisherige Stimmen bleiben erhalten und sind wieder da, sobald du Bewertungen wieder erlaubst. Deine Gilde ist davon nicht betroffen.",
    TAG_cringe      = "Cringe",

    RANK_LEGENDARY  = "Legendär",
    RANK_EPIC       = "Episch",
    RANK_RARE       = "Selten",
    RANK_UNCOMMON   = "Ungewöhnlich",
    RANK_COMMON     = "Gewöhnlich",
    RANK_POOR       = "Schrott",
}

LOCALES.frFR = {
    NOT_RATED       = "pas encore noté",
    TOO_FEW         = "pas assez de votes (%d/%d)",
    VOTE            = "vote",
    VOTES           = "votes",
    STAR            = "étoile",
    STARS           = "étoiles",
    YOURS           = "toi : %s",
    SUBMIT          = "Envoyer",
    DELETE          = "Supprimer",
    CURRENT         = "Actuel : %s",
    NO_TARGET       = "Cible d'abord un joueur ou un familier.",
    NO_GUILD        = "Ta cible n'est dans aucune guilde.",
    NO_SELF         = "Noter ton propre nom ne compte pas. ;)",
    NO_SELF_GUILD   = "Noter ta propre guilde ne compte pas. ;)",
    NO_SELF_PET     = "Noter ton propre familier ne compte pas. ;)",
    NO_VOTE         = "Tu n'as pas encore noté %s.",
    VOTE_DELETED    = "%s : ton vote a été supprimé.",
    STARS_RANGE     = "Donne entre 0,5 et 5 étoiles, par demi-étoile.",
    RATED           = "%s : %s %s. Nouveau score : %s",
    DECIMAL         = ",",
    PET_DISPLAY     = "%s (familier de %s)",
    GUILD_LABEL     = "Guilde",
    SYNC_REQUESTED  = "Synchronisation demandée – les votes de ta guilde, de ton groupe et de tes amis arrivent.",
    MIN_SET         = "Les scores s'affichent maintenant à partir de %d votes.",
    TOOLTIP_ERROR   = "Erreur d'infobulle (affichée une seule fois, merci de la signaler sur GitHub) :",
    MENU_RATE       = "Noter le nom",
    MENU_RATE_GUILD = "Noter la guilde",

    HELP_HEADER     = "Commandes :",
    HELP_OPEN       = "/ns – ouvrir la fenêtre de notation pour ta cible (joueur ou familier)",
    HELP_RATE       = "/ns <0,5-5> [drôle épique créatif calembour lore classique gênant] – noter ta cible directement",
    HELP_GUILD      = "/ns guild – noter la guilde de ta cible",
    HELP_DELETE     = "/ns delete [guild] – supprimer ton vote pour ta cible (ou sa guilde)",
    HELP_CHECK      = "/ns check <nom> – voir le score d'un joueur",
    HELP_HALL       = "/ns top – ouvrir le panthéon",
    HELP_ME         = "/ns moi – ce que les autres pensent de ton nom, ta guilde et tes familiers",
    HELP_OPTIONS    = "/ns options – ouvrir les réglages",
    HELP_MINIMAP    = "/ns minimap – afficher/masquer le bouton de la minicarte",
    HELP_SYNC       = "/ns sync – demander les votes de ta guilde, de ton groupe et de tes amis en ligne",

    HALL_TITLE      = "NameScore – Panthéon",
    TAB_TOP         = "Top",
    TAB_FLOP        = "Flop",
    TAB_MINE        = "Mes votes",
    TAB_ME          = "Moi",
    HALL_EMPTY      = "Rien pour l'instant.",
    HALL_FOOTER     = "Seulement les noms avec au moins %d votes · %d votes connus",
    HALL_FOOTER_MINE = "Clique sur un nom pour modifier ton vote",

    ME_TITLE        = "Ce que les autres pensent de toi :",
    ME_PET          = "Ton familier %s",
    ME_FOOTER       = "Compte les votes de tous ceux avec qui tu es synchronisé",

    OPT_BADGE       = "Afficher le score dans les infobulles",
    OPT_BADGE_TIP   = "Affiche le badge NameScore au survol des joueurs et des familiers, et le score de la guilde à côté de son nom.",
    OPT_OWN         = "Afficher ton propre vote",
    OPT_OWN_TIP     = "Affiche tes propres étoiles dans l'infobulle pour voir qui tu as déjà noté.",
    OPT_SIZE        = "Taille du badge",
    OPT_SIZE_TIP    = "Taille du badge NameScore dans l'infobulle. Petit n'affiche qu'une ligne de texte.",
    SIZE_SMALL      = "Petit (une ligne)",
    SIZE_NORMAL     = "Normal",
    SIZE_LARGE      = "Grand",
    SIZE_SET        = "Taille du badge : %s",
    HELP_SIZE       = "/ns taille petit|normal|grand – taille du badge dans l'infobulle",
    OPT_MIN         = "Votes nécessaires pour un score",
    OPT_MIN_TIP     = "Le score et le rang n'apparaissent qu'à partir de ce nombre de votes. Plus juste, car un seul vote ne décide pas tout.",
    OPT_ELVUI       = "Style ElvUI / EllesmereUI",
    OPT_ELVUI_TIP   = "Utilise l'apparence d'ElvUI ou d'EllesmereUI pour les fenêtres de NameScore si l'un des deux est installé. Prend effet après /reload.",
    OPT_MINIMAP     = "Bouton de la minicarte",
    OPT_MINIMAP_TIP = "Affiche le bouton NameScore sur la minicarte. Clic gauche : panthéon, clic droit : réglages.",
    MM_LEFT         = "Clic gauche : panthéon",
    MM_RIGHT        = "Clic droit : réglages",
    MM_VOTES        = "%d votes connus",

    USERS_RESULT    = "%d membres de la guilde en ligne sur %d utilisent NameScore",
    USERS_RESULT_NOTOTAL = "%d membres de la guilde en ligne utilisent NameScore",
    USERS_OLDER     = " (dont %d avec une version plus ancienne)",
    USERS_NO_GUILD  = "Tu n'es dans aucune guilde.",
    USERS_COUNTING  = "Comptage des utilisateurs de NameScore dans ta guilde…",
    HELP_USERS      = "/ns users – combien de membres de la guilde en ligne utilisent NameScore (un nombre seulement, sans noms)",
    UPDATE_AVAILABLE = "Une version plus récente de NameScore est disponible (%s, tu as %s). Mets-la à jour avec l'application CurseForge ou Wago.",
    MM_UPDATE       = "Mise à jour disponible : %s",
    HELP_FRIENDS    = "/ns amis – synchronisation avec les amis en ligne activée/désactivée",
    OPT_FRIENDS     = "Synchroniser avec les amis",
    OPT_FRIENDS_TIP = "Échange aussi les votes de façon invisible avec les amis en ligne de ta liste d'amis qui utilisent NameScore – même s'ils sont dans une autre guilde. Rien n'est enregistré sur tes amis.",
    MM_FRIENDS      = "%d amis en ligne utilisent NameScore",
    TAB_JUDGES      = "Juges",
    JUDGE_RANKUP    = "Nouveau rang de juge : %s – %d noms notés !",
    JUDGE_YOU       = "Ton rang de juge : %s – %d noms notés",
    JUDGE_NONE      = "Pas encore de rang de juge – note ton premier nom !",
    JUDGE_NEXT      = "Encore %d avant %s",
    JUDGE_MAX       = "Rang le plus élevé atteint – les noms te craignent.",
    JUDGE_TITLE     = "Les meilleurs juges :",
    JUDGE_COUNT     = "%d noms notés",
    JUDGE_FOOTER    = "Noms notés par joueur · %s",
    MM_JUDGE        = "Rang de juge : %s",
    HELP_JUDGES     = "/ns juges – ton rang de juge et les meilleurs juges",
    OPT_JUDGES      = "Apparaître dans la liste des juges",
    OPT_JUDGES_TIP  = "Partage le nombre de noms que tu as notés, pour apparaître dans la liste des juges des autres. Désactivé, tu disparais de leurs listes.",
    OPT_JUDGE_TT    = "Rang de juge dans l'infobulle",
    OPT_JUDGE_TT_TIP = "Affiche le rang de juge des joueurs dans leur infobulle.",
    JUDGE_H = {
        "Éclaireur des noms", -- 1
        "Grunt de la grammaire", -- 5
        "Sergent des syllabes", -- 10
        "Sergent-chef de l'orthographe", -- 20
        "Adjudant des noms de famille", -- 30
        "Garde de pierre des surnoms", -- 40
        "Garde de sang des calembours", -- 50
        "Légionnaire des lettres", -- 75
        "Centurion des consonnes", -- 100
        "Champion des noms", -- 150
        "Lieutenant général du lore", -- 200
        "Général de la nomenclature", -- 250
        "Seigneur de guerre des jeux de mots", -- 500
        "Grand seigneur de guerre des noms", -- 1000
    },
    JUDGE_A = {
        "Soldat des pseudonymes", -- 1
        "Caporal de l'alphabet", -- 5
        "Sergent des syllabes", -- 10
        "Sergent-chef de l'orthographe", -- 20
        "Sergent-major des noms de famille", -- 30
        "Chevalier des surnoms", -- 40
        "Chevalier-lieutenant des calembours", -- 50
        "Chevalier-capitaine des lettres", -- 75
        "Chevalier-champion des consonnes", -- 100
        "Lieutenant-commandant des noms", -- 150
        "Commandant du lore", -- 200
        "Maréchal de la nomenclature", -- 250
        "Grand maréchal des jeux de mots", -- 500
        "Connétable des noms", -- 1000
    },
    BIND_RATE       = "Noter la cible",
    BIND_HALL       = "Ouvrir/fermer le panthéon",

    TAG_lustig      = "Drôle",
    TAG_episch      = "Épique",
    TAG_kreativ     = "Créatif",
    TAG_wortspiel   = "Calembour",
    TAG_lore        = "Lore",
    TAG_klassiker   = "Classique",
    TAG_cute        = "Mignon",
    OPTED_OUT_TT    = "ne souhaite pas être noté",
    OPTED_OUT_RATE  = "%s ne souhaite pas être noté.",
    OPTOUT_ON       = "Tu ne peux plus être noté. Tous ceux qui ont NameScore 0.5 ou plus récent masquent ton score et n'acceptent plus de nouvelles notes. Les votes existants sont conservés et reviennent avec /ns optin.",
    OPTOUT_OFF      = "Tu peux de nouveau être noté.",
    ME_OPTED_OUT    = "tu ne souhaites pas être noté",
    HELP_OPTOUT     = "/ns optout – ne pas te laisser noter (ni tes familiers) · /ns optin – l'autoriser à nouveau",
    OPTOUT_ALREADY  = "Tu ne peux déjà plus être noté. Tape /ns optin pour l'autoriser à nouveau.",
    OPTIN_ALREADY   = "Tu peux déjà être noté. Tape /ns optout pour le désactiver.",
    OPT_OPTOUT      = "Ne pas me noter",
    OPT_OPTOUT_TIP  = "Les autres joueurs avec NameScore 0.5 ou plus récent masquent ton score et celui de tes familiers et n'acceptent plus de nouvelles notes. Les votes existants sont conservés et reviennent dès que tu autorises à nouveau les notes. Ta guilde n'est pas concernée.",
    TAG_cringe      = "Gênant",

    RANK_LEGENDARY  = "Légendaire",
    RANK_EPIC       = "Épique",
    RANK_RARE       = "Rare",
    RANK_UNCOMMON   = "Inhabituel",
    RANK_COMMON     = "Commun",
    RANK_POOR       = "Médiocre",
}

LOCALES.esES = {
    NOT_RATED       = "sin valorar",
    TOO_FEW         = "pocos votos (%d/%d)",
    VOTE            = "voto",
    VOTES           = "votos",
    STAR            = "estrella",
    STARS           = "estrellas",
    YOURS           = "tú: %s",
    SUBMIT          = "Enviar",
    DELETE          = "Borrar",
    CURRENT         = "Actual: %s",
    NO_TARGET       = "Primero selecciona a un jugador o una mascota.",
    NO_GUILD        = "Tu objetivo no está en ninguna hermandad.",
    NO_SELF         = "Valorar tu propio nombre no cuenta. ;)",
    NO_SELF_GUILD   = "Valorar tu propia hermandad no cuenta. ;)",
    NO_SELF_PET     = "Valorar tu propia mascota no cuenta. ;)",
    NO_VOTE         = "Aún no has valorado a %s.",
    VOTE_DELETED    = "%s: tu voto se ha borrado.",
    STARS_RANGE     = "Da entre 0,5 y 5 estrellas, en medias estrellas.",
    RATED           = "%s: %s %s. Nueva puntuación: %s",
    DECIMAL         = ",",
    PET_DISPLAY     = "%s (mascota de %s)",
    GUILD_LABEL     = "Hermandad",
    SYNC_REQUESTED  = "Sincronización solicitada: los votos de tu hermandad, tu grupo y tus amigos llegarán enseguida.",
    MIN_SET         = "Las puntuaciones se muestran ahora a partir de %d votos.",
    TOOLTIP_ERROR   = "Error de descripción emergente (se muestra una vez, avísanos en GitHub):",
    MENU_RATE       = "Valorar nombre",
    MENU_RATE_GUILD = "Valorar hermandad",

    HELP_HEADER     = "Comandos:",
    HELP_OPEN       = "/ns – abrir la ventana de valoración para tu objetivo (jugador o mascota)",
    HELP_RATE       = "/ns <0,5-5> [gracioso épico creativo ingenioso lore clásico cringe] – valorar a tu objetivo directamente",
    HELP_GUILD      = "/ns guild – valorar la hermandad de tu objetivo",
    HELP_DELETE     = "/ns delete [guild] – borrar tu voto para tu objetivo (o su hermandad)",
    HELP_CHECK      = "/ns check <nombre> – ver la puntuación de un jugador",
    HELP_HALL       = "/ns top – abrir el salón de la fama",
    HELP_ME         = "/ns yo – lo que los demás opinan de tu nombre, tu hermandad y tus mascotas",
    HELP_OPTIONS    = "/ns options – abrir los ajustes",
    HELP_MINIMAP    = "/ns minimap – mostrar/ocultar el botón del minimapa",
    HELP_SYNC       = "/ns sync – pedir los votos de tu hermandad, tu grupo y tus amigos conectados",

    HALL_TITLE      = "NameScore – Salón de la fama",
    TAB_TOP         = "Top",
    TAB_FLOP        = "Flop",
    TAB_MINE        = "Mis votos",
    TAB_ME          = "Yo",
    HALL_EMPTY      = "Todavía no hay nada.",
    HALL_FOOTER     = "Solo nombres con al menos %d votos · %d votos conocidos",
    HALL_FOOTER_MINE = "Haz clic en un nombre para cambiar tu voto",

    ME_TITLE        = "Lo que los demás opinan de ti:",
    ME_PET          = "Tu mascota %s",
    ME_FOOTER       = "Cuenta los votos de todos con los que te has sincronizado",

    OPT_BADGE       = "Mostrar puntuación en las descripciones",
    OPT_BADGE_TIP   = "Muestra la insignia de NameScore al pasar el ratón por jugadores y mascotas, y la puntuación de la hermandad junto a su nombre.",
    OPT_OWN         = "Mostrar tu propio voto",
    OPT_OWN_TIP     = "Muestra tus propias estrellas en la descripción para ver a quién ya has valorado.",
    OPT_SIZE        = "Tamaño de la insignia",
    OPT_SIZE_TIP    = "Tamaño de la insignia de NameScore en la descripción. Pequeño muestra solo una línea de texto.",
    SIZE_SMALL      = "Pequeño (una línea)",
    SIZE_NORMAL     = "Normal",
    SIZE_LARGE      = "Grande",
    SIZE_SET        = "Tamaño de la insignia: %s",
    HELP_SIZE       = "/ns tamaño pequeño|normal|grande – tamaño de la insignia",
    OPT_MIN         = "Votos necesarios para una puntuación",
    OPT_MIN_TIP     = "La puntuación y el rango solo aparecen a partir de este número de votos. Más justo, porque un solo voto no decide.",
    OPT_ELVUI       = "Estilo ElvUI / EllesmereUI",
    OPT_ELVUI_TIP   = "Usa el aspecto de ElvUI o EllesmereUI para las ventanas de NameScore si uno de ellos está instalado. Se aplica tras /reload.",
    OPT_MINIMAP     = "Botón del minimapa",
    OPT_MINIMAP_TIP = "Muestra el botón de NameScore en el minimapa. Clic izquierdo: salón de la fama, clic derecho: ajustes.",
    MM_LEFT         = "Clic izquierdo: salón de la fama",
    MM_RIGHT        = "Clic derecho: ajustes",
    MM_VOTES        = "%d votos conocidos",

    USERS_RESULT    = "%d de %d miembros conectados de la hermandad usan NameScore",
    USERS_RESULT_NOTOTAL = "%d miembros conectados de la hermandad usan NameScore",
    USERS_OLDER     = " (%d de ellos con una versión anterior)",
    USERS_NO_GUILD  = "No estás en ninguna hermandad.",
    USERS_COUNTING  = "Contando usuarios de NameScore en tu hermandad…",
    HELP_USERS      = "/ns users – cuántos miembros conectados de la hermandad usan NameScore (solo el número, sin nombres)",
    UPDATE_AVAILABLE = "Hay una versión más reciente de NameScore (%s, tienes %s). Actualízala con la aplicación de CurseForge o Wago.",
    MM_UPDATE       = "Actualización disponible: %s",
    HELP_FRIENDS    = "/ns amigos – sincronizar con amigos conectados sí/no",
    OPT_FRIENDS     = "Sincronizar con amigos",
    OPT_FRIENDS_TIP = "También intercambia votos de forma invisible con los amigos conectados de tu lista de amigos que usan NameScore, aunque estén en otra hermandad. No se guarda nada sobre tus amigos.",
    MM_FRIENDS      = "%d amigos conectados usan NameScore",
    TAB_JUDGES      = "Jueces",
    JUDGE_RANKUP    = "Nuevo rango de juez: %s – ¡%d nombres valorados!",
    JUDGE_YOU       = "Tu rango de juez: %s – %d nombres valorados",
    JUDGE_NONE      = "Aún sin rango de juez – ¡valora tu primer nombre!",
    JUDGE_NEXT      = "%d más para %s",
    JUDGE_MAX       = "Rango máximo alcanzado – los nombres te temen.",
    JUDGE_TITLE     = "Los mejores jueces:",
    JUDGE_COUNT     = "%d nombres valorados",
    JUDGE_FOOTER    = "Nombres valorados por jugador · %s",
    MM_JUDGE        = "Rango de juez: %s",
    HELP_JUDGES     = "/ns jueces – tu rango de juez y los mejores jueces",
    OPT_JUDGES      = "Aparecer en la lista de jueces",
    OPT_JUDGES_TIP  = "Comparte cuántos nombres has valorado, para aparecer en la lista de jueces de los demás. Desactivado, desapareces de sus listas.",
    OPT_JUDGE_TT    = "Rango de juez en el tooltip",
    OPT_JUDGE_TT_TIP = "Muestra el rango de juez de los jugadores en su tooltip.",
    JUDGE_H = {
        "Explorador de nombres", -- 1
        "Bruto de la gramática", -- 5
        "Sargento de sílabas", -- 10
        "Sargento mayor de la ortografía", -- 20
        "Brigada de los apellidos", -- 30
        "Guardia de piedra de los apodos", -- 40
        "Guardia de sangre de los juegos de palabras", -- 50
        "Legionario de las letras", -- 75
        "Centurión de las consonantes", -- 100
        "Campeón de los nombres", -- 150
        "Teniente general del lore", -- 200
        "General de la nomenclatura", -- 250
        "Señor de la guerra del ingenio", -- 500
        "Gran señor de la guerra de los nombres", -- 1000
    },
    JUDGE_A = {
        "Soldado de los seudónimos", -- 1
        "Cabo del alfabeto", -- 5
        "Sargento de sílabas", -- 10
        "Sargento maestro de la ortografía", -- 20
        "Sargento mayor de los apellidos", -- 30
        "Caballero de los apodos", -- 40
        "Caballero teniente de los juegos de palabras", -- 50
        "Caballero capitán de las letras", -- 75
        "Caballero campeón de las consonantes", -- 100
        "Teniente coronel de los nombres", -- 150
        "Comandante del lore", -- 200
        "Mariscal de la nomenclatura", -- 250
        "Mariscal de campo del ingenio", -- 500
        "Gran mariscal de los nombres", -- 1000
    },
    BIND_RATE       = "Valorar objetivo",
    BIND_HALL       = "Abrir/cerrar salón de la fama",

    TAG_lustig      = "Gracioso",
    TAG_episch      = "Épico",
    TAG_kreativ     = "Creativo",
    TAG_wortspiel   = "Ingenioso",
    TAG_lore        = "Lore",
    TAG_klassiker   = "Clásico",
    TAG_cute        = "Adorable",
    OPTED_OUT_TT    = "no quiere que lo valoren",
    OPTED_OUT_RATE  = "%s no quiere que lo valoren.",
    OPTOUT_ON       = "Ya no se te puede valorar. Todos con NameScore 0.5 o más reciente ocultan tu puntuación y no aceptan nuevas valoraciones. Los votos existentes se conservan y vuelven con /ns optin.",
    OPTOUT_OFF      = "Se te puede volver a valorar.",
    ME_OPTED_OUT    = "no quieres que te valoren",
    HELP_OPTOUT     = "/ns optout – no dejar que te valoren (ni a tus mascotas) · /ns optin – volver a permitirlo",
    OPTOUT_ALREADY  = "Ya no se te puede valorar. Escribe /ns optin para volver a permitirlo.",
    OPTIN_ALREADY   = "Ya se te puede valorar. Escribe /ns optout para desactivarlo.",
    OPT_OPTOUT      = "No valorarme",
    OPT_OPTOUT_TIP  = "Los demás con NameScore 0.5 o más reciente ocultan tu puntuación y la de tus mascotas y no aceptan nuevas valoraciones. Los votos existentes se conservan y vuelven cuando permitas de nuevo las valoraciones. Tu hermandad no se ve afectada.",
    TAG_cringe      = "Cringe",

    RANK_LEGENDARY  = "Legendario",
    RANK_EPIC       = "Épico",
    RANK_RARE       = "Raro",
    RANK_UNCOMMON   = "Poco común",
    RANK_COMMON     = "Común",
    RANK_POOR       = "Pobre",
}
LOCALES.esMX = LOCALES.esES

local override = LOCALES[GetLocale()]
if override then
    for k, v in pairs(override) do L[k] = v end
end

-- Names in the key bindings menu (Bindings.xml)
BINDING_HEADER_NAMESCORE = "NameScore"
BINDING_NAME_NAMESCORE_RATE = L.BIND_RATE
BINDING_NAME_NAMESCORE_HALL = L.BIND_HALL

ns.L = L
ns.LOCALES = LOCALES
