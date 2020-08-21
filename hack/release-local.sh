#!/bin/bash
set -euo pipefail

REPO="${REPO:-}"

if [ -z "$REPO" ]; then echo "REPO is required"; exit 1; fi

TEMP_COMMIT="false"
test -z "$(git status --porcelain)" || TEMP_COMMIT="true"

if [[ "${TEMP_COMMIT}" == "true" ]]; then
  git add .
  git commit -m "Temporary" || true
fi

REV=$(git rev-parse --short HEAD)
TAG="${TAG:-$REV}"

if [[ -z "${DOCKER+1}" ]] && command -v buildah >& /dev/null; then
  buildah bud -t $REPO:$TAG .
  buildah push $REPO:$TAG docker://$REPO:$TAG
else
  docker build -t $REPO:$TAG .
  docker push $REPO:$TAG
fi

if [[ "${TEMP_COMMIT}" == "true" ]]; then
  git reset --soft HEAD~1
fi

echo "Pushed $REPO:$TAG"
