# Домашнее задание к занятию "3.6. Компьютерные сети. Лекция 1"

### Цель задания

В результате выполнения этого задания вы: 

1. Научитесь работать с http запросами, чтобы увидеть, как клиенты взаимодействуют с серверами по этому протоколу
2. Поработаете с сетевыми утилитами, чтобы разобраться, как их можно использовать для отладки сетевых запросов, соединений.

### Чеклист готовности к домашнему заданию

1. Убедитесь, что у вас установлены необходимые сетевые утилиты - dig, traceroute, mtr, telnet.
2. Используйте `apt install` для установки пакетов


### Инструкция к заданию

1. Создайте .md-файл для ответов на задания в своём репозитории, после выполнения, прикрепите ссылку на него в личном кабинете.
2. Любые вопросы по выполнению заданий спрашивайте в чате учебной группы и/или в разделе “Вопросы по заданию” в личном кабинете.


### Инструменты/ дополнительные материалы, которые пригодятся для выполнения задания

1. Полезным дополнением к обозначенным выше утилитам будет пакет net-tools. Установить его можно с помощью команды `apt install net-tools`.
2. RFC протокола HTTP/1.0, в частности [страница с кодами ответа](https://www.rfc-editor.org/rfc/rfc1945#page-32).
3. [Ссылки на остальные RFC для HTTP](https://blog.cloudflare.com/cloudflare-view-http3-usage/).

------

## Задание

1. Работа c HTTP через телнет.
- Подключитесь утилитой телнет к сайту stackoverflow.com
`telnet stackoverflow.com 80`
- Отправьте HTTP запрос
```bash
GET /questions HTTP/1.0
HOST: stackoverflow.com
[press enter]
[press enter]
```
*В ответе укажите полученный HTTP код, что он означает?*
    
    <details>
    <summary>Ответ</summary>

        HTTP/1.1 403 Forbidden
    	Доступ запрещен

    </details>
    
2. Повторите задание 1 в браузере, используя консоль разработчика F12.
- откройте вкладку `Network`
- отправьте запрос http://stackoverflow.com
- найдите первый ответ HTTP сервера, откройте вкладку `Headers`
- укажите в ответе полученный HTTP код
- проверьте время загрузки страницы, какой запрос обрабатывался дольше всего?
- приложите скриншот консоли браузера в ответ.
    
    <details>
    <summary>Ответ</summary>

    	укажите в ответе полученный HTTP код - 200:
    		Request URL: https://stackoverflow.com/
			Request Method: GET
			Status Code: 200 
			Remote Address: 151.101.1.69:443
			Referrer Policy: no-referrer-when-downgrade

		Проверьте время загрузки страницы 515 ms
		Дольше всего обрабатывался первый GET запрос - 303 ms

    </details>
    
3. Какой IP адрес у вас в интернете?
    
    <details>
    <summary>Ответ</summary>

    	Мой внешний IP - 217.15.63.88
    	Посмотрел на ресурсе - https://myip.ru/

    </details>

4. Какому провайдеру принадлежит ваш IP адрес? Какой автономной системе AS? Воспользуйтесь утилитой `whois`
    
    <details>
    <summary>Ответ</summary>

        $ whois -h whois.radb.net 217.15.63.88
		route:          217.15.62.0/23
		origin:         AS201825
		mnt-by:         MNT-ROSPHONE
		created:        2019-02-18T10:05:46Z
		last-modified:  2019-02-18T10:05:46Z
		source:         RIPE
		remarks:        ****************************
		remarks:        * THIS OBJECT IS MODIFIED
		remarks:        * Please note that all data that is generally regarded as personal
		remarks:        * data has been removed from this object.
		remarks:        * To view the original object, please query the RIPE Database at:
		remarks:        * http://www.ripe.net/whois
		remarks:        ****************************


		Провайдер - Ростелеком.
		Автономная система - AS201825
		
		$ whois -h whois.radb.net AS201825
		aut-num:        AS201825
		as-name:        RUSPHONE-AS
		org:            ORG-RO19-RIPE
		import:         from AS28917 action pref=100; accept ANY
		import:         from AS9002 action pref=100; accept ANY
		import:         from AS8631 action pref=100; accept ANY
		export:         to AS28917 announce AS-RUSPHONE
		export:         to AS9002 announce AS-RUSPHONE
		export:         to AS8631 announce AS-RUSPHONE
		admin-c:        DUMY-RIPE
		tech-c:         DUMY-RIPE
		status:         ASSIGNED
		mnt-by:         RIPE-NCC-END-MNT
		mnt-by:         MNT-ROSPHONE
		created:        2014-07-02T11:10:39Z
		last-modified:  2021-07-22T02:23:04Z
		source:         RIPE
		remarks:        ****************************
		remarks:        * THIS OBJECT IS MODIFIED
		remarks:        * Please note that all data that is generally regarded as personal
		remarks:        * data has been removed from this object.
		remarks:        * To view the original object, please query the RIPE Database at:
		remarks:        * http://www.ripe.net/whois
		remarks:        ****************************

    </details>

5. Через какие сети проходит пакет, отправленный с вашего компьютера на адрес 8.8.8.8? Через какие AS? Воспользуйтесь утилитой `traceroute`
    
    <details>
    <summary>Ответ</summary>

        $ traceroute 8.8.8.8
		traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
		 1  _gateway (10.0.2.2)  0.486 ms  0.327 ms  0.738 ms
		 2  router.lan (192.168.88.1)  10.015 ms  12.311 ms  12.035 ms
		 3  192.168.1.1 (192.168.1.1)  11.833 ms  11.658 ms  12.242 ms
		 4  10.10.10.1 (10.10.10.1)  13.781 ms  13.627 ms  13.464 ms
		 5  89.17.35.249 (89.17.35.249)  17.585 ms  17.299 ms  17.164 ms
		 6  142.250.169.244 (142.250.169.244)  17.017 ms  12.704 ms  12.442 ms
		 7  * * *
		 8  72.14.235.226 (72.14.235.226)  8.378 ms 108.170.250.129 (108.170.250.129)  9.253 ms 108.170.250.33 (108.170.250.33)  12.458 ms
		 9  108.170.250.34 (108.170.250.34)  11.859 ms 108.170.250.130 (108.170.250.130)  11.161 ms 108.170.250.83 (108.170.250.83)  11.939 ms
		10  142.250.238.214 (142.250.238.214)  28.264 ms 172.253.66.116 (172.253.66.116)  27.817 ms 72.14.234.54 (72.14.234.54)  29.598 ms
		11  142.250.233.0 (142.250.233.0)  30.687 ms 216.239.57.222 (216.239.57.222)  29.615 ms 66.249.95.224 (66.249.95.224)  66.132 ms
		12  172.253.70.49 (172.253.70.49)  34.323 ms 216.239.57.229 (216.239.57.229)  19.675 ms 142.250.209.25 (142.250.209.25)  23.726 ms
		13  * * *
		14  * * *
		15  * * *
		16  * * *
		17  * * *
		18  * * *
		19  * * *
		20  * * *
		21  * * *
		22  dns.google (8.8.8.8)  20.745 ms  20.198 ms  22.062 ms

		AS:
		89.17.35.249 - AS201825
		142.250.169.244 - AS15169
		2.14.235.226 - AS3215
		108.170.250.34 - AS15169
		142.250.238.214 - AS15169
		142.250.233.0 - AS15169
		172.253.70.49 - AS15169


        ololololololololololololololololololololol

    </details>

6. Повторите задание 5 в утилите `mtr`. На каком участке наибольшая задержка - delay?
    
    <details>
    <summary>Ответ</summary>

        $ mtr 8.8.8.8

                                                           My traceroute  [v0.93]
		vagrant (10.0.2.15)                                                 		                                            2023-04-05T21:00:16+0000
		Keys:  Help   Display mode   Restart statistics   Order of fields quit                                                                                                                          Packets               Pings
		 Host                                                                                                                       Loss%   Snt   Last   Avg  Best  Wrst StDev
		 1. _gateway                                                                                                                 0.0%    30    1.1   1.4   0.5   2.5   0.5
		 2. router.lan                                                                                                               3.3%    30    2.8   5.1   2.1  48.5   8.4
		 3. 192.168.1.1                                                                                                              0.0%    29    5.2   7.8   2.8  50.8   9.5
		 4. 10.10.10.1                                                                                                               0.0%    29    5.6   9.4   4.5  17.3   3.8
		 5. 89.17.35.249                                                                                                             0.0%    29   15.4   8.7   4.3  16.5   3.2
		 6. 142.250.169.244                                                                                                          0.0%    29    6.0   9.1   4.9  16.8   3.6
		 7. 108.170.250.33                                                                                                           0.0%    29    6.9  10.6   5.3  26.4   5.0
		 8. 108.170.250.34                                                                                                           0.0%    29    6.7   8.8   5.2  15.6   1.9
		 9. 142.251.238.82                                                                                                           0.0%    29   21.7  25.3  20.8  55.2   6.2
		10. 142.251.238.68                                                                                                           0.0%    29   24.9  30.7  22.6  77.8  12.4
		11. 142.250.232.179                                                                                                          0.0%    29   34.2  29.6  24.8  41.1   4.2
		12. (waiting for reply)
		13. (waiting for reply)
		14. (waiting for reply)
		15. (waiting for reply)
		16. (waiting for reply)
		17. (waiting for reply)
		18. (waiting for reply)
		19. (waiting for reply)
		20. dns.google                                                                                                               0.0%    29   21.0  23.9  20.0  43.9   4.6


		Самая большая задержка на ip 142.251.238.68

    </details>

7. Какие DNS сервера отвечают за доменное имя dns.google? Какие A записи? Воспользуйтесь утилитой `dig`
    
    <details>
    <summary>Ответ</summary>

        dns.google.		882	IN	A	8.8.4.4
		dns.google.		882	IN	A	8.8.8.8
        
    </details>

8. Проверьте PTR записи для IP адресов из задания 7. Какое доменное имя привязано к IP? Воспользуйтесь утилитой `dig`

*В качестве ответов на вопросы приложите лог выполнения команд в консоли или скриншот полученных результатов.*
    
    <details>
    <summary>Ответ</summary>

        К IP 8.8.4.4 и 8.8.8.8 привязана запись dns.google

		# dig -x 8.8.4.4
		
		; <<>> DiG 9.16.1-Ubuntu <<>> -x 8.8.4.4
		;; global options: +cmd
		;; Got answer:
		;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 22055
		;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
		
		;; OPT PSEUDOSECTION:
		; EDNS: version: 0, flags:; udp: 65494
		;; QUESTION SECTION:
		;4.4.8.8.in-addr.arpa.		IN	PTR
		
		;; ANSWER SECTION:
		4.4.8.8.in-addr.arpa.	7127	IN	PTR	dns.google.
		
		;; Query time: 0 msec
		;; SERVER: 127.0.0.53#53(127.0.0.53)
		;; WHEN: Thu Apr 06 17:08:20 UTC 2023
		;; MSG SIZE  rcvd: 73


    </details>
    
----

### Правила приема домашнего задания

В личном кабинете отправлена ссылка на .md файл в вашем репозитории.


### Критерии оценки

Зачет - выполнены все задания, ответы даны в развернутой форме, приложены соответствующие скриншоты и файлы проекта, в выполненных заданиях нет противоречий и нарушения логики.

На доработку - задание выполнено частично или не выполнено, в логике выполнения заданий есть противоречия, существенные недостатки. 
 

