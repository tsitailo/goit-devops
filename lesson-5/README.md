\# 🏗️ Terraform AWS Infrastructure - Lesson 5



\## 📋 Опис проєкту



Цей проєкт містить Terraform-конфігурацію для розгортання базової

інфраструктури на AWS, яка включає:



\- \*\*S3 + DynamoDB\*\* — зберігання та блокування Terraform стейтів

\- \*\*VPC\*\* — мережева інфраструктура з публічними та приватними підмережами

\- \*\*ECR\*\* — реєстр Docker-образів



\## 📁 Структура проєкту



lesson-5/

├── main.tf          # Підключення модулів та налаштування провайдера

├── backend.tf       # Конфігурація S3 бекенду для стейтів

├── variables.tf     # Змінні кореневого модуля

├── outputs.tf       # Вихідні дані всіх модулів

├── README.md        # Документація

└── modules/

&#x20;   ├── s3-backend/  # S3 бакет + DynamoDB для стейтів

&#x20;   ├── vpc/         # VPC, підмережі, IGW, NAT GW

&#x20;   └── ecr/         # ECR репозиторій



\## 🔧 Модулі



\### 📦 s3-backend

Створює інфраструктуру для зберігання Terraform стейтів:

\- S3 бакет з версіюванням та шифруванням

\- DynamoDB таблицю для блокування стейтів

\- Публічний доступ заблоковано



\### 🌐 vpc

Створює мережеву інфраструктуру:

\- VPC з CIDR 10.0.0.0/16

\- 3 публічні підмережі (10.0.1-3.0/24)

\- 3 приватні підмережі (10.0.4-6.0/24)

\- Internet Gateway для публічних підмереж

\- NAT Gateway для приватних підмереж

\- Route Tables з правильними маршрутами



\### 🐳 ecr

Створює Docker реєстр:

\- ECR репозиторій з автосканування образів

\- Lifecycle policy для видалення старих образів

\- Repository policy для управління доступом



\## 🚀 Швидкий старт



\### Передумови

\- AWS CLI налаштований та автентифікований

\- Terraform >= 1.6.0

\- Достатні IAM права



\### Крок 1: Створення S3 та DynamoDB (перший запуск)



Перед використанням S3 бекенду потрібно спочатку

створити необхідні ресурси. Тимчасово закоментуйте

backend.tf та запустіть:



terraform init

terraform apply -target=module.s3\_backend



\### Крок 2: Перемістити стейт у S3



Розкоментуйте backend.tf та виконайте:



terraform init -migrate-state



\### Крок 3: Розгорнути всю інфраструктуру



terraform plan

terraform apply



\## 📌 Основні команди



\# Ініціалізація проєкту

terraform init



\# Перевірка змін без застосування

terraform plan



\# Застосування змін

terraform apply



\# Застосування без підтвердження

terraform apply -auto-approve



\# Знищення інфраструктури

terraform destroy



\# Виведення всіх outputs

terraform output



\# Форматування коду

terraform fmt -recursive



\# Валідація конфігурації

terraform validate



\## 🔐 Docker команди для ECR



\# Автентифікація в ECR

aws ecr get-login-password --region us-west-2 | \\

&#x20; docker login --username AWS --password-stdin \\

&#x20; <account-id>.dkr.ecr.us-west-2.amazonaws.com



\# Тегування образу

docker tag my-image:latest \\

&#x20; <account-id>.dkr.ecr.us-west-2.amazonaws.com/lesson-5-ecr:latest



\# Push образу

docker push \\

&#x20; <account-id>.dkr.ecr.us-west-2.amazonaws.com/lesson-5-ecr:latest



\## ⚙️ Змінні



| Змінна              | Опис                    | За замовчуванням          |

|---------------------|-------------------------|---------------------------|

| aws\_region          | AWS регіон              | us-west-2                 |

| bucket\_name         | Назва S3 бакета         | your-unique-bucket-name   |

| table\_name          | Назва DynamoDB таблиці  | terraform-locks           |

| vpc\_cidr\_block      | CIDR блок VPC           | 10.0.0.0/16               |

| vpc\_name            | Назва VPC               | lesson-5-vpc              |

| ecr\_name            | Назва ECR репозиторію   | lesson-5-ecr              |

| scan\_on\_push        | Сканування при push     | true                      |



\## ⚠️ Важливі замітки



1\. Назва S3 бакета повинна бути \*\*унікальною глобально\*\*

2\. NAT Gateway має \*\*погодинну оплату\*\* — не забудьте знищити після тестів

3\. Перед `terraform destroy` переконайтесь що ECR порожній

&#x20;  або встановіть `force\_delete = true`

