#!/bin/bash

# Stop execution on error
set -e

echo "Démarrage du déploiement..."

# 1. Pull latest changes (if using git)
# git pull origin main

# 2. Build and start containers
echo "Reconstruction et redémarrage des conteneurs..."
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# 3. Wait for database to be ready
echo "Attente de la base de données..."
sleep 10

# 4. Run migrations
echo "Exécution des migrations..."
docker-compose exec -T nexuschat-app php artisan migrate --force

# 5. Clear caches
echo "Nettoyage des caches..."
docker-compose exec -T nexuschat-app php artisan config:clear
docker-compose exec -T nexuschat-app php artisan cache:clear
docker-compose exec -T nexuschat-app php artisan route:clear
docker-compose exec -T nexuschat-app php artisan view:clear

# 6. Optimize
echo "Optimisation..."
docker-compose exec -T nexuschat-app php artisan config:cache
docker-compose exec -T nexuschat-app php artisan route:cache
docker-compose exec -T nexuschat-app php artisan view:cache

echo "Déploiement terminé avec succès !"
