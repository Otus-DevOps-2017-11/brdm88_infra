# brdm88_infra
Dmitry Bredikhin Infrastructure study repository


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
