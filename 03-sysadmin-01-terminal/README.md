# Домашнее задание к занятию "3.1. Работа в терминале, лекция 1"

1. Установите средство виртуализации [Oracle VirtualBox](https://www.virtualbox.org/).

2. Установите средство автоматизации [Hashicorp Vagrant](https://www.vagrantup.com/).

3. В вашем основном окружении подготовьте удобный для дальнейшей работы терминал. Можно предложить:

	* iTerm2 в Mac OS X
	* Windows Terminal в Windows
	* выбрать цветовую схему, размер окна, шрифтов и т.д.
	* почитать о кастомизации PS1/применить при желании.

	Несколько популярных проблем:
	* Добавьте Vagrant в правила исключения перехватывающих трафик для анализа антивирусов, таких как Kaspersky, если у вас возникают связанные с SSL/TLS ошибки,
	* MobaXterm может конфликтовать с Vagrant в Windows,
	* Vagrant плохо работает с директориями с кириллицей (может быть вашей домашней директорией), тогда можно либо изменить [VAGRANT_HOME](https://www.vagrantup.com/docs/other/environmental-variables#vagrant_home), либо создать в системе профиль пользователя с английским именем,
	* VirtualBox конфликтует с Windows Hyper-V и его необходимо [отключить](https://www.vagrantup.com/docs/installation#windows-virtualbox-and-hyper-v),
	* [WSL2](https://docs.microsoft.com/ru-ru/windows/wsl/wsl2-faq#does-wsl-2-use-hyper-v-will-it-be-available-on-windows-10-home) использует Hyper-V, поэтому с ним VirtualBox также несовместим,
	* аппаратная виртуализация (Intel VT-x, AMD-V) должна быть активна в BIOS,
	* в Linux при установке [VirtualBox](https://www.virtualbox.org/wiki/Linux_Downloads) может дополнительно потребоваться пакет `linux-headers-generic` (debian-based) / `kernel-devel` (rhel-based).

4. С помощью базового файла конфигурации запустите Ubuntu 20.04 в VirtualBox посредством Vagrant:

	* Создайте директорию, в которой будут храниться конфигурационные файлы Vagrant. В ней выполните `vagrant init`. Замените содержимое Vagrantfile по умолчанию следующим:

		```bash
		Vagrant.configure("2") do |config|
			config.vm.box = "bento/ubuntu-20.04"
		end
		```

	* Выполнение в этой директории `vagrant up` установит провайдер VirtualBox для Vagrant, скачает необходимый образ и запустит виртуальную машину.

	* `vagrant suspend` выключит виртуальную машину с сохранением ее состояния (т.е., при следующем `vagrant up` будут запущены все процессы внутри, которые работали на момент вызова suspend), `vagrant halt` выключит виртуальную машину штатным образом.

5. Ознакомьтесь с графическим интерфейсом VirtualBox, посмотрите как выглядит виртуальная машина, которую создал для вас Vagrant, какие аппаратные ресурсы ей выделены. Какие ресурсы выделены по-умолчанию?

	<details>
	<summary>Ответ</summary>

		CPU: 2 RAM: 1024Mb SSD: 64

	</details>

6. Ознакомьтесь с возможностями конфигурации VirtualBox через Vagrantfile: [документация](https://www.vagrantup.com/docs/providers/virtualbox/configuration.html). Как добавить оперативной памяти или ресурсов процессора виртуальной машине?

	<details>
	<summary>Ответ</summary>

		Vagrant.configure("2") do |config|
			# Image name
			config.vm.box = "bento/ubuntu-20.04"		# List OS: https://app.vagrantup.com/boxes/search
			config.vm.provider "virtualbox" do |v|
				# Name VM
				v.name = "ubuntu_devops"
				# Customize the amount of memory on the VM:
				v.memory = "1024"
				# Customize the amount of CPU on the VM:
				v.cpus = 1
				# the VM is modified to have a host CPU execution cap of 50%, meaning that no matter how much CPU is used in the VM, no more than 50% would be used on your own host machine
				v.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
			end
			# Hostname
			config.vm.hostname = "vagrant-01"
			# Network bridge
			config.vm.network "public_network"
			config.vm.network "forwarded_port", guest: 19999, host: 19999
		end

	</details>

7. Команда `vagrant ssh` из директории, в которой содержится Vagrantfile, позволит вам оказаться внутри виртуальной машины без каких-либо дополнительных настроек. Попрактикуйтесь в выполнении обсуждаемых команд в терминале Ubuntu.

	<details>
	<summary>Ответ</summary>

		Успешно зашел в сессию SSH.

	</details>

8. Ознакомиться с разделами `man bash`, почитать о настройках самого bash:
    * какой переменной можно задать длину журнала `history`, и на какой строчке manual это описывается?
    * что делает директива `ignoreboth` в bash?

	<details>
	<summary>Ответ</summary>

		* HISTFILESIZE строка 619
		* Директива `ignoreboth` в bash убирает из истории повторяющиеся команды

	</details>
	
9. В каких сценариях использования применимы скобки `{}` и на какой строчке `man bash` это описано?

	<details>
	<summary>Ответ</summary>

		Можно из зарезервированных слов сделать, например переменную. Строка 140 {} означают списки. Строка 205 {1..9} диапазон значений - 798 Можно обозначать переменную. Строка 469, 492

	</details>
	
10. Основываясь на предыдущем вопросе, как создать однократным вызовом `touch` 100000 файлов? А получилось ли создать 300000? Если нет, то почему?

	<details>
	<summary>Ответ</summary>

		touch f-{1..100000}.txt

		При создании файлов через “touch f-{1..300000}.txt” - возникает ошибка “Argument list too long” Скорее всего получится создать через цикл, но ждать очень долго придется:
			for f in f-{1..300000}; do touch $f; done
		Проще разбить на более маленькие диапазоны.

	</details>
	
11. В man bash поищите по `/\[\[`. Что делает конструкция `[[ -d /tmp ]]`

	<details>
	<summary>Ответ</summary>

		When used with [[, the < and > operators sort lexicographically using the current locale. The test command sorts using ASCII ordering. -d file True if file exists and is a directory. Если директория указанная /tmp существует, то результатом работы будет истина.

		Пример: if [[ -d /tmp ]] then echo "directory exists" else echo "directory does not exist" fi

		Результатом работы будет: “directory exists”.

		В документации сказано: "-d file - Истинно, если файл существует и является директорией." Мы знаем, что 1 - true, а 0 - false.

		[[ -d /tmp ]];echo $? # Я знаю, что /tmp точно существует и является директорией. Т.е. скрипт должен вернуть true. [[ -d /tmp1 ]];echo $? # Такой директории не существует. Т.е. скрипт должен вернуть false.

		Далее мы выводим значение переменной $?. Эта переменная означает код возврата. Если вывод успешный, то выведет "0", при ошибке выведет любую число отличное от нуля.

	</details>
	
12. Основываясь на знаниях о просмотре текущих (например, PATH) и установке новых переменных; командах, которые мы рассматривали, добейтесь в выводе type -a bash в виртуальной машине наличия первым пунктом в списке:

	```bash
	bash is /tmp/new_path_directory/bash
	bash is /usr/local/bin/bash
	bash is /bin/bash
	```

	(прочие строки могут отличаться содержимым и порядком)
    В качестве ответа приведите команды, которые позволили вам добиться указанного вывода или соответствующие скриншоты.

	<details>
	<summary>Ответ</summary>

		mkdir /tmp/olol cp /usr/bin/bash /tmp/olol/bash export PATH=/tmp/olol:$PATH

	</details>
	

13. Чем отличается планирование команд с помощью `batch` и `at`?

	<details>
	<summary>Ответ</summary>

		Batch выполнится при снижении load average до 0,8. У меня выполнился при 0.33 1.05 0.76 а для at указывается время запуска:
			at 11:23 -f /home/devops/date_test.sh

	</details>

14. Завершите работу виртуальной машины чтобы не расходовать ресурсы компьютера и/или батарею ноутбука.

	<details>
	<summary>Ответ</summary>

		vagrant halt

	</details>

 
 ---

## Как сдавать задания

Обязательными к выполнению являются задачи без указания звездочки. Их выполнение необходимо для получения зачета и диплома о профессиональной переподготовке.

Задачи со звездочкой (*) являются дополнительными задачами и/или задачами повышенной сложности. Они не являются обязательными к выполнению, но помогут вам глубже понять тему.

Домашнее задание выполните в файле readme.md в github репозитории. В личном кабинете отправьте на проверку ссылку на .md-файл в вашем репозитории.

Также вы можете выполнить задание в [Google Docs](https://docs.google.com/document/u/0/?tgif=d) и отправить в личном кабинете на проверку ссылку на ваш документ.
Название файла Google Docs должно содержать номер лекции и фамилию студента. Пример названия: "1.1. Введение в DevOps — Сусанна Алиева".

Если необходимо прикрепить дополнительные ссылки, просто добавьте их в свой Google Docs.

Перед тем как выслать ссылку, убедитесь, что ее содержимое не является приватным (открыто на комментирование всем, у кого есть ссылка), иначе преподаватель не сможет проверить работу. Чтобы это проверить, откройте ссылку в браузере в режиме инкогнито.

[Как предоставить доступ к файлам и папкам на Google Диске](https://support.google.com/docs/answer/2494822?hl=ru&co=GENIE.Platform%3DDesktop)

[Как запустить chrome в режиме инкогнито ](https://support.google.com/chrome/answer/95464?co=GENIE.Platform%3DDesktop&hl=ru)

[Как запустить  Safari в режиме инкогнито ](https://support.apple.com/ru-ru/guide/safari/ibrw1069/mac)

Любые вопросы по решению задач задавайте в чате Slack.

---