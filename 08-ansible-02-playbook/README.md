# Домашнее задание к занятию 2 «Работа с Playbook»

## Подготовка к выполнению

1. * Необязательно. Изучите, что такое [ClickHouse](https://www.youtube.com/watch?v=fjTNS2zkeBs) и [Vector](https://www.youtube.com/watch?v=CgEhyffisLY).
2. Создайте свой публичный репозиторий на GitHub с произвольным именем или используйте старый.
3. Скачайте [Playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
4. Подготовьте хосты в соответствии с группами из предподготовленного playbook.

## Основная часть

1. Подготовьте свой inventory-файл `prod.yml`.
2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev). Конфигурация vector должна деплоиться через template файл jinja2. От вас не требуется использовать все возможности шаблонизатора, просто вставьте стандартный конфиг в template файл. Информация по шаблонам по [ссылке](https://www.dmosk.ru/instruktions.php?object=ansible-nginx-install).
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать дистрибутив нужной версии, выполнить распаковку в выбранную директорию, установить vector.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
9. Подготовьте README.md-файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги. Пример качественной документации ansible playbook по [ссылке](https://github.com/opensearch-project/ansible-playbook).
10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.

<details>
<summary>Ответ</summary>

1. Подготовьте свой inventory-файл `prod.yml`.

```bash
$ cat inventory/prod.yml
---
clickhouse:
  hosts:
    clickhouse-01:
      ansible_host: 192.168.1.125
```
<br>

2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev). Конфигурация vector должна деплоиться через template файл jinja2. От вас не требуется использовать все возможности шаблонизатора, просто вставьте стандартный конфиг в template файл. Информация по шаблонам по [ссылке](https://www.dmosk.ru/instruktions.php?object=ansible-nginx-install).
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать дистрибутив нужной версии, выполнить распаковку в выбранную директорию, установить vector.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.

```bash
% ansible-lint site.yml
WARNING  Listing 24 violation(s) that are fatal
name[missing]: All tasks should be named.
site.yml:11 Task/Handler: block/always/rescue

risky-file-permissions: File permissions unset or incorrect.
site.yml:12 Task/Handler: Get clickhouse distrib

yaml[line-length]: Line too long (185 > 160 characters)
site.yml:15

risky-file-permissions: File permissions unset or incorrect.
site.yml:18 Task/Handler: Get clickhouse distrib

fqcn[action-core]: Use FQCN for builtin module actions (meta).
site.yml:30 Use `ansible.builtin.meta` or `ansible.legacy.meta` instead.

name[missing]: All tasks should be named.
site.yml:33 Task/Handler: block/always/rescue

no-changed-when: Commands should not change things if nothing needs doing.
site.yml:34 Task/Handler: Checking service clickhouse status

yaml[line-length]: Line too long (210 > 160 characters)
site.yml:38

fqcn[action-core]: Use FQCN for builtin module actions (wait_for).
site.yml:46 Use `ansible.builtin.wait_for` or `ansible.legacy.wait_for` instead.

name[casing]: All names should start with an uppercase letter.
site.yml:46 Task/Handler: verify clickhouse-server is listening on 9000

no-free-form: Avoid using free-form when calling module actions. (wait_for)
site.yml:46 Task/Handler: verify clickhouse-server is listening on 9000

jinja[spacing]: Jinja2 spacing could be improved: create_db.rc != 0 and create_db.rc !=82 -> create_db.rc != 0 and create_db.rc != 82 (warning)
site.yml:49 Jinja2 template rewrite recommendation: `create_db.rc != 0 and create_db.rc != 82`.

yaml[trailing-spaces]: Trailing spaces
site.yml:50

yaml[line-length]: Line too long (195 > 160 characters)
site.yml:51

yaml[line-length]: Line too long (161 > 160 characters)
site.yml:52

name[missing]: All tasks should be named.
site.yml:58 Task/Handler: block/always/rescue

name[template]: Jinja templates should only be at the end of 'name'
site.yml:59 Task/Handler: Create a directory {{ destin_vector_folder }} if it does not exist

risky-file-permissions: File permissions unset or incorrect.
site.yml:65 Task/Handler: Get Vector distrib

yaml[truthy]: Truthy value should be one of [false, true]
site.yml:75

name[template]: Jinja templates should only be at the end of 'name'
site.yml:76 Task/Handler: Remove archive file {{ destin_vector_folder }}/vector-{{ vector_version }}-{{ arch }}-unknown-linux-musl.tar.gz

fqcn[action-core]: Use FQCN for builtin module actions (template).
site.yml:81 Use `ansible.builtin.template` or `ansible.legacy.template` instead.

no-free-form: Avoid using free-form when calling module actions. (template)
site.yml:81 Task/Handler: Generate VECTOR.YAML file

no-changed-when: Commands should not change things if nothing needs doing.
site.yml:84 Task/Handler: Install Vector

yaml[empty-lines]: Too many blank lines (1 > 0)
site.yml:87

Read documentation for instructions on how to ignore specific rule violations.

                       Rule Violation Summary
 count tag                    profile    rule associated tags
     1 jinja[spacing]         basic      formatting (warning)
     2 no-free-form           basic      syntax, risk
     3 name[missing]          basic      idiom
     1 yaml[empty-lines]      basic      formatting, yaml
     4 yaml[line-length]      basic      formatting, yaml
     1 yaml[trailing-spaces]  basic      formatting, yaml
     1 yaml[truthy]           basic      formatting, yaml
     2 name[template]         moderate   idiom
     1 name[casing]           moderate   idiom
     3 risky-file-permissions safety     unpredictability
     2 no-changed-when        shared     command-shell, idempotency
     3 fqcn[action-core]      production formatting

Failed: 23 failure(s), 1 warning(s) on 1 files. Last profile that met the validation criteria was 'min'.
```

После исправления:
```bash
% ansible-lint site.yml

Passed: 0 failure(s), 0 warning(s) on 1 files. Last profile that met the validation criteria was 'production'.
```

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.

```bash
% ansible-playbook -i inventory/prod.yml site.yml --check

PLAY [Install Clickhouse] **********************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ******************************************************************************************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "gid": 1001, "group": "ansible", "item": "clickhouse-common-static", "mode": "0664", "msg": "Request failed", "owner": "ansible", "response": "HTTP Error 404: Not Found", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 246310036, "state": "file", "status_code": 404, "uid": 1001, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse distrib] ******************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Install clickhouse packages] *************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Flush handlers] **************************************************************************************************************************************************************************************

TASK [Checking service clickhouse status] ******************************************************************************************************************************************************************
skipping: [clickhouse-01] => (item=clickhouse-server)
skipping: [clickhouse-01]

TASK [Verify clickhouse-server is listening on 9000] *******************************************************************************************************************************************************
skipping: [clickhouse-01]

TASK [Create database] *************************************************************************************************************************************************************************************
skipping: [clickhouse-01]

PLAY [Install Vector] **************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Create a directory if does not exist /opt/vector] ****************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get Vector distrib] **********************************************************************************************************************************************************************************
changed: [clickhouse-01]

TASK [Extract vector distrib] ******************************************************************************************************************************************************************************
fatal: [clickhouse-01]: FAILED! => {"changed": false, "msg": "Source '/opt/vector/vector-0.33.0-x86_64-unknown-linux-musl.tar.gz' does not exist"}

PLAY RECAP *************************************************************************************************************************************************************************************************
clickhouse-01              : ok=6    changed=1    unreachable=0    failed=1    skipped=3    rescued=1    ignored=0
```

7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.

```bash
% ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Install Clickhouse] **********************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] ******************************************************************************************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "gid": 1001, "group": "ansible", "item": "clickhouse-common-static", "mode": "0664", "msg": "Request failed", "owner": "ansible", "response": "HTTP Error 404: Not Found", "secontext": "unconfined_u:object_r:user_home_t:s0", "size": 246310036, "state": "file", "status_code": 404, "uid": 1001, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse distrib] ******************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Install clickhouse packages] *************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Flush handlers] **************************************************************************************************************************************************************************************

TASK [Checking service clickhouse status] ******************************************************************************************************************************************************************
changed: [clickhouse-01] => (item=clickhouse-server)

TASK [Verify clickhouse-server is listening on 9000] *******************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Create database] *************************************************************************************************************************************************************************************
ok: [clickhouse-01]

PLAY [Install Vector] **************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Create a directory if does not exist /opt/vector] ****************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Get Vector distrib] **********************************************************************************************************************************************************************************
changed: [clickhouse-01]

TASK [Extract vector distrib] ******************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Remove archive file with distrib Click House] ********************************************************************************************************************************************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/opt/vector/vector-0.33.0-x86_64-unknown-linux-musl.tar.gz",
-    "state": "file"
+    "state": "absent"
 }

changed: [clickhouse-01]

TASK [Generate VECTOR.YAML file] ***************************************************************************************************************************************************************************
ok: [clickhouse-01]

TASK [Install Vector] **************************************************************************************************************************************************************************************
changed: [clickhouse-01]

PLAY RECAP *************************************************************************************************************************************************************************************************
clickhouse-01              : ok=13   changed=4    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0
```

8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.

Результат как в пункте 7

9. Подготовьте README.md-файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги. Пример качественной документации ansible playbook по [ссылке](https://github.com/opensearch-project/ansible-playbook).
10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.

</details>

---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---
