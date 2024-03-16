# Домашнее задание к занятию «Сетевое взаимодействие в K8S. Часть 2»

### Цель задания

В тестовой среде Kubernetes необходимо обеспечить доступ к двум приложениям снаружи кластера по разным путям.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым Git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция](https://microk8s.io/docs/getting-started) по установке MicroK8S.
2. [Описание](https://kubernetes.io/docs/concepts/services-networking/service/) Service.
3. [Описание](https://kubernetes.io/docs/concepts/services-networking/ingress/) Ingress.
4. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment приложений backend и frontend

1. Создать Deployment приложения _frontend_ из образа nginx с количеством реплик 3 шт.
2. Создать Deployment приложения _backend_ из образа multitool. 
3. Добавить Service, которые обеспечат доступ к обоим приложениям внутри кластера. 
4. Продемонстрировать, что приложения видят друг друга с помощью Service.
5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.

<details>
<summary>Ответ</summary>

1. Создать Deployment приложения _frontend_ из образа nginx с количеством реплик 3 шт.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dpl-frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
        tier: frontend-backend
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
          name: port-frontend
```

2. Создать Deployment приложения _backend_ из образа multitool. 

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dpl-backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
        tier: frontend-backend
    spec:
      containers:
      - name: multitool
        image: wbitt/network-multitool
        ports:
        - containerPort: 8080
          name: port-backend
        env:
          - name: HTTP_PORT
            value: "8080"
```

3. Добавить Service, которые обеспечат доступ к обоим приложениям внутри кластера. 

```yaml
apiVersion: v1
kind: Service
metadata:
  name: svc-front-back
spec:
  selector:
    tier: frontend-backend
  ports:
    - name: port-frontend
      port: 9001
      targetPort: port-frontend
    - name: port-backend
      port: 9002
      targetPort: port-backend
  type: NodePort
```

4. Продемонстрировать, что приложения видят друг друга с помощью Service.

```bash
kubectl run multitool --image=wbitt/network-multitool
kubectl exec -it multitool -- sh
    или
kubectl run multitool --image=wbitt/network-multitool -it --rm -- sh

/ # curl svc-front-back.default.svc.cluster.local:9001
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

/ # curl svc-front-back.default.svc.cluster.local:9002
WBITT Network MultiTool (with NGINX) - dpl-backend-fb66b698b-dphcn - 10.1.128.196 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
```

5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.

</details>

------

### Задание 2. Создать Ingress и обеспечить доступ к приложениям снаружи кластера

1. Включить Ingress-controller в MicroK8S.
2. Создать Ingress, обеспечивающий доступ снаружи по IP-адресу кластера MicroK8S так, чтобы при запросе только по адресу открывался _frontend_ а при добавлении /api - _backend_.
3. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.
4. Предоставить манифесты и скриншоты или вывод команды п.2.

<details>
<summary>Ответ</summary>

1. Включить Ingress-controller в MicroK8S.

```bash
microk8s enable ingress

% kubectl get ingressclasses.networking.k8s.io
NAME     CONTROLLER             PARAMETERS   AGE
public   k8s.io/ingress-nginx   <none>       29s
nginx    k8s.io/ingress-nginx   <none>       29s
```

2. Создать Ingress, обеспечивающий доступ снаружи по IP-адресу кластера MicroK8S так, чтобы при запросе только по адресу открывался _frontend_ а при добавлении /api - _backend_.

```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-app
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: microk8s.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: svc-front-back
                port:
                  name: port-frontend
          - path: /api
            pathType: Exact
            backend:
              service:
                name: svc-front-back
                port:
                  name: port-backend
```

```bash
% kubectl get ingress
NAME          CLASS   HOSTS                  ADDRESS   PORTS   AGE
ingress-app   nginx   microk8s.example.com             80      16s
```

3. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.

```bash
% curl http://microk8s.example.com    
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

% curl http://microk8s.example.com/api
WBITT Network MultiTool (with NGINX) - dpl-backend-5957dbdfc7-9hw26 - 10.1.128.202 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
```

4. Предоставить манифесты и скриншоты или вывод команды п.2.
</details>

------

### Правила приема работы

1. Домашняя работа оформляется в своем Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl` и скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.

------