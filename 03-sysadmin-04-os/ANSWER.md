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

		С метриками и комментариями ознакомился.

	</details>

4. Можно ли по выводу `dmesg` понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?

	<details>
	<summary>Ответ</summary>

		Думаю, что по выводу ниже можно понять, что это ВМ.
		
		$ dmesg
		...
		[    0.000000] DMI: innotek GmbH VirtualBox/VirtualBox, BIOS VirtualBox 12/01/2006
		[    0.000000] Hypervisor detected: KVM
		...
		[    0.183112] ACPI: RSDP 0x00000000000E0000 000024 (v02 VBOX  )
		[    0.183116] ACPI: XSDT 0x000000003FFF0030 00003C (v01 VBOX   VBOXXSDT 00000001 ASL  00000061)
		[    0.183120] ACPI: FACP 0x000000003FFF00F0 0000F4 (v04 VBOX   VBOXFACP 00000001 ASL  00000061)
		[    0.183125] ACPI: DSDT 0x000000003FFF0470 002325 (v02 VBOX   VBOXBIOS 00000002 INTL 20100528)
		...
		[    0.186681] Booting paravirtualized kernel on KVM
		...
		[   18.588381] vboxsf: g_fHostFeatures=0x8000000f g_fSfFeatures=0x1 g_uSfLastFunction=29
		[   18.588409] *** VALIDATE vboxsf ***
		[   18.588412] vboxsf: Successfully loaded version 6.1.40 r154048
		[   18.588542] vboxsf: Successfully loaded version 6.1.40 r154048 on 5.4.0-135-generic SMP mod_unload modversions  (LINUX_VERSION_CODE=0x504d4)
		[   18.618678] vboxsf: SHFL_FN_MAP_FOLDER failed for '/vagrant': share not found

	</details>

5. Как настроен sysctl `fs.nr_open` на системе по-умолчанию? Определите, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (`ulimit --help`)?

	<details>
	<summary>Ответ</summary>

		Настройки по умолчанию:
		$ sysctl fs.nr_open
		fs.nr_open = 1048576
			или
		$ cat /proc/sys/fs/nr_open
		1048576

		Это обозначает максимальное количество файловых дескрипторов, которые может выделить процесс. Значение по умолчанию — 1024*1024 (1048576), чего должно быть достаточно для большинства машин. Фактический лимит зависит от лимита ресурсов RLIMIT_NOFILE.
		
		'ulimit -n' не позволит достичь такого числа

	</details>

6. Запустите любой долгоживущий процесс (не `ls`, который отработает мгновенно, а, например, `sleep 1h`) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через `nsenter`. Для простоты работайте в данном задании под root (`sudo -i`). Под обычным пользователем требуются дополнительные опции (`--map-root-user`) и т.д.

	<details>
	<summary>Ответ</summary>

		# unshare -f --pid --mount-proc /bin/bash
		# ps aux
		USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
		root           1  0.0  0.3   7236  3868 pts/1    S    21:01   0:00 /bin/bash
		root           8  0.0  0.3   8888  3340 pts/1    R+   21:01   0:00 ps aux
		# sleep 1h
		
		В соседней сессии:
		# nsenter --target 2855 --pid --mount
		# ps aux
		USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
		root           1  0.0  0.3   7236  3956 pts/1    S    21:01   0:00 /bin/bash
		root           9  0.0  0.4   7360  4016 pts/2    S    21:03   0:00 -bash
		root          22  0.0  0.0   5476   580 pts/1    S+   21:03   0:00 sleep 1h
		root          23  0.0  0.3   8888  3380 pts/2    R+   21:03   0:00 ps aux

	</details>

7. Найдите информацию о том, что такое `:(){ :|:& };:`. Запустите эту команду в своей виртуальной машине Vagrant с Ubuntu 20.04 (**это важно, поведение в других ОС не проверялось**). Некоторое время все будет "плохо", после чего (минуты) – ОС должна стабилизироваться. Вызов `dmesg` расскажет, какой механизм помог автоматической стабилизации.  
Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?

	<details>
	<summary>Ответ</summary>

		`:(){ :|:& };:` - Форк бомба. Системный вызов в Unix-подобных операционных системах, создающий новый процесс, который является практически полной копией процесса-родителя, выполняющего этот вызов. Выполняться будет до тех пор пока не заполнится лимит процессов (ulimit -u).
		
		Вызов `dmesg`:
		...
		[ 2949.685442] cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-3.scope
		
		
		Если ограничить количество процессов у текущего пользователя, то система нагружена будет меньше по времени, т.к. лимит процессов закончится раньше.
		$ ulimit -u 500
		До уменьшения лиитов систему "колбасило" - 55 сек, а после уменьшения лимитов на процессы - 15 сек (увидел по мониторингу netdata).
		
	</details>

*В качестве решения ответьте на вопросы и опишите каким образом эти ответы были получены*

----

### Правила приема домашнего задания

В личном кабинете отправлена ссылка на .md файл в вашем репозитории.

-----

### Критерии оценки

Зачет - выполнены все задания, ответы даны в развернутой форме, приложены соответствующие скриншоты и файлы проекта, в выполненных заданиях нет противоречий и нарушения логики.

На доработку - задание выполнено частично или не выполнено, в логике выполнения заданий есть противоречия, существенные недостатки. 
