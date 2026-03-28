# Terraform AWS Infrastructure - Lesson 7

## Опис проєкту

Цей проєкт містить Terraform-конфігурацію для розгортання інфраструктури на AWS, а також Helm chart для деплою Django застосунку в Kubernetes. Включає:

- **S3 + DynamoDB** — зберігання та блокування Terraform стейтів
- **VPC** — мережева інфраструктура з публічними та приватними підмережами
- **ECR** — реєстр Docker-образів
- **EKS** — Kubernetes кластер у наявній VPC
- **Helm chart** — деплой Django застосунку з HPA, ConfigMap та LoadBalancer

## Структура проєкту

```
lesson-7/
├── main.tf                  # Підключення модулів та налаштування провайдера
├── backend.tf               # Конфігурація S3 бекенду для стейтів
├── variables.tf             # Змінні кореневого модуля
├── outputs.tf               # Вихідні дані всіх модулів
├── README.md
│
├── modules/
│   ├── s3-backend/          # S3 бакет + DynamoDB для стейтів
│   │   ├── s3.tf
│   │   ├── dynamodb.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── vpc/                 # VPC, підмережі, IGW, NAT GW
│   │   ├── vpc.tf
│   │   ├── routes.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ecr/                 # ECR репозиторій
│   │   ├── ecr.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── eks/                 # EKS Kubernetes кластер
│       ├── eks.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── charts/
    └── django-app/          # Helm chart для Django застосунку
        ├── Chart.yaml
        ├── values.yaml
        └── templates/
            ├── deployment.yaml
            ├── service.yaml
            ├── configmap.yaml
            └── hpa.yaml
```

## Модулі

### s3-backend

Створює інфраструктуру для зберігання Terraform стейтів:

- S3 бакет з версіюванням та AES256 шифруванням
- Публічний доступ повністю заблоковано
- Lifecycle policy: перехід у STANDARD_IA через 30 днів, видалення через 90 днів
- DynamoDB таблицю з `PAY_PER_REQUEST` та Point-in-Time Recovery для locking

### vpc

Створює мережеву інфраструктуру в `us-west-2`:

- VPC з CIDR `10.0.0.0/16`
- 3 публічні підмережі (`10.0.1-3.0/24`) з Internet Gateway
- 3 приватні підмережі (`10.0.4-6.0/24`) з окремим NAT Gateway на кожну
- Route tables з правильними маршрутами для кожного типу підмережі

### ecr

Створює Docker реєстр:

- ECR репозиторій з автосканування образів при push
- Lifecycle policy: зберігати 10 tagged образів (`v*`), видаляти untagged після 14 днів
- Repository policy: доступ лише для поточного AWS акаунта

### eks

Створює Kubernetes кластер у наявній VPC:

- IAM ролі для Control Plane та Node Group
- Security Groups для кластера та вузлів
- EKS кластер з логуванням API та audit
- Node Group у приватних підмережах (`t3.medium`, 2-4 вузли)
- Вузли мають ECR read-only доступ для pull образів

## Helm chart — django-app

Розгортає Django застосунок у Kubernetes:

| Ресурс | Опис |
|--------|------|
| Deployment | Образ з ECR, змінні середовища через `envFrom: configMapRef` |
| Service | Тип `LoadBalancer`, порт 80 → 8000 |
| HPA | Масштабування 2-6 реплік при CPU > 70% |
| ConfigMap | Змінні середовища Django |

## Передумови

- AWS CLI налаштований та автентифікований
- Terraform >= 1.6.0
- kubectl
- Helm >= 3.0
- Достатні IAM права (EKS, EC2, IAM, S3, DynamoDB, ECR)

## Швидкий старт

### Крок 1: Оновіть змінні

У `variables.tf` замініть:

```hcl
default = "your-unique-bucket-name"  # на унікальну глобальну назву
```

У `backend.tf` замініть:

```hcl
bucket = "your-unique-bucket-name"  # на ту саму назву
```

### Крок 2: Створення S3 та DynamoDB (перший запуск)

Перед використанням S3 бекенду потрібно спочатку створити необхідні ресурси. Тимчасово закоментуйте вміст `backend.tf` та запустіть:

```bash
terraform init
terraform apply -target=module.s3_backend
```

### Крок 3: Перемістити стейт у S3

Розкоментуйте `backend.tf` та виконайте:

```bash
terraform init -migrate-state
```

### Крок 4: Розгорнути всю інфраструктуру

```bash
terraform plan
terraform apply
```

### Крок 5: Налаштування kubectl

```bash
aws eks update-kubeconfig --region us-west-2 --name lesson-7-eks
kubectl get nodes
```

### Крок 6: Push Docker образу в ECR

```bash
# Автентифікація
aws ecr get-login-password --region us-west-2 | \
  docker login --username AWS --password-stdin \
  <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com

# Тегування та push
docker tag django-app:latest \
  <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/lesson-7-ecr:latest

docker push \
  <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/lesson-7-ecr:latest
```

> URL репозиторію можна отримати командою: `terraform output ecr_repository_url`

### Крок 7: Деплой через Helm

```bash
helm install django-app ./charts/django-app \
  --set image.repository=<ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/lesson-7-ecr

# Перевірка
kubectl get pods
kubectl get svc
kubectl get hpa
```

## Основні команди Terraform

```bash
# Ініціалізація
terraform init

# Перевірка змін
terraform plan

# Застосування
terraform apply

# Застосування без підтвердження
terraform apply -auto-approve

# Знищення інфраструктури
terraform destroy

# Виведення всіх outputs
terraform output

# Форматування коду
terraform fmt -recursive

# Валідація конфігурації
terraform validate
```

## Основні команди Helm

```bash
# Встановлення
helm install django-app ./charts/django-app

# Оновлення
helm upgrade django-app ./charts/django-app

# Перегляд статусу
helm status django-app

# Видалення
helm uninstall django-app

# Перевірка шаблонів без деплою
helm template django-app ./charts/django-app
```

## Змінні

### Terraform

| Змінна | Опис | За замовчуванням |
|--------|------|------------------|
| `aws_region` | AWS регіон | `us-west-2` |
| `bucket_name` | Назва S3 бакета | `your-unique-bucket-name` |
| `table_name` | Назва DynamoDB таблиці | `terraform-locks` |
| `vpc_cidr_block` | CIDR блок VPC | `10.0.0.0/16` |
| `vpc_name` | Назва VPC | `lesson-7-vpc` |
| `ecr_name` | Назва ECR репозиторію | `lesson-7-ecr` |
| `scan_on_push` | Сканування при push | `true` |
| `cluster_name` | Назва EKS кластера | `lesson-7-eks` |
| `cluster_version` | Версія Kubernetes | `1.29` |
| `node_instance_types` | Тип EC2 вузлів | `["t3.medium"]` |
| `node_desired_size` | Бажана кількість вузлів | `2` |
| `node_min_size` | Мінімальна кількість вузлів | `1` |
| `node_max_size` | Максимальна кількість вузлів | `4` |

### Helm values

| Параметр | Опис | За замовчуванням |
|----------|------|------------------|
| `image.repository` | URL ECR репозиторію | замінити на свій |
| `image.tag` | Тег Docker образу | `latest` |
| `replicaCount` | Початкова кількість реплік | `2` |
| `service.type` | Тип Kubernetes сервісу | `LoadBalancer` |
| `service.port` | Зовнішній порт | `80` |
| `autoscaling.minReplicas` | Мінімум реплік (HPA) | `2` |
| `autoscaling.maxReplicas` | Максимум реплік (HPA) | `6` |
| `autoscaling.targetCPUUtilizationPercentage` | Поріг CPU для HPA | `70` |

## Важливі зауваження

1. Назва S3 бакета повинна бути **унікальною глобально**
2. **NAT Gateway має погодинну оплату** (~$0.045/год кожен) — не забудьте знищити після тестів (`terraform destroy`)
3. **EKS кластер також платний** — Control Plane ~$0.10/год + EC2 вузли
4. Перед `terraform destroy` переконайтесь що ECR порожній або встановіть `force_delete = true`
5. При знищенні інфраструктури спочатку видаліть Helm release: `helm uninstall django-app`
