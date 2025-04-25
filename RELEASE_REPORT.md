Rapport de Publication

Outils Utilisés :

1. release.sh (Script Bash personnalisé)

Fonctionnalités :

    Analyse des messages de commit pour déterminer le type de version (major, minor, patch).

    Incrémentation automatique de la version dans pubspec.yaml.

    Génération d'un changelog structuré (CHANGELOG.md).

    Création et push du tag Git correspondant.

    Création d'une release GitHub via gh.​

Forces :

    Contrôle total sur le processus de publication.

    Adapté spécifiquement aux besoins du projet Flutter.

    Indépendant de Node.js ou d'autres dépendances externes.​

Faiblesses :

    Maintenance manuelle requise pour les évolutions.

2. gh (GitHub CLI)

Fonctionnalités :

    Création de releases GitHub en ligne de commande.

    Gestion des tags, titres et notes de version.​

Forces :

    Intégration directe avec GitHub.

    Facilite l'automatisation dans les scripts CI/CD.​

Faiblesses :

    Nécessite une configuration préalable (gh auth login).

    Dépendance supplémentaire à installer.​

3. conventional-changelog-cli

Fonctionnalités :

    Génération automatique de changelogs à partir des messages de commit respectant les conventions.

    Support de plusieurs presets (angular, conventionalcommits, etc.).​
    UNPKG+3npm+3GitHub+3

Forces :

    Standardisation des changelogs.

    Facile à intégrer dans des workflows existants.​

Faiblesses :

    Nécessite Node.js et une configuration initiale.

    Moins flexible pour des besoins très spécifiques sans personnalisation.​

    Lien vers les releases GitHub : https://github.com/MPFabio/tp-integration-mpf/releases​