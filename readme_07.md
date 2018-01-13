Homework-07
===========

##### Базовая задача. Параметризация шаблона создания базового образа ВМ.

 * ubuntu16_base.json - шаблон для создания базового образа без параметров (по описательной части д/з)
 
 * ubuntu16.json - параметризованный шаблон для создания базового образа (из самостоятельной работы)
 * variables.json.example - пример файла переменных для использования с шаблоном ubuntu16.json
 
 Валидация и запуск создания образа, соответственно, выполняем командой
 ```
 packer validate -var-file=variables.json ubuntu16.json
 packer build -var-file=variables.json ubuntu16.json
 ```

##### Дополнительная задача. Создание baked-образа ВМ с приложением, создание инстанса ВМ.

 * immutable.json - шаблон для создания baked-образа приложения (image family: reddit-full). 
Использует файл переменных из базовой задачи. Кроме действий, выполняемых при создании базового образа, производит загрузку кода приложения из репозитория, установку приложения, копирование созданного systemd unit-файла для службы сервера puma (из директории files, сначала file provisioner копирует его в /tmp, затем скрпит развертывания перемещает в /etc/systemd/system, такая реализация сделана из-за невозможности явного указания sudo в file provisioner), включение его автозапуска.
 
  * files/puma.service - systemd unit (service) файл конфигурации для puma server
  * scripts/deploy_app.sh - скрипт деплоя приложения
 ----
  * config-scripts/create-reddit-vm.sh - скрипт создания инстанса ВМ с приложением из baked-образа (gcloud)
 
 Валидация и запуск создания образа, соответственно, выполняем командой
 ```
 packer validate -var-file=variables.json immutable.json
 packer build -var-file=variables.json immutable.json
 ```
 
----
Review: Nklya
Labels: packer, homework-07
----
