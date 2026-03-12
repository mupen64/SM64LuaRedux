--
-- Copyright (c) 2025, Mupen64 maintainers.
--
-- SPDX-License-Identifier: GPL-2.0-or-later
--

---@type Locale
return {
    name = 'Français (FR)',
    -- General
    GENERIC_ON = 'Activé',
    GENERIC_OFF = 'Désactivé',
    GENERIC_START = 'Démarrer',
    GENERIC_STOP = 'Arrêter',
    GENERIC_RESET = 'Effacer',
    GENERIC_NIL = 'nil',
    -- Tab names
    TAS_TAB_NAME = 'TAS',
    SEMANTIC_WORKFLOW_TAB_NAME = 'Flux Sémantique',
    SETTINGS_TAB_NAME = 'Paramètres',
    TOOLS_TAB_NAME = 'Outils',
    TIMER_TAB_NAME = 'Chronomètre',
    PRESET = 'Préréglage ',
    -- Preset Context Menu
    PRESET_CONTEXT_MENU_DELETE_ALL = 'Tout supprimer',
    -- TAS Tab
    DISABLED = 'Désactivé',
    MATCH_YAW = 'Correspondre Yaw',
    REVERSE_YAW = 'Inverser Yaw',
    MATCH_ANGLE = 'Angle',
    D99_ALWAYS = 'Toujours',
    D99 = '.99',
    DYAW = 'Relatif',
    ATAN_STRAIN = 'Arctan strain',
    ATAN_STRAIN_REV = 'I',
    MAG_RESET = 'Vider',
    MAG_HI = 'Élevé',
    SPDKICK = 'Spdkick',
    FRAMEWALK = 'Framewalk',
    SWIM = 'Nager',
    -- Semantic Workflow Tab
    SEMANTIC_WORKFLOW_PROJECT_TAB_NAME = 'Projet',
    SEMANTIC_WORKFLOW_INPUTS_TAB_NAME = 'Saisies',
    SEMANTIC_WORKFLOW_PREFERENCES_TAB_NAME = 'Préférences',
    SEMANTIC_WORKFLOW_DUPLICATE_SHEET = 'CP',
    YES = 'Oui',
    NO = 'Non',
    SEMANTIC_WORKFLOW_HELP_HEADER_TITLE = 'Aide Flux Sémantique',
    SEMANTIC_WORKFLOW_HELP_SHOW_TOOL_TIP = 'Afficher l\'aide',
    SEMANTIC_WORKFLOW_HELP_EXIT_TOOL_TIP = 'Quitter',
    SEMANTIC_WORKFLOW_HELP_PREV_PAGE = 'précédent',
    SEMANTIC_WORKFLOW_HELP_NEXT_PAGE = 'suivant',
    SEMANTIC_WORKFLOW_SHEET_NO_SELECTED = 'Aucune feuille de flux sémantique sélectionnée.\nSélectionnez-en une pour continuer.',
    SEMANTIC_WORKFLOW_SHEET_DELETE_CONFIRMATION =
    '[Confirmer la suppression]\n\nÊtes-vous sûr de vouloir supprimer "%s" ?\nCette action est irréversible.',
    SEMANTIC_WORKFLOW_FRAMELIST_START = 'Début : ',
    SEMANTIC_WORKFLOW_FRAMELIST_NAME = 'Nom',
    SEMANTIC_WORKFLOW_FRAMELIST_SECTION = '#Section',
    SEMANTIC_WORKFLOW_FRAMELIST_STICK = 'manette',
    SEMANTIC_WORKFLOW_FRAMELIST_UNTIL = 'Jusqu\'à',
    SEMANTIC_WORKFLOW_TOOL_COPY_ENTIRE_STATE = 'Copier l\'état entier',
    SEMANTIC_WORKFLOW_CONTROL_MANUAL = 'Manuel',
    SEMANTIC_WORKFLOW_CONTROL_MATCH_YAW = 'Yaw',
    SEMANTIC_WORKFLOW_CONTROL_MATCH_ANGLE = 'Angle',
    SEMANTIC_WORKFLOW_CONTROL_REVERSE_YAW = 'Basculer',
    SEMANTIC_WORKFLOW_CONTROL_DYAW = 'DYaw',
    SEMANTIC_WORKFLOW_CONTROL_ATAN_RETIME = 'calculer...',
    SEMANTIC_WORKFLOW_CONTROL_ATAN_SELECT_START = 'Sélectionner début...',
    SEMANTIC_WORKFLOW_CONTROL_ATAN_SELECT_END = 'Sélectionner fin...',
    SEMANTIC_WORKFLOW_CONTROL_ATAN = 'Activer',
    SEMANTIC_WORKFLOW_CONTROL_ATAN_REVERSE = 'Basculer',
    SEMANTIC_WORKFLOW_CONTROL_HIGH_MAG = 'Mag.Haut',
    SEMANTIC_WORKFLOW_CONTROL_SPDKICK = 'Spdk',
    SEMANTIC_WORKFLOW_PROJECT_FILE_VERSION = 'Version fichier : ',
    SEMANTIC_WORKFLOW_PROJECT_NO_SHEETS_AVAILABLE = 'Aucune feuille de flux sémantique disponible.\nCréez-en une pour continuer.',
    SEMANTIC_WORKFLOW_PROJECT_NEW = 'Nouveau',
    SEMANTIC_WORKFLOW_PROJECT_NEW_TOOL_TIP = 'Créer un nouveau projet dans un nouvel emplacement',
    SEMANTIC_WORKFLOW_PROJECT_OPEN = 'Ouvrir',
    SEMANTIC_WORKFLOW_PROJECT_OPEN_TOOL_TIP = 'Ouvrir un projet existant',
    SEMANTIC_WORKFLOW_PROJECT_SAVE = 'Sauver',
    SEMANTIC_WORKFLOW_PROJECT_SAVE_TOOL_TIP = 'Sauvegarder le projet actuel (sans confirmation !)',
    SEMANTIC_WORKFLOW_PROJECT_PURGE = 'Purger',
    SEMANTIC_WORKFLOW_PROJECT_PURGE_TOOL_TIP = 'Supprimer les fichiers n\'appartenant pas à ce projet',
    SEMANTIC_WORKFLOW_PROJECT_CONFIRM_PURGE =
    [[
[Confirmer la purge du projet]

Êtes-vous sûr de vouloir purger les feuilles inutilisées du répertoire du projet ?
Les fichiers non liés (ne se terminant pas par .sws ou .sws.savestate) ne seront pas touchés.
Cette action est irréversible.
]],
    SEMANTIC_WORKFLOW_PROJECT_CONFIRM_SHEET_DELETION_1 = '[Confirmer la suppression]\n\nÊtes-vous sûr de vouloir supprimer "',
    SEMANTIC_WORKFLOW_PROJECT_CONFIRM_SHEET_DELETION_2 = '" ?\nCette action est irréversible.',
    SEMANTIC_WORKFLOW_PROJECT_DISABLE_TOOL_TIP = 'Désélectionner la feuille',
    SEMANTIC_WORKFLOW_PROJECT_SELECT_TOOL_TIP = 'Sélectionner et exécuter la feuille',
    SEMANTIC_WORKFLOW_PROJECT_ADD_SHEET = 'Aj. feuille',
    SEMANTIC_WORKFLOW_PROJECT_REBASE_SHEET_TOOL_TIP = 'Définir le début maintenant',
    SEMANTIC_WORKFLOW_PROJECT_BASE_SHEET_TOOL_TIP = 'Cette feuille est basée sur ',
    SEMANTIC_WORKFLOW_PROJECT_NO_BASE_SHEET_TOOL_TIP = 'Cette feuille n\'est pas basée sur une autre feuille.',
    SEMANTIC_WORKFLOW_PROJECT_SET_BASE_SHEET_TOOL_TIP = 'Définir comme feuille de base pour ',
    SEMANTIC_WORKFLOW_PROJECT_REPLACE_INPUTS_TOOL_TIP = 'Remplacer les saisies par celles de la frame active',
    SEMANTIC_WORKFLOW_PROJECT_PLAY_WITHOUT_ST_TOOL_TIP = 'Jouer sans charger .st',
    SEMANTIC_WORKFLOW_PROJECT_DELETE_SHEET_TOOL_TIP = 'Supprimer',
    SEMANTIC_WORKFLOW_PROJECT_ADD_SHEET_TOOL_TIP = 'Ajouter',
    SEMANTIC_WORKFLOW_PROJECT_MOVE_SHEET_UP_TOOL_TIP = 'Monter',
    SEMANTIC_WORKFLOW_PROJECT_MOVE_SHEET_DOWN_TOOL_TIP = 'Descendre',
    SEMANTIC_WORKFLOW_INPUTS_EXPAND_SECTION = 'Développer',
    SEMANTIC_WORKFLOW_INPUTS_COLLAPSE_SECTION = 'Réduire',
    SEMANTIC_WORKFLOW_INPUTS_INSERT_SECTION = '+Partie',
    SEMANTIC_WORKFLOW_INPUTS_INSERT_SECTION_TOOL_TIP = 'Insérer une section après la sélection',
    SEMANTIC_WORKFLOW_INPUTS_DELETE_SECTION = '-Partie',
    SEMANTIC_WORKFLOW_INPUTS_DELETE_SECTION_TOOL_TIP = 'Supprimer la section sélectionnée',
    SEMANTIC_WORKFLOW_INPUTS_TIMEOUT = 'Délai :',
    SEMANTIC_WORKFLOW_INPUTS_TIMEOUT_TOOL_TIP = 'Terminer la section après N frames maximum',
    SEMANTIC_WORKFLOW_INPUTS_END_ACTION = 'Action de fin :',
    SEMANTIC_WORKFLOW_INPUTS_END_ACTION_TOOL_TIP = 'Terminer la section quand Mario entre dans cette action',
    SEMANTIC_WORKFLOW_INPUTS_END_ACTION_TYPE_TO_SEARCH_TOOL_TIP = 'Taper pour filtrer les actions',
    SEMANTIC_WORKFLOW_INPUTS_INSERT_INPUT = '+Taper',
    SEMANTIC_WORKFLOW_INPUTS_INSERT_INPUT_TOOL_TIP = 'Insérer une frame après la sélection',
    SEMANTIC_WORKFLOW_INPUTS_DELETE_INPUT = '-Taper',
    SEMANTIC_WORKFLOW_INPUTS_DELETE_INPUT_TOOL_TIP = 'Supprimer la frame sélectionnée',
    SEMANTIC_WORKFLOW_PREFERENCES_EDIT_ENTIRE_STATE = 'Modifier l\'état entier',
    SEMANTIC_WORKFLOW_PREFERENCES_FAST_FORWARD = 'Avance rapide',
    SEMANTIC_WORKFLOW_PREFERENCES_DEFAULT_SECTION_TIMEOUT = 'Délai de section par défaut :',
    -- Settings Tab
    SETTINGS_VISUALS_TAB_NAME = 'Visuels',
    SETTINGS_INTERACTION_TAB_NAME = 'Interaction',
    SETTINGS_VARWATCH_TAB_NAME = 'Varwatch',
    SETTINGS_MEMORY_TAB_NAME = 'Mémoire',
    SETTINGS_VISUALS_STYLE = 'Style',
    SETTINGS_VISUALS_LOCALE = 'Langue',
    SETTINGS_VISUALS_NOTIFICATIONS = 'Notifications',
    SETTINGS_VISUALS_NOTIFICATIONS_BUBBLE = 'Bulle',
    SETTINGS_VISUALS_NOTIFICATIONS_CONSOLE = 'Console',
    SETTINGS_VISUALS_NOTIFICATIONS_TOOLTIP = 'Le style utilisé pour les notifications.\n    Bulle : afficher les notifications au-dessus du jeu.\n    Console : afficher les notifications dans la console Lua.',
    SETTINGS_VISUALS_FF_FPS = 'FPS en avance rapide',
    SETTINGS_VISUALS_FF_FPS_TOOLTIP = 'Les FPS lors de l\'avance rapide. Diminuer pour améliorer les performances.',
    SETTINGS_VISUALS_UPDATE_EVERY_VI = 'Mettre à jour chaque VI',
    SETTINGS_VISUALS_UPDATE_EVERY_VI_TOOLTIP =
    'Met à jour l\'UI chaque VI, améliorant la synchronisation de capture mupen. Réduit les performances.',
    SETTINGS_INTERACTION_MANUAL_ON_JOYSTICK_INTERACT = "Interaction joystick",
    SETTINGS_INTERACTION_LOCK_HOTKEYS_WHEN_CONTROL_ACTIVE = "Verrouiller les raccourcis quand un contrôle est actif",
    SETTINGS_VARWATCH_DISABLED = '(désactivé)',
    SETTINGS_VARWATCH_HIDE = 'Cacher',
    SETTINGS_VARWATCH_ANGLE_FORMAT = 'Format d\'angle',
    SETTINGS_VARWATCH_ANGLE_FORMAT_SHORT = 'Court',
    SETTINGS_VARWATCH_ANGLE_FORMAT_DEGREE = 'Degré',
    SETTINGS_VARWATCH_ANGLE_FORMAT_TOOLTIP = 'Le style de formatage pour les variables d\'angle.\n    Court : Formate les angles comme des short (0-65535)\n    Degré : Formate les angles en degrés (0-360)',
    SETTINGS_VARWATCH_DECIMAL_POINTS = 'Décimales',
    SETTINGS_VARWATCH_DECIMAL_POINTS_TOOLTIP = 'Le nombre maximum de décimales affichées dans les nombres.',
    SETTINGS_VARWATCH_SPD_EFFICIENCY = 'Visualisation efficacité de vitesse',
    SETTINGS_VARWATCH_SPD_EFFICIENCY_PERCENTAGE = 'Pourcentage',
    SETTINGS_VARWATCH_SPD_EFFICIENCY_FRACTION = 'Fraction',
    SETTINGS_VARWATCH_SPD_EFFICIENCY_TOOLTIP = 'Le style de formatage pour l\'efficacité de vitesse.\n    Pourcentage : affiche en pourcentage (0‑100 %)\n    Fraction : affiche comme fraction mathématique (par ex. 1/4)',
    SETTINGS_MEMORY_FILE_SELECT = 'Carte mémoire…',
    SETTINGS_MEMORY_FILE_SELECT_TOOLTIP = 'Choisissez un fichier .map pour charger les adresses',
    SETTINGS_MEMORY_DETECT_NOW = 'Détecter maintenant',
    SETTINGS_MEMORY_DETECT_NOW_TOOLTIP = 'Détecte automatiquement la région du jeu en cours d\'exécution',
    SETTINGS_MEMORY_DETECT_ON_START = 'Détecter au démarrage',
    SETTINGS_MEMORY_DETECT_ON_START_TOOLTIP = 'Détecte automatiquement la région du jeu au démarrage du script',
    SETTINGS_MEMORY_REGION_TOOLTIP = 'La région du jeu actuelle',
    SETTINGS_HOTKEYS_NOTHING = '(rien)',
    SETTINGS_HOTKEYS_CONFIRMATION = 'Appuyer sur Entrée pour confirmer',
    SETTINGS_HOTKEYS_CLEAR = 'Vider',
    SETTINGS_HOTKEYS_RESET = 'Vider',
    SETTINGS_HOTKEYS_ASSIGN = 'Assigner',
    SETTINGS_HOTKEYS_ACTIVATION = 'Activation des raccourcis',
    SETTINGS_HOTKEYS_ACTIVATION_ALWAYS = 'Toujours',
    SETTINGS_HOTKEYS_ACTIVATION_WHEN_NO_FOCUS = 'Quand aucun contrôle n\'est actif',
    -- Tools Tab
    TOOLS_RNG = 'RNG',
    TOOLS_RNG_LOCK = 'Bloquer',
    TOOLS_RNG_USE_INDEX = 'index',
    TOOLS_DUMPING = 'Export',
    TOOLS_EXPERIMENTS = 'Expériences',
    TOOLS_GHOST = 'Fantôme',
    TOOLS_GHOST_START = 'Démarrer rec.',
    TOOLS_GHOST_STOP = 'Arrêter rec.',
    TOOLS_GHOST_START_RECORDING_FAILED = 'Échec du démarrage de l\'enregistrement fantôme.',
    TOOLS_GHOST_STOP_RECORDING_FAILED = 'Échec de l\'arrêt de l\'enregistrement fantôme.',
    TOOLS_TRACKERS = 'Trackers',
    TOOLS_OVERLAYS = 'Superpositions',
    TOOLS_AUTOMATION = 'Automatisation',
    TOOLS_MOVED_DIST = 'Distance',
    TOOLS_MINI_OVERLAY = 'Saisie en jeu',
    TOOLS_AUTO_FIRSTIES = 'Auto-firsties',
    TOOLS_WORLD_VISUALIZER = 'Visu. monde',
    -- Timer Tab
    TIMER_START = 'Démarrer',
    TIMER_STOP = 'Arrêter',
    TIMER_RESET = 'Vider',
    TIMER_MANUAL = 'Manuel',
    TIMER_AUTO = 'Auto',
    -- Varwatch display strings
    VARWATCH_FACING_YAW = 'Orientation Yaw : %s (O : %s)',
    VARWATCH_INTENDED_YAW = 'Yaw ciblé : %s (O : %s)',
    VARWATCH_H_SPEED = 'Vitesse H : %s (S : %s)',
    VARWATCH_H_SLIDING = 'Vitesse de glisse H : %s',
    VARWATCH_Y_SPEED = 'Vitesse Y : %s',
    VARWATCH_SPD_EFFICIENCY = 'Efficacité Vitesse : %s',
    VARWATCH_SPD_EFFICIENCY_PERCENTAGE = 'Efficacité Vitesse : %s',
    VARWATCH_SPD_EFFICIENCY_FRACTION = 'Efficacité Vitesse : %d/4',
    VARWATCH_POS_X = 'X : %s',
    VARWATCH_POS_Y = 'Y : %s',
    VARWATCH_POS_Z = 'Z : %s',
    VARWATCH_PITCH = 'Pitch : %s',
    VARWATCH_YAW_VEL = 'Yaw Vel : %s',
    VARWATCH_PITCH_VEL = 'Pitch Vel : %s',
    VARWATCH_XZ_MOVEMENT = 'Mouvement XZ : %s',
    VARWATCH_ACTION = 'Action : ',
    VARWATCH_UNKNOWN_ACTION = 'Action inconnue ',
    VARWATCH_RNG = 'RNG : ',
    VARWATCH_RNG_INDEX = 'Index : ',
    VARWATCH_GLOBAL_TIMER = 'Compteur global : %s',
    VARWATCH_DIST_MOVED = 'Distance parcourue : %s',
    -- Memory addresses
    ADDRESS_USA = 'États-Unis',
    ADDRESS_JAPAN = 'Japon',
    ADDRESS_SHINDOU = 'Shindou',
    ADDRESS_PAL = 'Europe',
    -- placing help explanations here so they don't clutter the bottom
    SEMANTIC_WORKFLOW_HELP_EXPLANATIONS = {
        PROJECT_TAB = {
            HEADING = 'Projets Flux Sémantique',
            PAGES = {
                {
                    HEADING = 'À propos',
                    TEXT =
                    [[
Cette page vous permet de rejouer une séquence d'entrées TAS en partant d'un état spécifique avec effet immédiat.

Le but est de parcourir rapidement les effets de petits changements "dans le passé" afin d'itérer plus efficacement sur différentes implémentations de la même stratégie.

En gérant les soi-disant "projets de flux sémantique", il est possible de concevoir des runs complets en termes de sémantiques composées de quelques sections seulement.

Cet outil est divisé en plusieurs pages d'onglets que vous pouvez sélectionner en haut. Une fois que vous avez commencé à travailler sur un projet de flux sémantique, une page d'aide dédiée sera disponible pour chaque onglet comme celle-ci.

Cliquez sur la flèche "suivant" en haut pour en savoir plus sur la façon de commencer.
]],
                },
                {
                    HEADING = 'Premiers pas',
                    TEXT =
                    [[
La "Feuille" est l'unité de travail : elle contient une séquence d'entrées découpée en sections, chacune finissant après un nombre de frames ou une condition.

Un projet de flux sémantique n'est que l'ensemble des feuilles dans un dossier (*.swp) ; créez, ouvrez et sauvegardez-en avec les boutons en haut.

« Nouveau » demande un emplacement (préférez un dossier vide pour éviter les conflits) et « Sauver » écrase toujours le fichier courant.
]],
                },
                {
                    HEADING = 'Enregistrement',
                    TEXT =
                    [[
Quand tout est prêt, enregistrez‑le dans un .m64 : ouvrez un film dans mupen et avancez jusqu'au savestate de la première feuille, puis passez en mode lecture/écriture (ou commencez un nouvel enregistrement au même état).

Jouez chaque feuille à tour de rôle avec les flèches « Jouer sans charger .st », en les laissant terminer ; cela ne fonctionnera que si les feuilles sont « assemblées » (chacune commence à l’aperçu de la précédente).

Évitez de lire d’autres .m64 pendant que vous éditez ou d’avoir une feuille sélectionnée lors de la lecture, cela fausserait les entrées.
]],
                },
                {
                    HEADING = 'Utilisation de git',
                    TEXT =
                    [[
Le fichier de projet de flux sémantique et ses fichiers de feuilles associés suivent un format lisible par l'homme.
Afin de garder une trace du travail effectué sur un TAS, je recommande d'initialiser un dépôt git local dans le répertoire où se trouve le fichier .swp.
De cette façon, vous pouvez enregistrer votre projet et faire un commit chaque fois que vous avez fait des progrès significatifs, et gérer différentes branches pour comparer des stratégies.
Cela aide à suivre les progrès, à prévenir la perte de travail et à garder les choses organisées.

Pour faire un commit, il suffit de cliquer sur « Sauvegarder » et de committer tous les changements.
Après avoir basculé sur un commit ou une branche, vous devrez « Ouvrir » de nouveau le fichier .swp pour recharger tout depuis le disque.

Vous pouvez même trouver utile de gérer d'autres fichiers avec git, aussi, comme des fantômes, des fichiers .m64 enregistrés, des configurations de traceur STROOP ou des rédactions de stratégies !
]],
                },
                {
                    HEADING = 'Versions de fichiers',
                    TEXT =
                    [[
Les fichiers .sws et .swp suivent le versionnement sémantique ; c'est-à-dire un format <MAJOR>.<MINOR>.<PATCH>.
Comparez la version du script en cours d'exécution (en haut à droite à côté du bouton d'aide) avec la version du fichier vue dans l'onglet Projet pour comprendre ce qui se passe :

Les versions MAJEURES peuvent être incompatibles vers le haut comme vers le bas.
Mettez à jour ou rétrogradez le script en conséquence.

Les versions MINEURES peuvent être incompatibles vers le haut,
par exemple lorsqu'une version mineure plus élevée introduit une nouvelle fonctionnalité non encore prise en charge par la version de script inférieure.

Les versions PATCH devraient être compatibles vers le haut comme vers le bas dans la même version mineure, car elles sont destinées uniquement aux corrections de bogues.
Cependant, comme c'est la nature des bogues, cela peut parfois ne pas être fait correctement ¯\\_(ツ)_/¯
]],
                },
            },
        },
        INPUTS_TAB = {
            HEADING = 'Éditeur d\'entrées',
            PAGES = {
                {
                    HEADING = 'Aperçu',
                    TEXT =
                    [[
Cliquez sur « #Section » pour choisir l’aperçu (rouge) et sur la colonne centrale pour fixer la frame active (verte) utilisée lors de l’édition.
Les sections avec plusieurs frames peuvent s’ouvrir/fermer.
Modifier des entrées rejoue automatiquement le jeu jusqu’à l’aperçu.

Les boutons +Section / -Section ajoutent ou suppriment une section, +Input / -Input une frame dans la section courante (utile pour démarrer une nouvelle action).

Les contrôles du bas fonctionnent comme dans l’onglet TAS standard, mais plus compacts.
]],
                },
                {
                    HEADING = 'Édition',
                    TEXT =
                    [[
Vous pouvez sélectionner une plage d'entrées de joystick à éditer en cliquant gauche et en faisant glisser sur les mini-joysticks dans la plage désirée. Maintenez la touche CTRL pour ne pas Effacer la sélection lors du clic gauche.
La plage sélectionnée suivra la frame active mise en évidence par une bordure verte.
Ses valeurs seront affichées dans les contrôles du joystick en bas, et lorsque vous effectuerez des modifications, ces valeurs seront copiées dans la plage sélectionnée.

Si le basculement 'Modifier l'état entier' dans la page de préférences est désactivé, seules les modifications apportées à la frame active (plutôt que toutes ses valeurs) seront copiées dans la plage sélectionnée.

Lorsque la frame active et l'image d'aperçu sont identiques, la surbrillance deviendra d'un vert jaunâtre.

Pour modifier les entrées de boutons, il suffit de cliquer et de faire glisser sur les petits cercles à droite. Cela n'est pas affecté par, et n'affecte pas, votre sélection ou votre frame active.
]],
                },
                {
                    HEADING = 'Arctan straining',
                    TEXT =
                    [[
L'arctan straining fonctionne de manière similaire à ce dont vous avez l'habitude dans l'onglet TAS.
Cliquer sur le bouton 'Activer' permettra d'activer l'arctan straining pour les frames d'entrée sélectionnées, mais ne définira pas les variables 'start' et 'N'.
Pour ce faire, cliquez sur le bouton 'Recalculer...', puis sélectionnez la frame de début désirée (inclusive), suivie de la frame de fin désirée (exclusive).
Vous pouvez toujours ajuster manuellement les paramètres selon vos besoins par la suite.
]],
                },
            },
        },
        PREFERENCES_TAB = {
            HEADING = 'Préférences',
            PAGES = {
                {
                    HEADING = 'Vue d\'ensemble',
                    TEXT =
                    [[
Cette page affiche et modifie des paramètres qui ne sont pas stockés dans un projet de flux sémantique, et qui persistent plutôt dans vos paramètres locaux.
Chaque paramètre peut obtenir une page d'aide individuelle ici à l'avenir. Pour l'instant, voici une brève liste de ce que fait chaque paramètre :

- Modifier l'état entier : Copier l'intégralité de l'état du joystick de la frame active dans la plage sélectionnée dans la page « Entrées ». Lorsqu'il est désactivé, seules les valeurs modifiées seront copiées dans la plage sélectionnée.

- Avance rapide : Jouer le jeu en mode vitesse maximale lors de la relecture d'une feuille (par exemple lors de modifications). Lorsqu'il est désactivé, le jeu reviendra en temps réel.

- Délai de section par défaut : Le nombre de frames après lesquelles une nouvelle section expirera par défaut.
]],
                },
            },
        },
    },

    ACTIONS = {
        [0x04000201] = 'normal',
        [0x00000202] = 'commence à dormir',
        [0x00000203] = 'dort',
        [0x00000204] = 'se réveille',
        [0x00000205] = 'halète',
        [0x00000208] = 'immobile avec objet',
        [0x00000209] = 'immobile avec objet lourd',
        [0x00000210] = 'debout contre un mur',
        [0x00000211] = 'tousse',
        [0x00000212] = 'frissonne',
        [0x00000213] = 'dans les sables mouvants',
        [0x00000214] = 'inconnu 0x00000214',
        [0x00800220] = 'accroupi',
        [0x00800221] = 'commence à s\'accroupir',
        [0x00800222] = 'arrête de s\'accroupir',
        [0x00800223] = 'commence à ramper',
        [0x00800224] = 'rampe',
        [0x00800225] = 'arrête de ramper',
        [0x00800226] = 'arrêt glissade coup de pied',
        [0x0080022F] = 'rebond onde de choc',
        [0x04000230] = 'vue à la première personne',
        [0x00000233] = 'arrêt glissade fessier',
        [0x04000440] = 'marche',
        [0x04000442] = 'marche avec objet',
        [0x00000443] = 'demi-tour',
        [0x04000444] = 'fin demi-tour',
        [0x04000445] = 'court',
        [0x04000446] = 'court avec objet',
        [0x00000447] = 'sur carapace au sol',
        [0x04000448] = 'marche avec objet lourd',
        [0x00000449] = 'ralentit glissade',
        [0x0400044A] = 'glissade fessier',
        [0x0400044B] = 'glissade ventre',
        [0x0000044C] = 'glissade fessier avec objet',
        [0x0000044D] = 'glissade ventre avec objet',
        [0x0400044E] = 'glissade accroupi',
        [0x0400044F] = 'glissade coup de pied',
        [0x00000450] = 'choc au sol arrière fort',
        [0x00000451] = 'choc au sol avant fort',
        [0x00020452] = 'choc au sol arrière',
        [0x00020453] = 'choc au sol avant',
        [0x00020454] = 'choc au sol arrière doux',
        [0x00020455] = 'choc au sol avant doux',
        [0x00020456] = 'coup contre le sol',
        [0x00020457] = 'atterrissage sortie mort',
        [0x00020460] = 'choc au sol arrière fort',
        [0x00020461] = 'choc au sol avant fort',
        [0x00020462] = 'choc au sol arrière',
        [0x00020463] = 'choc au sol avant',
        [0x00020464] = 'choc au sol arrière doux',
        [0x00020465] = 'choc au sol avant doux',
        [0x00020466] = 'coup contre le sol',
        [0x00020467] = 'atterrissage sortie mort',
        [0x04000470] = 'atterrissage saut',
        [0x04000471] = 'atterrissage chute libre',
        [0x04000472] = 'atterrissage double saut',
        [0x04000473] = 'atterrissage saut latéral',
        [0x00000474] = 'atterrissage saut avec objet',
        [0x00000475] = 'atterrissage chute libre avec objet',
        [0x00000476] = 'atterrissage saut sables mouvants',
        [0x00000477] = 'atterrissage saut sables mouvants avec objet',
        [0x04000478] = 'atterrissage triple saut',
        [0x00000479] = 'atterrissage saut long',
        [0x0400047A] = 'atterrissage salto arrière',
        [0x03000880] = 'saut',
        [0x03000881] = 'double saut',
        [0x01000882] = 'triple saut',
        [0x01000883] = 'salto arrière',
        [0x03000885] = 'saut pente',
        [0x03000886] = 'saut mur',
        [0x01000887] = 'saut latéral',
        [0x03000888] = 'saut long',
        [0x01000889] = 'saut aquatique',
        [0x0188088A] = 'plongeon',
        [0x0100088C] = 'chute libre',
        [0x0300088D] = 'saut sommet poteau',
        [0x0300088E] = 'glissade fessier aérienne',
        [0x03000894] = 'triple saut volant',
        [0x00880898] = 'tiré du canon',
        [0x10880899] = 'vole',
        [0x0281089A] = 'saut sur carapace',
        [0x0081089B] = 'chute sur carapace',
        [0x1008089C] = 'vent vertical',
        [0x030008A0] = 'saut avec objet',
        [0x010008A1] = 'chute libre avec objet',
        [0x010008A2] = 'glissade fessier aérienne avec objet',
        [0x010008A3] = 'saut aquatique avec objet',
        [0x108008A4] = 'tournoyant',
        [0x010008A6] = 'roulade avant',
        [0x000008A7] = 'choc contre mur aérien',
        [0x000004A8] = 'sur Hoot',
        [0x008008A9] = 'coup de pied au sol',
        [0x018008AA] = 'coup de pied glissade',
        [0x830008AB] = 'lancer aérien',
        [0x018008AC] = 'coup de pied saut',
        [0x010008AD] = 'roulade arrière',
        [0x000008AE] = 'rebond boîte folle',
        [0x030008AF] = 'triple saut spécial',
        [0x010208B0] = 'choc aérien arrière',
        [0x010208B1] = 'choc aérien avant',
        [0x010208B2] = 'choc aérien avant fort',
        [0x010208B3] = 'choc aérien arrière fort',
        [0x010208B4] = 'saut brûlant',
        [0x010208B5] = 'chute brûlante',
        [0x010208B6] = 'coup doux',
        [0x010208B7] = 'boost lave',
        [0x010208B8] = 'emporté par le vent',
        [0x010208BD] = 'jeté en avant',
        [0x010208BE] = 'jeté en arrière',
        [0x380022C0] = 'immobile dans l\'eau',
        [0x380022C1] = 'immobile dans l\'eau avec objet',
        [0x300022C2] = 'fin action aquatique',
        [0x300022C3] = 'fin action aquatique avec objet',
        [0x300032C4] = 'noyade',
        [0x300222C5] = 'choc aquatique arrière',
        [0x300222C6] = 'choc aquatique avant',
        [0x300032C7] = 'mort aquatique',
        [0x300222C8] = 'électrocuté dans l\'eau',
        [0x300024D0] = 'brasse',
        [0x300024D1] = 'fin nage',
        [0x300024D2] = 'coup de pied rapide',
        [0x300024D3] = 'brasse avec objet',
        [0x300024D4] = 'fin nage avec objet',
        [0x300024D5] = 'coup de pied rapide avec objet',
        [0x300024D6] = 'nage sur carapace dans l\'eau',
        [0x300024E0] = 'lancer dans l\'eau',
        [0x300024E1] = 'coup de poing dans l\'eau',
        [0x300022E2] = 'plongeon dans l\'eau',
        [0x300222E3] = 'pris dans un tourbillon',
        [0x080042F0] = 'debout dans l\'eau métallique',
        [0x080042F1] = 'debout dans l\'eau métallique avec objet',
        [0x000044F2] = 'marche dans l\'eau métallique',
        [0x000044F3] = 'marche dans l\'eau métallique avec objet',
        [0x000042F4] = 'chute dans l\'eau métallique',
        [0x000042F5] = 'chute dans l\'eau métallique avec objet',
        [0x000042F6] = 'atterrissage chute eau métallique',
        [0x000042F7] = 'atterrissage chute eau métallique avec objet',
        [0x000044F8] = 'saut eau métallique',
        [0x000044F9] = 'saut eau métallique avec objet',
        [0x000044FA] = 'atterrissage saut eau métallique',
        [0x000044FB] = 'atterrissage saut eau métallique avec objet',
        [0x00001300] = 'disparu',
        [0x04001301] = 'cinématique intro',
        [0x00001302] = 'sortie danse étoile',
        [0x00001303] = 'danse étoile dans l\'eau',
        [0x00001904] = 'chute après étoile',
        [0x20001305] = 'lecture dialogue automatique',
        [0x20001306] = 'lecture dialogue PNJ',
        [0x00001307] = 'danse étoile sans sortie',
        [0x00001308] = 'lecture panneau',
        [0x00001909] = 'cinématique grande étoile',
        [0x0000130A] = 'attente dialogue',
        [0x0000130F] = 'déplacement libre debug',
        [0x00021311] = 'mort debout',
        [0x00021312] = 'mort sables mouvants',
        [0x00021313] = 'électrocution',
        [0x00021314] = 'suffocation',
        [0x00021315] = 'mort sur le ventre',
        [0x00021316] = 'mort sur le dos',
        [0x00021317] = 'mangé par Bubba',
        [0x00001918] = 'cinématique Peach',
        [0x00001319] = 'crédits',
        [0x0000131A] = 'fait signe',
        [0x00001320] = 'tire la porte',
        [0x00001321] = 'pousse la porte',
        [0x00001322] = 'apparition porte de téléportation',
        [0x00001923] = 'sort du tuyau',
        [0x00001924] = 'apparition rotation aérienne',
        [0x00001325] = 'atterrissage rotation',
        [0x00001926] = 'sortie aérienne',
        [0x00001327] = 'atterrissage sortie mort avec sauvegarde',
        [0x00001928] = 'sortie mort',
        [0x00001929] = 'sortie mort (inutilisé)',
        [0x0000192A] = 'sortie mort en tombant',
        [0x0000192B] = 'sortie spéciale aérienne',
        [0x0000192C] = 'sortie mort spéciale',
        [0x0000192D] = 'sortie aérienne en tombant',
        [0x0000132E] = 'déverrouille porte clé',
        [0x0000132F] = 'déverrouille porte étoile',
        [0x00001331] = 'entre porte étoile',
        [0x00001932] = 'apparition sans rotation aérienne',
        [0x00001333] = 'atterrissage sans rotation',
        [0x00001934] = 'saut entrée BBH',
        [0x00001535] = 'rotation entrée BBH',
        [0x00001336] = 'téléportation disparition',
        [0x00001337] = 'téléportation apparition',
        [0x00020338] = 'électrocuté',
        [0x00020339] = 'écrasé',
        [0x0002033A] = 'tête coincée dans le sol',
        [0x0002033B] = 'fesses coincées dans le sol',
        [0x0002033C] = 'pieds coincés dans le sol',
        [0x0000133D] = 'met la casquette',
        [0x08100340] = 'tient le poteau',
        [0x00100341] = 'attrape poteau lentement',
        [0x00100342] = 'attrape poteau rapidement',
        [0x00100343] = 'grimpe poteau',
        [0x00100344] = 'transition sommet poteau',
        [0x00100345] = 'sommet poteau',
        [0x08200348] = 'commence à s\'accrocher',
        [0x00200349] = 'accroché',
        [0x0020054A] = 'accroché en mouvement',
        [0x0800034B] = 'suspendu à une corniche',
        [0x0000054C] = 'grimpe corniche lentement 1',
        [0x0000054D] = 'grimpe corniche lentement 2',
        [0x0000054E] = 'descend corniche',
        [0x0000054F] = 'grimpe corniche rapidement',
        [0x00020370] = 'attrapé',
        [0x00001371] = 'dans le canon',
        [0x10020372] = 'tournoyant tornade',
        [0x00800380] = 'donne un coup de poing',
        [0x00000383] = 'ramasse',
        [0x00000385] = 'ramasse en plongeant',
        [0x00000386] = 'arrêt glissade ventre',
        [0x00000387] = 'pose',
        [0x80000588] = 'lance',
        [0x80000589] = 'lance objet lourd',
        [0x00000390] = 'ramasse Bowser',
        [0x00000391] = 'tient Bowser',
        [0x00000392] = 'relâche Bowser',
    }
    }
