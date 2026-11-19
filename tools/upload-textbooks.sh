#!/usr/bin/env bash
set -euo pipefail

# 在仓库根目录运行：
# bash tools/upload-textbooks.sh "/path/战略管理.pdf" "/path/运营管理.pdf" "/path/技术经济学概论.pdf"

if [[ $# -ne 3 ]]; then
  echo '用法：bash tools/upload-textbooks.sh "战略管理PDF" "运营管理PDF" "技术经济学PDF"' >&2
  exit 2
fi
command -v git >/dev/null || { echo "缺少 git" >&2; exit 2; }
command -v gh >/dev/null || { echo "缺少 gh（GitHub CLI），需要先安装并登录，以核验仓库为 Private" >&2; exit 2; }
command -v git-lfs >/dev/null || git lfs version >/dev/null || { echo "缺少 git-lfs" >&2; exit 2; }

visibility="$(gh repo view Alkaid-9/booooks --json visibility --jq .visibility)"
if [[ "$visibility" != "PRIVATE" ]]; then
  echo "拒绝上传：仓库仍为 $visibility，请先在 GitHub Settings 中改为 Private。" >&2
  exit 1
fi

git lfs install
mkdir -p '战略管理' '运营管理' '技术经济学'
cp -- "$1" '战略管理/教材.pdf'
cp -- "$2" '运营管理/教材.pdf'
cp -- "$3" '技术经济学/教材.pdf'

# 防止误传不一致或截断的文件
printf '%s  %s\n' \
  d586c99944382efeccdf11fad76b2c34eba5ecf05117b18a0996c3e7ca623a64 '战略管理/教材.pdf' \
  61325eb00ce2506c9a95211cf0c22314931bdc8af6db0e14f87c59a3b984a711 '运营管理/教材.pdf' \
  bd54512b3690aa2195dade08ce557f013546256190cdd25516a3c51706cfb4c7 '技术经济学/教材.pdf' | sha256sum -c -

git add .gitattributes '战略管理/教材.pdf' '运营管理/教材.pdf' '技术经济学/教材.pdf'
git commit -m "Add three course textbooks via Git LFS"
git push origin HEAD
echo '三本教材已通过 Git LFS 提交；请检查远端文件及私有可见性。'
