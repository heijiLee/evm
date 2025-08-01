#!/bin/bash

# How to use : ./build-evmds.sh "branch-name"

# 사용법 체크
if [ -z "$1" ]; then
  echo "❌ 브랜치 이름을 인자로 넣어주세요."
  echo "예: ./build_evmd_pair.sh my-feature-branch"
  exit 1
fi

BRANCH_NAME="$1"

set -e  

# 1. main branch checkout & build
echo "🔄 Checking out main branch..."
git checkout main

echo "🔨 Building main version..."
make install

echo "📦 Copying main binary to ../bin/evmd-main..."
cp "$(which evmd)" ./bin/evmd-main

# 2. branch checkout & build
echo "🔀 Switching to $BRANCH_NAME branch..."
git checkout "$BRANCH_NAME"

echo "🔨 Building modified version ($BRANCH_NAME)..."
make install

echo "📦 Copying modified binary to ../bin/evmd-modified..."
cp "$(which evmd)" ./bin/evmd-modified

echo "✅ All done!"