# Домашнее задание к занятию «Запуск приложений в K8S»

### Цель задания

В тестовой среде для работы с Kubernetes, установленной в предыдущем ДЗ, необходимо развернуть Deployment с приложением, состоящим из нескольких контейнеров, и масштабировать его.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) Deployment и примеры манифестов.
2. [Описание](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) Init-контейнеров.
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment и обеспечить доступ к репликам приложения из другого Pod

1. Создать Deployment приложения, состоящего из двух контейнеров — nginx и multitool. Решить возникшую ошибку.
2. После запуска увеличить количество реплик работающего приложения до 2.
3. Продемонстрировать количество подов до и после масштабирования.
4. Создать Service, который обеспечит доступ до реплик приложений из п.1.
5. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложений из п.1.

<details>
<summary>Ответ</summary>

1. Создать Deployment приложения, состоящего из двух контейнеров — nginx и multitool. Решить возникшую ошибку.

Манифест Deployment:
```yam
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dpl-nginx-multitool
spec:
  replicas: 1
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
        - containerPort: 1180
        env:
          - name: HTTP_PORT
            value: "1180"
          - name: HTTPS_PORT
            value: "11443"
```

Запускаем деплой:
```bash
% kubectl apply -f dpl-nginx-multitool.yml 
deployment.apps/dpl-nginx-multitool created

% kubectl get pods -o wide
NAME                                   READY   STATUS    RESTARTS   AGE   IP             NODE       NOMINATED NODE   READINESS GATES
dpl-nginx-multitool-554d6494c9-kl6fn   2/2     Running   0          9s    10.1.128.197   microk8s   <none>           <none>

% kubectl get deployments -o wide
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS        IMAGES                                 SELECTOR
dpl-nginx-multitool   1/1     1            1           31s   nginx,multitool   nginx:1.14.2,wbitt/network-multitool   app=nginx-multitool
```

2. После запуска увеличить количество реплик работающего приложения до 2.

```bash
% kubectl scale deployment/dpl-nginx-multitool --replicas=2
deployment.apps/dpl-nginx-multitool scaled
```

3. Продемонстрировать количество подов до и после масштабирования.

После масштабирования:
```bash
% kubectl get pods -o wide
NAME                                   READY   STATUS    RESTARTS   AGE   IP             NODE       NOMINATED NODE   READINESS GATES
dpl-nginx-multitool-554d6494c9-kl6fn   2/2     Running   0          80s   10.1.128.197   microk8s   <none>           <none>
dpl-nginx-multitool-554d6494c9-bkhr4   2/2     Running   0          28s   10.1.128.201   microk8s   <none>           <none>

% kubectl get deployments -o wide                          
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS        IMAGES                                 SELECTOR
dpl-nginx-multitool   2/2     2            2           96s   nginx,multitool   nginx:1.14.2,wbitt/network-multitool   app=nginx-multitool
```

4. Создать Service, который обеспечит доступ до реплик приложений из п.1.

Манифест Service:
```yml
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
      port: 80
    - name: port-multitool
      port: 1180
```

Запускаем деплой:
```bash
% kubectl apply -f svc-nginx-multitool.yml 
service/svc-nginx-multitool created
```

Описание сервиса:
```
% kubectl describe service svc-nginx-multitool 
Name:              svc-nginx-multitool
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=nginx-multitool
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.152.183.138
IPs:               10.152.183.138
Port:              port-nginx  80/TCP
TargetPort:        80/TCP
Endpoints:         10.1.128.197:80,10.1.128.201:80
Port:              port-multitool  1180/TCP
TargetPort:        1180/TCP
Endpoints:         10.1.128.197:1180,10.1.128.201:1180
Session Affinity:  None
Events:            <none>
```

Прокидываем порт для сервиса (на машине с k8s):
```bash
microk8s kubectl port-forward service/svc-nginx-multitool --address 0.0.0.0 80:80 --address 0.0.0.0 1180:1180
```

Проверяем доступность Pod:
```bash
% curl http://192.168.1.126:1180
WBITT Network MultiTool (with NGINX) - dpl-nginx-multitool-554d6494c9-kl6fn - 10.1.128.197 - HTTP: 1180 , HTTPS: 11443 . (Formerly praqma/network-multitool)
```

5. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложений из п.1.

Манифест Pod:
```yml
apiVersion: v1
kind: Pod
metadata:
  name: multitool-2
  labels:
    app: nginx-multitool
spec:
  containers:
    - name: multitool
      image: wbitt/network-multitool
```

Запускаем деплой:
```bash
kubectl apply -f pod-multitool-2.yml
```

```bash
% kubectl get pod -o wide
NAME                                   READY   STATUS    RESTARTS   AGE     IP             NODE       NOMINATED NODE   READINESS GATES
dpl-nginx-multitool-554d6494c9-kl6fn   2/2     Running   0          10m     10.1.128.197   microk8s   <none>           <none>
dpl-nginx-multitool-554d6494c9-bkhr4   2/2     Running   0          9m34s   10.1.128.201   microk8s   <none>           <none>
multitool-2                            1/1     Running   0          18s     10.1.128.205   microk8s   <none>           <none>

% kubectl describe service svc-nginx-multitool 
Name:              svc-nginx-multitool
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=nginx-multitool
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.152.183.138
IPs:               10.152.183.138
Port:              port-nginx  80/TCP
TargetPort:        80/TCP
Endpoints:         10.1.128.197:80,10.1.128.201:80,10.1.128.205:80
Port:              port-multitool  1180/TCP
TargetPort:        1180/TCP
Endpoints:         10.1.128.197:1180,10.1.128.201:1180,10.1.128.205:1180
Session Affinity:  None
Events:            <none>
```

#В описании сервиса видно, что есть endpoints на все pods, но curl проходит только на первый (10.1.128.197), label "app: nginx-multitool" есть у всех pod.
#Почему трафик идет только на один под?

</details>

------

### Задание 2. Создать Deployment и обеспечить старт основного контейнера при выполнении условий

1. Создать Deployment приложения nginx и обеспечить старт контейнера только после того, как будет запущен сервис этого приложения.
2. Убедиться, что nginx не стартует. В качестве Init-контейнера взять busybox.
3. Создать и запустить Service. Убедиться, что Init запустился.
4. Продемонстрировать состояние пода до и после запуска сервиса.


<details>
<summary>Ответ</summary>

1. Создать Deployment приложения nginx и обеспечить старт контейнера только после того, как будет запущен сервис этого приложения.

Манифест Deployment:
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dpl-nginx-with-init
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-init
  template:
    metadata:
      labels:
        app: nginx-init
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
      initContainers:
      - name: busybox
        image: busybox
        command: ['sh', '-c', 'until nslookup svc-nginx.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for svc-nginx; sleep 1; done']
```

2. Убедиться, что nginx не стартует. В качестве Init-контейнера взять busybox.

```bash
 % kubectl apply -f dpl-nginx-with-init.yml 
deployment.apps/dpl-nginx-with-init created

% kubectl get pod -o wide
NAME                                   READY   STATUS     RESTARTS   AGE   IP             NODE       NOMINATED NODE   READINESS GATES
dpl-nginx-with-init-679cd97f75-rg2mp   0/1     Init:0/1   0          18s   10.1.128.221   microk8s   <none>           <none>
```

Лог init контейнера:
```bash
% kubectl logs pods/dpl-nginx-with-init-679cd97f75-rg2mp -c busybox
...
Server:         10.152.183.10
Address:        10.152.183.10:53

** server can't find svc-nginx.default.svc.cluster.local: NXDOMAIN

** server can't find svc-nginx.default.svc.cluster.local: NXDOMAIN

waiting for svc-nginx
...
```

3. Создать и запустить Service. Убедиться, что Init запустился.

Манифест Service:
```yml
apiVersion: v1
kind: Service
metadata:
  name: svc-nginx
spec:
  selector:
    app: nginx-init
  ports:
    - name: port-nginx
      port: 80
```

4. Продемонстрировать состояние пода до и после запуска сервиса.

```bash
 % kubectl apply -f svc-nginx-init.yml 
service/svc-nginx created

 % kubectl get pod -o wide
NAME                                   READY   STATUS    RESTARTS   AGE     IP             NODE       NOMINATED NODE   READINESS GATES
dpl-nginx-with-init-679cd97f75-rg2mp   1/1     Running   0          2m35s   10.1.128.221   microk8s   <none>           <none>
```

</details>

------

### Правила приема работы

1. Домашняя работа оформляется в своем Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl` и скриншоты результатов.
3. Репозиторий должен содержать файлы манифестов и ссылки на них в файле README.md.

------
