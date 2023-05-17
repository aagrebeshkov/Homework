
# Домашнее задание к занятию 3. «Введение. Экосистема. Архитектура. Жизненный цикл Docker-контейнера»

## Как сдавать задания

Обязательны к выполнению задачи без звёздочки. Их нужно выполнить, чтобы получить зачёт и диплом о профессиональной переподготовке.

Задачи со звёздочкой (*) — дополнительные задачи и/или задачи повышенной сложности. Их выполнять не обязательно, но они помогут вам глубже понять тему.

Домашнее задание выполните в файле readme.md в GitHub-репозитории. В личном кабинете отправьте на проверку ссылку на .md-файл в вашем репозитории.

Любые вопросы по решению задач задавайте в чате учебной группы.

---


## Важно

Перед отправкой работы на проверку удаляйте неиспользуемые ресурсы.
Это нужно, чтобы не расходовать средства, полученные в результате использования промокода.

Подробные рекомендации [здесь](https://github.com/netology-code/virt-homeworks/blob/virt-11/r/README.md).

---

## Задача 1

Сценарий выполнения задачи:

- создайте свой репозиторий на https://hub.docker.com;
- выберите любой образ, который содержит веб-сервер Nginx;
- создайте свой fork образа;
- реализуйте функциональность:
запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```

Опубликуйте созданный fork в своём репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.

<details>
<summary>Ответ</summary>
Dockerfile с сожержимым:
	
	FROM nginx
	COPY index.html /usr/share/nginx/html

# docker build -t mynginx .
# docker run --name mynginx -d -p 8080:80 mynginx
# curl http://localhost:8080
	<html>
	<head>
	Hey, Netology
	</head>
	<body>
	<h1>I’m DevOps Engineer!</h1>
	</body>
	</html>

# docker login --username aagrebeshkov
# docker tag mynginx aagrebeshkov/mynginx-repo
# docker push aagrebeshkov/mynginx-repo

https://hub.docker.com/repositories/aagrebeshkov

</details>

## Задача 2

Посмотрите на сценарий ниже и ответьте на вопрос:
«Подходит ли в этом сценарии использование Docker-контейнеров или лучше подойдёт виртуальная машина, физическая машина? Может быть, возможны разные варианты?»

Детально опишите и обоснуйте свой выбор.

--

Сценарий:

- высоконагруженное монолитное Java веб-приложение;
- Nodejs веб-приложение;
- мобильное приложение c версиями для Android и iOS;
- шина данных на базе Apache Kafka;
- Elasticsearch-кластер для реализации логирования продуктивного веб-приложения — три ноды elasticsearch, два logstash и две ноды kibana;
- мониторинг-стек на базе Prometheus и Grafana;
- MongoDB как основное хранилище данных для Java-приложения;
- Gitlab-сервер для реализации CI/CD-процессов и приватный (закрытый) Docker Registry.

<details>
<summary>Ответ</summary>

| Сценарий | Ответ |
| ------------- | ------------- |
| высоконагруженное монолитное Java веб-приложение | Подойдет ВМ или физический сервер |
| Nodejs веб-приложение | Подойдет контейнер |
| Мобильное приложение c версиями для Android и iOS | Для тестирования приложений может можно в контейнере, но работа будет производиться на мобильном устройстве |
| Шина данных на базе Apache Kafka | ВМ или физический сервер |
| Elasticsearch-кластер для реализации логирования продуктивного веб-приложения — три ноды elasticsearch, два logstash и две ноды kibana | Думаю можно использовать docker swarm |
| Мониторинг-стек на базе Prometheus и Grafana | Можно в контейнере, историчность метрик хранить через volumes |
| MongoDB как основное хранилище данных для Java-приложения | ВМ или физический сервер |
| Gitlab-сервер для реализации CI/CD-процессов и приватный (закрытый) Docker Registry | Можно в контейнере, т.к. данные локального docker registry хранятся в /mnt/registry |

</details>

## Задача 3

- Запустите первый контейнер из образа ***centos*** c любым тегом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера.
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера.
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```.
- Добавьте ещё один файл в папку ```/data``` на хостовой машине.
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.

<details>
<summary>Ответ</summary>

	root@vagrant:/opt/docker# docker run -it -d -v $(pwd)/data:/data --name centos7 centos:7
	Unable to find image 'centos:7' locally
	7: Pulling from library/centos
	2d473b07cdd5: Already exists 
	Digest: sha256:be65f488b7764ad3638f236b7b515b3678369a5124c47b8d32916d6487418ea4
	Status: Downloaded newer image for centos:7
	41cbfff6cb2e566938e3d5707b0f5830d0fbf51fcd85039e68e9efd6649feb82

	root@vagrant:/opt/docker# docker run -it -d -v $(pwd)/data:/data --name debian debian
	Unable to find image 'debian:latest' locally
	latest: Pulling from library/debian
	918547b94326: Pull complete 
	Digest: sha256:63d62ae233b588d6b426b7b072d79d1306bfd02a72bff1fc045b8511cc89ee09
	Status: Downloaded newer image for debian:latest
	24b4bebcd61024e502d916ea5c511598ee8e12ca1285e841696319db2cbbcdea

	root@vagrant:/opt/docker# docker exec -it centos7 /bin/bash
	[root@41cbfff6cb2e /]# touch /data/12345
	[root@41cbfff6cb2e /]# exit
	exit

	root@vagrant:/opt/docker# touch data/testfile

	root@vagrant:/opt/docker# docker exec -it debian /bin/bash
	root@24b4bebcd610:/# ls -l /data/
	total 0
	-rw-r--r-- 1 root root 0 May 17 20:13 12345
	-rw-r--r-- 1 root root 0 May 17 20:13 testfile

</details>

## Задача 4 (*)

Воспроизведите практическую часть лекции самостоятельно.

Соберите Docker-образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.


---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---

