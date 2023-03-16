# Домашнее задание к занятию "3.4. Операционные системы. Лекция 2"

### Цель задания

В результате выполнения этого задания вы:
1. Познакомитесь со средством сбора метрик node_exporter и средством сбора и визуализации метрик NetData. Такого рода инструменты позволяют выстроить систему мониторинга сервисов для своевременного выявления проблем в их работе.
2. Построите простой systemd unit файл для создания долгоживущих процессов, которые стартуют вместе со стартом системы автоматически.
3. Проанализируете dmesg, а именно часть лога старта виртуальной машины, чтобы понять, какая полезная информация может там находиться.
4. Поработаете с unshare и nsenter для понимания, как создать отдельный namespace для процесса (частичная контейнеризация).

### Чеклист готовности к домашнему заданию

1. Убедитесь, что у вас установлен [Netdata](https://github.com/netdata/netdata) c ресурса с предподготовленными [пакетами](https://packagecloud.io/netdata/netdata/install) или `sudo apt install -y netdata`.


### Инструменты/ дополнительные материалы, которые пригодятся для выполнения задания

1. [Документация](https://www.freedesktop.org/software/systemd/man/systemd.service.html) по systemd unit файлам
2. [Документация](https://www.kernel.org/doc/Documentation/sysctl/) по параметрам sysctl

------

## Задание

1. На лекции мы познакомились с [node_exporter](https://github.com/prometheus/node_exporter/releases). В демонстрации его исполняемый файл запускался в background. Этого достаточно для демо, но не для настоящей production-системы, где процессы должны находиться под внешним управлением. Используя знания из лекции по systemd, создайте самостоятельно простой [unit-файл](https://www.freedesktop.org/software/systemd/man/systemd.service.html) для node_exporter:

    * поместите его в автозагрузку,
    * предусмотрите возможность добавления опций к запускаемому процессу через внешний файл (посмотрите, например, на `systemctl cat cron`),
    * удостоверьтесь, что с помощью systemctl процесс корректно стартует, завершается, а после перезагрузки автоматически поднимается.

	<details>
	<summary>Ответ</summary>

		# cat /etc/systemd/system/node_exporter.service
		[Unit]
		Description=Node Exporter
		
		[Service]
		EnvironmentFile=/etc/default/node_exporter
		ExecStart=/usr/local/bin/node_exporter $OPTIONS
		KillMode=process
		Restart=on-failure
		
		[Install]
		WantedBy=multi-user.target
		
		
		# cat /etc/default/node_exporter
		OPTIONS="--collector.textfile.directory /var/lib/node_exporter/textfile_collector"
		
		посмотреть статус:
		# systemctl status node_exporter
		
		Видим, что он disabled — делаем авто запуск:
		# systemctl enable node_exporter
		
		После рестарта ВМ сервис запускается.
		# systemctl status node_exporter
		● node_exporter.service - Node Exporter
			Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
			Active: active (running) since Sat 2023-02-04 03:07:45 UTC; 2min 15s ago
		Main PID: 1812 (node_exporter)
			Tasks: 3 (limit: 1066)
			Memory: 2.2M
			CGroup: /system.slice/node_exporter.service
					└─1812 /usr/local/bin/node_exporter --collector.textfile.directory /var/lib/node_exporter/textfile_collector
		
		Feb 04 03:07:45 vagrant-01 node_exporter[1812]: ts=2023-02-04T03:07:45.949Z caller=node_exporter.go:117 level=info collector=therm>
		Feb 04 03:07:45 vagrant-01 node_exporter[1812]: ts=2023-02-04T03:07:45.949Z caller=node_exporter.go:117 level=info collector=time
		Feb 04 03:07:45 vagrant-01 node_exporter[1812]: ts=2023-02-04T03:07:45.949Z caller=node_exporter.go:117 level=info collector=timex
		Feb 04 03:07:45 vagrant-01 node_exporter[1812]: ts=2023-02-04T03:07:45.949Z caller=node_exporter.go:117 level=info collector=udp_q>
		Feb 04 03:07:45 vagrant-01 node_exporter[1812]: ts=2023-02-04T03:07:45.949Z caller=node_exporter.go:117 level=info collector=uname
		Feb 04 03:07:45 vagrant-01 node_exporter[1812]: ts=2023-02-04T03:07:45.949Z caller=node_exporter.go:117 level=info collector=vmstat
		Feb 04 03:07:45 vagrant-01 node_exporter[1812]: ts=2023-02-04T03:07:45.949Z caller=node_exporter.go:117 level=info collector=xfs
		Feb 04 03:07:45 vagrant-01 node_exporter[1812]: ts=2023-02-04T03:07:45.949Z caller=node_exporter.go:117 level=info collector=zfs
		Feb 04 03:07:45 vagrant-01 node_exporter[1812]: ts=2023-02-04T03:07:45.949Z caller=tls_config.go:232 level=info msg="Listening on">
		Feb 04 03:07:45 vagrant-01 node_exporter[1812]: ts=2023-02-04T03:07:45.949Z caller=tls_config.go:235 level=info msg="TLS is disabl>

	</details>

2. Ознакомьтесь с опциями node_exporter и выводом `/metrics` по-умолчанию. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.

	<details>
	<summary>Ответ</summary>

		Для мониторинга CPU:
		# TYPE node_cpu_seconds_total counter
		node_cpu_seconds_total{cpu="0",mode="idle"} 80.53
		node_cpu_seconds_total{cpu="0",mode="iowait"} 2.82
		node_cpu_seconds_total{cpu="0",mode="irq"} 0
		node_cpu_seconds_total{cpu="0",mode="nice"} 0
		node_cpu_seconds_total{cpu="0",mode="softirq"} 0.33
		node_cpu_seconds_total{cpu="0",mode="steal"} 0
		node_cpu_seconds_total{cpu="0",mode="system"} 13.67
		node_cpu_seconds_total{cpu="0",mode="user"} 9.24

		Для файловай системы:
		node_filesystem_avail_bytes{device="/dev/mapper/ubuntu--vg-ubuntu--lv",fstype="ext4",mountpoint="/"} 2.6339016704e+10
		node_filesystem_avail_bytes{device="/dev/sda2",fstype="ext4",mountpoint="/boot"} 1.805344768e+09
		node_filesystem_avail_bytes{device="tmpfs",fstype="tmpfs",mountpoint="/run"} 1.01421056e+08
		node_filesystem_avail_bytes{device="tmpfs",fstype="tmpfs",mountpoint="/run/lock"} 5.24288e+06
		node_filesystem_avail_bytes{device="tmpfs",fstype="tmpfs",mountpoint="/run/snapd/ns"} 1.01421056e+08
		node_filesystem_avail_bytes{device="tmpfs",fstype="tmpfs",mountpoint="/run/user/1000"} 1.02432768e+08
		node_filesystem_avail_bytes{device="vagrant",fstype="vboxsf",mountpoint="/vagrant"} 8.2472972288e+10

		Для памяти:
		process_resident_memory_bytes 1.7965056e+07
		process_virtual_memory_bytes 7.43759872e+08
		process_virtual_memory_max_bytes 1.8446744073709552e+19
		node_memory_SwapFree_bytes 2.047864832e+09
		node_memory_SwapTotal_bytes 2.047864832e+09
		
		Для сети:
		node_network_speed_bytes{device="eth0"} 1.25e+08
		node_network_speed_bytes{device="eth1"} 1.25e+08
		node_network_transmit_bytes_total{device="eth0"} 116597
		node_network_transmit_bytes_total{device="eth1"} 363785
		node_network_transmit_bytes_total{device="lo"} 693990

	</details>

3. Установите в свою виртуальную машину [Netdata](https://github.com/netdata/netdata). Воспользуйтесь [готовыми пакетами](https://packagecloud.io/netdata/netdata/install) для установки (`sudo apt install -y netdata`). 
   
   После успешной установки:
    * в конфигурационном файле `/etc/netdata/netdata.conf` в секции [web] замените значение с localhost на `bind to = 0.0.0.0`,
    * добавьте в Vagrantfile проброс порта Netdata на свой локальный компьютер и сделайте `vagrant reload`:

    ```bash
    config.vm.network "forwarded_port", guest: 19999, host: 19999
    ```

    После успешной перезагрузки в браузере *на своем ПК* (не в виртуальной машине) вы должны суметь зайти на `localhost:19999`. Ознакомьтесь с метриками, которые по умолчанию собираются Netdata и с комментариями, которые даны к этим метрикам.

	<details>
	<summary>Ответ</summary>

		ololoololololololololololololololololoolololololololol

	</details>

4. Можно ли по выводу `dmesg` понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?

	<details>
	<summary>Ответ</summary>

		ololoololololololololololololololololoolololololololol

	</details>

5. Как настроен sysctl `fs.nr_open` на системе по-умолчанию? Определите, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (`ulimit --help`)?

	<details>
	<summary>Ответ</summary>

		ololoololololololololololololololololoolololololololol

	</details>

6. Запустите любой долгоживущий процесс (не `ls`, который отработает мгновенно, а, например, `sleep 1h`) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через `nsenter`. Для простоты работайте в данном задании под root (`sudo -i`). Под обычным пользователем требуются дополнительные опции (`--map-root-user`) и т.д.

	<details>
	<summary>Ответ</summary>

		ololoololololololololololololololololoolololololololol

	</details>

7. Найдите информацию о том, что такое `:(){ :|:& };:`. Запустите эту команду в своей виртуальной машине Vagrant с Ubuntu 20.04 (**это важно, поведение в других ОС не проверялось**). Некоторое время все будет "плохо", после чего (минуты) – ОС должна стабилизироваться. Вызов `dmesg` расскажет, какой механизм помог автоматической стабилизации.  
Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?

	<details>
	<summary>Ответ</summary>

		ololoololololololololololololololololoolololololololol

	</details>

*В качестве решения ответьте на вопросы и опишите каким образом эти ответы были получены*

----

### Правила приема домашнего задания

В личном кабинете отправлена ссылка на .md файл в вашем репозитории.

-----

### Критерии оценки

Зачет - выполнены все задания, ответы даны в развернутой форме, приложены соответствующие скриншоты и файлы проекта, в выполненных заданиях нет противоречий и нарушения логики.

На доработку - задание выполнено частично или не выполнено, в логике выполнения заданий есть противоречия, существенные недостатки. 
