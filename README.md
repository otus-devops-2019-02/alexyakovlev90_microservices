# alexyakovlev90_microservices


### ДЗ docker-1
#### Технология контейнеризации. Введение в Docker

1) Познакомились с Докером
2) Прикрутили Travis CI
3) Посмотрели результаты выполнения основных комманд Докера
4) Описали разницу между контейнером и образом с помощью команды `docker inspect`


### ДЗ docker-2
#### 
1) Создание Docker-хоста в GCP
```bash
export GOOGLE_PROJECT=_project_name_ 

docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-zone europe-west1-b \
    docker-host 
docker-machine ls
```
2) Работа с Docker-хостом
```bash
eval $(docker-machine env docker-host)
```

3) PID namespace (изоляция процессов)
    - запускаем контейнер `docker run --rm -it ubuntu:latest bash`
    - запускаем процесс внутри контейнера `sleep 1000 &`
    - смотрим PID процесса внутри контейнера и наследование процесса на хосте `ps auxf`

4) net namespace (изоляция сети) 
    - запускаем контейнер
    - проверяем наличие интерфейса сети внутри контейнера `ifconfig`
    - проверяем на хосте виртуальный интерфейс контейнера `brctl show docker0` соотносим с общим списком `ifconfig`

5) user namespaces (изоляция пользователей) 
    - UID и GID внутри контейнеров отображаются в другом диапазоне UID и GID
    - https://docs.docker.com/engine/security/userns-remap/

6) Просмотр PID процессов хостовой системы
    - только процессы контейнера `docker run --rm -ti tehbilly/htop`
    - процессы хостовой системы `docker run --rm --pid host -ti tehbilly/htop`

7) Установка файрволла в GCP
```bash
gcloud compute firewall-rules create reddit-app \
    --allow tcp:9292 \
    --target-tags=docker-machine \
    --description="Allow PUMA connections" \
    --direction=INGRESS
```
##### Задания со *
1) Поднятие инстансов с помощью Terraform, их количество задается переменной

2) Несколько плейбуков Ansible с использованием динамического
   инвентори для установки докера и запуска там образа приложения
   - для установки докера использована роль: https://github.com/nickjj/ansible-docker
   - для запуска докер контейнера приложения роль `container-app` 
   с предустановкой `docker-py` и `docker-compose`
   
3) Шаблон пакера, который делает образ с уже установленным Docker   
   
   
   







