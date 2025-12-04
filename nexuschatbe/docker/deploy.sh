#!/bin/bash

# NexusChat - Redéploiement rapide
set -e

echo "🔄 Redéploiement de l'application..."

# 1. Stop containers
echo "Arrêt des conteneurs..."
docker compose down

# 2. Rebuild only the app (fastest)
echo "Reconstruction de l'image..."
docker compose build

# 3. Start everything
echo "Démarrage..."
docker compose up -d

# 4. Wait for MySQL
echo "Attente de MySQL (10s)..."
sleep 10

# 5. Run migrations
echo "Migrations..."
docker compose exec -T nexuschat-app php artisan migrate --force

# 6. Clear and cache
echo "Optimisation..."
docker compose exec -T nexuschat-app php artisan config:clear
docker compose exec -T nexuschat-app php artisan config:cache
docker compose exec -T nexuschat-app php artisan route:cache
docker compose exec -T nexuschat-app php artisan view:cache

echo "✅ Déploiement terminé!"
docker compose ps
