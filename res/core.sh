source $(dirname $0)/config.sh
source $(dirname $0)/res/help-screen.sh
source $(dirname $0)/res/echos.sh


#Функция для установки необходимых пакетов
function installPackage(){
    # Если требуется установить Composer
    if [[ $1 == "composer" ]]; then
        dangerMessage "Composer is not installed!"
        read -n 2 -p "Do you want install Composer now? (y/[a]):" AMSURE
        if [ "$AMSURE" = "y" ]; then
            curl -sS https://getcomposer.org/installer | php
            mv composer.phar /usr/local/bin/composer
            sudo -u $USERNAME composer global require "fxp/composer-asset-plugin:*"
            successMessage "Success! Run the script again."
            exit 1;
        else
            dangerMessage "Cancelled"
            exit 1
        fi
    fi

    # Если требуется установить xclip
    if [[ $1 == "xclip" ]]; then
        dangerMessage "Xclip is not installed!"
        read -n 2 -p "Do you want install xclip now?? (y/[a]):" AMSURE
        if [ "$AMSURE" = "y" ]; then
            apt-get install xclip
            successMessage "Success! Run the script again."
            exit 1;
        else
            dangerMessage "Cancelled"
            exit 1
        fi
    fi
    # Если требуется установить Git
    if [[ $1 == "git" ]]; then
        dangerMessage "Git is not installed!"
        read -n 2 -p "Do you want install Git now? (y/[a]):" AMSURE
        if [ "$AMSURE" = "y" ]; then
            apt-get install git
            successMessage "Success! Run the script again."
            exit 1;
        else
            dangerMessage "Cancelled"
            exit 1
        fi
    fi
}

#Функция проверяет допустимость аргумента.
function checkargs () {
    # Если аргумент начинается с минуса - значит это ключ, это ошибка.
    if [[ $OPTARG =~ ^-+.*$ ]]
    then
        dangerMessage "Unknow argument $OPTARG for option $opt!"
        exit 1
    fi
}

function regLocalSite(){
    HOSTNAME=$IP"\t"$1$DOMAIN
    #проверяем состояние пакета xclip (dpkg) и ищем в выводе его статус (grep)
    I=`dpkg -s xclip 2>/dev/null | grep "Status" `
    #проверяем что нашли строку со статусом (что строка не пуста)
    if [ -n "$I" ]
    then
        if [[ -f $DIR/$SAMPLE.conf ]]
        then
            #Если название введено
            if [[ $1 != "" ]];
            then
                sitename=$1
                #Если файл с таким названием уже существует
                if [[ -f $DIR/$sitename.conf ]]; then
                    dangerMessage "Site already exists!"
                else
                    read -n 2 -p "Do you really want create new site: "$sitename"? (y/[a]):" AMSURE
                    #Если пользователь ответил Y
                    if [ "$AMSURE" = "y" ]; then
                        warningMessage "Preparing for create host..."
                        # После слеша - файл образец настройки виртуального хоста,с которого обычно копипастишь.
                        cat $DIR/$SAMPLE.conf | xclip
                        # Создаем новый файл конфигурации
                        xclip -o > $DIR/$sitename.conf
                        # Заменяем название образца на введенное значение
                        sed -i 's/<!template!>/'$sitename'/g' $DIR/$sitename.conf
                        # Заменяем .юзера на текущего
                        sed -i 's/<!username!>/'$USERNAME'/g' $DIR/$sitename.conf
                        # Добавляем строку в hosts.
                        sed -i -e '1 s/^/'$HOSTNAME'\n/;' $HOSTS
                        # Создаем каталог в указанной папке,в соответствии с указанным названием.
                        # Если каталог уже есть, ничего страшного, просто уведомим
                        if [ -d $SERVER_DIR/$sitename ]; then
                            warningMessage "Warning! Folder for project already exists! Host creating continue anyway"
                        fi
                        #Создаем папку от имени текущего юзера
                        sudo -u $USERNAME mkdir $SERVER_DIR/$sitename 2>/dev/null
                        # Активируем новый хост
                        a2ensite $sitename
                        # Перезапускаем апач.
                        apacheRestart
                        successMessage "$sitename: Site successfully created!"
                    else
                        dangerMessage "Cancelled"
                    fi
                fi
            # Если ничего не ввели в названии при запуске скрипта - выдаем ошибку
            else
                dangerMessage "Sitename can not be blank!"
            fi
        else
            criticalMessage "ERROR! File "$DIR/$SAMPLE".conf is not exists!"
        fi
    #Если не установлен пакет xclip
    else
        installPackage xclip
    fi
}

function removeLocalSite(){
    #Если ввели название
    if [[ $1 != "" ]]; then
        if [[ $1 == '--all' ]]; then
            all=$1
            sitename=$2
        else
            all=""
            sitename=$1
        fi
        #Если конфиг-файл введенного сайта существует
        if [[ -f $DIR/$sitename.conf && $sitename != "" ]]; then
    	#Спросим, не ошибся ли пользователь
            read -n 2 -p "Do you really want remove "$sitename"? (y/[a]):" AMSURE
    	#Если уверен в выборе (нажал "y")
            if [ "$AMSURE" = "y" ]; then
    	    #Выключаем сайт
                warningMessage "Preparing for remove host..."
                a2dissite $sitename

    	    #Удаляем конфиг
                rm $DIR/$sitename.conf

                #Удаляем строку из /etc/hosts
                sed -i "/"$sitename"/d" $HOSTS

                #Если удаляем проект
                if [[ $all == "--all" ]]; then
                    #Если директория существует
                    if [[ -d $SERVER_DIR/$sitename ]]; then
                        #Выпиливаем
                        rm -rf $SERVER_DIR/$sitename
                    else
                        warningMessage "$sitename project folder already deleted."
                    fi

                fi
    	        #Перезагружаем апач
                apacheRestart
    	    #Уведомляем
            if [[ $all != "" ]]; then
                successMessage "Site $sitename succesfully disabled and deleted. Your project folder has been deleted too."
            else
                successMessage "Site $sitename succesfully disabled and deleted. You can delete project folder from your server."
            fi

            else
    	    #Если пользователь ошибся - отменяем операцию
            dangerMessage "Cancelled"
            fi
        else
    	    #Если конфига не существует
            dangerMessage "$sitename: Site not found"
        fi
    else
        #Если прило пустое значение
        criticalMessage "ERROR! Sitename can't be blank!"
    fi
}

#Скрипт открывает файл настроек введенного хоста.
function confLocalSite(){
    FILE=$DIR/$1.conf

    #Если название введено
    if [[ $1 != "" ]]; then
        sitename=$1
        #И если файл с таким названием существует
        if [[ -f $FILE ]]; then
            #Уведомляем об успехе и открываем файл в редакторе
            successMessage "Configuration file of $sitename exists and ready to edit..."
            $FAVORITE_EDITOR /etc/apache2/sites-available/$sitename.conf
        #Если файла не существует
        else
            #Уведомляем об ошибке
            dangerMessage "$FILE not found"
        fi
    #Если не было введено название
    else
        #Уведомляем об ошибке
        criticalMessage "Sitename can not be blank!"
    fi
}

#Развертка голого проекта через composer
function deployWithComposer(){
    #Если composer установлен глобально
    if [[ -f /usr/local/bin/composer ]]; then
        #Если ввели название
        if [[ $1 != "" ]]; then
            sitename=$1
            if [[ -f $DIR/$sitename.conf ]]; then
                warningMessage "Wait for composer init..."
                sudo -u $USERNAME composer create-project --prefer-dist yiisoft/yii2-app-basic $SERVER_DIR/$sitename
                chmod -R 777 $SERVER_DIR/$sitename/runtime
                chmod -R 777 $SERVER_DIR/$sitename/web/assets
            else
                dangerMessage "$sitename: Site not found"
            fi
        else
            criticalMessage "Sitename can not be blank!"
        fi
    #Если composer не установлен
    else
        installPackage composer
    fi

}

#Скачивание проекта из удаленного репозитория
function deployWithGit(){
    I=`dpkg -s git 2>/dev/null | grep "Status" `
    #проверяем что нашли строку со статусом (что строка не пуста)
    if [ -n "$I" ]; then
        if [[ $1 != "" ]]; then
            sitename=$1
            if [[ $2 != "" ]]; then
                repository=$2
                if [[ -f $DIR/$sitename.conf ]]; then
                    #Если введено название проекта, адрес репозитория и найден развернутый хост, качаем проект
                    sudo -u $USERNAME git clone $repository $SERVER_DIR/$sitename
                    chmod -R 777 $SERVER_DIR/$sitename/runtime
                    chmod -R 777 $SERVER_DIR/$sitename/web/assets
                    successMessage "$sitename$DOMAIN successfully deployed into $SERVER_DIR/$sitename from $repository"
                else
                    dangerMessage "$sitename: Site not found"
                fi
            else
                criticalMessage "Repository address can not be blank!"
            fi
        else
            criticalMessage "Sitename can not be blank!"
        fi
    else
        installPackage git
    fi
}

function siteList(){

    echo -e "\n\033[32;1;37mActive Sites:\033[0m"
    RESULT=$(cat $HOSTS | awk -F "" ' /'127.0.0.3'\t/ {print} ')
    RESULT=$(echo $RESULT | sed -e "s/127.0.0.3/\n/g")
    RESULT=$(echo $RESULT | sed -e '1 s/ /\\n/g')
    echo -e "\033[32;1;32m"$RESULT"\033[0m\n"
}

function apacheRestart(){
    warningMessage "Please, wait for Apache2 restart..."
    service apache2 restart;
    successMessage "Apache2 successfully restarted!"
}
