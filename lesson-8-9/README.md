# Terraform + Helm + Jenkins CI/CD — Lesson 8-9

## Опис проєкту

Повна CI/CD інфраструктура на AWS з автоматизованим розгортанням Django-застосунку через GitOps:

- **S3 + DynamoDB** — зберігання та блокування Terraform стейтів
- **VPC** — мережева інфраструктура з публічними та приватними підмережами
- **ECR** — реєстр Docker-образів
- **EKS** — Kubernetes кластер (1.29) у приватних підмережах
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

## Структура проєкту

```
lesson-8-9/
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
│   ├── jenkins/             # Jenkins via Helm + IRSA IAM role
│   │   ├── jenkins.tf       # Helm release
│   │   ├── irsa.tf          # IAM Role for Service Account (ECR push)
│   │   ├── values.yaml      # Jenkins Helm values (JCasC + Kaniko pod template)
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── argo_cd/             # Argo CD via Helm + Application
│
└── charts/
    └── django-app/          # Helm chart для Django застосунку
        ├── Chart.yaml
        ├── values.yaml      # image.tag оновлюється pipeline автоматично
        └── templates/
            ├── deployment.yaml
            ├── service.yaml
            ├── configmap.yaml
            └── hpa.yaml
```

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
- Достатні IAM права (EKS, EC2, IAM, S3, DynamoDB, ECR)

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
               -var="github_repo_url=https://github.com/<org>/<repo>" \
               -var="github_ssh_key=$(cat ~/.ssh/id_rsa)"
terraform apply
```

### Крок 5: Налаштування kubectl

```bash
aws eks update-kubeconfig --region us-west-2 --name lesson-8-9-eks
kubectl get nodes
```

### Крок 6: Налаштування Jenkins

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

### Крок 7: Перший запуск pipeline

Push будь-якого коміту у репо — Jenkins автоматично:
1. Збере Docker образ через Kaniko
2. Запуше в ECR з тегом `{BUILD_NUMBER}-{SHA7}`
3. Оновить `charts/django-app/values.yaml` → `image.tag`
4. Запушить зміни в `main`
5. Argo CD підхопить зміни та задеплоїть нову версію

## Змінні Terraform

| Змінна | Опис | Default |
|--------|------|---------|
| `aws_region` | AWS регіон | `us-west-2` |
| `bucket_name` | Назва S3 бакета (унікальна!) | `your-unique-bucket-name` |
| `cluster_name` | Назва EKS кластера | `lesson-8-9-eks` |
| `cluster_version` | Версія Kubernetes | `1.29` |
| `node_instance_types` | Тип EC2 вузлів | `["t3.medium"]` |
| `node_desired_size` | Бажана кількість вузлів | `2` |
| `jenkins_admin_user` | Логін адміна Jenkins | `admin` |
| `jenkins_admin_password` | Пароль адміна Jenkins | sensitive |
| `github_repo_url` | HTTPS URL GitHub репо | required |
| `github_ssh_key` | SSH ключ для Argo CD | required, sensitive |

## Важливі зауваження

1. **S3 бакет** — назва повинна бути **глобально унікальною**
2. **NAT Gateway** — ~$0.045/год × 3 шт. Знищуйте після тестів: `terraform destroy`
3. **EKS Control Plane** — ~$0.10/год + EC2 вузли
4. **IRSA** — Jenkins пушить у ECR без AWS ключів, через IAM Role for Service Account
5. **[skip ci]** — коміт оновлення тегу не тригерить новий pipeline
6. Перед `terraform destroy` видаліть Helm releases: `helm uninstall django-app -n default`
