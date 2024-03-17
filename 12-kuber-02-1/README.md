# Домашнее задание к занятию «Хранение в K8s. Часть 1»

### Цель задания

В тестовой среде Kubernetes нужно обеспечить обмен файлами между контейнерам пода и доступ к логам ноды.

------

### Чеклист готовности к домашнему заданию

1. Установленное K8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключенным GitHub-репозиторием.

------

### Дополнительные материалы для выполнения задания

1. [Инструкция по установке MicroK8S](https://microk8s.io/docs/getting-started).
2. [Описание Volumes](https://kubernetes.io/docs/concepts/storage/volumes/).
3. [Описание Multitool](https://github.com/wbitt/Network-MultiTool).

------

### Задание 1 

**Что нужно сделать**

Создать Deployment приложения, состоящего из двух контейнеров и обменивающихся данными.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Сделать так, чтобы busybox писал каждые пять секунд в некий файл в общей директории.
3. Обеспечить возможность чтения файла контейнером multitool.
4. Продемонстрировать, что multitool может читать файл, который периодоически обновляется.
5. Предоставить манифесты Deployment в решении, а также скриншоты или вывод команды из п. 4.

<details>
<summary>Ответ</summary>

Манифесты Deployment:
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dpl-busybox-multitool
spec:
  replicas: 1
  selector:
    matchLabels:
      app: busybox-multitool
  template:
    metadata:
      labels:
        app: busybox-multitool
    spec:
      containers:
      - name: busybox
        image: busybox
        command: ['sh', '-c', 'while true ; do date "+%F %H:%M:%S" >> /etc/log/log_busybox; sleep 5; done']
        volumeMounts:
          - name: busybox-volume
            mountPath: /etc/log
      - name: multitool
        image: wbitt/network-multitool
        volumeMounts:
          - name: busybox-volume
            mountPath: /etc/log
      volumes:
      - name: busybox-volume
        hostPath:
          path: /var/data
```

Заходим в контейнер multitool
```bash
kubectl exec -i -t dpl-busybox-multitool-69d688b8b-nv2tp --container multitool -- sh

/ # cat /etc/log/log_busybox
2024-03-17 11:19:46
2024-03-17 11:19:51
2024-03-17 11:19:52
2024-03-17 11:19:56
2024-03-17 11:19:57
2024-03-17 11:20:01
2024-03-17 11:20:02
2024-03-17 11:20:06
2024-03-17 11:20:07
2024-03-17 11:20:11
2024-03-17 11:20:12
2024-03-17 11:20:17
2024-03-17 11:20:22
2024-03-17 11:20:27
2024-03-17 11:20:32
2024-03-17 11:20:37
2024-03-17 11:20:42
2024-03-17 11:20:47
2024-03-17 11:20:52
2024-03-17 11:21:02
2024-03-17 11:21:07
2024-03-17 11:21:12
```

</details>

------

### Задание 2

**Что нужно сделать**

Создать DaemonSet приложения, которое может прочитать логи ноды.

1. Создать DaemonSet приложения, состоящего из multitool.
2. Обеспечить возможность чтения файла `/var/log/syslog` кластера MicroK8S.
3. Продемонстрировать возможность чтения файла изнутри пода.
4. Предоставить манифесты Deployment, а также скриншоты или вывод команды из п. 2.

<details>
<summary>Ответ</summary>

Манифест DaemonSet:
```yml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ds-multitool
spec:
  selector:
    matchLabels:
      app: multitool
  template:
    metadata:
      labels:
        app: multitool
    spec:
      containers:
      - name: multitool
        image: wbitt/network-multitool
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
          - name: varlog-volume
            mountPath: /var/logk8s
      volumes:
      - name: varlog-volume
        hostPath:
          path: /var/log
```

Заходим в контейнер multitool:
```bash
% kubectl exec -i -t ds-multitool-pxr2b --container multitool -- sh

/ # cat /var/logk8s/syslog
Mar 17 10:28:22 microk8s rsyslogd: [origin software="rsyslogd" swVersion="8.2001.0" x-pid="777" x-info="https://www.rsyslog.com"] rsyslogd was HUPedSucceeded.
Mar 17 10:28:22 microk8s systemd[1]: Started Disk Manager.
Mar 17 10:28:22 microk8s udisksd[797]: Acquired the name org.freedesktop.UDisks2 on the system message bus
Mar 17 10:28:22 microk8s systemd[1]: tmp-snap.rootfs_pA0XM0.mount: Succeeded.
Mar 17 10:28:22 microk8s systemd[1]: man-db.service: Succeeded.
Mar 17 10:28:22 microk8s systemd[1]: Finished Daily man-db regeneration.
Mar 17 10:28:22 microk8s systemd[1]: logrotate.service: Succeeded.
Mar 17 10:28:22 microk8s systemd[1]: Finished Rotate log files.
Mar 17 10:28:22 microk8s microk8s.daemon-containerd[784]: + source /snap/microk8s/6089/actions/common/utils.sh
Mar 17 10:28:22 microk8s microk8s.daemon-apiserver-proxy[780]: + export PATH=/snap/microk8s/6089/usr/sbin:/snap/microk8s/6089/usr/bin:/snap/microk8s/6089/sbin:/snap/mi
crok8s/6089/bin:/snap/microk8s/6089/usr/bin:/snap/microk8s/6089/bin:/snap/microk8s/6089/usr/sbin:/snap/microk8s/6089/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr
/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
```

</details>

------

### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl`, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.

------