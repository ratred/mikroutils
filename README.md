# mikroutils

Небольшая утилита для работы с Микротиками

## Использование

ma <options> [user]@<mikrotik_address>


	Options:

		--copyid <user>     - Работает, как ssh-copy-id, только с микротиком
		                      Заводит на микротике пользователя user, добавляет в группу full,
		                      копирует ~/.ssh/rsa.id и экспортирует в пользователя
		--getconfig         - Скачивает конфиг в текстовом виде, сохраняет его в файле 
		                      <identity_роутера>.src
		--admpass <pass>    - Меняет пароль админа на <pass>


# Планы

 - Сделать опцию которая копирует на микротик конфиг и выполняет:

   system reset-configuration no-defaults=yes skip-backup=yes run-after-reset=flash/$config_file
