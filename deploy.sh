#!/bin/bash

# CC Wiki 部署脚本
# 用于腾讯云服务器自动部署

set -e

# 配置
WIKI_DIR="/var/www/wiki"
REPO_DIR="/opt/cc-wiki"
NGINX_USER="www"

echo "========== CC Wiki 部署开始 =========="

# 1. 进入仓库目录
cd $REPO_DIR

# 2. 拉取最新代码
echo "[1/5] 拉取代码..."
git fetch origin main
git reset --hard origin/main

# 3. 安装依赖（如有更新）
echo "[2/5] 安装依赖..."
npm ci --silent

# 4. 构建 Quartz
echo "[3/5] 构建网站..."
npm run quartz -- build --concurrency=1

# 5. 复制到 Nginx 目录
echo "[4/5] 部署到 Nginx..."
rm -rf $WIKI_DIR/*
cp -r public/* $WIKI_DIR/

# 6. 权限设置
echo "[5/5] 设置权限..."
chown -R $NGINX_USER:$NGINX_USER $WIKI_DIR

echo "========== 部署完成 =========="