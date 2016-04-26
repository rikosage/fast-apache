# Рендерим экран подсказок
function printHelp(){
                echo -e "            _________________________________________________________________________
            |------------------------------------------------------------------------|
            |\t\t\t\033[32;4;32mFAST APACHE HELP SCREEN\033[0m\t\t\t\t     |
            |________________________________________________________________________|
            |                                                                        |
            |     \033[32;1;32m-n <sitename>\033[0m                                                      |
            |           Register new local host (new)                                |
            |     \033[32;1;32m-d <!-a> <sitename>\033[0m                                                |
            |           Remove local host (delete).                                  |
            |           \033[32;1;32m-a option\033[0m                                                    |
            |           delete host with project folder                              |
            |     \033[32;1;32m-c <sitename>\033[0m                                                      |
            |     Open configuration file for host (configurate)                     |
            |     \033[32;1;32m-r\033[0m                                                                 |
            |     Restarting Apache2 (restart)                                       |
            |     \033[32;1;32m-l\033[0m                                                                 |
            |     Show list of active hosts (list)                                   |
            |     \033[32;1;32m-h\033[0m                                                                 |
            |     Show this help page (help)                                         |
            |     \033[32;1;32m-u <option>:\033[0m                                                       |
            |     Download framework                                                 |
            |       \033[32;1;32m-u <sitename>\033[0m                                                    |
            |       deploy new project with composer                                 |
            |       \033[32;1;32m-u [--repo <sitename> <repository>]\033[0m                              |
            |       deploy project from repository                                   |
            |    \033[32;1;32m-g <sitename> <repository>:\033[0m                                         |
            |     Fast deploy from git (get)                                         |
            |                                                                        |
            |     \033[32;1;33mSCRIPT NEEDS SUPERUSER RIGHTS!\033[0m                                     |
            |________________________________________________________________________|"
}
