
# Домашнее задание к занятию 2. «Применение принципов IaaC в работе с виртуальными машинами»

## Как сдавать задания

Обязательны к выполнению задачи без звёздочки. Их нужно выполнить, чтобы получить зачёт и диплом о профессиональной переподготовке.

Задачи со звёздочкой (*) — дополнительные задачи и/или задачи повышенной сложности. Их выполнять не обязательно, но они помогут вам глубже понять тему.

Домашнее задание выполните в файле readme.md в GitHub-репозитории. В личном кабинете отправьте на проверку ссылку на .md-файл в вашем репозитории.

Любые вопросы по решению задач задавайте в чате учебной группы.

---


## Важно

Перед отправкой работы на проверку удаляйте неиспользуемые ресурсы.
Это нужно, чтобы не расходовать средства, полученные в результате использования промокода.

Подробные рекомендации [здесь](https://github.com/netology-code/virt-homeworks/blob/virt-11/r/README.md).

---

## Задача 1

- Опишите основные преимущества применения на практике IaaC-паттернов.
<details>
<summary>Ответ</summary>

Идемпотентность — это свойство объекта или операции, при повторном выполнении которой мы получаем результат идентичный предыдущему и всем последующим выполнениям.

</details>

- Какой из принципов IaaC является основополагающим?
<details>
<summary>Ответ</summary>

Более быстрая и эффективная разработка

</details>

## Задача 2

- Чем Ansible выгодно отличается от других систем управление конфигурациями?
<details>
<summary>Ответ</summary>

- Быстрый старт на текущей SSH инфраструктуре
- Декларативный метод описания конфигурыций
- Легкое подключение кастомныз ролей и модулей
- Низкий порог входа

</details>

- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный — push или pull?
<details>
<summary>Ответ</summary>

На мой взгляд более надежным методом является push, т.к. нет необходимости устанавливать агент. И меньше узлов, где могут возникнуть проблемы.

</details>


## Задача 3

Установите на личный компьютер:

- [VirtualBox](https://www.virtualbox.org/),
- [Vagrant](https://github.com/netology-code/devops-materials),
- [Terraform](https://github.com/netology-code/devops-materials/blob/master/README.md),
- Ansible.

*Приложите вывод команд установленных версий каждой из программ, оформленный в Markdown.*
<details>
<summary>Ответ</summary>

VirtualBox:
```bash
% vboxmanage --version
7.0.6r155176
```

Vagrant:
```bash
% vagrant version
Installed Version: 2.3.4
Latest Version: 2.3.4

You're running an up-to-date version of Vagrant!
```

Terraform:
```bash
% terraform -version                                                                             
Terraform v1.4.6
on darwin_amd64
```

Ansible:
```bash
% ansible --version   
ansible [core 2.14.5]
  config file = None
  configured module search path = ['/Users/aleksandrgrebeshkov/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/Cellar/ansible/7.5.0/libexec/lib/python3.11/site-packages/ansible
  ansible collection location = /Users/aleksandrgrebeshkov/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/local/bin/ansible
  python version = 3.11.3 (main, Apr  7 2023, 19:25:52) [Clang 14.0.0 (clang-1400.0.29.202)] (/usr/local/Cellar/ansible/7.5.0/libexec/bin/python3.11)
  jinja version = 3.1.2
  libyaml = True
```

</details>

## Задача 4 

Воспроизведите практическую часть лекции самостоятельно.

- Создайте виртуальную машину.
- Зайдите внутрь ВМ, убедитесь, что Docker установлен с помощью команды
```
docker ps,
```
Vagrantfile из лекции и код ansible находятся в [папке](https://github.com/netology-code/virt-homeworks/tree/virt-11/05-virt-02-iaac/src).
<details>
<summary>Ответ</summary>

```bash
vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
</details>

Примечание. Если Vagrant выдаёт ошибку:
```
URL: ["https://vagrantcloud.com/bento/ubuntu-20.04"]     
Error: The requested URL returned error: 404:
```

выполните следующие действия:

1. Скачайте с [сайта](https://app.vagrantup.com/bento/boxes/ubuntu-20.04) файл-образ "bento/ubuntu-20.04".
2. Добавьте его в список образов Vagrant: "vagrant box add bento/ubuntu-20.04 <путь к файлу>".

