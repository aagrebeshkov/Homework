# Домашнее задание к занятию "3.9. Элементы безопасности информационных систем"


### Цель задания

В результате выполнения этого задания вы: 

1. Настроите парольный менеджер, что позволит не использовать один и тот же пароль на все ресурсы и удобно работать с множеством паролей.
2. Настроите веб-сервер на работу с https. Сегодня https является стандартом в интернете. Понимание сути работы центра сертификации, цепочки сертификатов позволит понять, на чем основывается https протокол.
3. Сконфигурируете ssh клиент на работу с разными серверами по-разному, что дает большую гибкость ssh соединений. Например, к некоторым серверам мы можем обращаться по ssh через приложения, где недоступен ввод пароля.
4. Поработаете со сбором и анализом трафика, которые необходимы для отладки сетевых проблем


### Инструкция к заданию

1. Создайте .md-файл для ответов на задания в своём репозитории, после выполнения прикрепите ссылку на него в личном кабинете.
2. Любые вопросы по выполнению заданий спрашивайте в чате учебной группы и/или в разделе “Вопросы по заданию” в личном кабинете.


### Инструменты/ дополнительные материалы, которые пригодятся для выполнения задания

1. [SSL + Apache2](https://digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-apache-in-ubuntu-20-04)

------

## Задание

1. Установите Bitwarden плагин для браузера. Зарегестрируйтесь и сохраните несколько паролей.

<details>
<summary>Ответ</summary>

![Bitwarden](https://github.com/aagrebeshkov/Homework/blob/main/03-sysadmin-09-security/Bitwarden.png)

</details>

2. Установите Google authenticator на мобильный телефон. Настройте вход в Bitwarden акаунт через Google authenticator OTP.

<details>
<summary>Ответ</summary>

    Двухэтапная аутентификация настроена

</details>

3. Установите apache2, сгенерируйте самоподписанный сертификат, настройте тестовый сайт для работы по HTTPS.

<details>
<summary>Ответ</summary>

    # adduser apache
    # usermod -aG sudo apache
    # su - apache
    
    Установка apache2:
    $ sudo apt install -y apache2
    
    Проверка статуса:
    $ sudo systemctl status apache2
    
    Включаем модуль mod_ssl Apache:
    sudo a2enmod ssl
    
    Перезапускаем Apache для активации модуля:
    sudo systemctl restart apache2
    
    Создание самоподписного сертификата:
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/apache-selfsigned.key \
    -out /etc/ssl/certs/apache-selfsigned.crt \
    -subj "/C=RU/ST=Moscow/L=Moscow/O=Netology_test/OU=Org/CN=192.168.1.109"
    
    
    Создаем новый файл с содержимым ниже:
    sudo vim /etc/apache2/sites-available/192.168.1.109.conf
    <VirtualHost *:443>
        ServerName 192.168.1.109
        DocumentRoot /var/www/192.168.1.109
        SSLEngine on
        SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
        SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
    </VirtualHost>
    
    Создание html страници:
    sudo mkdir /var/www/192.168.1.109
    sudo vim /var/www/192.168.1.109/index.html
    <h1>it worked!</h1>
    
    Включение файла конфигурации:
    sudo a2ensite 192.168.1.109.conf
    
    Проверка на ошибки в конфиге:
    sudo apache2ctl configtest
    sudo systemctl reload apache2

</details>

4. Проверьте на TLS уязвимости произвольный сайт в интернете (кроме сайтов МВД, ФСБ, МинОбр, НацБанк, РосКосмос, РосАтом, РосНАНО и любых госкомпаний, объектов КИИ, ВПК ... и тому подобное).

<details>
<summary>Ответ</summary>

    $ git clone --depth 1 https://github.com/drwetter/testssl.sh.git
    $ cd testssl.sh

    $ ./testssl.sh -U --sneaky https://habr.com/

    ...

     Testing vulnerabilities 

     Heartbleed (CVE-2014-0160)                not vulnerable (OK), no heartbeat extension
     CCS (CVE-2014-0224)                       not vulnerable (OK)
     Ticketbleed (CVE-2016-9244), experiment.  not vulnerable (OK)
     ROBOT                                     not vulnerable (OK)
     Secure Renegotiation (RFC 5746)           supported (OK)
     Secure Client-Initiated Renegotiation     not vulnerable (OK)
     CRIME, TLS (CVE-2012-4929)                not vulnerable (OK)
     BREACH (CVE-2013-3587)                    no gzip/deflate/compress/br HTTP compression (OK)  - only supplied "/" tested
     POODLE, SSL (CVE-2014-3566)               not vulnerable (OK)
     TLS_FALLBACK_SCSV (RFC 7507)              No fallback possible (OK), no protocol below TLS 1.2 offered
     SWEET32 (CVE-2016-2183, CVE-2016-6329)    VULNERABLE, uses 64 bit block ciphers
     FREAK (CVE-2015-0204)                     not vulnerable (OK)
     DROWN (CVE-2016-0800, CVE-2016-0703)      not vulnerable on this host and port (OK)
                                           make sure you don't use this certificate elsewhere with SSLv2 enabled services, see
                                           https://search.censys.io/search?resource=hosts&virtual_hosts=INCLUDE&q=911F5FFC18D826413DCC656A3B1CF9E38229099A3F410F98F64C2AD9915B3336
     LOGJAM (CVE-2015-4000), experimental      not vulnerable (OK): no DH EXPORT ciphers, no DH key detected with <= TLS 1.2
     BEAST (CVE-2011-3389)                     not vulnerable (OK), no SSL3 or TLS1
     LUCKY13 (CVE-2013-0169), experimental     potentially VULNERABLE, uses cipher block chaining (CBC) ciphers with TLS. Check patches
     Winshock (CVE-2014-6321), experimental    not vulnerable (OK)
     RC4 (CVE-2013-2566, CVE-2015-2808)        no RC4 ciphers detected (OK)

</details>

5. Установите на Ubuntu ssh сервер, сгенерируйте новый приватный ключ. Скопируйте свой публичный ключ на другой сервер. Подключитесь к серверу по SSH-ключу.

<details>
<summary>Ответ</summary>

    Генерим ключи:
    $ ssh-keygen
    
    Копируем публичный ключ на удаленный сервер:
    $ ssh-copy-id apache@192.168.1.109
    
    Или копируем вручную в файл authorized_keys
    $ echo public_key_string >> ~/.ssh/authorized_keys
    
    Подключаемся по SSH ключу
    $ ssh apache@192.168.1.109

</details>
 
6. Переименуйте файлы ключей из задания 5. Настройте файл конфигурации SSH клиента, так чтобы вход на удаленный сервер осуществлялся по имени сервера.

<details>
<summary>Ответ</summary>

    $ ssh apache@192.168.1.109 -q 'rm .ssh/authorized_keys'
    
    Копируем публичный ключ на удаленный сервер:
    $ ssh-copy-id -i apache@vagrant
    
    Подключаемся по SSH ключу
    $ ssh apache@vagrant

</details>

7. Соберите дамп трафика утилитой tcpdump в формате pcap, 100 пакетов. Откройте файл pcap в Wireshark.

<details>
<summary>Ответ</summary>

    tcpdump -c 100 -w dump.pcap
    
![Wireshark](https://github.com/aagrebeshkov/Homework/blob/main/03-sysadmin-09-security/wireshark.png)

</details>

*В качестве решения приложите: скриншоты, выполняемые команды, комментарии (по необходимости).*

 ---
 
## Задание для самостоятельной отработки* (необязательно к выполнению)

8. Просканируйте хост scanme.nmap.org. Какие сервисы запущены?

<details>
<summary>Ответ</summary>

    # nmap -O scanme.nmap.org
    Starting Nmap 7.80 ( https://nmap.org ) at 2023-04-18 10:29 UTC
    Nmap scan report for scanme.nmap.org (45.33.32.156)
    Host is up (0.15s latency).
    Other addresses for scanme.nmap.org (not scanned): 2600:3c01::f03c:91ff:fe18:bb2f
    Not shown: 995 closed ports
    PORT      STATE    SERVICE
    22/tcp    open     ssh
    25/tcp    filtered smtp
    80/tcp    open     http
    9929/tcp  open     nping-echo
    31337/tcp open     Elite
    No exact OS matches for host (If you know what OS is running on it, see https://nmap.org/submit/ ).
    TCP/IP fingerprint:
    OS:SCAN(V=7.80%E=4%D=4/18%OT=22%CT=1%CU=31315%PV=N%DS=2%DC=I%G=Y%TM=643E714
    OS:2%P=x86_64-pc-linux-gnu)SEQ(SP=11%GCD=FA00%ISR=9C%TI=I%CI=RD%TS=U)OPS(O1
    OS:=M5B4%O2=M5B4%O3=M5B4%O4=M5B4%O5=M5B4%O6=M5B4)WIN(W1=FFFF%W2=FFFF%W3=FFF
    OS:F%W4=FFFF%W5=FFFF%W6=FFFF)ECN(R=Y%DF=N%T=41%W=FFFF%O=M5B4%CC=N%Q=)T1(R=Y
    OS:%DF=N%T=41%S=O%A=S+%F=AS%RD=0%Q=)T2(R=Y%DF=N%T=100%W=0%S=Z%A=S%F=AR%O=%R
    OS:D=0%Q=)T3(R=Y%DF=N%T=100%W=0%S=Z%A=S+%F=AR%O=%RD=0%Q=)T4(R=Y%DF=N%T=100%
    OS:W=0%S=A%A=Z%F=R%O=%RD=0%Q=)T5(R=Y%DF=N%T=100%W=0%S=Z%A=S+%F=AR%O=%RD=0%Q
    OS:=)T6(R=Y%DF=N%T=100%W=0%S=A%A=Z%F=R%O=%RD=0%Q=)T7(R=Y%DF=N%T=100%W=0%S=Z
    OS:%A=S%F=AR%O=%RD=0%Q=)U1(R=Y%DF=N%T=3A%IPL=164%UN=0%RIPL=G%RID=G%RIPCK=G%
    OS:RUCK=G%RUD=G)IE(R=N)
    
    Network Distance: 2 hops
    
    OS detection performed. Please report any incorrect results at https://nmap.org/submit/ .
    Nmap done: 1 IP address (1 host up) scanned in 27.88 seconds

</details>

9. Установите и настройте фаервол ufw на web-сервер из задания 3. Откройте доступ снаружи только к портам 22,80,443

<details>
<summary>Ответ</summary>

    Уставновка ufw
    # apt install ufw
    
    посмотреть настроенные правила
    # ufw status verbose
    
    Добавление правила на разрешение на подключение по портам 22, 80, 443
    # ufw allow 22/tcp
    # ufw allow 80/tcp
    # ufw allow 443/tcp
    
    Включить фаервол
    # ufw enable
    
    Удалить правило:
    # ufw delete allow 443/tcp
    
    
### или ###
    
    
    Посмотреть список профилей ufw:
    # ufw app list
    
    Из вывода получаем, что для Apache доступны три профиля:
        - Apache: откроет порт 80
        - Apache Full: откроет порт 80 и порт 443
        - Apache Secure: откроет порт 443
        - OpenSSH откроет порт 22 по протоколу tcp
    
    Просмотр детальной информации:
    # ufw app info 'OpenSSH'
    
    Добавление правила на разрешение на подключение по портам 80 и 443:
    # ufw allow 'Apache Full'
    
    Добавление правила на разрешение на подключение по портам 22
    # ufw allow 'OpenSSH'
    
    Посмотреть настроенные правила
    # ufw status verbose
    Status: active
    Logging: on (low)
    Default: deny (incoming), allow (outgoing), disabled (routed)
    New profiles: skip
    
    To                         Action      From
    --                         ------      ----
    80,443/tcp (Apache Full)   ALLOW IN    Anywhere
    22/tcp (OpenSSH)           ALLOW IN    Anywhere
    80,443/tcp (Apache Full (v6)) ALLOW IN    Anywhere (v6)
    22/tcp (OpenSSH (v6))      ALLOW IN    Anywhere (v6)
    
    
    Удалить правила:
    # ufw delete allow 'Apache Full'
    # ufw delete allow 'OpenSSH'
    
    
    
    
    # Настроить логирование
    ufw logging on
    tail -f /var/log/ufw.log

</details>

----

### Правила приема домашнего задания

В личном кабинете отправлена ссылка на .md файл в вашем репозитории.

-----

### Критерии оценки

Зачет - выполнены все задания, ответы даны в развернутой форме, приложены соответствующие скриншоты и файлы проекта, в выполненных заданиях нет противоречий и нарушения логики.

На доработку - задание выполнено частично или не выполнено, в логике выполнения заданий есть противоречия, существенные недостатки. 
 
Обязательными к выполнению являются задачи без указания звездочки. Их выполнение необходимо для получения зачета и диплома о профессиональной переподготовке.
Задачи со звездочкой (*) являются дополнительными задачами и/или задачами повышенной сложности. Они не являются обязательными к выполнению, но помогут вам глубже понять тему.
