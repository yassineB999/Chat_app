#!/bin/bash

# Stop execution on error
set -e

echo "Démarrage de l'installation initiale..."

# 1. Check if .env exists, if not copy from example
if [ ! -f ../.env ]; then
    echo "Création du fichier .env à partir de .env.example..."
    cp ../.env.example ../.env
    echo "Veuillez éditer ../.env et configurer vos identifiants de base de données et Pusher !"
else
    echo "Le fichier .env existe déjà."
fi

# 2. Build containers
echo "Construction des conteneurs Docker..."
docker-compose build

# 3. Start containers
echo "Démarrage des conteneurs..."
docker-compose up -d

# 4. Wait for database
echo "Attente de l'initialisation de la base de données..."
sleep 20

# 5. Generate Application Key
echo "Génération de la clé d'application..."
docker-compose exec -T nexuschat-app php artisan key:generate

# 6. Run Migrations
echo "Exécution des migrations..."
docker-compose exec -T nexuschat-app php artisan migrate --force

# 7. Link Storage
echo "Création du lien symbolique pour le stockage..."
docker-compose exec -T nexuschat-app php artisan storage:link

echo "Installation terminée ! Votre application devrait être accessible sur http://votre-ip ou http://localhost"
