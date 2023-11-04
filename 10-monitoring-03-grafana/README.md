# Домашнее задание к занятию 14 «Средство визуализации Grafana»

## Задание повышенной сложности

**При решении задания 1** не используйте директорию [help](./help) для сборки проекта. Самостоятельно разверните grafana, где в роли источника данных будет выступать prometheus, а сборщиком данных будет node-exporter:

- grafana;
- prometheus-server;
- prometheus node-exporter.

За дополнительными материалами можете обратиться в официальную документацию grafana и prometheus.

В решении к домашнему заданию также приведите все конфигурации, скрипты, манифесты, которые вы 
использовали в процессе решения задания.

**При решении задания 3** вы должны самостоятельно завести удобный для вас канал нотификации, например, Telegram или email, и отправить туда тестовые события.

В решении приведите скриншоты тестовых событий из каналов нотификаций.

<details>
<summary>Ответ</summary>

https://grafana.com/docs/grafana/latest/setup-grafana/installation/redhat-rhel-fedora/#install-grafana-as-a-standalone-binary
cd /opt/grafana-10.2.0; nohup ./bin/grafana server > outGrafana.out 2>&1 &
http://192.168.1.125:3000/

https://prometheus.io/docs/introduction/first_steps/
cd /opt/prometheus-2.48.0-rc.2.linux-amd64; nohup ./prometheus --config.file=prometheus.yml > outPrometheus.out 2>&1 &
http://192.168.1.125:9090/

https://prometheus.io/docs/guides/node-exporter/
cd /opt/node_exporter-1.6.1.linux-amd64; nohup ./node_exporter > outNodeExporter.out 2>&1 &
http://192.168.1.125:9100/metrics

</details>

## Обязательные задания

### Задание 1

1. Используя директорию [help](./help) внутри этого домашнего задания, запустите связку prometheus-grafana.
1. Зайдите в веб-интерфейс grafana, используя авторизационные данные, указанные в манифесте docker-compose.
1. Подключите поднятый вами prometheus, как источник данных.
1. Решение домашнего задания — скриншот веб-интерфейса grafana со списком подключенных Datasource.

<details>
<summary>Ответ</summary>

<br>

![DS](https://github.com/aagrebeshkov/Homework/blob/main/10-monitoring-03-grafana/images/DS.png)
<br>

</details>

## Задание 2

Изучите самостоятельно ресурсы:

1. [PromQL tutorial for beginners and humans](https://valyala.medium.com/promql-tutorial-for-beginners-9ab455142085).
1. [Understanding Machine CPU usage](https://www.robustperception.io/understanding-machine-cpu-usage).
1. [Introduction to PromQL, the Prometheus query language](https://grafana.com/blog/2020/02/04/introduction-to-promql-the-prometheus-query-language/).

Создайте Dashboard и в ней создайте Panels:

- утилизация CPU для nodeexporter (в процентах, 100-idle);
- CPULA 1/5/15;
- количество свободной оперативной памяти;
- количество места на файловой системе.

Для решения этого задания приведите promql-запросы для выдачи этих метрик, а также скриншот получившейся Dashboard.

<details>
<summary>Ответ</summary>

<br>

![Dashboard](https://github.com/aagrebeshkov/Homework/blob/main/10-monitoring-03-grafana/images/Dashboard.png)
<br>

CPU Usage:
 - 100 - (avg by (instance) (rate(node_cpu_seconds_total{job="node",mode="idle"}[1m])) * 100)

Load Average:
 - node_load1{instance="192.168.1.125:9100"}
 - node_load5{instance="192.168.1.125:9100"}
 - node_load15{instance="192.168.1.125:9100"}

Memory Usage:
 - node_memory_MemTotal_bytes
 - node_memory_MemTotal_bytes - node_memory_MemFree_bytes

Disk Space:
 - node_filesystem_avail_bytes{instance="192.168.1.125:9100"}

Стресс тесты:
 - fallocate -l 20G /opt/test.img
 - stress-ng --vm 2 --vm-bytes 3G --timeout 60s
 - stress-ng --class memory --sequential 8 --timeout 60s --metrics-brief
 - dd if=/dev/urandom | bzip2 -9 > /dev/null

</details>

## Задание 3

1. Создайте для каждой Dashboard подходящее правило alert — можно обратиться к первой лекции в блоке «Мониторинг».
1. В качестве решения задания приведите скриншот вашей итоговой Dashboard.

<details>
<summary>Ответ</summary>

<br>

![Grafics1](https://github.com/aagrebeshkov/Homework/blob/main/10-monitoring-03-grafana/images/Grafics1.png)
<br>

![Grafics2](https://github.com/aagrebeshkov/Homework/blob/main/10-monitoring-03-grafana/images/Grafics2.png)
<br>

![AlertMessage](https://github.com/aagrebeshkov/Homework/blob/main/10-monitoring-03-grafana/images/AlertMessage.png)
<br>

</details>

## Задание 4

1. Сохраните ваш Dashboard. Для этого перейдите в настройки Dashboard, выберите в боковом меню «JSON MODEL». Далее скопируйте отображаемое json-содержимое в отдельный файл и сохраните его.
1. В качестве решения задания приведите листинг этого файла.

<details>
<summary>Ответ</summary>

[Листинг](./JSONModel_My_dashboard.json)

</details>

---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---
