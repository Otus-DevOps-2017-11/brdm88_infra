﻿Homework-07
===========

##### Базовая задача. Параметризация шаблона создания базового образа ВМ.

 * ubuntu16_base.json - шаблон для создания базового образа без параметров
 * ubuntu16.json - параметризованный шаблон для создания базового образа
 * variables.json.example - пример файла переменных

##### Дополнительная задача. Создание baked-образа ВМ с приложением, создание инстанса ВМ.

 * immutable.json - шаблон для создания baked-образа приложения (image family: reddit-full). Использует файл переменных из базовой задачи
 * config-scripts/create-reddit-vm.sh - скрипт создания инстанса ВМ с приложением из baked-образа
 ----
 * files/puma.service - systemd service конфигурация для puma server
 * scripts/deploy_app.sh - скрипт деплоя приложения (gcloud)
 
----
Review: Nklya
Labels: packer, homework-07
----