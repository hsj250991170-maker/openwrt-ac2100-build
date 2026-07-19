#!/bin/bash
# ============================================================
# diy-part2.sh —— 在 feeds install 之后、生成 .config 之前执行
# 作用：修改默认设置（IP、主机名、主题、时区等）
# ============================================================
set -e

WORKSPACE_ROOT="$GITHUB_WORKSPACE"
OPENWRT_DIR="$WORKSPACE_ROOT/openwrt"
cd "$OPENWRT_DIR"

echo "===== [DIY-2] 进入 $OPENWRT_DIR ====="

# ------------------------------------------------------------
# 1. 修改默认 LAN IP（避免和主路由 192.168.1.1 冲突）
#    设为 192.168.31.1（小米原厂同网段，方便 Breed 刷完直接进）
# ------------------------------------------------------------
echo "===== [DIY-2] 修改默认 LAN IP 为 192.168.31.1 ====="
sed -i 's/192\.168\.1\.1/192.168.31.1/g' package/base-files/files/bin/config_generate 2>/dev/null || true

# ------------------------------------------------------------
# 2. 修改主机名
# ------------------------------------------------------------
echo "===== [DIY-2] 修改主机名 ====="
sed -i 's/OpenWrt/AC2100/g' package/base-files/files/bin/config_generate 2>/dev/null || true

# ------------------------------------------------------------
# 3. 修改默认时区为东八区
# ------------------------------------------------------------
echo "===== [DIY-2] 设置时区 ====="
sed -i "s/.*timezone=.*/        set timezone='CST-8'/g" package/base-files/files/bin/config_generate 2>/dev/null || true

# ------------------------------------------------------------
# 4. 设置默认主题为 argon
# ------------------------------------------------------------
echo "===== [DIY-2] 设置默认主题 ====="
mkdir -p package/lean/default-settings/files 2>/dev/null || true
if [ -f package/lean/default-settings/files/zzz-default-settings ]; then
    sed -i '/exit 0/i uci set luci.main.mediaurlbase="/luci-static/argon"' \
        package/lean/default-settings/files/zzz-default-settings 2>/dev/null || true
fi

# ------------------------------------------------------------
# 5. 内置自定义文件 (files/ 目录会被原样拷贝到固件根目录)
# ------------------------------------------------------------
echo "===== [DIY-2] 拷贝自定义 files/ ====="
if [ -d "$WORKSPACE_ROOT/files" ] && [ "$(ls -A $WORKSPACE_ROOT/files 2>/dev/null)" ]; then
    cp -rf "$WORKSPACE_ROOT/files/." "$OPENWRT_DIR/files/" 2>/dev/null || true
    echo "files/ 已拷贝"
else
    echo "files/ 为空或不存在，跳过"
fi

# ------------------------------------------------------------
# 6. 给 OpenClash 预置 mihomo 内核下载脚本（首次启动时下载 mipsel 版内核）
#    因为编译期下载 mihomo 内核会被 GitHub Actions 网络限制，且体积大
#    这里在系统启动时检查并下载
# ------------------------------------------------------------
echo "===== [DIY-2] 配置 OpenClash mihomo 内核自动下载 ====="
mkdir -p "$OPENWRT_DIR/etc/init.d" 2>/dev/null || true
# 这一步通过 files/ 在 diy-part2 完成更清晰，所以这里跳过

echo ""
echo "===== [DIY-2] 完成 ====="
