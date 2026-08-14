#!/bin/bash
# ============================================================
# One-shot dbt + Snowflake setup script
# Run from the healthcare_proj directory
# ============================================================
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROFILES_SRC="$PROJECT_DIR/profiles.yml"
PROFILES_DEST="$HOME/.dbt/profiles.yml"

echo "==> Creating Python virtual environment..."
python3 -m venv "$PROJECT_DIR/.venv"
source "$PROJECT_DIR/.venv/bin/activate"

echo "==> Installing dbt-core and dbt-snowflake..."
pip install --upgrade pip
pip install dbt-core dbt-snowflake

echo "==> Copying profiles.yml to ~/.dbt/ ..."
mkdir -p "$HOME/.dbt"
cp "$PROFILES_SRC" "$PROFILES_DEST"
echo "    Wrote: $PROFILES_DEST"

echo ""
echo "✅ dbt installed: $(dbt --version)"
echo ""
echo "Next steps:"
echo "  1. Run ./generate_keys.sh  — generates RSA keys & prints ALTER USER SQL"
echo "  2. Run the ALTER USER SQL in Snowflake (snowflake_setup.sql has the full setup)"
echo "  3. Run: source .venv/bin/activate && dbt debug"
