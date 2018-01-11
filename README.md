# brdm88_infra
Dmitry Bredikhin Infrastructure study repository

Homework-06
===========

##### Задача 1. Представлены сценарии развертывания тестового приложения:

 * install_ruby.sh
 * install_mongodb.sh
 * deploy.sh

##### Дополнительная задача 1.

Команда создания инстанса с использованием startup script (сам startup script находится локально на машине инженера):

```
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata startup-script=~/gcp-scripts/reddit_startup.sh
```

Вариант с startup-script-url:

```
```

##### Дополнительная задача 2.

Команда удаления правила файервола:

```
```

Команда создания правила файервола:

```
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
