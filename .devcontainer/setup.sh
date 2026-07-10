#!/bin/bash
set -e

echo "🚀 GEOFlow Codespaces 初始化..."

# Copy .env.example to .env if not exists
if [ ! -f .env ]; then
    cp .env.example .env
    echo "✅ .env 已创建"
fi

# Fix APP_KEY
if grep -q 'APP_KEY=$' .env || grep -q 'APP_KEY=$' .env; then
    sed -i 's/APP_KEY=$/APP_KEY=base64:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/' .env
    php artisan key:generate --force
    echo "✅ APP_KEY 已生成"
fi

# Set local settings
sed -i 's/APP_ENV=production/APP_ENV=local/' .env
sed -i 's/APP_DEBUG=false/APP_DEBUG=true/' .env
sed -i 's|APP_URL=https://your-domain.com|APP_URL=http://localhost:18080|' .env
sed -i 's/DB_HOST=127.0.0.1/DB_HOST=postgres/' .env
sed -i 's/DB_PORT=5432/DB_PORT=5432/' .env
sed -i 's/DB_DATABASE=.*/DB_DATABASE=geo_flow/' .env
sed -i 's/DB_USERNAME=.*/DB_USERNAME=geo_user/' .env
sed -i 's/DB_PASSWORD=.*/DB_PASSWORD=geo_password/' .env
sed -i 's/CACHE_STORE=.*/CACHE_STORE=redis/' .env
sed -i 's/REDIS_HOST=127.0.0.1/REDIS_HOST=redis/' .env
sed -i 's/REDIS_PORT=.*/REDIS_PORT=6379/' .env

echo "✅ .env 配置完成"

# Start services
echo "🚀 启动 PostgreSQL 和 Redis..."
cd /workspace/GEOFlow/.devcontainer
docker compose up -d postgres redis
echo "⏳ 等待 PostgreSQL 就绪..."
sleep 5
docker compose up -d postgres redis
until docker compose exec -T postgres pg_isready -U geo_user -d geo_flow > /dev/null 2>&1; do
    sleep 2
    echo "等待 PostgreSQL..."
done
echo "✅ PostgreSQL 就绪"

# Install PHP dependencies
echo "📦 安装 PHP 依赖..."
cd /workspace/GEOFlow
composer install --no-interaction --prefer-dist

# Install Node dependencies & build
echo "📦 安装 Node 依赖..."
npm ci --include=dev
npm run build

# Run migrations
echo "📦 运行数据库迁移..."
php artisan migrate --force

# GEOFlow install
echo "🔧 GEOFlow 安装..."
php artisan geoflow:install --force 2>/dev/null || true

echo ""
echo "============================================"
echo "🎉 GEOFlow 启动完成！"
echo "🌐 访问地址: http://localhost:18080"
echo "👤 管理员账号: admin"
echo "🔑 管理员密码: password"
echo "============================================"