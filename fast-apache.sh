#!/bin/bash
# Внимание! Скрипт нужно исполнять от рута!

# Для функций деплоя Composer устанавливается глобально


source $(dirname $0)/res/core.sh

#Если список аргументов пуст
if [ -z $1 ]
then
    #Показать экран помощи
printHelp
    #И завершить работу
exit 1
fi

if [[ $USER == 'root' ]]; then
    #Разбираем пришедшие ключи
    while getopts "n:d:c:u:g:lrh" opt
    do
    case $opt in

        #Если пришел ключ -n: создаем новый хост
    n)  checkargs
        regLocalSite $OPTARG
        ;;

    #Если пришел ключ -d: деактивируем хост
    d) case $OPTARG in
            --all | -a) removeLocalSite "--all" $3
                ;;
            *)  removeLocalSite $2
                ;;
        esac
        ;;

        #Если пришел ключ -c: Открываем файл конфигурации
    c)  checkargs
        confLocalSite $OPTARG
        ;;

        #Если пришел ключ -f: Определяем,откуда пользователь собирается разворачивать сайт
    u)  case $OPTARG in
            #Если через git
            --rep) deployWithGit $3 $4
                    ;;
            #Если не указано,врубаем композер
            * | "") deployWithComposer $2
            ;;
        esac
        ;;

    # Молниеносная развертка из репозитория
    g)  checkargs
        if [[ $2 != "" && $3 != "" ]]; then
            regLocalSite $2
            deployWithGit $2 $3
        else
            echo -e "\033[32;1;31mNot enough actual parameters.\033[0m \n\033[32;1;32mHelp: fast-apache -g <sitename> <repository>\033[0m"
        fi
        ;;

    #Список активных сайтов
    l) siteList;;

        #Если пришел ключ -r: Перезагружаем апач
    r)  apacheRestart;;

        #Если пришел ключ -h: Показываем экран помощи
    h)  printHelp;;
    esac
    done
else
    echo -e '\033[32;1;31mScript needs superuser rights! Cancelled.\033[0m'
fi
