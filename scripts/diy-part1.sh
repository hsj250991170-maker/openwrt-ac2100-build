#!/bin/bash
# ============================================================
# diy-part1.sh —— 在 feeds update 之前执行
# 作用：添加第三方 feed（OpenClash）、修改软件源等
# ============================================================
set -e

cd "$(dirname "$0")/.."
WORKSPACE_ROOT="$GITHUB_WORKSPACE"
OPENWRT_DIR="$WORKSPACE_ROOT/openwrt"

echo "===== [DIY-1] 当前目录: $(pwd) ====="
echo "===== [DIY-1] OpenWrt 目录: $OPENWRT_DIR ====="

# 进入 OpenWrt 源码目录
cd "$OPENWRT_DIR"

# 1. 添加 OpenClash feed (ImmortalWrt 官方不含 OpenClash)
echo ""
echo "===== [DIY-1] 添加 OpenClash feed ====="
if ! grep -q "OpenClash" feeds.conf.default 2>/dev/null; then
    echo 'src-git openclash https://github.com/vernesong/OpenClash.git;dev' >> feeds.conf.default
fi
cat feeds.conf.default

# 2. 替换 luci-app-passwall 为最新版（可选，immortalwrt 自带的也可用）
# 这里保持使用 ImmortalWrt 自带的 passwall，更稳定

# 3. 替换 git 协议为 https（避免某些网络环境 git:// 失败）
sed -i 's/git:\/\//https:\/\//g' feeds.conf.default 2>/dev/null || true

echo ""
echo "===== [DIY-1] 完成 ====="
