#!/usr/bin/env bash
# Publica as demos no GitHub Pages.
#   ./publicar.sh                  -> publica tudo que mudou
#   ./publicar.sh camarao-e-parmegiana   -> publica so essa pasta
set -e
cd "$(dirname "$0")"

CONTA="$(cat .conta 2>/dev/null || true)"
REPO="$(cat .repo 2>/dev/null || echo demos)"
if [ -z "$CONTA" ]; then
  echo "Falta o usuario do GitHub. Rode: echo SEU-USUARIO > .conta"
  exit 1
fi

if [ -f .git-credentials ]; then
  git config --global credential.helper "store --file=$(pwd)/.git-credentials"
fi

if [ ! -d .git ]; then
  git init -q -b main
  git remote add origin "https://github.com/$CONTA/$REPO.git"
fi
git config user.name  "$(git config user.name  || echo 'HIGH Development')" >/dev/null 2>&1 || true
git config user.email "$(git config user.email || echo 'contato@high-development.com.br')" >/dev/null 2>&1 || true

ALVO="${1:-.}"
git add "$ALVO"
if git diff --cached --quiet; then
  echo "Nada mudou."
else
  git commit -q -m "demo: ${1:-atualizacao geral}"
fi
git push -u origin main

echo
echo "No ar em alguns minutos:"
if [ "$ALVO" = "." ]; then
  for d in */; do
    [ -f "$d/index.html" ] && echo "  https://$CONTA.github.io/$REPO/${d%/}/"
  done
else
  echo "  https://$CONTA.github.io/$REPO/$ALVO/"
fi
