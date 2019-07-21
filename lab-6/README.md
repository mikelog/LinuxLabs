## Репозиторий с RPM, собранным из исходников
1. Для получения репозитория с пакетом pcapsipdump необходимо:

    1.1. Скаталоги playbooks и roles, скачать Vagrantfile, ansible.cfg и положить их рядом с ними. Далее сделать vagrant up, репозиторий будет доступен на 10.10.10.20:8080
    
    1.2. Или можно скачать докер образ docker pull mikelog/pcapsipdumper:v1 и запустить его потом docker run -p 8080:80 -t  mikelog/pcapsipdumper:v1
