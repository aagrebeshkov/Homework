# Домашнее задание к занятию «Базовые объекты K8S»

### Цель задания

В тестовой среде для работы с Kubernetes, установленной в предыдущем ДЗ, необходимо развернуть Pod с приложением и подключиться к нему со своего локального компьютера. 

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключенным Git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. Описание [Pod](https://kubernetes.io/docs/concepts/workloads/pods/) и примеры манифестов.
2. Описание [Service](https://kubernetes.io/docs/concepts/services-networking/service/).

------

### Задание 1. Создать Pod с именем hello-world

1. Создать манифест (yaml-конфигурацию) Pod.
2. Использовать image - gcr.io/kubernetes-e2e-test-images/echoserver:2.2.
3. Подключиться локально к Pod с помощью `kubectl port-forward` и вывести значение (curl или в браузере).

<details>
<summary>Ответ</summary>

1. Создать манифест (yaml-конфигурацию) Pod.

```yml
apiVersion: v1
kind: Pod
metadata:
  name: pod-hello-world
spec:
  containers:
    - name: container-hello-world
      image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2
```

2. Использовать image - gcr.io/kubernetes-e2e-test-images/echoserver:2.2.
3. Подключиться локально к Pod с помощью `kubectl port-forward` и вывести значение (curl или в браузере).

```bash
% kubectl get pods -o wide
NAME              READY   STATUS    RESTARTS   AGE   IP             NODE       NOMINATED NODE   READINESS GATES
pod-hello-world   1/1     Running   0          26s   10.1.128.221   microk8s   <none>           <none>
```

Зайти в контейнер, чтоб увидеть какой порт в нем слушается:
```bash
kubectl exec -it pod-hello-world -- sh
```

На сервере с microk8s запустить port-forward:
```bash
microk8s kubectl port-forward pod-hello-world --address 0.0.0.0 80:8080
```

Открыл в браузере:
![browser](https://github.com/aagrebeshkov/Homework/blob/main/12-kuber-01-2/images/browser.png)
<br>

Создал второй под и из него дернул curl:
```bash
kubectl run pod-curl --image=curlimages/curl -it --rm -- sh
curl 10.1.128.221:8080
```
![curl](https://github.com/aagrebeshkov/Homework/blob/main/12-kuber-01-2/images/curl.png)
<br>

Удалил Pod:
```bash
kubectl delete -f pod-hello-world.yaml
```

</details>

------

### Задание 2. Создать Service и подключить его к Pod

1. Создать Pod с именем netology-web.
2. Использовать image — gcr.io/kubernetes-e2e-test-images/echoserver:2.2.
3. Создать Service с именем netology-svc и подключить к netology-web.
4. Подключиться локально к Service с помощью `kubectl port-forward` и вывести значение (curl или в браузере).

<details>
<summary>Ответ</summary>

1. Создать Pod с именем netology-web.
2. Использовать image — gcr.io/kubernetes-e2e-test-images/echoserver:2.2.
3. Создать Service с именем netology-svc и подключить к netology-web.

```yml
apiVersion: v1
kind: Pod
metadata:
  name: netology-web
  labels:
    app: echoserver
spec:
  containers:
    - name: container-hello-world
      image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2

---
apiVersion: v1
kind: Service
metadata:
  name: netology-svc
spec:
  selector:
    app: echoserver
  ports:
    - name      : app-echoserver
      protocol  : TCP
      port      : 80
      targetPort: 8080
```

Запуск создания пода и сервиса из манифест файла:
```bash
% kubectl apply -f pod-netology-web.yaml 
pod/netology-web created
service/netology-svc created

% kubectl get pods
NAME           READY   STATUS    RESTARTS   AGE
netology-web   1/1     Running   0          8s

% kubectl get svc 
NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
kubernetes     ClusterIP   10.152.183.1     <none>        443/TCP   24h
netology-svc   ClusterIP   10.152.183.181   <none>        80/TCP    13s
```

4. Подключиться локально к Service с помощью `kubectl port-forward` и вывести значение (curl или в браузере).
На сервере с microk8s запустить port-forward:
```bash
microk8s kubectl port-forward services/netology-svc --address 0.0.0.0 80:80
```

![browser_2](https://github.com/aagrebeshkov/Homework/blob/main/12-kuber-01-2/images/browser_2.png)
<br>

Удалил Pod и Services:
```bash
kubectl delete -f pod-netology-web.yaml
```

</details>

------

### Правила приёма работы

1. Домашняя работа оформляется в своем Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода команд `kubectl get pods`, а также скриншот результата подключения.
3. Репозиторий должен содержать файлы манифестов и ссылки на них в файле README.md.

------

### Критерии оценки
Зачёт — выполнены все задания, ответы даны в развернутой форме, приложены соответствующие скриншоты и файлы проекта, в выполненных заданиях нет противоречий и нарушения логики.

На доработку — задание выполнено частично или не выполнено, в логике выполнения заданий есть противоречия, существенные недостатки.
