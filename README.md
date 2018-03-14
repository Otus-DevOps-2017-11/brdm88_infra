# brdm88_infra
Dmitry Bredikhin Infrastructure study repository

[![Build Status](https://travis-ci.org/Otus-DevOps-2017-11/brdm88_infra.svg?branch=master)](https://travis-ci.org/Otus-DevOps-2017-11/brdm88_infra)


Homework-12
===========

В рамках данных задач (для теста) были переработаны конфигурационные файлы Terraform для возможности управления развертыванием приложения стредствами Terraform
(развертывать, либо нет). При этом была отработана концепция реализации условий в коде Terraform через логические переменные и свойство `count`.
Хотя Terraform не имеет официально заявленной поддержки булевых переменных, true и false в коде HCL трактуются соответственно как 1 и 0.
В модулях **app** и **db** описаны 2 вариации ресурса "google_compute_instance", с использованием provisioners для развертывания приложения и без,
создаваемых в зависимости от значения переменной `deploy_by_tf`.



##### Базовая часть.

Предварительно с помощью команды `ansible-galaxy init` были инициализированы структуры папок для ролей *app* и *db*.
Логика созданных в рамках предыдущего задания playbook-ов была перенесена в роли.
Созданы конфигурации для окружений **stage** и **prod**, заданы переменные для групп хостов.
Плейбуки перенесены в директорию *playbooks*, `app.yml` `db.yml` теперь используют созданные роли, плейбуки для подобных целей 
из предыдущего задания переименованы в *app_direct.yml` и `db_direct.yml`.
Наработки из предыдущих заданий перемещены в папку **old**.

Установлена community-роль **jdauphant.nginx** из Ansible Galaxy, с помощью задания переменных для группы хостов *app* настроено 
проксирование запросов на 80 порт к приложению.
В конфигурацию Terraform добавлено разрешение доступа по 80 порту к серверу приложения (путем добавления тега *http-server* к инстансу).

Проверена корректность развертывания и работы приложения для различных окружений.


##### Дополнительное задание 1 (*). Динамический Inventory.

В предыдущем задании использовался скрипт `gce.py` из репозитория Ansible, сейчас он также будет использован для получения данных об инфраструктуре.
Группировка хостов производится по тегам инстансов (`tag_<tag_name>`). Для работы как со статическим, так и с динамическим inventory в плейбуках 
app.yml, db.yml, deploy.yml в качестве целевых групп хостов указаны оба варианта именования.
Например, 
```
  hosts:
    - app
    - tag_reddit-app
```
Что в данном случае обращает на себя внимание, это ассоциация групповых переменных (`group_vars`) с группами хостов.
Учитывая логику работы ansible-playbook с переменными групп хостов (имена файлов должны совпадать с именами групп хостов в inventory) 
в различных окружениях, для корректного использования group_vars как с данными статического inventory, так динамического, в итоге были созданы 
символические ссылки с именами "динамических" групп хостов на "статические" файлы.
В условиях данной задачи (один проект GCP для stage и prod окружений) динамический inventory в окружениях stage и prod является символической ссылкой 
на скрипт gce.py, также для корректной его работы необходимо предварительно определить переменную среды `GCE_INI_PATH`, указав путь к файлу gce.ini c 
анными проекта для gce.py.


##### Дополнительное задание 2 (**). Интеграция с Travis CI.

Чтобы не производить много тестовых коммитов в основном репозитории, было решено воспользоваться утилитой `trytravis` и тестовым репозиторием.

Исходя из приинципов работы Travis CI, для проведения тестов необходимо предварительно подготовить среду, т.е. установить Packer, Terraform, 
Terraform Lint, Ansible, ansible-lint. Данные команды описаны в секции `install` сценария **.travis.yml**

Собственно команды валидации описаны в секции `script`. Для перечисления окружений используется секция `env`.

Для валидации конфигураций Packer и Terraform достаточно будет воспользоваться примером файла переменных из репозитория (`.example`), 
т.к. нет необходимости в развертывыании реальной конфигурации.

Стоит отметить, что в нашем случае для корректной работы `terraform init` с Remote Backend в среде Travis CI необходимо передавать в Travis CI 
GCP Service Account Key для авторизации на Storage Bucket, по сему было решено отключить использование Remote Backend в Terraform.


----
----

Homework-11
===========

##### Общие сведения.

Конфигурационные файлы Ansible, созданные при выполнении данного задания, расположены в директории *ansible*.
Inventory-файлы в альтернативных форматах и вспомогательные файлы из предыдущего задания помещены в папку *ansible/alt_invertories*.
Конфигурационные файлы Terraform, использованные для выполнения данного задания ("облегченная" монолитная конфигурация, создающая инстансы без приложения),
расположены в директории *terraform/stage_clean*.


##### Один playbook, один сценарий.

Создан playbook *reddit_app_one_play.yml*, в котором описаны задачи конфигурации сервера БД (tag: `db-tag`) и приложения (tag: `app-tag`),
а также установки приложения из репозитория (tag: `deploy-tag`).

Протестирован запуск плейбука с лимитирующими параметрами на различных частях инфраструктуры, приложение было успешно развернуто (ниже приведены команды для запуска).

```
 ansible-playbook reddit_app_one_play.yml --check --limit db --tags db-tag
 ansible-playbook reddit_app_one_play.yml --limit db --tags db-tag
 
 ansible-playbook reddit_app_one_play.yml --check --limit app --tags app-tag
 ansible-playbook reddit_app_one_play.yml --limit app --tags app-tag
 
 ansible-playbook reddit_app_one_play.yml --check --limit app --tags deploy-tag
 ansible-playbook reddit_app_one_play.yml --limit app --tags deploy-tag
```


##### Один playbook, много сценариев.

Сценарий playbook-а из предыдущего блока разбит на несколько, в зависимости от целевых групп хостов, теги вынесены на уровень сценария.
Файл playbook-а: *reddit_app_multiple_plays.yml*.

Проверено успешное развертывание приложения.
```
ansible-playbook reddit_app_multiple_plays.yml --tags db-tag --check
ansible-playbook reddit_app_multiple_plays.yml --tags db-tag
ansible-playbook reddit_app_multiple_plays.yml --tags app-tag --check
ansible-playbook reddit_app_multiple_plays.yml --tags app-tag
ansible-playbook reddit_app_multiple_plays.yml --tags deploy-tag --check
ansible-playbook reddit_app_multiple_plays.yml --tags deploy-tag
```


##### Много playbook-ов.

Playbook из предыдущего блока разбит на три: *db.yml*, *app.yml* и *deploy.yml*, соответственно реализующие конфигурацию хостов БД, web-сервера, 
развертывание приложения. Также были исключены теги.
Создан playbook *site.yml*, включающий в себя ссылки на три вышеуказанных.

Проверено успешное развертывание приложения.
```
ansible-playbook site.yml --check
ansible-playbook site.yml
```


##### Provisioning в Packer

Были созданы playbook-и *packer-db.yml* и *packer-app.yml*, реализующие соответственно устанокву окружений для серверов БД и приложения.
Для реализации установки пакетов использованы следующие модули:
 * `apt_key` - добавление apt-ключа
 * `apt_repositroy` - добавление репозитория
 * `apt` - установка пакетов через *apt*

Для установки нескольких пакетов в одном task-е использован цикл (директива `with_items`).

Конфигурационные файлы Packer, измененные в рамках данного задания (`shell` provisioners заменены на `ansible`), 
расположены в директории *packer/using-ansible* (`db.json` и `app.json`).

Выполнено создание базовых образов с помощью Packer, развертывание инфраструктуры c помощью Terraform и деплой приложения с помощью Ansible.

Для корректной работы ansible provisioners в Packer требуется явное указание (в качестве параметра "user") пользователя, под которым на временном инстансе
будет запущен Ansible (`ansible_user`), т.к. по умолчанию он запустится от имени того пользователя, который запустил Packer, и далее при выполнении
провижионера возникает ошибка прав доступа.

Листинг команд приведен ниже:

``` 
# VM images creation
 packer validate -var-file=./packer/variables.json ./packer/using-ansible/db.json
 packer build -var-file=./packer/variables.json -on-error=ask ./packer/using-ansible/db.json

 packer validate -var-file=./packer/variables.json ./packer/using-ansible/app.json
 packer build -var-file=./packer/variables.json ./packer/using-ansible/app.json
```

```
# stage_clean environment deployment
 terraform plan
 terraform apply -auto-approve=true
```

```
# Application deployment
 ansible-playbook site.yml --check
 ansible-playbook site.yml
```


##### Дополнительное задание. Dynamic inventory.

Для динамического Inventory в нашем случае формирование списка хостов возможно на основе данных либо от Google Compute Engine, либо от Terraform.
Первый вариант более универсальный, не зависит от наличия средств управления инфраструктурой, но требует указания данных Service Account 
для доступа к gcloud API.
Второй вариант не требует данных авторизации GCP, однако требует установки отдельного приложения и актуален только если для управления инфраструктурой 
используется Terraform.

Файлы, созданные в рамках данного заданя, находятся в папке *ansible/dyn_inventory*. 

**Реализация варианта 1**

В первую очередь необходимо предоставить Ansible данные авторизации для взаимодействия с GCP (credentials).
Предварительно создадим Service account key в формате JSON через оснастку 'APIs and Services -> Credentials' в Google Cloud Console.
Далее, используем inventory-скрипт для GCE из репозитория Ansible: `https://github.com/ansible/ansible/blob/devel/contrib/inventory/gce.py`.
В сопутствующем файле `gce.ini` указываем данные проекта и путь к json-файлу с ключами.
Для того, чтобы указать *gce.py* расположение ini-файла, требуется задать значение переменной среды *GCE_INI_PATH*:
`export GCE_INI_PATH=<full_path_to_gce_ini_file>`

Для работы скрипта необходима *apache-libcloud*, ее можно предварительно установить с помощью `pip install apache-libcloud`.
Для того, чтобы в репозиторий не были отправлены ключи авторизации сервисного аккаунта, необходимо добавить в файл *.gitignore* записи о 
gce.ini и json-файле ключей, также создан файл *gce.ini.example* - пример заполнения ini-файла.

Проверить работу скрипта можно с помощью его запуска с параметром `--list`, должны быть выведены полные данные об инстансах.
Проверка работы Ansible на динамическом inventory, в качестве пути указываем скрипт: `ansible all -i ./dyn_inventory/gce.py -m ping`

Группировка хостов в данном случае реализуется с помощью тегов инстансов (в загруженных playbook-ах имена групп хостов изменены под динамический inventory).

Указание групп хостов по тегам производится следующим образом: `ansible tag_<tag_name>`. Пример: `ansible tag_reddit-app -m ping`

Проверка деплоя конфигурации с помощью Ansible:
```
 ansible-playbook site.yml --check
 ansible-playbook site.yml
```

----
----

Homework-10
===========

##### Базовая задача. Установка Ansible и практика работы с модулями.

На локальную рабочую машину с помощью `pip` был установлен Ansible 2.4.2.0. С помощью Terraform развернута stage-среда из предыдущих заданий.
В подкаталоге ansible репозитория созданы файлы *requirements.txt* для установщика pip, *ansible.cfg* конфигурации Ansible, *inventory*, 
inventory-файл развернутой инфраструктуры в ini-формате.
Проведены тесты модулей `ping` и `command` на различных группах хостов.
Создан файл *inventory.yml*, inventory-файл формата YAML. Работа Ansible c данным типом inventory проверена с помощью модуля `ping`.
Выполнены тестовые запуски модулей `command`, `shell`, `systemd`, `service`, `git` с различными аргументами на созданной инфраструктуре.

Видны особенности реализации выполнения одних и тех же действий на целевой системе в различных модулях.
Если на момент запуска ansible-команд приложение на сервере уже было развернуто, то при попытке загрузить код из репозитория 
в существующую папку приложения с помощью модуля `git` Ansible отрабатывает со статусом SUCCESS, но параметр `"changed"` будет равен false.
При тех же действиях с использованием модуля `command` статус будет равен FAILED из-за попытки копирования в непустой каталог.


##### Дополнительная задача. JSON Inventory.

Для текущей конфигурации инфраструктуры создан inventory-файл в формате JSON - *inventory.json*. 

Проверил в версии 2.0, в ней, в отличие от версии 2.4, вариант непосредственного указания json-файла в качестве inventory не работает. 
Ожидается inventory script. В нашем случае статического содержимого требуется создание исполняемого файла (кроме того, начинающегося с shebang), 
который выводил бы в stdout данные inventory в формате JSON, при этом значения в объектах, описывающих группы и хосты, должны быть представлены 
как JSON-массивы.

Создан скрипт *dyn_inv.sh*, выводящий содержимое *inventory.json*, этот скрипт передается в качестве inventory-файла при запуске ansible:

`ansible all -i dyn_inv.sh -m ping`

Работа Ansible c данным типом inventory проверена с помощью модуля `ping` в среде с установленной версией 2.0.0.0.


----
----

﻿Homework-09
===========

##### Базовая часть

Предварительно с помощью Packer были подготовлены базовые образы витруальных машин для серверов БД (*reddit-db-base*) и приложения (*reddit-app-base*).
Созданы модули app и db, соответственно реализующие логику создания инстансов для приложения и БД.
Подготовлены конфигурации для окружений prod и stage.

Структура каталогов в директории terraform:

 * **modules** - директория модулей
 * **prev** - предыдущие наработки (реализация балансировщика из задания 8 в папке *balancer*, промежуточные сценарии в папке *backup*)
 * **prod** - конфигурационные файлы Terraform для среды *Production*
 * **stage** - конфигурационные файлы Terraform для среды *Stage*
 * **storage-buckets** - тест работы с реестром модулей

##### Задание 1. Создать модуль vpc c правилом firewall для ssh

Модуль, реализующий создание правила файервола для разрешения доступа по SSH и project-wide публичный ключ, создан, его директория: *modules/vpc*.

*Входные переменные:*
 * `project_ssh_user` - пользователь ssh (в рамках проекта)
 * `project_pubkey_path` - публичный ключ ssh (в рамках проекта)
 * `source_ranges` - диапазон IP-адресов для разрешения доступа по SSH

*Выходные переменные:*
 * `ssh_allowed_networks` - подсети, из которых разрешен доступ по SSH.

Проверена работа файрвола на разрешение и блокировку доступа с разных ip-адресов.


##### Задание 2. Параметризация модулей и окружений

Определены следующие входные и выходные переменные для модулей и окружений:

**Входные переменные, определенные для обоих модулей**

 * `project_ssh_user` - пользователь ssh (в рамках проекта)
 * `public_key_path` - публичный ключ ssh (в рамках проекта)
 * `private_key_path` - приватный ключ для подключения provisioners
 * `region_zone` - географическая зона для  GCE
 * `machine_type` - тип виртуальной машины

**Модуль app**

*Входные переменные:*
 * `app_instance_name` - имя инстанса ВМ web-сервера
 * `app_disk_image` - имя образа диска для ВМ web-сервера
 * `app_port` - порт приложения (HTTP)
 * `app_user` - пользователь, от имени которого работеат приложение
 * `app_workdir` - рабочая директория приложения
 
*Выходные переменные:*
 * `app_external_ip` - внешний ip-адрес сервера приложения
 * `app_http_port` - HTTP порт приложения
 
**Модуль db**

*Входные переменные:*
 * `db_instance_name` - имя инстанса ВМ сервера БД
 * `db_disk_image` - имя образа диска для ВМ сервера БД
 
*Выходные переменные:*
 * `db_external_ip` - внешний ip-адрес сервера БД
 * `db_internal_ip` - внутренний ip-адрес сервера БД

 
Окружения **stage** и **prod** для развертывания приложения различаются разрешенными подсетями для доступа по SSH, именами и типами инстансов ВМ.
Входные переменные используемых модулей инициализируются нужными значениями входных переменных окружений.
Выходные переменные окружений в качестве своих значений имеют значения нужных выходных переменных модулей.
Пример задания значений входных переменных для окружений приведен в файле `terraform.tfvars.example`

----

##### Задание 1*. Хранение state-файла в remote backend

Предварительно создан storage bucket в GCP для хранения state-файлов Terraform. Настроен remote backend.
Теперь state-файлы в локальных директориях запуска Terraform отсутствуют, state-файлы для различных окружений находятся по заданным путям в GCP Storage.
При работе Terraform создается файл блокировки (*.tflock*). При попытке запуска параллельных экземпляров Terraform во время выполнения сценария 
возникает ошибка `"Error acquiring the state lock: writing <path to default.tflock> failed"`, работает механизм блокировок.


##### Задание 2*. Деплой приложения в текущей конфигурации инфраструктуры

Для выполнения развертывания приложения в архитектуре различных инстансов для базы данных и web-сервера реализовано следующее:

1. Приложение устанавливается в домашний каталог пользователя. Подключение к серверу БД производится по внутреннему ip-адресу.
Имеется возможность задать порт, на котором будет работать web-сервер Puma. URL сервера баз данных задается с помощью переменной окружения через 
директиву `Environment` в systemd unit-файле сервиса.

2. В модуле *app* добавлены provisioners типов `file`, генерирующий systemd unit-файл для службы puma из шаблона (provider `template_file`)
 с подстановкой параметров из входных переменных,
и `remote-exec` запускающий скрипт развертывания deploy.sh, который, в свою очередь, выполняет загрузку исходного кода из репозитория, 
установку и запуск сервиса приложения.

3. В модуле *db* добавлен `remote-exec` provisioner для inline запуска команд правки конфигурационного файла `/etc/mongod.conf`
 (изменение bindIp с 127.0.0.1 на 0.0.0.0 при помощи `sed`) и перезапуска службы MongoDB.

Все конфигурационные файлы Terraform отформатированы при помощи `terraform fmt`


----
----

Homework-08
===========

Файлы конфигурации находятся в директории ./terraform, ниже приведены описания файлов из этой директории.

##### Базовое задание.

Определены input-переменные для приватного ключа подключения provisioners, зоны инстанса, типа витуальной машины. 
Конфигурационные файлы отформатированы с помощью `terraform fmt`.

Конфигурационные файлы: 
 * **main.tf** - главный конфигурационный файл
 * **variables.tf** - файл определения входных переменных
 * **outputs.tf** - выходные переменные
 * **terraform.tfvars.example** - пример задания значений входных переменных
 
----

##### Дополнительное задание 1.

 * Добавление ssh-ключа в метеданные проекта
 * Добавление в метеданные проекта публичных ключей нескольких пользователей)
 * Добавление публичного ключа для appuser-web через web-интерфейс с дальнейшим terraform apply
 
Добавление публичных ssh ключей для проекта производится с помощью ресурса `google_compute_project_metadata`. Код добавлен в main.tf.

Если через web-интерфейс произвести добавление ключа, да и вообще любые манипуляции с объектами, так или иначе затрагиваемыми применением terraform, 
то после terraform apply эти изменения будут затерты (либо может быть ошибка), т.к. terraform ничего о них не знает, беря данные о состоянии инфраструктуры
только из своего .tfstate файла. Для актуализации данных в нем можно использовать terraform import.
 
##### Дополнительное задание 2.

 * Создание HTTP-балансировщика
 * Создание еще одного инстанса приложения, добавление в балансировщик. Создание нескольких инстансов через count
 
Балансировщик создавался с использованием следующих ресурсов:
 * `google_compute_instance_group` - группа идентичных серверов приложения
 * `google_compute_http_health_check` - healthcheck серверов приложения, проверяющий http доступ на нужном порту
 * `google_compute_backend_service` - группа хостов для балансировщика
 * `google_compute_url_map` - правило отправки запросов на backend
 * `google_compute_target_http_proxy` -  проксирование запросов c балансировщика
 * `google_compute_global_forwarding_rule` - правило обработки входящих запросов на балансировщик
 
Код добавлен в main.tf.
Добавлена входная переменная "nodes_count" (default=1, для случая базового задания), в которой задается число создаваемых экземпляров для backend, 
а также выходная переменная "balancer_external_ip", содержащая внешний ip-адрес балансировщика.
Конфигурация проверна на количестве backend-хостов, раном 2 и 4. 
Ее недостатком является то, что на каждом узле получается развернут свой автономный экземпляр БД,
что, в общем, может привести к некорректному обслуживанию пользователей (учетная запись и посты создавались на одном узле, при следующем входе
пользователь уже попадает на другой узел, где на тот момент этих данных нет).
Для возможности работы одного клиента в рамках одной сессии на одном и том же backend сервере, возможно, применим атрибут session_affinity для backend_service, 
что, быть может, обесепчит стабильность работы одной сессии, но несколько снизит общую отказоустойчивость решения и не решит глобальной проблемы.


----
----

Homework-07
===========

##### Базовая задача. Параметризация шаблона создания базового образа ВМ.

 * packer/ubuntu16_base.json - шаблон для создания базового образа без параметров (по описательной части д/з)
 
 * packer/ubuntu16.json - параметризованный шаблон для создания базового образа (из самостоятельной работы)
 * packer/variables.json.example - пример файла переменных для использования с шаблоном ubuntu16.json
 
 Валидация и запуск создания образа, соответственно, выполняем командой
 ```
 packer validate -var-file=variables.json ubuntu16.json
 packer build -var-file=variables.json ubuntu16.json
 ```

##### Дополнительная задача. Создание baked-образа ВМ с приложением, создание инстанса ВМ.

 * packer/immutable.json - шаблон для создания baked-образа приложения (image family: reddit-full). 
Использует файл переменных из базовой задачи. Кроме действий, выполняемых при создании базового образа, производит загрузку кода приложения из репозитория, установку приложения, копирование созданного systemd unit-файла для службы сервера puma (из директории files, сначала file provisioner копирует его в /tmp, затем скрпит развертывания перемещает в /etc/systemd/system, такая реализация сделана из-за невозможности явного указания sudo в file provisioner), включение его автозапуска.
 
  * packer/files/puma.service - systemd unit (service) файл конфигурации для puma server
  * packer/scripts/deploy_app.sh - скрипт деплоя приложения
----
  * packer/config-scripts/create-reddit-vm.sh - скрипт создания инстанса ВМ с приложением из baked-образа (gcloud)
 
 Валидация и запуск создания образа, соответственно, выполняем командой
 ```
 packer validate -var-file=variables.json immutable.json
 packer build -var-file=variables.json immutable.json
 ```


----
----

Homework-06
===========

##### Задача 1. Представлены сценарии развертывания тестового приложения:

 * install_ruby.sh
 * install_mongodb.sh
 * deploy.sh

##### Дополнительная задача 1.

Команда создания инстанса с использованием startup script (startup script находится локально на машине инженера в текущей директории, откуда выполняется команда):

```
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script=reddit_startup.sh
```

Использование startup-script-url, при этом startup script был предварительно загружен в Storage Bucket:

```
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata startup-script-url=gs://metadata_storage/reddit_startup.sh
```

##### Дополнительная задача 2.

Команда удаления правила файервола:

```
gcloud compute firewall-rules delete default-puma-server --quiet
```

Команда создания правила файервола:

```
gcloud compute firewall-rules create default-puma-server \
  --direction=INGRESS \
  --priority=1000 \
  --network=default \
  --action=ALLOW \
  --rules=tcp:9292 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=puma-server
```


----
----

Homework-05
===========

----
**Конфигурация инфраструктуры:**

***Хост bastion***: public IP: 35.187.37.55, private IP: 10.132.0.2

***Хост internal-host-1:*** private IP: 10.132.0.3

----

#### Задача 1. Исследовать способ подключения к внутреннему хосту в частной сети облака с рабочей машины в одну команду.

В качестве решения можно предложить проксирование SSH, задав опцию ProxyCommand.
В случае текущей инфраструктуры получаем следующую команду для подключения:
```
ssh -o ProxyCommand='ssh -W %h:%p brdm88@35.187.37.55' brdm88@10.132.0.3
```
Опция -W работает, начиная с OpenSSH версии 5.4, как альтернативу можно использовать в проксировании "Native" Netcat:
```
ssh -o ProxyCommand='ssh brdm88@35.187.37.55 nc 10.132.0.3 22' brdm88@10.132.0.3
```

Можно добавить перенаправление stderr, чтобы подавить вывод ошибок от Netcat ('Killed by signal 1.') при выходе с внутреннего хоста:
```
ssh -o ProxyCommand='ssh -W %h:%p %r@35.187.37.55' brdm88@10.132.0.3 2> /dev/null
```


#### Задача 2. Вариант подключения к тому же хосту командой вида ssh internalhost.

Для решения этой задачи зададим псевдонимы в файле ~/.ssh/config на рабочей машине, содержимое файла следующее:

```
Host bastion
    Hostname 35.187.37.55

Host internal-host-1
    Hostname 10.132.0.3
    User brdm88
    ProxyCommand ssh brdm88@bastion -W %h:%p 2> /dev/null	
```

С такой конфигурацией возможно подключиться к хосту с внутренним адресом 10.132.0.3 командой:

``` ssh internal-host-1 ```
