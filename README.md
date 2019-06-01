# alexyakovlev90_microservices


### ДЗ docker-1
#### Технология контейнеризации. Введение в Docker

1) Познакомились с Докером
2) Прикрутили Travis CI
3) Посмотрели результаты выполнения основных комманд Докера
4) Описали разницу между контейнером и образом с помощью команды `docker inspect`


### ДЗ docker-2
#### Docker контейнеры. Docker под капотом
Запуск VM с установленным Docker Engine при помощи Docker Machine. 
Написание Dockerfile и сборка образа с тестовым приложением. Сохранение образа на DockerHub.
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
   
   
### ДЗ docker-3
#### Docker-образы. Микросервисы  
Линтер для написания докерфайлов
- https://github.com/hadolint/hadolint

1) Сборка образов с сервисами
```bash
    docker build -t alexyakovlev90/post:1.0 ./post-py
    docker build -t alexyakovlev90/comment:1.0 ./comment
    docker build -t alexyakovlev90/ui:1.0 ./ui
```
* для запуска без ошибок alexyakovlev90/post:1.0 билда 
в начало python скрипта запуска был добавлен **shebang** 
(https://stackoverflow.com/questions/55271912/flask-cli-throws-oserror-errno-8-exec-format-error-when-run-through-docker)
* для имаджей `alexyakovlev90/ui:1.0` и `alexyakovlev90/comment:1.0 `
для коректной сборки руби был явно указан репозиторий командой:
```bash
printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main" > /etc/apt/sources.list
```

2) Создали bridge-сеть для контейнеров, так как сетевые алиасы не работают в сети по умолчанию
```bash
    docker network create reddit
```

3) Запуск контейнеров в созданной сети с алиасами
    Сетевые алиасы могут быть использованы для сетевых соединений, как доменные имена
```bash
docker run -d --network=reddit \
    --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit \
    --network-alias=post alexyakovlev90/post:1.0
docker run -d --network=reddit \
    --network-alias=comment alexyakovlev90/comment:1.0
docker run -d --network=reddit \
    -p 9292:9292 alexyakovlev90/ui:1.0
```
4) После изменения исходного образа Dockerfile сервиса UI
с `ruby:2.2` на `ubuntu:16.04` размер имаджа снизился почти в 2 раза
```bash
docker build -t alexyakovlev90/ui:2.0 ./ui
```
5) Доп заданием образы, наследуемые от ruby:2.2 были
собраны на основе Alpine Linux. Это существенно уменьшело их размер

6) Монтирование volume к БД
```bash
docker volume create reddit_db
docker run -d --network=reddit --network-alias=post_db \
    --network-alias=comment_db -v reddit_db:/data/db mongo:latest
```


### ДЗ docker-4
#### Docker: сети, docker-compose
1) Запустим контейнер с использованием none-драйвера.
   В качестве образа используем joffotron/docker-net-tools,
   его состав уже входят необходимые утилиты для работы с сетью: пакеты bindtools, net-tools и curl. 
```bash
docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig
```
Контейнер запустится, выполнить команду `ifconfig` и будет удален (флаг --rm)
Можно запускать сетевые сервисы внутри такого контейнера, но лишь для локальных
экспериментов (тестирование, контейнеры для выполнения разовых задач и т.д.)

2) Запустим контейнер в сетевом пространстве docker-хоста
```bash
docker run -ti --rm --network host joffotron/docker-net-tools -c ifconfig
```
вывод команды практически идентичен `docker-machine ssh docker-host ifconfig`

3) Повторите запуски контейнеров с использованием драйверов
none и host и посмотрите, как меняется список namespace.
Для просмотра net-namespaces с помощью команды `sudo ip netns`
На docker-host машине выполните команду: 
```bash
 sudo ln -s /var/run/docker/netns /var/run/netns
```
- При запуске контейнера с использованием none-драйвера 
для каждого нового контейнера создается дополнительный namespace

- При запуске контейнера с использованием host-драйвера сети
контейнер будет использовать default namespace

4) Создадим bridge-сеть в docker (флаг --driver указывать не обязательно, по-умолчанию используется bridge)
```bash
 docker network create reddit --driver bridge
```
Запуск приложений в сети с использованием алиасов,
чтобы обращаться по dns-именам, прописанным в ENV-переменных
```bash
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post alexyakovlev90/post:1.0
docker run -d --network=reddit --network-alias=comment alexyakovlev90/comment:1.0
docker run -d --network=reddit -p 9292:9292 alexyakovlev90/ui:1.0
```

5) Запуск проекта в 2х bridge сетях
```bash
> docker network create back_net --subnet=10.0.2.0/24
> docker network create front_net --subnet=10.0.1.0/24
```
Docker при инициализации контейнера может подключить к нему только 1 сеть
Подключим контейнеры ко второй сети
```bash
> docker network connect front_net post
> docker network connect front_net comment 
```

6) Собрать и запустить образы приложения reddit с помощью docker-compose 
с множеством сетей и параметризированных переменных окружений
```bash
> docker-compose up -d
> docker-compose ps
```
Имя проекта задано с помощью переменной окружения
COMPOSE_PROJECT_NAME=dockermicroservices
и указано в .env файле (https://docs.docker.com/compose/environment-variables/)
