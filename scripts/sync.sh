#!/bin/bash
# Dropbox → GitHub Pages 自動同期スクリプト
# kyoto-workation-2026 用

SRC="/Users/yugo/Dropbox/Obsidian/obsidian_all/FP/AssetG/2604ワーケーション京都/ワーク/小池担当"
DEST="/Users/yugo/kyoto-workation-2026"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
LOG="/Users/yugo/kyoto-workation-2026/scripts/sync.log"

FILES=(
  "session1/slides_session1.html"
  "session1/worksheet_session1.html"
  "session2/slides_session2.html"
)

CHANGED=false

for f in "${FILES[@]}"; do
  if [ ! -f "$SRC/$f" ]; then
    continue
  fi
  # ファイルが異なる場合のみコピー
  if ! cmp -s "$SRC/$f" "$DEST/$f"; then
    cp "$SRC/$f" "$DEST/$f"
    # HTMLからPDFを生成
    PDF="${f%.html}.pdf"
    "$CHROME" --headless --disable-gpu --print-to-pdf="$DEST/$PDF" --no-pdf-header-footer "$DEST/$f" 2>/dev/null
    CHANGED=true
    echo "$(date '+%Y-%m-%d %H:%M:%S') 更新: $f" >> "$LOG"
  fi
done

# PDFのみの更新もチェック
PDF_FILES=(
  "session1/slides_session1.pdf"
  "session1/worksheet_session1.pdf"
  "session2/worksheet_session2.pdf"
  "session2/slides_session2.pdf"
)

for f in "${PDF_FILES[@]}"; do
  HTML="${f%.pdf}.html"
  # HTMLが元ファイルに無い場合、PDFだけ直接コピー
  if [ ! -f "$SRC/$HTML" ] && [ -f "$SRC/$f" ]; then
    if ! cmp -s "$SRC/$f" "$DEST/$f"; then
      cp "$SRC/$f" "$DEST/$f"
      CHANGED=true
      echo "$(date '+%Y-%m-%d %H:%M:%S') 更新(PDF直接): $f" >> "$LOG"
    fi
  fi
done

if [ "$CHANGED" = true ]; then
  cd "$DEST"
  git add -A
  git commit -m "auto-sync: ワークシート・スライドを自動更新 $(date '+%Y-%m-%d %H:%M')"
  git push
  echo "$(date '+%Y-%m-%d %H:%M:%S') push完了" >> "$LOG"
fi
