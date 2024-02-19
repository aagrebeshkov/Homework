# Домашнее задание к занятию «Сетевое взаимодействие в K8S. Часть 1»

### Цель задания

В тестовой среде Kubernetes необходимо обеспечить доступ к приложению, установленному в предыдущем ДЗ и состоящему из двух контейнеров, по разным портам в разные контейнеры как внутри кластера, так и снаружи.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым Git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) Deployment и примеры манифестов.
2. [Описание](https://kubernetes.io/docs/concepts/services-networking/service/) Описание Service.
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment и обеспечить доступ к контейнерам приложения по разным портам из другого Pod внутри кластера

1. Создать Deployment приложения, состоящего из двух контейнеров (nginx и multitool), с количеством реплик 3 шт.
2. Создать Service, который обеспечит доступ внутри кластера до контейнеров приложения из п.1 по порту 9001 — nginx 80, по 9002 — multitool 8080.
3. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложения из п.1 по разным портам в разные контейнеры.
4. Продемонстрировать доступ с помощью `curl` по доменному имени сервиса.
5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.

<details>
<summary>Ответ</summary>

1. Создать Deployment приложения, состоящего из двух контейнеров (nginx и multitool), с количеством реплик 3 шт.

Манифест Deployment:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dpl-nginx-multitool
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-multitool
  template:
    metadata:
      labels:
        app: nginx-multitool
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
      - name: multitool
        image: wbitt/network-multitool    # https://github.com/wbitt/Network-MultiTool
        ports:
        - containerPort: 8080
        env:
          - name: HTTP_PORT
            value: "8080"
```

2. Создать Service, который обеспечит доступ внутри кластера до контейнеров приложения из п.1 по порту 9001 — nginx 80, по 9002 — multitool 8080.

Манифест Service:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: svc-nginx-multitool
spec:
  selector:
    app: nginx-multitool
  ports:
    - name: port-nginx
      port: 9001
      targetPort: 80
    - name: port-multitool
      port: 9002
      targetPort: 8080
```

3. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложения из п.1 по разным портам в разные контейнеры.

Манифест Pod:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multitool-2
  labels:
    app: multitool-2
spec:
  containers:
    - name: multitool
      image: wbitt/network-multitool
```

```bash
% kubectl get pod -o wide
NAME                                   READY   STATUS    RESTARTS   AGE    IP             NODE       NOMINATED NODE   READINESS GATES
dpl-nginx-multitool-5dfb45b486-s2s6r   2/2     Running   0          2m1s   10.1.128.225   microk8s   <none>           <none>
dpl-nginx-multitool-5dfb45b486-68bcl   2/2     Running   0          2m1s   10.1.128.226   microk8s   <none>           <none>
dpl-nginx-multitool-5dfb45b486-2g5wd   2/2     Running   0          2m1s   10.1.128.229   microk8s   <none>           <none>
multitool-2                            1/1     Running   0          22s    10.1.128.227   microk8s   <none>           <none>
```

Проваливаемся в под multitool-2 с контейнером multitool:
```bash
kubectl exec -it multitool-2 -- sh 
```

Curl до Nginx:
```bash
/ # curl 10.1.128.225:80
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

Curl до MultiTool:
```bash 
/ # curl 10.1.128.225:8080
WBITT Network MultiTool (with NGINX) - dpl-nginx-multitool-5dfb45b486-s2s6r - 10.1.128.225 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
```

4. Продемонстрировать доступ с помощью `curl` по доменному имени сервиса.

Curl до Nginx:
```bash
/ # curl svc-nginx-multitool.default.svc.cluster.local:9001
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

Curl до MultiTool:
```bash
/ # curl svc-nginx-multitool.default.svc.cluster.local:9002
WBITT Network MultiTool (with NGINX) - dpl-nginx-multitool-5dfb45b486-2g5wd - 10.1.128.229 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
```

5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.

![curl](https://github.com/aagrebeshkov/Homework/blob/main/12-kuber-01-4/images/curl.png)

</details>

------

### Задание 2. Создать Service и обеспечить доступ к приложениям снаружи кластера

1. Создать отдельный Service приложения из Задания 1 с возможностью доступа снаружи кластера к nginx, используя тип NodePort.
2. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.
3. Предоставить манифест и Service в решении, а также скриншоты или вывод команды п.2.

<details>
<summary>Ответ</summary>

1. Создать отдельный Service приложения из Задания 1 с возможностью доступа снаружи кластера к nginx, используя тип NodePort.

Манифест service и deployment:
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dpl-nginx-multitool
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-multitool
  template:
    metadata:
      labels:
        app: nginx-multitool
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
          name: port-nginx
      - name: multitool
        image: wbitt/network-multitool    # https://github.com/wbitt/Network-MultiTool
        ports:
        - containerPort: 8080
          name: port-multitool
        env:
          - name: HTTP_PORT
            value: "8080"

---
apiVersion: v1
kind: Service
metadata:
  name: svc-nginx-multitool
spec:
  selector:
    app: nginx-multitool
  ports:
    - name: port-nginx
      port: 9001
      nodePort: 30080
      targetPort: port-nginx
    - name: port-multitool
      port: 9002
      nodePort: 30090
      targetPort: port-multitool
  type: NodePort
```

2. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.
3. Предоставить манифест и Service в решении, а также скриншоты или вывод команды п.2.

Curl до MultiTool:
```bash
% curl 192.168.1.126:30090 
WBITT Network MultiTool (with NGINX) - dpl-nginx-multitool-5dfb45b486-fx67c - 10.1.128.239 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
```

Curl до Nginx:
```bash
% curl 192.168.1.126:30080
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

</details>

------

### Правила приёма работы

1. Домашняя работа оформляется в своем Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl` и скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.
