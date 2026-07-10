#!/bin/bash
set -e

echo "馃寠 GEOFlow Codespaces 鍒濆鍖?(SQLite 妯″紡)..."

# Copy .env.example to .env if not exists
if [ ! -f .env ]; then
    cp .env.example .env
    echo "鉁?.env 宸插垱寤?
fi

# Disable broadcasting (not needed in dev/Codespaces)
cat >> .env <<'EOF'
BROADCAST_DRIVER=log
PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME=https
PUSHER_APP_CLUSTER=mt1
VITE_PUSHER_KEY=
VITE_PUSHER_HOST=
VITE_PUSHER_PORT=443
VITE_PUSHER_SCHEME=https
VITE_PUSHER_APP_CLUSTER=mt1
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:18080
CACHE_STORE=file
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
DB_CONNECTION=sqlite
DB_DATABASE=database/database.sqlite
EOF

echo "鉁?.env 閰嶇疆瀹屾垚"

# Create SQLite database file
mkdir -p database
touch database/database.sqlite

# Install PHP dependencies (skip scripts to avoid Pusher error)
echo "馃摝 瀹夎 PHP 渚濊禆..."
composer install --no-interaction --prefer-dist --no-scripts

# Install Node dependencies & build
echo "馃摝 瀹夎 Node 渚濊禆..."
npm ci --include=dev
npm run build

# Generate app key
echo "馃攽 鐢熸垚 APP_KEY..."
php artisan key:generate --force

# Run migrations
echo "馃梽锔?杩愯鏁版嵁搴撹縼绉?.."
php artisan migrate --force

# GEOFlow install
echo "鈿欙笍 GEOFlow 瀹夎..."
php artisan geoflow:install --force 2>/dev/null || true

echo ""
echo "============================================"
echo "鉁?GEOFlow 鍒濆鍖栧畬鎴愶紒"
echo "馃寪 璁块棶鍦板潃: http://localhost:18080"
echo "馃懁 绠＄悊鍛樿处鍙? admin"
echo "馃攽 绠＄悊鍛樺瘑鐮? password"
echo "============================================"
echo "杩愯 'php artisan serve --port=18080' 鍚姩鏈嶅姟"
