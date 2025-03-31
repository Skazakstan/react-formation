# Infrastructure Terraform avec S3, CloudFront et Route53

Ce projet utilise Terraform pour déployer une application Next.js statique sur S3 avec CloudFront, avec authentification OIDC pour GitHub Actions et gestion complète des enregistrements DNS via Route53.

## Prérequis

- AWS CLI configuré
- Terraform v1.5.0+
- Yarn 1.22+
- Node.js 20+
- Accès AWS avec les permissions nécessaires
- Configuration OIDC entre GitHub et AWS
- Une zone hébergée Route53 pour votre domaine

## Structure du projet

```
terraform/
├── provider.tf                # Configuration des providers
├── main.tf                    # Ressources principales (S3, CloudFront, Route53)
├── variables.tf               # Variables globales
├── terraform.tfvars           # Valeurs par défaut des variables
├── outputs.tf                 # Outputs Terraform
├── iam-permissions.tf         # Politique IAM de référence
└── setup-remote-state.sh      # Script pour créer le bucket S3 d'état
.github/
└── workflows/
    └── terraform-deploy.yml   # Workflow GitHub Actions avec génération dynamique de backend.tf
```

## Gestion des dépendances

Ce projet utilise Yarn comme gestionnaire de paquets. Assurez-vous d'utiliser Yarn et non npm pour installer les dépendances et exécuter les scripts :

```bash
# Installation des dépendances
yarn install

# Démarrer le serveur de développement
yarn dev

# Construire pour la production
yarn build
```

## Flux de travail Git et déploiement

Le projet suit un workflow Git basé sur les branches suivantes:

```
main (production) → déploie sur nextjs.stansk.com
  ↑
staging (développement) → déploie sur dev-nextjs.stansk.com
  ↑
branches de fonctionnalités
```

### Processus de déploiement

1. **Développement de fonctionnalités**:

   - Créez des branches de fonctionnalités à partir de `staging`
   - Ouvrez une PR vers `staging` lorsque la fonctionnalité est prête
   - Les validations Terraform et autres vérifications sont exécutées automatiquement

2. **Déploiement en développement**:

   - Lorsqu'une PR est fusionnée dans `staging`, le workflow déploie automatiquement sur `dev-nextjs.stansk.com`
   - L'équipe peut tester les nouvelles fonctionnalités dans l'environnement de développement

3. **Promotion en production**:
   - Lorsque l'environnement de développement est stable, créez une PR de `staging` vers `main`
   - Après approbation et fusion dans `main`, le workflow déploie automatiquement en production sur `nextjs.stansk.com`

## Gestion des environnements

Cette configuration supporte plusieurs environnements (dev, prod) avec:

1. **Séparation complète des états**:

   - Chaque environnement a son propre bucket d'état: `dev-react-formation-terraform-state` et `prod-react-formation-terraform-state`
   - Le fichier `backend.tf` est généré dynamiquement par le pipeline CI/CD
   - Les pull requests utilisent l'environnement `dev`
   - Les pushes sur `main` utilisent l'environnement `prod`

2. **Préfixage des ressources**:

   - Toutes les ressources sont préfixées avec l'environnement (`dev-`, `prod-`)
   - Cela garantit qu'il n'y a pas de conflit de noms entre environnements

3. **Domaines spécifiques par environnement**:
   - Environnement dev: `dev-nextjs.stansk.com`
   - Environnement prod: `nextjs.stansk.com`
   - Configuration automatique basée sur la variable `environment`

## Infrastructure déployée

Cette configuration Terraform déploie:

1. **Bucket S3** pour héberger le site statique Next.js
2. **Distribution CloudFront** pour servir le contenu avec:
   - Gestion des pages d'erreur (redirection SPA vers index.html)
   - Politiques de cache optimisées
   - Support HTTPS avec certificat SSL
3. **Configuration DNS Route53** avec:
   - Enregistrement A pour l'environnement approprié (dev/prod)
   - Validation automatique des certificats SSL
4. **Intégration CI/CD** via GitHub Actions:
   - Déploiement automatique sur S3
   - Invalidation du cache CloudFront

## Configuration initiale

1. Créer le fournisseur OIDC et le rôle IAM (voir `iam-permissions.tf` pour les permissions requises)

2. **Pour chaque environnement**, exécuter le script de configuration du stockage distant:

   ```bash
   # Pour l'environnement dev
   ./terraform/setup-remote-state.sh dev

   # Pour l'environnement prod
   ./terraform/setup-remote-state.sh prod
   ```

   > **Important**: Ce script crée uniquement les buckets S3 pour stocker l'état Terraform. Le fichier `backend.tf` est généré dynamiquement par le pipeline CI/CD.

3. Configurer les variables GitHub:

   - `AWS_ACCOUNT_ID`: ID de votre compte AWS (pour le rôle OIDC)

4. Créer la branche `staging`:
   ```bash
   git checkout -b staging
   git push origin staging
   ```

## Déploiement manuel

Pour les déploiements manuels, vous devez spécifier le backend correspondant à l'environnement:

```bash
cd terraform

# Pour l'environnement dev
echo 'terraform {
  backend "s3" {
    bucket         = "dev-react-formation-terraform-state"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}' > backend.tf

terraform init
terraform plan -var="environment=dev"
terraform apply -var="environment=dev"

# Pour l'environnement prod
echo 'terraform {
  backend "s3" {
    bucket         = "prod-react-formation-terraform-state"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}' > backend.tf

terraform init -reconfigure
terraform plan -var="environment=prod"
terraform apply -var="environment=prod"
```

## Configuration Route53 et domaine

La configuration des domaines est automatique et basée sur l'environnement:

- Environnement `dev` → `dev-nextjs.stansk.com`
- Environnement `prod` → `nextjs.stansk.com`

La logique de construction du nom de domaine est définie dans `main.tf`:

```hcl
locals {
  domain_prefix = var.environment == "prod" ? "" : "${var.environment}-"
  full_domain_name = "${local.domain_prefix}nextjs.${var.parent_domain}"
}
```

## Déploiement automatisé

Le déploiement est automatiquement déclenché par:

- **Push sur main**: déploie en environnement **prod** sur `nextjs.stansk.com`
- **Push sur staging**: déploie en environnement **dev** sur `dev-nextjs.stansk.com`
- **Pull Request**: planifie et affiche un plan Terraform sans application

Le workflow utilise l'authentification OIDC avec AWS, éliminant le besoin de stocker des secrets AWS à long terme.

## Rafraîchissement du cache CloudFront

Le workflow GitHub Actions invalide automatiquement le cache CloudFront après chaque déploiement.

Manuellement, vous pouvez utiliser:

```bash
aws cloudfront create-invalidation --distribution-id <DISTRIBUTION_ID> --paths "/*"
```

## Notes importantes

- Le stockage d'état utilise uniquement S3 sans mécanisme de verrouillage (pas de DynamoDB)
- Attention aux modifications simultanées qui pourraient causer des conflits d'état
- L'authentification OIDC est plus sécurisée que l'utilisation de clés d'accès statiques
