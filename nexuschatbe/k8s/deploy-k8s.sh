#!/bin/bash

# NexusChat Kubernetes Deployment Script
set -e

echo "Déploiement de NexusChat sur Kubernetes..."

# 1. Create namespace
echo "1. Création du namespace..."
kubectl apply -f namespace.yaml

# 2. Create ConfigMap and Secrets
echo "2. Configuration des secrets et configmaps..."
kubectl apply -f configmap.yaml
kubectl apply -f secrets.yaml

# 3. Deploy MySQL
echo "3. Déploiement de MySQL..."
kubectl apply -f mysql-deployment.yaml

# Wait for MySQL to be ready
echo "Attente de MySQL..."
kubectl wait --for=condition=ready pod -l app=mysql -n nexuschat --timeout=120s

# 4. Run migrations
echo "4. Exécution des migrations..."
kubectl apply -f migration-job.yaml
kubectl wait --for=condition=complete job/laravel-migration -n nexuschat --timeout=300s

# 5. Deploy Laravel app
echo "5. Déploiement de l'application Laravel..."
kubectl apply -f laravel-deployment.yaml

# 6. Deploy Nginx
echo "6. Déploiement de Nginx..."
kubectl apply -f nginx-deployment.yaml

# 7. Show status
echo ""
echo "✅ Déploiement terminé!"
echo ""
echo "Status des pods:"
kubectl get pods -n nexuschat

echo ""
echo "Services:"
kubectl get svc -n nexuschat

echo ""
echo "Pour accéder à l'application:"
echo "kubectl port-forward -n nexuschat svc/nginx 8080:80"
echo "Puis ouvrez: http://localhost:8080"
