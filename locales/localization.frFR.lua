--[[
	CensusPlus for World of Warcraft(tm).
	
	Copyright 2005 - 2016 Cooper Sellers and WarcraftRealms.com

	License:
		This program is free software; you can redistribute it and/or
		modify it under the terms of the GNU General Public License
		as published by the Free Software Foundation; either version 2
		of the License, or (at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program(see GLP.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
]]
-- initial translations provided by Matisk@curseforge, updated translations by jey013@curseforge,  many phrases need review
-- more updated translations provided by Dabeuliou@curseforge
-- latest translations provided by Matisk@curseforge

if ( GetLocale() == "frFR" ) then

CENSUS_BUTTON_TOOLTIP = "Ouvrir CensusPlus"

CENSUS_OPTIONS_AUTOCENSUS = "Recensement automatique"

CENSUS_OPTIONS_AUTOSTART = "Démarrage automatique"

CENSUS_OPTIONS_BACKGROUND_TRANSPARENCY_TOOLTIP = "Transparence du fond - dix niveaux"

CENSUS_OPTIONS_BUTSHOW = "Afficher le bouton Census sur la mini-carte"

CENSUS_OPTIONS_CCO_REMOVE_OVERRIDE = "Enlever le remplacement"

CENSUS_OPTIONS_LOG_BARS = "Histogramme logarithmique des niveaux"

CENSUS_OPTIONS_LOG_BARSTEXT = "Active la graduation logarithmique des histogrammes"

CENSUS_OPTIONS_SOUNDFILE = "Sélectionner le numéro du fichier de son fourni par l'utilisateur"

CENSUS_OPTIONS_SOUNDFILETEXT = "Sélectionner le fichier son .mp3 ou .OGG désiré"

CENSUS_OPTIONS_SOUND_ON_COMPLETE = "Bip sonore à la fin"

CENSUS_OPTIONS_SOUND_TOOLTIP = "Activer le son puis sélectionner le fichier de son"

CENSUS_OPTIONS_STEALTH = "Furtivité"

CENSUS_OPTIONS_STEALTH_TOOLTIP = "Mode furtif - pas de messages chat, désactive la verbosité"

CENSUS_OPTIONS_TIMER_TOOLTIP = "Définit, en minutes, le délai entre deux recensements"

CENSUS_OPTIONS_VERBOSE = "Verbeux"

CENSUS_OPTIONS_VERBOSE_TOOLTIP = "Active le texte verbeux dans la fenêtre de chat, désactive le mode furtif"

CENSUSPLUS_ACCOUNT_WIDE = "Sur tout le compte"

CENSUSPLUS_ACCOUNT_WIDE_ONLY_OPTIONS = "Options réservées au seul compte"

CENSUSPLUS_AND = " et"

CENSUSPLUS_APANDAREN = "Pandaren"

CENSUSPLUS_AUTOCENSUS_DELAYTIME = "Délai en minutes"

CENSUSPLUS_AUTOCENSUSOFF = "Mode auto-recensement : DÉSACTIVÉ"

CENSUSPLUS_AUTOCENSUSON = "Mode auto-recensement : ACTIVÉ"

CENSUSPLUS_AUTOCENSUSTEXT = "Démarrer le recensement après le délai initial"

CENSUSPLUS_AUTOCLOSEWHO = "Fermeture automatique du /qui"

CENSUSPLUS_AUTOSTARTTEXT = "Démarrage automatique à la connexion lorsque le minuteur est inférieur à "

CENSUSPLUS_BADLOCAL_1 = "Vous semblez avoir une version US de Census, pourtant votre localisation est réglé sur Français ou Allemand ou Italien."

CENSUSPLUS_BADLOCAL_2 = "Merci de ne pas téléverser de données sur WarcraftRealms jusqu'à ce que ce soit possible."

CENSUSPLUS_BADLOCAL_3 = "Si c'est incorrect, merci d'informer Bringoutyourdead sur www.WarcraftRealms.com de votre problème afin qu'il puisse apporter des corrections."

CENSUSPLUS_BLOODELF = "Elfe de sang"

CENSUSPLUS_BUTTON_CHARACTERS = "Afficher Persos"

CENSUSPLUS_BUTTON_OPTIONS = "Options"

CENSUSPLUS_CCO_OPTIONOVERRIDES = "Remplacements d'options pour ce personnage seulement"

CENSUSPLUS_CENSUSBUTTONANIMIOFF = "Animation du bouton Census : DÉSACTIVÉ"

CENSUSPLUS_CENSUSBUTTONANIMION = "Animation du bouton Census : ACTIVÉ"

CENSUSPLUS_CENSUSBUTTONANIMITEXT = "Animation du bouton Census"

CENSUSPLUS_CENSUSBUTTONSHOWNOFF = "Affichage du bouton Census : DÉSACTIVÉ"

CENSUSPLUS_CENSUSBUTTONSHOWNON = "Affichage du bouton Census : ACTIVÉ"

CENSUSPLUS_CHARACTERS = "Personnages"

CENSUSPLUS_CLASS = "Classes"

CENSUSPLUS_CMDERR_WHO2 = "Les requêtes /qui devraient s'écrire : /qui nom niveau _ pas de nom trouvé, le niveau est optionnel "

CENSUSPLUS_CMDERR_WHO2NUM = "Les requêtes /qui peuvent s'écrire : /qui nom (pas de nombre dans le nom)"

CENSUSPLUS_CONNECTED = "Connecté :"

CENSUSPLUS_CONNECTED2 = "Connexions additionnelles :"

CENSUSPLUS_CONNECTEDREALMSFOUND = "CensusPlus a trouvé les royaumes interconnectés suivants"

CENSUSPLUS_CONSECUTIVE = "Recensement consécutif :"

CENSUSPLUS_DARKIRON = "Nain sombrefer"

CENSUSPLUS_DEATHKNIGHT = "Chevalier de la mort"

CENSUSPLUS_DEMONHUNTER = "Chasseur de démons"

CENSUSPLUS_DRAENEI = "Draeneï"

CENSUSPLUS_DRUID = "Druide"

CENSUSPLUS_DWARF = "Nain"

CENSUSPLUS_EU_LOCALE = "Choisissez si vous jouez sur des serveurs EURO"

CENSUSPLUS_FACTION = "Faction : %s"

CENSUSPLUS_FACTIONUNKNOWN = "Faction : Inconnue"

CENSUSPLUS_FINISHED = "Recensement terminé. %s nouveaux personnages trouvés et %s analysés. Temps écoulé : %s."

CENSUSPLUS_FOUND = "trouvé"

CENSUSPLUS_FOUND_CAP = "Trouvé(s)"

CENSUSPLUS_GETGUILD = [=[Cliquer sur le royaume pour 
obtenir ses données de guildes.]=]

CENSUSPLUS_GNOME = "Gnome"

CENSUSPLUS_GOBLIN = "Gobelin"

CENSUSPLUS_GUILDREALM = "Royaume de la guilde"

CENSUSPLUS_HELP_0 = "commande suivante comme indiquée ci-dessous"

CENSUSPLUS_HELP_1 = "_ Activer/désactiver le mode verbeux "

CENSUSPLUS_HELP_10 = "_ Fait une mise à jour du recensement du joueur uniquement. C'est fait automatiquement quand l'analyse /CensusPlus se termine."

CENSUSPLUS_HELP_11 = " _ Active/désactive le mode furtif - désactive le verbeux et tous les messages chat de CensusPlus"

CENSUSPLUS_HELP_2 = "_ Affiche la fenêtre d'options"

CENSUSPLUS_HELP_3 = "_ Démarrer un instantané de recensement "

CENSUSPLUS_HELP_4 = "_ Arrêter l'instantané de recensement "

CENSUSPLUS_HELP_5 = " X  _ Purger la base de données en supprimant les personnages pas vus dans les X derniers jours (par défaut X = 30)"

CENSUSPLUS_HELP_6 = " X _ Purger la base de données en supprimant tous les personnages pas vus dans les X derniers jours des serveurs différents de celui sur lequel vous êtes actuellement (par défaut X = 0)"

CENSUSPLUS_HELP_7 = " _  Affichera des informations sur les noms correspondants."

CENSUSPLUS_HELP_8 = " _  Listera les personnages sans guilde de ce niveau."

CENSUSPLUS_HELP_9 = " _  Réglera le minuteur de recensement automatique (à X minutes)"

CENSUSPLUS_HIGHMOUNTAIN = "Tauren de Haut-Roc"

CENSUSPLUS_HPANDAREN = "Pandaren"

CENSUSPLUS_HUMAN = "Humain"

CENSUSPLUS_HUNTER = "Chasseur"

CENSUSPLUS_ISINBG = "Vous êtes actuellement en champ de bataille, le recensement ne peut être réalisé."

CENSUSPLUS_ISINPROGRESS = "Recensement en cours, recommencez plus tard."

CENSUSPLUS_KULTIRAN			= "Kultirassien"

CENSUSPLUS_LANGUAGECHANGED = "Langue du client changée, base de données purgée."

CENSUSPLUS_LASTSEEN = "Vu pour la dernière fois"

CENSUSPLUS_LASTSEEN_COLON = " Vu pour la dernière fois :"

CENSUSPLUS_LEVEL = "Niveaux"

CENSUSPLUS_LIGHTFORGED = "Draeneï sancteforge"

CENSUSPLUS_LOCALE = "Région : %s"

CENSUSPLUS_LOCALE_SELECT = "Choisissez si vous jouez sur des serveurs US ou EURO"

CENSUSPLUS_LOCALEUNKNOWN = "Région : Inconnue"

CENSUSPLUS_MAGE = "Mage"

CENSUSPLUS_MAGHAR = "Orc mag’har"

CENSUSPLUS_MAXXED = "AU MAXIMUM !"
CENSUSPLUS_MECHAGNOME = "Mécagnome"

CENSUSPLUS_MONK = "Moine"

CENSUSPLUS_MSG1 = " Chargé - Tapez /censusplus ou /census+ ou /census pour afficher les commandes valides"

CENSUSPLUS_NIGHTBORNE = "Sacrenuit"

CENSUSPLUS_NIGHTELF = "Elfe de la nuit"

CENSUSPLUS_NOCENSUS = "Aucun recensement en cours"

CENSUSPLUS_NOTINFACTION = "Faction neutre - recensement non autorisé"

CENSUSPLUS_NOW = " maintenant"

CENSUSPLUS_OBSOLETEDATAFORMATTEXT = "Ancien format de base de données trouvé, base de donnée purgée. "

CENSUSPLUS_OPTIONS_CHATTYCONFIRM = "Confirmation d'option de bavardage - cocher pour activer"

CENSUSPLUS_OPTIONS_CHATTY_TOOLTIP = "Activer le chat pour afficher les paramètres actuels des options - apparaît lors de l'ouverture de la fenêtre des options d'interface et des nombreux changements d'options CensusPlus"

CENSUSPLUS_OPTIONS_HEADER = "Options Census+"

CENSUSPLUS_OPTIONS_OVERRIDE = "Remplacer"

CENSUSPLUS_OR = " ou"

CENSUSPLUS_ORC = "Orc"

CENSUSPLUS_PALADIN = "Paladin"

CENSUSPLUS_PAUSE = "Suspendre"

CENSUSPLUS_PAUSECENSUS = "Suspendre le recensement en cours"

CENSUSPLUS_PLAYERS = " joueurs."

CENSUSPLUS_PLAYFINISHSOUNDNUM = "Numéro du son de fin"

CENSUSPLUS_PLAYFINISHSOUNDOFF = "Jouer un son à la fin : DÉSACTIVÉ"

CENSUSPLUS_PLAYFINISHSOUNDON = "Jouer un son à la fin : ACTIVÉ"

CENSUSPLUS_PRIEST = "Prêtre"

CENSUSPLUS_PROBLEMNAME = "Ce nom pose problème => "

CENSUSPLUS_PROBLEMNAME_ACTION = ", nom passé. Ce message n'apparaîtra qu'une fois."

CENSUSPLUS_PROCESSING = "Analyse de %s personnages."

CENSUSPLUS_PRUNE = "Nettoyer"

CENSUSPLUS_PRUNECENSUS = "Nettoyer la base de données en supprimant les personnages non détectés dans les 30 derniers jours."

CENSUSPLUS_PRUNEINFO = "%d personnages supprimés."

CENSUSPLUS_PURGE = "Purger"

CENSUSPLUS_PURGEDALL = "Toutes les données de recensement ont été purgées."

CENSUSPLUS_PURGEDATABASE = "Effacer toute la base de données."

CENSUSPLUS_PURGE_LOCAL_CONFIRM = "Êtes-vous certain de vouloir EFFACER la base de données locale ?"

CENSUSPLUS_PURGEMSG = "Base de données effacée."

CENSUSPLUS_RACE = "Races"

CENSUSPLUS_REALM = "Royaume"

CENSUSPLUS_REALMNAME = "Royaume : "

CENSUSPLUS_REALMUNKNOWN = "Royaume : Inconnu"

CENSUSPLUS_ROGUE = "Voleur"

CENSUSPLUS_SCAN_PROGRESS = "Analyse en cours : %d requêtes dans la file d'attente - %s"

CENSUSPLUS_SCAN_PROGRESS_0 = "Pas d'analyse en cours"

CENSUSPLUS_SENDING = "Envoi de requête /qui %s"

CENSUSPLUS_SHAMAN = "Chaman"

CENSUSPLUS_STEALTHOFF = "Mode furtif : DÉSACTIVÉ"

CENSUSPLUS_STEALTHON = "Mode furtif : ACTIVÉ"

CENSUSPLUS_STOP = "Arrêter"

CENSUSPLUS_STOPCENSUS_TOOLTIP = "Arrêter le recensement CensusPlus en cours"

CENSUSPLUS_TAKE = "Recenser"

CENSUSPLUS_TAKECENSUS = [=[Faire un recensement des personnages
actuellement en ligne sur ce serveur
et dans cette faction]=]

CENSUSPLUS_TAKINGONLINE = "Recensement des personnages en ligne..."

CENSUSPLUS_TAUREN = "Tauren"

CENSUSPLUS_TEXT = "Census+"

CENSUSPLUS_TOOMANY = "ATTENTION : Trop de joueurs correspondent à : %s"

CENSUSPLUS_TOOSLOW = "Mise à jour trop lente ! Ordinateur surchargé ? Problèmes de connexion ?"

CENSUSPLUS_TOPGUILD = "Meilleures guildes par XP"

CENSUSPLUS_TOTALCHAR = "Nombre total de personnages : %d"

CENSUSPLUS_TOTALCHAR_0 = "Nombre total de personnages : 0"

CENSUSPLUS_TOTALCHARXP = "Facteur XP : %d"

CENSUSPLUS_TOTALCHARXP_0 = "Facteur XP : 0"

CENSUSPLUS_TRANSPARENCY = "Transparence de la fenêtre de recensement"

CENSUSPLUS_TROLL = "Troll"

CENSUSPLUS_UNDEAD = "Mort-vivant"

CENSUSPLUS_UNGUILDED = "(Sans guilde)"

CENSUSPLUS_UNKNOWNRACE = "Race inconnue trouvée ( "

CENSUSPLUS_UNKNOWNRACE_ACTION = " ), merci d'en informer Bringoutyourdead sur WarcraftRealms.com"

CENSUSPLUS_UNPAUSE = "Reprendre"

CENSUSPLUS_UNPAUSECENSUS = "Reprendre le recensement en cours"

CENSUSPLUS_UPLOAD = "Assurez-vous de téléverser vos données CensusPlus sur www.WarcraftRealms.com !"

CENSUSPLUS_USAGE = "Utilisation :"

CENSUSPLUS_USING_WHOLIB = "Utilisation de WhoLib"

CENSUSPLUS_US_LOCALE = "Choisissez si vous jouez sur des serveurs US"

CENSUSPLUS_VERBOSEOFF = "Mode verbeux : DÉSACTIVÉ"

CENSUSPLUS_VERBOSEON = "Mode verbeux : ACTIVÉ"

CENSUSPLUS_VERBOSE_TOOLTIP = "Désactiver pour arrêter le flood !"

CENSUSPLUS_VOIDELF = "Elfe du Vide"
CENSUSPLUS_VULPERA = "Vulpérin"
CENSUSPLUS_WAITING = "En attente pour le lancement de requêtes /qui..."

CENSUSPLUS_WARLOCK = "Démoniste"

CENSUSPLUS_WARRIOR = "Guerrier"

CENSUSPLUS_WAS = " était"

CENSUSPLUS_WHOQUERY = "Requête /qui : "

CENSUSPLUS_WORGEN = "Worgen"

CENSUSPLUS_WRONGLOCAL_PURGE = "La région courante diffère de la configuration précédente, purge de la base de données réalisée."
CENSUSPLUS_ZANDALARI		= "Troll zandalari";

end