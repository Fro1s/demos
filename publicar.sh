#!/usr/bin/env bash
# Publica as demos no GitHub Pages.
#   ./publicar.sh                  -> publica tudo que mudou
#   ./publicar.sh camarao-e-parmegiana   -> publica so essa pasta
set -e
cd "$(dirname "$0")"

CONTA="$(cat .conta 2>/dev/null || true)"
REPO="$(cat .repo 2>/dev/null || echo demos)"
REMOTO="$(cat .remote 2>/dev/null || echo "git@github.com:$CONTA/$REPO.git")"
if [ -z "$CONTA" ]; then
  echo "Falta o usuario do GitHub. Rode: echo SEU-USUARIO > .conta"
  exit 1
fi

if [ ! -d .git ]; then
  git init -q -b main
fi
git remote remove origin 2>/dev/null || true
git remote add origin "$REMOTO"

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
