# MySQL Master|Slave & GTID Replication    
1. [Скачиваем каталог](../30-mysql_from_dump)    
2. Переходим в каталог с Vagrantfile    
3. Запускаем vagrant up    
4. Роль  поднимает два инстанса MASTER и SLAVE, на MASTER разворачивается база из dump файла. Производится настройка MASTER и SLAVE для работы в режиме GTID репликации. Так же настроено игнорирование 2х таблиц при репликации: bet.events_on_demand и bet.v_same_event.    
По завершению работы плейбуков стартует хэндлер, который  записывает данные в таблицу **bookmaker** данные на MASTER,  затем выводим результат реплицации на SLAVE. Все это будет в консоли выполения роли. 
```
RUNNING HANDLER [mysql : debug] ************************************************
ok: [slave] => {
    "msg": {
        "Auto_Position": 1, 
        "Channel_Name": "", 
        "Connect_Retry": 60, 
        "Exec_Master_Log_Pos": 194, 
        "Executed_Gtid_Set": "dfdac7d4-0626-11ea-bca9-525400261060:1-42", 
        "Is_Slave": true, 
        "Last_Errno": 0, 
        "Last_Error": "", 
        "Last_IO_Errno": 0, 
        "Last_IO_Error": "", 
        "Last_IO_Error_Timestamp": "", 
        "Last_SQL_Errno": 0, 
        "Last_SQL_Error": "", 
        "Last_SQL_Error_Timestamp": "", 
        "Master_Bind": "", 
        "Master_Host": "192.168.11.150", 
        "Master_Info_File": "/var/lib/mysql/master.info", 
        "Master_Log_File": "mysql-bin.000003", 
        "Master_Port": 3306, 
        "Master_Retry_Count": 86400, 
        "Master_SSL_Allowed": "No", 
        "Master_SSL_CA_File": "", 
        "Master_SSL_CA_Path": "", 
        "Master_SSL_Cert": "", 
        "Master_SSL_Cipher": "", 
        "Master_SSL_Crl": "", 
        "Master_SSL_Crlpath": "", 
        "Master_SSL_Key": "", 
        "Master_SSL_Verify_Server_Cert": "No", 
        "Master_Server_Id": 1, 
        "Master_TLS_Version": "", 
        "Master_UUID": "dfdac7d4-0626-11ea-bca9-525400261060", 
        "Master_User": "repl", 
        "Read_Master_Log_Pos": 194, 
        "Relay_Log_File": "slave-relay-bin.000004", 
        "Relay_Log_Pos": 367, 
        "Relay_Log_Space": 574, 
        "Relay_Master_Log_File": "mysql-bin.000003", 
        "Replicate_Do_DB": "", 
        "Replicate_Do_Table": "", 
        "Replicate_Ignore_DB": "", 
        "Replicate_Ignore_Server_Ids": "", 
        "Replicate_Ignore_Table": "bet.events_on_demand", 
        "Replicate_Rewrite_DB": "", 
        "Replicate_Wild_Do_Table": "", 
        "Replicate_Wild_Ignore_Table": "", 
        "Retrieved_Gtid_Set": "", 
        "SQL_Delay": 0, 
        "SQL_Remaining_Delay": null, 
        "Seconds_Behind_Master": 0, 
        "Skip_Counter": 0, 
        "Slave_IO_Running": "Yes", 
        "Slave_IO_State": "Waiting for master to send event", 
        "Slave_SQL_Running": "Yes", 
        "Slave_SQL_Running_State": "Slave has read all relay log; waiting for more updates", 
        "Until_Condition": "None", 
        "Until_Log_File": "", 
        "Until_Log_Pos": 0, 
        "changed": false, 
        "failed": false
    }
}

RUNNING HANDLER [mysql : get data after backup] ********************************
changed: [slave]

RUNNING HANDLER [mysql : debug] ************************************************
ok: [slave] => {
    "mysql_data_before_repl.stdout_lines": [
        "id\tbookmaker_name", 
        "4\tbetway", 
        "5\tbwin", 
        "6\tladbrokes", 
        "3\tunibet"
    ]
}

RUNNING HANDLER [mysql : insert_into_master] ***********************************
changed: [slave]

RUNNING HANDLER [mysql : debug] ************************************************
ok: [slave] => {
    "msg": {
        "changed": true, 
        "cmd": "mysql -h192.168.11.150 -ubob -p7ksah}MS8B?fPP -e\"use bet; INSERT INTO bookmaker (id,bookmaker_name) VALUES(1,'1xbet');\"", 
        "delta": "0:00:00.227227", 
        "end": "2019-11-13 15:11:09.059109", 
        "failed": false, 
        "rc": 0, 
        "start": "2019-11-13 15:11:08.831882", 
        "stderr": "mysql: [Warning] Using a password on the command line interface can be insecure.", 
        "stderr_lines": [
            "mysql: [Warning] Using a password on the command line interface can be insecure."
        ], 
        "stdout": "", 
        "stdout_lines": []
    }
}

RUNNING HANDLER [mysql : check_slave] ******************************************
changed: [slave]

RUNNING HANDLER [mysql : debug] ************************************************
ok: [slave] => {
    "select_from_slave.stdout_lines": [
        "id\tbookmaker_name", 
        "1\t1xbet", 
        "4\tbetway", 
        "5\tbwin", 
        "6\tladbrokes", 
        "3\tunibet"
    ]
}
```