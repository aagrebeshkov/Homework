# Домашнее задание к занятию «2.4. Инструменты Git»

### Цель задания

В результате выполнения этого задания вы научитесь работать с утилитами Git и  потренируетесь решать типовые задачи, возникающие при работе в команде. 

### Инструкция к заданию

1. Склонируйте [репозиторий](https://github.com/hashicorp/terraform) с исходным кодом Terraform.
2. Создайте файл для ответов на задания в своём репозитории, после выполнения, прикрепите ссылку на .md-файл с ответами в личном кабинете.
3. Любые вопросы по решению задач задавайте в чате учебной группы.

------

## Задание

В клонированном репозитории:

1. Найдите полный хеш и комментарий коммита, хеш которого начинается на `aefea`.
	
	
	<details>
	<summary>Ответ</summary>

		$ git log | grep aefea
		commit aefead2207ef7e2aa5dc81a34aedf0cad4c32545

	</details>
	
	
2. Какому тегу соответствует коммит `85024d3`?
	
	
	<details>
	<summary>Ответ</summary>

		$ git show 85024d3
		commit 85024d3100126de36331c6982bfaac02cdab9e76 (tag: v0.12.23)
		...

	</details>
	
	
3. Сколько родителей у коммита `b8d720`? Напишите их хеши.
	
	
	<details>
	<summary>Ответ</summary>

		$ git show b8d720 --pretty=format:"%P"
		56cd7859e05c36c06b56d013b55a252d0bb7e158 9ea88f22fc6269854151c571162c5bcf958bee2b

	</details>
	
	
4. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами  v0.12.23 и v0.12.24.
	
	
	<details>
	<summary>Ответ</summary>

		$ git log --pretty=format:"%H %s" v0.12.23...v0.12.24
		33ff1c03bb960b332be3af2e333462dde88b279e v0.12.24
		b14b74c4939dcab573326f4e3ee2a62e23e12f89 [Website] vmc provider links
		3f235065b9347a758efadc92295b540ee0a5e26e Update CHANGELOG.md
		6ae64e247b332925b872447e9ce869657281c2bf registry: Fix panic when server is unreachable
		5c619ca1baf2e21a155fcdb4c264cc9e24a2a353 website: Remove links to the getting started guide's old location
		06275647e2b53d97d4f0a19a0fec11f6d69820b5 Update CHANGELOG.md
		d5f9411f5108260320064349b757f55c09bc4b80 command: Fix bug when using terraform login on Windows
		4b6d06cc5dcb78af637bbb19c198faff37a066ed Update CHANGELOG.md
		dd01a35078f040ca984cdd349f18d0b67e486c35 Update CHANGELOG.md
		225466bc3e5f35baa5d07197bbc079345b77525e Cleanup after v0.12.23 release

	</details>
	
	
5. Найдите коммит в котором была создана функция `func providerSource`, ее определение в коде выглядит 
так `func providerSource(...)` (вместо троеточия перечислены аргументы).
	
	
	<details>
	<summary>Ответ</summary>

		$ git log -S 'func providerSource' --oneline
		5af1e6234a main: Honor explicit provider_installation CLI config when present
		8c928e8358 main: Consult local directories as potential mirrors of providers
		
		$ git show 5af1e6234a
		commit 5af1e6234ab6da412fb8637393c5a17a1b293663
		Author: Martin Atkins <mart@degeneration.co.uk>
		Date:   Tue Apr 21 16:28:59 2020 -0700
		
		$ git show 8c928e8358
		commit 8c928e83589d90a031f811fae52a81be7153e82f
		Author: Martin Atkins <mart@degeneration.co.uk>
		Date:   Thu Apr 2 18:04:39 2020 -0700
		
		Итого: Самый ранний коммит с функцией providerSource - 8c928e8358 или полный хеш - 8c928e83589d90a031f811fae52a81be7153e82f

	</details>
	
	
6. Найдите все коммиты в которых была изменена функция `globalPluginDirs`.
	
	
	<details>
	<summary>Ответ</summary>

		$ git log -S 'globalPluginDirs' --oneline
		65c4ba7363 Remove terraform binary
		125eb51dc4 Remove accidentally-committed binary
		22c121df86 Bump compatibility version to 1.3.0 for terraform core release (#30988)
		7c7e5d8f0a Don't show data while input if sensitive
		35a058fb3d main: configure credentials from the CLI config file
		c0b1761096 prevent log output during init
		
		# В коммите ниже функция была создана
		8364383c35 Push plugin discovery down into command package

	</details>
	
	
7. Кто автор функции `synchronizedWriters`? 
	
	
	<details>
	<summary>Ответ</summary>

		$ git log -S "synchronizedWriters" --pretty=format:"%h - %an"
		bdfea50cc8 - James Bardin
		fd4f7eb0b9 - James Bardin
		5ac311e2a9 - Martin Atkins
		Автор функции: Martin Atkins

	</details>
	
	

*В качестве решения ответьте на вопросы и опишите каким образом эти ответы были получены*

---

### Правила приема домашнего задания

В личном кабинете отправлена ссылка на .md файл в вашем репозитории.

### Критерии оценки

Зачет - выполнены все задания, ответы даны в развернутой форме, приложены соответствующие скриншоты и файлы проекта, в выполненных заданиях нет противоречий и нарушения логики.

На доработку - задание выполнено частично или не выполнено, в логике выполнения заданий есть противоречия, существенные недостатки. 
