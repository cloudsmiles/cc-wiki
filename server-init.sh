#!/bin/bash

# CC Wiki 服务器初始化脚本
# 在腾讯云 CentOS 服务器上运行

set -e

echo "========== CC Wiki 服务器初始化 =========="

# 1. 安装 Node.js 18
echo "[1/6] 安装 Node.js 18..."
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# 2. 安装 Nginx
echo "[2/6] 安装 Nginx..."
yum install -y nginx
systemctl enable nginx
systemctl start nginx

# 3. 创建目录
echo "[3/6] 创建目录..."
mkdir -p /var/www/wiki
mkdir -p /opt/cc-wiki

# 4. 克隆仓库（请替换为你的仓库地址）
echo "[4/6] 克隆仓库..."
cd /opt/cc-wiki
git clone https://github.com/YOUR_USERNAME/cc-wiki.git .
git checkout -b main

# 5. 安装依赖
echo "[5/6] 安装依赖..."
npm ci

# 6. 首次构建
echo "[6/6] 首次构建..."
npm run quartz -- build
cp -r public/* /var/www/wiki/

# 7. 配置权限
echo "配置权限..."
chown -R nginx:nginx /var/www/wiki
chown -R nginx:nginx /opt/cc-wiki

# 8. 配置定时任务
echo "配置定时任务..."
echo "*/5 * * * * cd /opt/cc-wiki && git pull && npm run quartz -- build --concurrency=1 && cp -r public/* /var/www/wiki/ && chown -R nginx:nginx /var/www/wiki" >> /etc/crontab

echo "========== 初始化完成 =========="
echo "请修改 Nginx 配置以指向 /var/www/wiki"
echo "并在 GitHub 上配置仓库"