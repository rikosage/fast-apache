START_STYLE='\033['
END_STYLE='\033[0m'

NORMAL='0'
BOLD='1;'
OPACITY='2;'
GREY='3;'
UNDER='4;'
BG='7;'

BLACK='30m'
RED='31m'
GREEN='32m'
YELLOW='33m'
BLUE='34m'
PURPLE='35m'
AQUA='36m'
WHITE='37m'

#Предупреждение об ошибке
function dangerMessage(){
    echo -e $START_STYLE$BOLD$RED$1$END_STYLE
}

#Внимание
function warningMessage(){
    echo -e $START_STYLE$BOLD$YELLOW$1$END_STYLE
}

#Завершено успешно
function successMessage(){
    echo -e $START_STYLE$BOLD$GREEN$1$END_STYLE
}

#Критическая ошибка
function criticalMessage(){
    echo -e $START_STYLE$BG$RED$1$END_STYLE
}

function colorEcho(){
    if   [[ $1 == "" || $2 == "" || $3 == "" ]]; then
        dangerEcho 'Sintax error! Template: <$STYLE> <$COLOR> <your text>'
    else
        echo -e $START_STYLE$1$2$3$END_STYLE
    fi

}
