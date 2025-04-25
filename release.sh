#!/bin/bash

set -e  # Arrêter le script en cas d'erreur

# Script de publication unifiée
#
# === Gestion des versions et incrémentation ===
#
# Ce script utilise Semantic Versioning (SemVer) pour gérer les versions sous la forme MAJEUR.MINEUR.PATCH (ex: 1.0.3).
# L'incrémentation de la version est déterminée automatiquement en fonction des messages de commit.
#
# **Conventions des messages de commit et impact sur la version :**
# - **major** : Incrémente la version MAJEUR (+1.0.0)
#   Exemple : "major: refonte de l'API" ou "major: suppression de l'ancienne API"
#   Résultat : 1.0.3 → 2.0.0
# - **feat** : Incrémente la version MINEUR (+0.1.0)
#   Exemple : "feat: ajout de la page de profil"
#   Résultat : 1.0.3 → 1.1.0
# - **fix** ou **refactor** (ou autre) : Incrémente la version PATCH (+0.0.1)
#   Exemple : "fix: correction du bug de navigation" ou "refactor: optimisation du code"
#   Résultat : 1.0.3 → 1.0.4
#
# **Instructions pour les commits :**
# - Utilisez des préfixes clairs dans vos messages de commit pour indiquer le type de changement.
# - Assurez-vous que les messages suivent la convention (ex: "feat: description", "fix: description").
# - Si vous ne suivez pas cette convention, modifiez les expressions régulières ci-dessous (grep -E) pour correspondre à votre format.
#
# **Exemple de workflow :**
# 1. Commits : "feat: ajout de la page de profil", "fix: correction d'un bug"
# 2. Résultat : Version passe de 1.0.3 à 1.1.0 (car "feat" est détecté)
# 3. Changelog : Les messages avec "feat" apparaissent sous "Added", ceux avec "fix" ou "refactor" sous "Changed".

# 1. Déterminer la plage de commits et le type d'incrémentation
echo "Détermination de la plage de commits..."
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -z "$LATEST_TAG" ]; then
  COMMIT_RANGE="HEAD"
else
  COMMIT_RANGE="$LATEST_TAG..HEAD"
fi

# Analyser les messages de commit pour déterminer le type d'incrémentation
echo "Analyse des messages de commit pour déterminer le type de version..."
BREAKING_CHANGE=$(git log "$COMMIT_RANGE" --pretty=format:"%s" | grep -E "BREAKING CHANGE|major" || true)
FEATURE=$(git log "$COMMIT_RANGE" --pretty=format:"%s" | grep -E "^feat" || true)

# Récupérer la version actuelle
CURRENT_VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}')
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Déterminer le type d'incrémentation
if [ -n "$BREAKING_CHANGE" ]; then
  echo "Changement majeur détecté (BREAKING CHANGE ou major), incrémentation de la version majeure..."
  MAJOR=$((MAJOR + 1))
  MINOR=0
  PATCH=0
elif [ -n "$FEATURE" ]; then
  echo "Nouvelle fonctionnalité détectée (feat), incrémentation de la version mineure..."
  MINOR=$((MINOR + 1))
  PATCH=0
else
  echo "Changement mineur détecté (fix, refactor ou autre), incrémentation de la version patch..."
  PATCH=$((PATCH + 1))
fi

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

# Vérifier si la version existe déjà comme tag et la supprimer si nécessaire
while git tag -l | grep -q "^$NEW_VERSION$"; do
  echo "La version $NEW_VERSION existe déjà comme tag, suppression..."
  git tag -d "$NEW_VERSION" || { echo "Échec de la suppression du tag local"; exit 1; }
  git push origin --delete "$NEW_VERSION" || true
  gh release delete "$NEW_VERSION" --yes || true
  PATCH=$((PATCH + 1))
  NEW_VERSION="$MAJOR.$MINOR.$PATCH"
done
echo "Nouvelle version : $NEW_VERSION"
sed -i "s/version: $CURRENT_VERSION/version: $NEW_VERSION/" pubspec.yaml || { echo "Échec de la mise à jour de pubspec.yaml"; exit 1; }
git add pubspec.yaml

# 2. Générer un changelog propre avec les changements pertinents
echo "Génération du changelog..."
TEMP_CHANGELOG=$(mktemp)
echo "## [$NEW_VERSION] - $(date +%F)" > "$TEMP_CHANGELOG"
echo "" >> "$TEMP_CHANGELOG"

echo "### Added" >> "$TEMP_CHANGELOG"
git log "$COMMIT_RANGE" --pretty=format:"%s" | grep -E "^feat" | sed 's/^feat: \(.*\)/- \1/' >> "$TEMP_CHANGELOG" || echo "- Aucun ajout" >> "$TEMP_CHANGELOG"
echo "" >> "$TEMP_CHANGELOG"

echo "### Changed" >> "$TEMP_CHANGELOG"
git log "$COMMIT_RANGE" --pretty=format:"%s" | grep -E "^fix|^refactor" | sed 's/^\(fix\|refactor\): \(.*\)/- \1: \2/' >> "$TEMP_CHANGELOG" || echo "- Aucun changement" >> "$TEMP_CHANGELOG"
echo "" >> "$TEMP_CHANGELOG"

if [ -f CHANGELOG.md ]; then
  echo "Ancien CHANGELOG.md trouvé, ajout de son contenu..."
  cat CHANGELOG.md >> "$TEMP_CHANGELOG"
else
  echo "Aucun CHANGELOG.md existant trouvé, création d'un nouveau..."
fi

mv "$TEMP_CHANGELOG" CHANGELOG.md
echo "Contenu de CHANGELOG.md après génération :"
cat CHANGELOG.md
git add CHANGELOG.md

# 3. Créer un tag Git
echo "Création du tag Git pour la version $NEW_VERSION..."
git tag -a "$NEW_VERSION" -m "Release $NEW_VERSION" || { echo "Échec de la création du tag"; exit 1; }

# 4. Pousser le tag et les commits
echo "Poussage des commits et du tag..."
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
git commit -m "chore(release): $NEW_VERSION" || { echo "Échec du commit"; exit 1; }
git push origin "$CURRENT_BRANCH" || { echo "Échec du push de la branche"; exit 1; }
git push origin "$NEW_VERSION" || { echo "Échec du push du tag"; exit 1; }

# 5. Créer une release publique (GitHub)
echo "Création de la release publique..."
gh release create "$NEW_VERSION" --title "Release $NEW_VERSION" --notes-file CHANGELOG.md || { echo "Échec de la création de la release"; exit 1; }

echo "Publication terminée avec succès !"