#!/bin/bash
# =============================================================
# setup_github.sh
# สร้าง git repo และ push ขึ้น GitHub: vacharapat/minizinc-training
#
# วิธีใช้:
#   1. เปิด Terminal
#   2. cd ไปที่ folder นี้
#   3. chmod +x setup_github.sh
#   4. ./setup_github.sh
#
# ต้องการ: git + gh (GitHub CLI) หรือ Personal Access Token
# =============================================================

set -e  # หยุดทันทีถ้ามี error

REPO_NAME="minizinc-training"
GITHUB_USER="vacharapat"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📂 Working directory: $SCRIPT_DIR"
cd "$SCRIPT_DIR"

# ── 1. Init git ──────────────────────────────────────────────
echo ""
echo "🔧 Initializing git repository..."

# ลบ lock file หรือ .git ที่ไม่สมบูรณ์จากการรันครั้งก่อน
if [ -f ".git/index.lock" ]; then
    echo "  ⚠️  Found stale .git/index.lock — removing..."
    rm -f ".git/index.lock"
fi
if [ -d ".git" ] && ! git rev-parse --git-dir &>/dev/null 2>&1; then
    echo "  ⚠️  Found broken .git directory — removing..."
    rm -rf ".git"
fi

git init
git branch -m main
git config user.email "vacharapat@eng.src.ku.ac.th"
git config user.name "vacharapat"

# ── 2. Add files ─────────────────────────────────────────────
echo "📦 Adding all files (solution files excluded via .gitignore)..."
git add .
echo "   Tracked: $(git status --short | wc -l) files"
echo "   Excluded (*_solution.mzn): $(find . -name '*_solution.mzn' | wc -l) files"

# ── 3. Initial commit ────────────────────────────────────────
echo ""
echo "💾 Creating initial commit..."
git commit -m "Initial commit: MiniZinc 6-day industrial training course

- 6 days of slides (Day1-Day6 .pptx)
- 69 MiniZinc model files (.mzn) and data files (.dzn)
- Topics: basics, arrays/enums, global constraints,
  scheduling, routing/packing, effective modelling
- Workshops with starter + solution files for each day
- Debugging challenges and capstone template
- Course overview document (MiniZinc_Training_Curriculum.docx)"

# ── 4. Create GitHub repo ────────────────────────────────────
echo ""
echo "🐙 Creating GitHub repository..."

if command -v gh &>/dev/null; then
    # ใช้ GitHub CLI ถ้ามี
    echo "  Using GitHub CLI..."
    gh auth status 2>/dev/null || gh auth login
    gh repo create "$GITHUB_USER/$REPO_NAME" \
        --public \
        --description "MiniZinc 6-day training course for industrial optimization" \
        --source=. \
        --remote=origin \
        --push
    echo ""
    echo "✅ Done! Repository created and pushed."
    echo "🔗 https://github.com/$GITHUB_USER/$REPO_NAME"

else
    # ไม่มี gh CLI — ใช้ HTTPS + Personal Access Token
    echo ""
    echo "  GitHub CLI not found. Using HTTPS with Personal Access Token..."
    echo ""
    echo "  ─────────────────────────────────────────────────────────"
    echo "  กรุณาสร้าง Personal Access Token ก่อน:"
    echo "  1. ไปที่ https://github.com/settings/tokens/new"
    echo "  2. Note: minizinc-training-push"
    echo "  3. Expiration: 7 days (หรือตามต้องการ)"
    echo "  4. Scopes: ✅ repo (เลือกทั้งหมด)"
    echo "  5. คลิก 'Generate token' แล้ว COPY ค่าที่ได้"
    echo "  ─────────────────────────────────────────────────────────"
    echo ""
    read -s -p "  Paste Personal Access Token here (ไม่แสดงบนหน้าจอ): " PAT
    echo ""

    # สร้าง repo บน GitHub ผ่าน API
    echo "  Creating repository on GitHub..."
    RESPONSE=$(curl -s -w "\n%{http_code}" \
        -H "Authorization: token $PAT" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/user/repos \
        -d "{\"name\":\"$REPO_NAME\",\"description\":\"MiniZinc 6-day training course for industrial optimization\",\"private\":false}")

    HTTP_CODE=$(echo "$RESPONSE" | tail -1)
    BODY=$(echo "$RESPONSE" | head -1)

    if [ "$HTTP_CODE" = "201" ]; then
        echo "  ✅ Repository created!"
    elif echo "$BODY" | grep -q "already exists"; then
        echo "  ℹ️  Repository already exists, continuing..."
    else
        echo "  ❌ Error creating repo (HTTP $HTTP_CODE):"
        echo "$BODY" | python3 -c "import sys,json; d=json.load(sys.stdin); print('  ', d.get('message','Unknown error'))" 2>/dev/null || echo "$BODY"
        exit 1
    fi

    # Set remote และ push
    REMOTE_URL="https://${PAT}@github.com/${GITHUB_USER}/${REPO_NAME}.git"
    git remote add origin "$REMOTE_URL" 2>/dev/null || git remote set-url origin "$REMOTE_URL"

    echo "  Pushing to GitHub..."
    git push -u origin main

    # ลบ PAT จาก remote URL เพื่อความปลอดภัย
    git remote set-url origin "https://github.com/${GITHUB_USER}/${REPO_NAME}.git"

    echo ""
    echo "✅ Done! Repository pushed successfully."
    echo "🔗 https://github.com/$GITHUB_USER/$REPO_NAME"
fi
