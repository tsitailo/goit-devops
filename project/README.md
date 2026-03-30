# Terraform + Helm + Jenkins CI/CD — Project

## Опис проєкту

Повна CI/CD інфраструктура на AWS з автоматизованим розгортанням Django-застосунку через GitOps:

- **S3 + DynamoDB** — зберігання та блокування Terraform стейтів
- **VPC** — мережева інфраструктура з публічними та приватними підмережами
- **ECR** — реєстр Docker-образів
- **EKS** — Kubernetes кластер (1.29) у приватних підмережах
- **RDS** — база даних (Aurora Cluster або звичайна RDS instance) у приватних підмережах
- **Secrets Manager + ESO** — безпечне зберігання пароля БД без хардкоду в Git
- **Jenkins** — CI сервер, розгорнутий через Helm + Terraform, з Kaniko та Git агентами
- **Argo CD** — GitOps CD, автоматично синхронізує зміни з Git
- **Helm chart** — деплой Django-застосунку з HPA, ConfigMap, LoadBalancer

## Архітектура CI/CD

```
Developer push
      │
      ▼
  GitHub repo ──────────────────────────────────┐
      │                                          │
      ▼                                          │ watch (Argo CD)
  Jenkins Pipeline                              │
  ┌────────────────────────┐                    │
  │ Stage 1: Build & Push  │                    │
  │   Kaniko container     │                    │
  │   → ECR push           │                    │
  └────────────────────────┘                    │
  ┌────────────────────────┐                    │
  │ Stage 2: Update Values │                    │
  │   git clone repo       │                    │
  │   sed image tag        │                    │
  │   git push → main ─────┼────────────────────┘
  └────────────────────────┘
                                      │
                                      ▼
                               Argo CD sync
                                      │
                                      ▼
                              EKS: helm upgrade
                              django-app deployment
```

## Архітектура управління секретами

```
terraform apply
      │
      ▼
AWS Secrets Manager
  "project-db/db-password"
  { password, username, dbname, host, port }
      │
      ▼ (IRSA: ESO ServiceAccount → IAM Role → GetSecretValue)
External Secrets Operator (namespace: external-secrets)
      │
      ▼
K8s Secret: <release>-db-secret
  DATABASE_PASSWORD: <value>
      │
      ▼ (secretKeyRef)
Django Pod env: DATABASE_PASSWORD
```

`DATABASE_PASSWORD` **ніколи не потрапляє у Git** — ні в `values.yaml`, ні в ConfigMap.

## Структура проєкту

```
project/
├── main.tf                  # Підключення всіх модулів
├── backend.tf               # S3 бекенд для стейтів
├── variables.tf             # Змінні кореневого модуля
├── outputs.tf               # Вихідні дані
├── Jenkinsfile              # CI/CD pipeline
├── README.md
│
├── modules/
│   ├── s3-backend/          # S3 + DynamoDB для стейтів
│   ├── vpc/                 # VPC, підмережі, IGW, NAT GW
│   ├── ecr/                 # ECR репозиторій
│   ├── eks/                 # EKS кластер + OIDC + EBS CSI Driver
│   ├── rds/                 # RDS — Aurora або звичайна instance
│   │   ├── rds.tf           # aws_db_instance (use_aurora = false)
│   │   ├── aurora.tf        # aws_rds_cluster + instances (use_aurora = true)
│   │   ├── shared.tf        # Subnet Group, Security Group, Parameter Group
│   │   ├── secrets.tf       # aws_secretsmanager_secret з паролем БД
│   │   ├── variables.tf
│   │   └── outputs.tf       # endpoint, port, secret_arn, secret_name
│   ├── external_secrets/    # External Secrets Operator
│   │   ├── eso.tf           # Helm release ESO + IRSA IAM role
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   └── outputs.tf       # eso_irsa_role_arn
│   ├── jenkins/             # Jenkins via Helm + IRSA IAM role
│   │   ├── jenkins.tf       # Helm release
│   │   ├── irsa.tf          # IAM Role for Service Account (ECR push)
│   │   ├── values.yaml      # Jenkins Helm values (JCasC + Kaniko pod template)
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── argo_cd/             # Argo CD via Helm + Application
│       ├── argocd.tf
│       ├── variables.tf
│       ├── providers.tf
│       ├── values.yaml
│       ├── outputs.tf
│       └── charts/
│           ├── Chart.yaml
│           ├── values.yaml
│           └── templates/
│               ├── application.yaml
│               └── repository.yaml
│
└── charts/
    └── django-app/          # Helm chart для Django застосунку
        ├── Chart.yaml
        ├── values.yaml      # image.tag оновлюється pipeline; без паролів
        └── templates/
            ├── deployment.yaml   # DATABASE_PASSWORD із K8s Secret
            ├── service.yaml
            ├── configmap.yaml
            ├── secretstore.yaml  # ESO SecretStore → AWS Secrets Manager
            ├── externalsecret.yaml # ESO ExternalSecret → K8s Secret
            └── hpa.yaml
```

## Модуль RDS

Універсальний модуль, який розгортає або Aurora Cluster, або звичайну RDS instance залежно від змінної `use_aurora`. Пароль БД **автоматично зберігається** в AWS Secrets Manager.

### Логіка перемикання

| `use_aurora` | Що створюється |
|---|---|
| `false` (default) | `aws_db_instance` + `aws_db_parameter_group` |
| `true` | `aws_rds_cluster` + writer instance + N reader instances + `aws_rds_cluster_parameter_group` |

В обох випадках автоматично створюються:
- `aws_db_subnet_group` — з приватних підмереж VPC
- `aws_security_group` — з доступом лише з CIDR/SG зазначених у змінних
- Parameter Group з параметрами: `max_connections`, `log_statement`, `work_mem`
- `aws_secretsmanager_secret` — зберігає `{password, username, dbname, host, port}` як JSON

### Розгортання звичайної RDS (PostgreSQL)

```bash
terraform apply \
  -var="rds_db_password=secret" \
  -var="jenkins_admin_password=admin" \
  -var="github_repo_url=https://github.com/<org>/<repo>" \
  -var="github_ssh_key=$(cat ~/.ssh/id_rsa)"
```

### Розгортання Aurora PostgreSQL

```bash
terraform apply \
  -var="rds_use_aurora=true" \
  -var="rds_engine=aurora-postgresql" \
  -var="rds_engine_version=15.4" \
  -var="rds_instance_class=db.r6g.large" \
  -var="rds_aurora_replica_count=1" \
  -var="rds_db_password=secret" \
  -var="jenkins_admin_password=admin" \
  -var="github_repo_url=https://github.com/<org>/<repo>" \
  -var="github_ssh_key=$(cat ~/.ssh/id_rsa)"
```

## Модуль External Secrets Operator

Встановлює [External Secrets Operator](https://external-secrets.io) через Helm та налаштовує IRSA роль, що дозволяє ESO читати секрети з AWS Secrets Manager **без статичних AWS ключів**.

### Потік секрету від Terraform до Pod

1. `terraform apply` → пароль записується у AWS Secrets Manager (`rds_identifier/db-password`)
2. ESO `SecretStore` підключається до Secrets Manager через IRSA
3. ESO `ExternalSecret` синхронізує пароль у K8s Secret `<release>-db-secret` (оновлення кожну годину)
4. Django Pod читає `DATABASE_PASSWORD` через `secretKeyRef`

### Налаштування в Helm chart

У [charts/django-app/values.yaml](charts/django-app/values.yaml) вкажіть:

```yaml
externalSecrets:
  region: "us-west-2"                    # AWS регіон
  secretName: "project-db/db-password"   # Назва секрету в Secrets Manager
```

Назва секрету формується автоматично: `<rds_identifier>/db-password`.

## Як працює pipeline

### Jenkinsfile stages

| Stage | Agent container | Дія |
|-------|----------------|-----|
| `Build & Push` | `kaniko` | Збирає Docker-образ із `Dockerfile`, пушить до ECR з тегом `{BUILD_NUMBER}-{GIT_COMMIT:7}` та `latest`. Авторизація через IRSA (без AWS ключів). |
| `Update Helm Values` | `git` | Клонує репо, оновлює `image.tag` у `charts/django-app/values.yaml`, комітить та пушить у `main` з `[skip ci]`. |

### Jenkins Kubernetes Agent

Pod template `kaniko` містить два контейнери:
- **kaniko** (`gcr.io/kaniko-project/executor:v1.21.0-debug`) — збирає образи без Docker daemon
- **git** (`alpine/git:latest`) — клонує репо та пушить зміни

### IRSA для ECR push

Jenkins ServiceAccount отримує IAM роль через OIDC, що дозволяє Kaniko пушити образи до ECR **без AWS access keys** у Jenkins credentials.

## Передумови

- AWS CLI налаштований та автентифікований
- Terraform >= 1.6.0
- kubectl
- Helm >= 3.0
- Достатні IAM права (EKS, EC2, IAM, S3, DynamoDB, ECR, RDS, SecretsManager)

## Швидкий старт

### Крок 1: Оновіть змінні

У [variables.tf](variables.tf) замініть:
```hcl
default = "your-unique-bucket-name"  # унікальна глобальна назва S3 бакета
```

У [backend.tf](backend.tf) замініть:
```hcl
bucket = "your-unique-bucket-name"
```

### Крок 2: Перший запуск — створення S3/DynamoDB

Тимчасово закоментуйте вміст `backend.tf` та:
```bash
terraform init
terraform apply -target=module.s3_backend
```

### Крок 3: Перенесення стейту в S3

Розкоментуйте `backend.tf`:
```bash
terraform init -migrate-state
```

### Крок 4: Розгортання всієї інфраструктури

```bash
terraform plan -var="jenkins_admin_password=<password>" \
               -var="rds_db_password=<password>" \
               -var="github_repo_url=https://github.com/<org>/<repo>" \
               -var="github_ssh_key=$(cat ~/.ssh/id_rsa)"
terraform apply
```

### Крок 5: Налаштування kubectl

```bash
aws eks update-kubeconfig --region us-west-2 --name project-eks
kubectl get nodes
```

### Крок 6: Перевірка External Secrets Operator

```bash
# Перевірити що ESO запущений
kubectl get pods -n external-secrets

# Перевірити що ExternalSecret синхронізований
kubectl get externalsecret -n default
kubectl get secret <release>-db-secret -n default
```

### Крок 7: Налаштування Jenkins

1. Отримати URL Jenkins:
```bash
terraform output jenkins_url_command
# або напряму:
kubectl get svc -n jenkins jenkins-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

2. Увійти з credentials `jenkins_admin_user` / `jenkins_admin_password`

3. Додати credentials у Jenkins → Manage Credentials:
   - `github-credentials` — GitHub username + Personal Access Token (тип: Username/Password)

4. Створити Pipeline job → вказати GitHub репо → Jenkinsfile

### Крок 8: Перший запуск pipeline

Push будь-якого коміту у репо — Jenkins автоматично:
1. Збере Docker образ через Kaniko
2. Запуше в ECR з тегом `{BUILD_NUMBER}-{SHA7}`
3. Оновить `charts/django-app/values.yaml` → `image.tag`
4. Запушить зміни в `main`
5. Argo CD підхопить зміни та задеплоїть нову версію

## Змінні Terraform

### Загальні

| Змінна | Опис | Default |
|--------|------|---------|
| `aws_region` | AWS регіон | `us-west-2` |
| `bucket_name` | Назва S3 бакета (унікальна!) | `your-unique-bucket-name` |
| `cluster_name` | Назва EKS кластера | `project-eks` |
| `cluster_version` | Версія Kubernetes | `1.29` |
| `node_instance_types` | Тип EC2 вузлів | `["t3.medium"]` |
| `node_desired_size` | Бажана кількість вузлів | `2` |
| `jenkins_admin_user` | Логін адміна Jenkins | `admin` |
| `jenkins_admin_password` | Пароль адміна Jenkins | sensitive |
| `github_repo_url` | HTTPS URL GitHub репо | required |
| `github_ssh_key` | SSH ключ для Argo CD | required, sensitive |

### RDS

| Змінна | Опис | Default |
|--------|------|---------|
| `rds_use_aurora` | `true` — Aurora, `false` — RDS instance | `false` |
| `rds_identifier` | Ідентифікатор кластера/instance | `project-db` |
| `rds_engine` | Движок БД | `postgres` |
| `rds_engine_version` | Версія движка | `15.4` |
| `rds_instance_class` | Клас інстансу | `db.t3.medium` |
| `rds_db_name` | Назва бази даних | `appdb` |
| `rds_db_username` | Логін адміністратора | `dbadmin` |
| `rds_db_password` | Пароль адміністратора | required, sensitive |
| `rds_db_port` | Порт підключення | `5432` |
| `rds_multi_az` | Multi-AZ для RDS instance | `false` |
| `rds_aurora_replica_count` | Кількість reader instances (Aurora) | `1` |

## Важливі зауваження

1. **S3 бакет** — назва повинна бути **глобально унікальною**
2. **NAT Gateway** — ~$0.045/год × 3 шт. Знищуйте після тестів: `terraform destroy`
3. **EKS Control Plane** — ~$0.10/год + EC2 вузли
4. **RDS** — Aurora потребує мінімум `db.r6g.large`; для тестів використовуйте `db.t3.medium` зі звичайною RDS instance
5. **Secrets Manager** — пароль БД **ніколи не зберігається у Git**; `recovery_window_in_days = 0` дозволяє швидке видалення при `terraform destroy`
6. **IRSA** — Jenkins пушить у ECR, ESO читає секрети — обидва без статичних AWS ключів
7. **[skip ci]** — коміт оновлення тегу не тригерить новий pipeline
8. Перед `terraform destroy` видаліть Helm releases: `helm uninstall django-app -n default`
