# Домашнее задание к занятию «Введение в Terraform»

### Цель задания

1. Установить и настроить Terrafrom.
2. Научиться использовать готовый код.

------

### Чеклист готовности к домашнему заданию

1. Скачайте и установите актуальную версию **terraform** >=1.4.X . Приложите скриншот вывода команды ```terraform --version```.
2. Скачайте на свой ПК данный git репозиторий. Исходный код для выполнения задания расположен в директории **01/src**.
3. Убедитесь, что в вашей ОС установлен docker.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. Репозиторий с ссылкой на зеркало для установки и настройки Terraform  [ссылка](https://github.com/netology-code/devops-materials).
2. Установка docker [ссылка](https://docs.docker.com/engine/install/ubuntu/). 
------

### Задание 1

1. Перейдите в каталог [**src**](https://github.com/netology-code/ter-homeworks/tree/main/01/src). Скачайте все необходимые зависимости, использованные в проекте. 
2. Изучите файл **.gitignore**. В каком terraform файле согласно этому .gitignore допустимо сохранить личную, секретную информацию?
3. Выполните код проекта. Найдите  в State-файле секретное содержимое созданного ресурса **random_password**, пришлите в качестве ответа конкретный ключ и его значение.
4. Раскомментируйте блок кода, примерно расположенный на строчках 29-42 файла **main.tf**.
Выполните команду ```terraform validate```. Объясните в чем заключаются намеренно допущенные ошибки? Исправьте их.
5. Выполните код. В качестве ответа приложите вывод команды ```docker ps```
6. Замените имя docker-контейнера в блоке кода на ```hello_world```, выполните команду ```terraform apply -auto-approve```.
Объясните своими словами, в чем может быть опасность применения ключа  ```-auto-approve``` ? В качестве ответа дополнительно приложите вывод команды ```docker ps```
8. Уничтожьте созданные ресурсы с помощью **terraform**. Убедитесь, что все ресурсы удалены. Приложите содержимое файла **terraform.tfstate**. 
9. Объясните, почему при этом не был удален docker образ **nginx:latest** ? Ответ подкрепите выдержкой из документации провайдера.

<details>
<summary>Ответ</summary>
- Изучите файл **.gitignore**. В каком terraform файле согласно этому .gitignore допустимо сохранить личную, секретную информацию?
В файле personal.auto.tfvars
<br>

- Выполните код проекта. Найдите  в State-файле секретное содержимое созданного ресурса **random_password**, пришлите в качестве ответа конкретный ключ и его значение.
Ключ - random_string
Значение:
```bash
        {
          "schema_version": 3,
          "attributes": {
            "bcrypt_hash": "$2a$10$jsHefpAah6G0DhZrBgNIIOehjiEBgZ5pSCGVCt4V2Mo/kdleA1cgG",
            "id": "none",
            "keepers": null,
            "length": 16,
            "lower": true,
            "min_lower": 1,
            "min_numeric": 1,
            "min_special": 0,
            "min_upper": 1,
            "number": true,
            "numeric": true,
            "override_special": null,
            "result": "9Wq8709oeADTEhDt",
            "special": false,
            "upper": true
          },
```

- Раскомментируйте блок кода, примерно расположенный на строчках 29-42 файла **main.tf**. Выполните команду ```terraform validate```. Объясните в чем заключаются намеренно допущенные ошибки? Исправьте их.

Исправленный код:<br>
```bash
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "example_${random_password.random_string.result}"

  ports {
    internal = 80
    external = 8000
  }
}
```
Ошибки:
1. У ресурса "docker_image" не было параметра name
2. В ресурсе "docker_container" была допащена ошибка "1nginx"
3. В Ресурсе названии ресурса "random_password" была ошибка "random_string_fake"
4. У параметра name было "resuld" вместо "result"
<br>

- Выполните код. В качестве ответа приложите вывод команды ```docker ps```
```bash
# docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                  NAMES
d83fa895df77   021283c8eb95   "/docker-entrypoint.…"   4 seconds ago   Up 3 seconds   0.0.0.0:8000->80/tcp   example_9Wq8709oeADTEhDt
```
<br>

- Замените имя docker-контейнера в блоке кода на ```hello_world```, выполните команду ```terraform apply -auto-approve```.
Объясните своими словами, в чем может быть опасность применения ключа  ```-auto-approve``` ? В качестве ответа дополнительно приложите вывод команды ```docker ps```

С применением флага "-auto-approve" terraform не спросит подтверждение на запуск, так можно внести не верные изменения в систему.

```bash
# docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                  NAMES
628dace98806   021283c8eb95   "/docker-entrypoint.…"   7 seconds ago   Up 6 seconds   0.0.0.0:8000->80/tcp   hello_world
```

- Уничтожьте созданные ресурсы с помощью **terraform**. Убедитесь, что все ресурсы удалены. Приложите содержимое файла **terraform.tfstate**. 
```bash
# terraform destroy
```

```yml
# cat terraform.tfstate
{
  "version": 4,
  "terraform_version": "1.5.3",
  "serial": 13,
  "lineage": "81c20b6f-f9cb-1a6d-011d-89106f06d8be",
  "outputs": {},
  "resources": [],
  "check_results": null
}
```

- Объясните, почему при этом не был удален docker образ **nginx:latest** ? Ответ подкрепите выдержкой из документации провайдера.
keep_locally (Boolean) If true, then the Docker image won't be deleted on destroy operation. If this is false, it will delete the image from the docker local storage on destroy operation.

</details>

------

## Дополнительные задания (со звездочкой*)

**Настоятельно рекомендуем выполнять все задания под звёздочкой.**   Их выполнение поможет глубже разобраться в материале.   
Задания под звёздочкой дополнительные (необязательные к выполнению) и никак не повлияют на получение вами зачета по этому домашнему заданию. 

### Задание 2*

1. Изучите в документации provider [**Virtualbox**](https://docs.comcloud.xyz/providers/shekeriev/virtualbox/latest/docs) от 
shekeriev.
2. Создайте с его помощью любую виртуальную машину. Чтобы не использовать VPN советуем выбрать любой образ с расположением в github из [**списка**](https://www.vagrantbox.es/)

В качестве ответа приложите plan для создаваемого ресурса и скриншот созданного в VB ресурса.

<details>
<summary>Ответ</summary>

```bash
% terraform plan
virtualbox_vm.node[0]: Refreshing state... [id=0d6b13af-3026-464b-a4a3-10359caeb6d6]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # virtualbox_vm.node[0] will be updated in-place
  ~ resource "virtualbox_vm" "node" {
        id         = "0d6b13af-3026-464b-a4a3-10359caeb6d6"
      ~ memory     = "1.9 gib" -> "2048 Mb"
        name       = "node-01"
        # (4 unchanged attributes hidden)

        # (1 unchanged block hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```

![VM](https://github.com/aagrebeshkov/Homework/blob/main/05-virt-05-docker-swarm/images/VM.png)

Содержимое main.tf
```bash
terraform {
  required_providers {
    virtualbox = {
      source = "shekeriev/virtualbox"
      version = "0.0.4"
    }
  }
}

resource "virtualbox_vm" "node" {
  count  = 1
  name   = "${ format("node-%02d", count.index+1)}"
  image  = "https://app.vagrantup.com/shekeriev/boxes/debian-11/versions/0.2/providers/virtualbox.box"

  cpus   = 1
  memory = "2048 Mb"

  status = "running"

  network_adapter {
    type           = "bridged"
    host_interface = "en0: Wi-Fi"
    device         = "IntelPro1000MTDesktop"
  }
}

output "IPAddress" {
  value = element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 1)
}
```
</details>




------

### Правила приема работы

Домашняя работа оформляется в отдельном GitHub репозитории в файле README.md.   
Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

### Критерии оценки

Зачёт:

* выполнены все задания;
* ответы даны в развёрнутой форме;
* приложены соответствующие скриншоты и файлы проекта;
* в выполненных заданиях нет противоречий и нарушения логики.

На доработку:

* задание выполнено частично или не выполнено вообще;
* в логике выполнения заданий есть противоречия и существенные недостатки. 