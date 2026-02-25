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
    GENERIC_RESET = 'Réinitialiser',
    GENERIC_NIL = 'nil',
    -- Tab names
    TAS_TAB_NAME = 'TAS',
    SEMANTIC_WORKFLOW_TAB_NAME = 'Flux Sémantique',
    SETTINGS_TAB_NAME = 'Paramètres',
    TOOLS_TAB_NAME = 'Outils',
    TIMER_TAB_NAME = 'Minuteur',
    PRESET = 'Préréglage ',
    -- Preset Context Menu
    PRESET_CONTEXT_MENU_DELETE_ALL = 'Tout supprimer',
    -- TAS Tab
    DISABLED = 'Désactivé',
    MATCH_YAW = 'Correspondre Yaw',
    REVERSE_YAW = 'Inverser Yaw',
    MATCH_ANGLE = 'Correspondre Angle',
    D99_ALWAYS = 'Toujours',
    D99 = '.99',
    DYAW = 'Relatif',
    ATAN_STRAIN = 'Contrainte Arctan',
    ATAN_STRAIN_REV = 'I',
    MAG_RESET = 'Réinitialiser',
    MAG_HI = 'Élevé',
    SPDKICK = 'Spdkick',
    FRAMEWALK = 'Framewalk',
    SWIM = 'Nager',
    -- Semantic Workflow Tab
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
    SEMANTIC_WORKFLOW_FRAMELIST_STICK = 'Joystick',
    SEMANTIC_WORKFLOW_FRAMELIST_UNTIL = 'Jusqu\'à',
    SEMANTIC_WORKFLOW_TOOL_COPY_ENTIRE_STATE = 'Copier l\'état entier',
    SEMANTIC_WORKFLOW_CONTROL_MANUAL = 'Manuel',
    SEMANTIC_WORKFLOW_CONTROL_MATCH_YAW = 'Yaw',
    SEMANTIC_WORKFLOW_CONTROL_MATCH_ANGLE = 'Angle',
    SEMANTIC_WORKFLOW_CONTROL_REVERSE_YAW = 'Inverser',
    SEMANTIC_WORKFLOW_CONTROL_DYAW = 'DYaw',
    SEMANTIC_WORKFLOW_CONTROL_ATAN_RETIME = 'Recalculer...',
    SEMANTIC_WORKFLOW_CONTROL_ATAN_SELECT_START = 'Sélectionner début...',
    SEMANTIC_WORKFLOW_CONTROL_ATAN_SELECT_END = 'Sélectionner fin...',
    SEMANTIC_WORKFLOW_CONTROL_ATAN = 'Activer',
    SEMANTIC_WORKFLOW_CONTROL_ATAN_REVERSE = 'Inverser',
    SEMANTIC_WORKFLOW_CONTROL_HIGH_MAG = 'Mag. élevée',
    SEMANTIC_WORKFLOW_CONTROL_SPDKICK = 'Spdk',
    SEMANTIC_WORKFLOW_PROJECT_FILE_VERSION = 'Version fichier : ',
    SEMANTIC_WORKFLOW_PROJECT_NO_SHEETS_AVAILABLE = 'Aucune feuille de flux sémantique disponible.\nCréez-en une pour continuer.',
    SEMANTIC_WORKFLOW_PROJECT_NEW = 'Nouveau',
    SEMANTIC_WORKFLOW_PROJECT_NEW_TOOL_TIP = 'Créer un nouveau projet dans un nouvel emplacement',
    SEMANTIC_WORKFLOW_PROJECT_OPEN = 'Ouvrir',
    SEMANTIC_WORKFLOW_PROJECT_OPEN_TOOL_TIP = 'Ouvrir un projet existant',
    SEMANTIC_WORKFLOW_PROJECT_SAVE = 'Sauvegarder',
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
    SEMANTIC_WORKFLOW_PROJECT_ADD_SHEET = 'Ajouter une feuille...',
    SEMANTIC_WORKFLOW_PROJECT_REBASE_SHEET_TOOL_TIP = 'Définir le début maintenant',
    SEMANTIC_WORKFLOW_PROJECT_REPLACE_INPUTS_TOOL_TIP = 'Remplacer les inputs',
    SEMANTIC_WORKFLOW_PROJECT_PLAY_WITHOUT_ST_TOOL_TIP = 'Jouer sans charger .st',
    SEMANTIC_WORKFLOW_PROJECT_DELETE_SHEET_TOOL_TIP = 'Supprimer',
    SEMANTIC_WORKFLOW_PROJECT_ADD_SHEET_TOOL_TIP = 'Ajouter',
    SEMANTIC_WORKFLOW_PROJECT_MOVE_SHEET_UP_TOOL_TIP = 'Monter',
    SEMANTIC_WORKFLOW_PROJECT_MOVE_SHEET_DOWN_TOOL_TIP = 'Descendre',
    SEMANTIC_WORKFLOW_INPUTS_EXPAND_SECTION = 'Développer',
    SEMANTIC_WORKFLOW_INPUTS_COLLAPSE_SECTION = 'Réduire',
    SEMANTIC_WORKFLOW_INPUTS_INSERT_SECTION = '+Section',
    SEMANTIC_WORKFLOW_INPUTS_INSERT_SECTION_TOOL_TIP = 'Insérer une section après la sélection',
    SEMANTIC_WORKFLOW_INPUTS_DELETE_SECTION = '-Section',
    SEMANTIC_WORKFLOW_INPUTS_DELETE_SECTION_TOOL_TIP = 'Supprimer la section sélectionnée',
    SEMANTIC_WORKFLOW_INPUTS_TIMEOUT = 'Délai :',
    SEMANTIC_WORKFLOW_INPUTS_TIMEOUT_TOOL_TIP = 'Terminer la section après N frames maximum',
    SEMANTIC_WORKFLOW_INPUTS_END_ACTION = 'Action de fin :',
    SEMANTIC_WORKFLOW_INPUTS_END_ACTION_TOOL_TIP = 'Terminer la section quand Mario entre dans cette action',
    SEMANTIC_WORKFLOW_INPUTS_END_ACTION_TYPE_TO_SEARCH_TOOL_TIP = 'Taper pour filtrer les actions',
    SEMANTIC_WORKFLOW_INPUTS_INSERT_INPUT = '+Input',
    SEMANTIC_WORKFLOW_INPUTS_INSERT_INPUT_TOOL_TIP = 'Insérer une frame après la sélection',
    SEMANTIC_WORKFLOW_INPUTS_DELETE_INPUT = '-Input',
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
    SETTINGS_INTERACTION_MANUAL_ON_JOYSTICK_INTERACT = "Activer le mode manuel lors de l'interaction joystick",
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
    SETTINGS_MEMORY_FILE_SELECT = 'Sélectionner le fichier de carte...',
    SETTINGS_MEMORY_FILE_SELECT_TOOLTIP = 'Choisissez un fichier .map pour charger les adresses',
    SETTINGS_MEMORY_DETECT_NOW = 'Détection automatique maintenant',
    SETTINGS_MEMORY_DETECT_NOW_TOOLTIP = 'Détecte automatiquement la région du jeu en cours d\'exécution',
    SETTINGS_MEMORY_DETECT_ON_START = 'Détection automatique au démarrage',
    SETTINGS_MEMORY_DETECT_ON_START_TOOLTIP = 'Détecte automatiquement la région du jeu au démarrage du script',
    SETTINGS_MEMORY_REGION_TOOLTIP = 'La région du jeu actuelle',
    SETTINGS_HOTKEYS_NOTHING = '(rien)',
    SETTINGS_HOTKEYS_CONFIRMATION = 'Appuyer sur Entrée pour confirmer',
    SETTINGS_HOTKEYS_CLEAR = 'Effacer',
    SETTINGS_HOTKEYS_RESET = 'Réinitialiser',
    SETTINGS_HOTKEYS_ASSIGN = 'Assigner',
    SETTINGS_HOTKEYS_ACTIVATION = 'Activation des raccourcis',
    SETTINGS_HOTKEYS_ACTIVATION_ALWAYS = 'Toujours',
    SETTINGS_HOTKEYS_ACTIVATION_WHEN_NO_FOCUS = 'Quand aucun contrôle n\'est actif',
    -- Tools Tab
    TOOLS_RNG = 'RNG',
    TOOLS_RNG_LOCK = 'Verrouiller sur',
    TOOLS_RNG_USE_INDEX = 'Utiliser l\'index',
    TOOLS_DUMPING = 'Export',
    TOOLS_EXPERIMENTS = 'Expériences',
    TOOLS_GHOST = 'Fantôme',
    TOOLS_GHOST_START = 'Démarrer l\'enregistrement',
    TOOLS_GHOST_STOP = 'Arrêter l\'enregistrement',
    TOOLS_GHOST_START_RECORDING_FAILED = 'Échec du démarrage de l\'enregistrement fantôme.',
    TOOLS_GHOST_STOP_RECORDING_FAILED = 'Échec de l\'arrêt de l\'enregistrement fantôme.',
    TOOLS_TRACKERS = 'Trackers',
    TOOLS_OVERLAYS = 'Superpositions',
    TOOLS_AUTOMATION = 'Automatisation',
    TOOLS_MOVED_DIST = 'Distance parcourue',
    TOOLS_MINI_OVERLAY = 'Superposition inputs',
    TOOLS_AUTO_FIRSTIES = 'Auto-firsties',
    TOOLS_WORLD_VISUALIZER = 'Visualiseur de monde',
    -- Timer Tab
    TIMER_START = 'Démarrer',
    TIMER_STOP = 'Arrêter',
    TIMER_RESET = 'Réinitialiser',
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
L'entité principale avec laquelle vous travaillerez est la "Feuille".
Une Feuille décrit une séquence d'entrées qui, à partir d'un point spécifique, tentera d'effectuer une certaine suite d'actions constituant un segment d'un run complet.
Les feuilles sont subdivisées en sections, chaque section se terminant soit lorsqu'un certain nombre de frames est passé, soit lorsqu'une autre condition est remplie.

Cette page vous permet de gérer plusieurs feuilles liées dans un "Projet de flux sémantique".
Les projets de flux sémantique sont en réalité juste un ensemble de feuilles sauvegardées dans un répertoire à côté du fichier de projet (*.swp).
Vous pouvez créer, sauvegarder et charger des projets en utilisant les boutons correspondants en haut.

Le bouton "Nouveau" demandera un emplacement pour le nouveau projet. Il est recommandé de créer un nouveau dossier vide pour le projet, car avoir plusieurs projets dans le même répertoire peut les faire interférer involontairement.
Le bouton "Sauvegarder" enregistrera toujours par-dessus le fichier de projet actuellement chargé sans confirmation, sauf si vous n'avez encore ouvert ou créé aucun projet.
]],
                },
                {
                    HEADING = 'Enregistrement de fichiers .m64',
                    TEXT =
                    [[
Une fois que vous êtes satisfait de votre travail, vous voudrez probablement l'enregistrer dans un fichier .m64.
Pour ce faire, ouvrez un fichier .m64 dans mupen comme d'habitude et laissez-le jouer jusqu'à un état qui correspond au savestate de la première feuille que vous voulez lire de manière sémantique.
Ensuite, passez en mode lecture/écriture afin que les frames puissent être enregistrées.
Vous pouvez également y parvenir en commençant simplement un nouvel enregistrement à partir du savestate de la première feuille.

Ensuite, cliquez sur les flèches pointant vers la droite ("Jouer sans charger .st") pour chaque feuille dans l'ordre.
(Assurez-vous de les laisser jouer jusqu'à la fin avant d'appuyer sur la suivante)
Ceci, bien sûr, suppose que les feuilles sont correctement "assemblées", c'est-à-dire que chaque feuille que vous cliquez commence là où la précédente se termine (c'est-à-dire où se trouve son image d'aperçu).

Ne jouez pas de films .m64 pendant que vous créez des feuilles, car cela produira des entrées imprévisibles.
Lors de la lecture d'un fichier .m64, assurez-vous qu'aucune feuille n'est sélectionnée dans la liste des feuilles du projet.
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
Cliquez sur la colonne "#Section" dans la liste de sections pour sélectionner l'image d'aperçu (en surbrillance en rouge).
Vous pouvez développer et réduire les sections qui ont plus d'une frame d'entrée initiale.
Cliquez la colonne du milieu dans la liste des sections pour sélectionner la "frame active" (en surbrillance en vert), qui est utilisée pour l'édition (plus d'informations sur la page d'aide suivante).

Chaque fois que vous apportez des modifications à des entrées (par ex. changer des boutons), le jeu sera rejoué jusqu'à l'image d'aperçu depuis le début de la feuille avec les nouvelles entrées.

Les boutons "+Section" et "-Section" ajoutent et suppriment respectivement une section à la section actuellement sélectionnée.
Une feuille doit toujours avoir au moins une section.

Les boutons "+Input" et "-Input" ajoutent et suppriment respectivement une frame à la frame sélectionnée dans la section sélectionnée.
Ceci est utile pour initier une nouvelle action comme un long jump, par exemple après avoir atterri d'un rollout précédent.

Les contrôles en bas se comportent de la même manière que les vues « TAS » standard auxquelles vous êtes peut-être habitué, juste dans une disposition plus condensée.
]],
                },
                {
                    HEADING = 'Édition',
                    TEXT =
                    [[
Vous pouvez sélectionner une plage d'entrées de joystick à éditer en cliquant gauche et en faisant glisser sur les mini-joysticks dans la plage désirée. Maintenez la touche CTRL pour ne pas réinitialiser la sélection lors du clic gauche.
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
    -- Actions (kept in English as these are technical SM64 terms)
    ACTIONS = {
        [0x04000201] = 'idle',
        [0x00000202] = 'start sleeping',
        [0x00000203] = 'sleeping',
        [0x00000204] = 'waking up',
        [0x00000205] = 'panting',
        [0x00000208] = 'hold idle',
        [0x00000209] = 'hold heavy idle',
        [0x00000210] = 'standing against wall',
        [0x00000211] = 'coughing',
        [0x00000212] = 'shivering',
        [0x00000213] = 'in quicksand',
        [0x00000214] = 'unknown 0x00000214',
        [0x00800220] = 'crouching',
        [0x00800221] = 'start crouching',
        [0x00800222] = 'stop crouching',
        [0x00800223] = 'start crawling',
        [0x00800224] = 'crawling',
        [0x00800225] = 'stop crawling',
        [0x00800226] = 'slide kick slide stop',
        [0x0080022F] = 'shockwave bounce',
        [0x04000230] = 'first person',
        [0x00000233] = 'butt slide stop',
        [0x04000440] = 'walking',
        [0x04000442] = 'hold walking',
        [0x00000443] = 'turning around',
        [0x04000444] = 'finish turning around',
        [0x04000445] = 'running',
        [0x04000446] = 'hold running',
        [0x00000447] = 'riding shell ground',
        [0x04000448] = 'hold heavy walking',
        [0x00000449] = 'slow down slide',
        [0x0400044A] = 'butt slide',
        [0x0400044B] = 'stomach slide',
        [0x0000044C] = 'hold butt slide',
        [0x0000044D] = 'hold stomach slide',
        [0x0400044E] = 'crouch slide',
        [0x0400044F] = 'slide kick slide',
        [0x00000450] = 'hard backward ground kb',
        [0x00000451] = 'hard forward ground kb',
        [0x00020452] = 'backward ground kb',
        [0x00020453] = 'forward ground kb',
        [0x00020454] = 'soft backward ground kb',
        [0x00020455] = 'soft forward ground kb',
        [0x00020456] = 'ground bonk',
        [0x00020457] = 'death exit land',
        [0x00020460] = 'hard backward ground kb',
        [0x00020461] = 'hard forward ground kb',
        [0x00020462] = 'backward ground kb',
        [0x00020463] = 'forward ground kb',
        [0x00020464] = 'soft backward ground kb',
        [0x00020465] = 'soft forward ground kb',
        [0x00020466] = 'ground bonk',
        [0x00020467] = 'death exit land',
        [0x04000470] = 'jump land',
        [0x04000471] = 'freefall land',
        [0x04000472] = 'double jump land',
        [0x04000473] = 'side flip land',
        [0x00000474] = 'hold jump land',
        [0x00000475] = 'hold freefall land',
        [0x00000476] = 'quicksand jump land',
        [0x00000477] = 'hold quicksand jump land',
        [0x04000478] = 'triple jump land',
        [0x00000479] = 'long jump land',
        [0x0400047A] = 'backflip land',
        [0x03000880] = 'jump',
        [0x03000881] = 'double jump',
        [0x01000882] = 'triple jump',
        [0x01000883] = 'backflip',
        [0x03000885] = 'steep jump',
        [0x03000886] = 'wall kick air',
        [0x01000887] = 'side flip',
        [0x03000888] = 'long jump',
        [0x01000889] = 'water jump',
        [0x0188088A] = 'dive',
        [0x0100088C] = 'freefall',
        [0x0300088D] = 'top of pole jump',
        [0x0300088E] = 'butt slide air',
        [0x03000894] = 'flying triple jump',
        [0x00880898] = 'shot from cannon',
        [0x10880899] = 'flying',
        [0x0281089A] = 'riding shell jump',
        [0x0081089B] = 'riding shell fall',
        [0x1008089C] = 'vertical wind',
        [0x030008A0] = 'hold jump',
        [0x010008A1] = 'hold freefall',
        [0x010008A2] = 'hold butt slide air',
        [0x010008A3] = 'hold water jump',
        [0x108008A4] = 'twirling',
        [0x010008A6] = 'forward rollout',
        [0x000008A7] = 'air hit wall',
        [0x000004A8] = 'riding hoot',
        [0x008008A9] = 'ground pound',
        [0x018008AA] = 'slide kick',
        [0x830008AB] = 'air throw',
        [0x018008AC] = 'jump kick',
        [0x010008AD] = 'backward rollout',
        [0x000008AE] = 'crazy box bounce',
        [0x030008AF] = 'special triple jump',
        [0x010208B0] = 'backward air kb',
        [0x010208B1] = 'forward air kb',
        [0x010208B2] = 'hard forward air kb',
        [0x010208B3] = 'hard backward air kb',
        [0x010208B4] = 'burning jump',
        [0x010208B5] = 'burning fall',
        [0x010208B6] = 'soft bonk',
        [0x010208B7] = 'lava boost',
        [0x010208B8] = 'getting blown',
        [0x010208BD] = 'thrown forward',
        [0x010208BE] = 'thrown backward',
        [0x380022C0] = 'water idle',
        [0x380022C1] = 'hold water idle',
        [0x300022C2] = 'water action end',
        [0x300022C3] = 'hold water action end',
        [0x300032C4] = 'drowning',
        [0x300222C5] = 'backward water kb',
        [0x300222C6] = 'forward water kb',
        [0x300032C7] = 'water death',
        [0x300222C8] = 'water shocked',
        [0x300024D0] = 'breaststroke',
        [0x300024D1] = 'swimming end',
        [0x300024D2] = 'flutter kick',
        [0x300024D3] = 'hold breaststroke',
        [0x300024D4] = 'hold swimming end',
        [0x300024D5] = 'hold flutter kick',
        [0x300024D6] = 'water shell swimming',
        [0x300024E0] = 'water throw',
        [0x300024E1] = 'water punch',
        [0x300022E2] = 'water plunge',
        [0x300222E3] = 'caught in whirlpool',
        [0x080042F0] = 'metal water standing',
        [0x080042F1] = 'hold metal water standing',
        [0x000044F2] = 'metal water walking',
        [0x000044F3] = 'hold metal water walking',
        [0x000042F4] = 'metal water falling',
        [0x000042F5] = 'hold metal water falling',
        [0x000042F6] = 'metal water fall land',
        [0x000042F7] = 'hold metal water fall land',
        [0x000044F8] = 'metal water jump',
        [0x000044F9] = 'hold metal water jump',
        [0x000044FA] = 'metal water jump land',
        [0x000044FB] = 'hold metal water jump land',
        [0x00001300] = 'disappeared',
        [0x04001301] = 'intro cutscene',
        [0x00001302] = 'star dance exit',
        [0x00001303] = 'star dance water',
        [0x00001904] = 'fall after star grab',
        [0x20001305] = 'reading automatic dialog',
        [0x20001306] = 'reading npc dialog',
        [0x00001307] = 'star dance no exit',
        [0x00001308] = 'reading sign',
        [0x00001909] = 'grand star cutscene',
        [0x0000130A] = 'waiting for dialog',
        [0x0000130F] = 'debug free move',
        [0x00021311] = 'standing death',
        [0x00021312] = 'quicksand death',
        [0x00021313] = 'electrocution',
        [0x00021314] = 'suffocation',
        [0x00021315] = 'death on stomach',
        [0x00021316] = 'death on back',
        [0x00021317] = 'eaten by bubba',
        [0x00001918] = 'peach cutscene',
        [0x00001319] = 'credits',
        [0x0000131A] = 'waving',
        [0x00001320] = 'pulling door',
        [0x00001321] = 'pushing door',
        [0x00001322] = 'warp door spawn',
        [0x00001923] = 'emerge from pipe',
        [0x00001924] = 'spawn spin airborne',
        [0x00001325] = 'spawn spin landing',
        [0x00001926] = 'exit airborne',
        [0x00001327] = 'exit land save dialog',
        [0x00001928] = 'death exit',
        [0x00001929] = 'death exit (unused)',
        [0x0000192A] = 'falling death exit',
        [0x0000192B] = 'special exit airborne',
        [0x0000192C] = 'special death exit',
        [0x0000192D] = 'falling exit airborne',
        [0x0000132E] = 'unlocking key door',
        [0x0000132F] = 'unlocking star door',
        [0x00001331] = 'entering star door',
        [0x00001932] = 'spawn no spin airborne',
        [0x00001333] = 'spawn no spin landing',
        [0x00001934] = 'bbh enter jump',
        [0x00001535] = 'bbh enter spin',
        [0x00001336] = 'teleport fade out',
        [0x00001337] = 'teleport fade in',
        [0x00020338] = 'shocked',
        [0x00020339] = 'squished',
        [0x0002033A] = 'head stuck in ground',
        [0x0002033B] = 'butt stuck in ground',
        [0x0002033C] = 'feet stuck in ground',
        [0x0000133D] = 'putting on cap',
        [0x08100340] = 'holding pole',
        [0x00100341] = 'grab pole slow',
        [0x00100342] = 'grab pole fast',
        [0x00100343] = 'climbing pole',
        [0x00100344] = 'top of pole transition',
        [0x00100345] = 'top of pole',
        [0x08200348] = 'start hanging',
        [0x00200349] = 'hanging',
        [0x0020054A] = 'hang moving',
        [0x0800034B] = 'ledge grab',
        [0x0000054C] = 'ledge climb slow 1',
        [0x0000054D] = 'ledge climb slow 2',
        [0x0000054E] = 'ledge climb down',
        [0x0000054F] = 'ledge climb fast',
        [0x00020370] = 'grabbed',
        [0x00001371] = 'in cannon',
        [0x10020372] = 'tornado twirling',
        [0x00800380] = 'punching',
        [0x00000383] = 'picking up',
        [0x00000385] = 'dive picking up',
        [0x00000386] = 'stomach slide stop',
        [0x00000387] = 'placing down',
        [0x80000588] = 'throwing',
        [0x80000589] = 'heavy throw',
        [0x00000390] = 'picking up bowser',
        [0x00000391] = 'holding bowser',
        [0x00000392] = 'releasing bowser',
    },
}
