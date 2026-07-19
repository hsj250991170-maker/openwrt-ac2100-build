#!/bin/sh
# ============================================================
# oc-mihomo-helper —— OpenClash mihomo 内核下载辅助脚本
# 适用于小米/红米 AC2100 (MT7621, mipsel, soft-float)
#
# 使用方法：
#   sh /usr/bin/oc-mihomo-helper.sh            # 下载 latest
#   sh /usr/bin/oc-mihomo-helper.sh v1.18.5    # 指定版本
#
# 下载后内核会被放到 OpenClash 默认路径 /etc/openclash/core/
# ============================================================
set -e

CORE_DIR="/etc/openclash/core"
ARCH_FILE="mihomo-linux-mips-LE-softfloat"  # MT7621 = mipsel soft-float
META_BASE="https://github.com/MetaCubeX/mihomo/releases"
TMP_DIR="/tmp/oc-mihomo-tmp"

VERSION="${1:-latest}"
mkdir -p "$CORE_DIR" "$TMP_DIR"

echo "==> 查询 mihomo 版本: $VERSION"
if [ "$VERSION" = "latest" ]; then
    # 通过 GitHub API 拿最新版 tag
    TAG=$(curl -fsSL "https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" \
        | grep -o '"tag_name": *"v[^"]*"' | head -1 | sed 's/.*"v/v/;s/"$//')
    [ -z "$TAG" ] && TAG="v1.18.10"  # fallback
else
    TAG="$VERSION"
    case "$TAG" in
        v*) ;;
        *) TAG="v$TAG" ;;
    esac
fi
echo "==> 目标版本: $TAG"

URL="$META_BASE/download/$TAG/$ARCH_FILE-$TAG.gz"
echo "==> 下载地址: $URL"
echo "==> 如果直连慢，请 Ctrl+C 后用代理重试，或手动下载后用 scp 传到 $CORE_DIR"

cd "$TMP_DIR"
curl -fSL -o mihomo.gz "$URL"
echo "==> 校验文件..."
file mihomo.gz | grep -qi gzip || { echo "!! 下载的不是 gzip 文件，可能 URL 失效"; exit 1; }

echo "==> 解压..."
gunzip -c mihomo.gz > mihomo
chmod +x mihomo
# 校验是 mipsel 可执行
ELF_MAGIC=$(head -c 20 mihomo | xxd | head -1)
echo "==> ELF 头: $ELF_MAGIC"
echo "$ELF_MAGIC" | grep -q "7f45 4c46" || { echo "!! 不是 ELF 文件"; exit 1; }
echo "$ELF_MAGIC" | grep -q "0102 0001" || echo "!! 警告: 不是 mipsel big-endian 检查跳过"

# 移动到 OpenClash core 目录
mv -f mihomo "$CORE_DIR/mihomo"
ls -lh "$CORE_DIR/mihomo"
echo ""
echo "==> 完成。请到 OpenClash -> 内核管理 刷新即可看到 mihomo 内核。"
echo "==> 或在 LuCI 中执行: /etc/init.d/openclash restart"
