# Домашнее задание к занятию «Kubernetes. Причины появления. Команда kubectl»

### Цель задания

Для экспериментов и валидации ваших решений вам нужно подготовить тестовую среду для работы с Kubernetes. Оптимальное решение — развернуть на рабочей машине или на отдельной виртуальной машине MicroK8S.

------

### Чеклист готовности к домашнему заданию

1. Личный компьютер с ОС Linux или MacOS 

или

2. ВМ c ОС Linux в облаке либо ВМ на локальной машине для установки MicroK8S  

------

### Инструкция к заданию

1. Установка MicroK8S:
    - sudo apt update,
    - sudo apt install snapd,
    - sudo snap install microk8s --classic,
    - добавить локального пользователя в группу `sudo usermod -a -G microk8s $USER`,
    - изменить права на папку с конфигурацией `sudo chown -f -R $USER ~/.kube`.

2. Полезные команды:
    - проверить статус `microk8s status --wait-ready`;
    - подключиться к microK8s и получить информацию можно через команду `microk8s command`, например, `microk8s kubectl get nodes`;
    - включить addon можно через команду `microk8s enable`; 
    - список addon `microk8s status`;
    - вывод конфигурации `microk8s config`;
    - проброс порта для подключения локально `microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443`.

3. Настройка внешнего подключения:
    - отредактировать файл /var/snap/microk8s/current/certs/csr.conf.template
    ```shell
    # [ alt_names ]
    # Add
    # IP.4 = 123.45.67.89
    ```
    - обновить сертификаты `sudo microk8s refresh-certs --cert front-proxy-client.crt`.

4. Установка kubectl:
    - curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl;
    - chmod +x ./kubectl;
    - sudo mv ./kubectl /usr/local/bin/kubectl;
    - настройка автодополнения в текущую сессию `bash source <(kubectl completion bash)`;
    - добавление автодополнения в командную оболочку bash `echo "source <(kubectl completion bash)" >> ~/.bashrc`.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция](https://microk8s.io/docs/getting-started) по установке MicroK8S.
2. [Инструкция](https://kubernetes.io/ru/docs/reference/kubectl/cheatsheet/#bash) по установке автодополнения **kubectl**.
3. [Шпаргалка](https://kubernetes.io/ru/docs/reference/kubectl/cheatsheet/) по **kubectl**.

------

### Задание 1. Установка MicroK8S

1. Установить MicroK8S на локальную машину или на удалённую виртуальную машину.
2. Установить dashboard.
3. Сгенерировать сертификат для подключения к внешнему ip-адресу.

<details>
<summary>Ответ</summary>

1. Установить MicroK8S на локальную машину или на удалённую виртуальную машину.
Установил по инструкции выше на ВМ в yandex cloud.



2. Установить dashboard.
```bash
$ microk8s enable dashboard
```

Проверка статуса:
```bash
$ microk8s status -a dashboard
enabled
```

Проброс портов:
```bash
microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443 --address 0.0.0.0
```

Заходим по адресу:
https://62.84.126.2:10443/

Генерация токена доступа:
microk8s kubectl create token default

Логинимся в консоль с помощью токена.



3. Сгенерировать сертификат для подключения к внешнему ip-адресу.
В файле /var/snap/microk8s/current/certs/csr.conf.template добавил строку с внешним IP:
```bash
[ alt_names ]
...
IP.3 = 62.84.126.2
```

Выполнил команду:
```bash
$ sudo microk8s refresh-certs --cert front-proxy-client.crt
Taking a backup of the current certificates under /var/snap/microk8s/6089/certs-backup/
Creating new certificates
Signature ok
subject=CN = front-proxy-client
Getting CA Private Key
Restarting service kubelite.
```

</details>

------

### Задание 2. Установка и настройка локального kubectl
1. Установить на локальную машину kubectl.
2. Настроить локально подключение к кластеру.
3. Подключиться к дашборду с помощью port-forward.

<details>
<summary>Ответ</summary>

1. Установить на локальную машину kubectl.
Установил по инструкции выше.



2. Настроить локально подключение к кластеру.
В файле /var/snap/microk8s/current/certs/csr.conf.template добавил строку с внешним IP:
```bash
[ alt_names ]
...
IP.3 = 62.84.126.2
```

Выполнил команду на ВМ с microk8s:
```bash
$ sudo microk8s refresh-certs --cert front-proxy-client.crt
Taking a backup of the current certificates under /var/snap/microk8s/6089/certs-backup/
Creating new certificates
Signature ok
subject=CN = front-proxy-client
Getting CA Private Key
Restarting service kubelite.
```

На локальной машине создал директорию ~/.kube и в конфиг ~/.kube/config записал вывод команды "microk8s config" на ВМ с microk8s.
Затем в файле ~/.kube/config в блоке cluster - server поменял локальный ip на внешний 62.84.126.2.

Проверка подключения к кластеру:
```bash
% kubectl get nodes -o wide
NAME      STATUS   ROLES    AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
minik8s   Ready    <none>   3h53m   v1.28.3   10.0.1.20     <none>        Ubuntu 20.04.6 LTS   5.4.0-169-generic   containerd://1.6.15
```



3. Подключиться к дашборду с помощью port-forward.
```bash
$ microk8s enable dashboard
```

Проверка статуса:
```bash
$ microk8s status -a dashboard
enabled
```

Проброс портов:
```bash
microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443 --address 0.0.0.0
```

Заходим по адресу:
https://62.84.126.2:10443/

Генерация токена доступа:
microk8s kubectl create token default

Логинимся в консоль с помощью токена.

![dashboard](https://github.com/aagrebeshkov/Homework/blob/main/12-kuber-01-1/images/dashboard.png)
<br>


</details>

------

### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода команд `kubectl get nodes` и скриншот дашборда.

------

### Критерии оценки
Зачёт — выполнены все задания, ответы даны в развернутой форме, приложены соответствующие скриншоты и файлы проекта, в выполненных заданиях нет противоречий и нарушения логики.

На доработку — задание выполнено частично или не выполнено, в логике выполнения заданий есть противоречия, существенные недостатки.
