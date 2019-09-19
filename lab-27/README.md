# Postfix + Dovecot + Virtual domainx
1. [postfix.cfg](./etc/postfix)
2. [dovecot.cfg](./etc/dovecot)
3. Для работы с почтой создаем:

    3.0. Ставим:

        
        yum install dovecot postvix vim telnet -y
        

    3.1. Пользователя postfix и запоминаем его uid и guid:

        
        useradd -s /sbin/nologin userpostfix
        tail /etc/passwd
            userpostfix:x:1001:1001::/home/userpostfix:/sbin/nologin
        

    У меня 1001, у вас может быть иначе.

    3.2. Вносим изменения в конфиг main.cf, лучше искать через / по ключам и если такие уже есть, то менять на ниже указанные значения, если таких параметров нет, то просто добавить:

        
        vi /etc/postfix/main.cf
            myhostname = www.tecdistro.com
            mydomain = tecdistro.com
            myorigin = $mydomain
            inet_interfaces = all
            home_mailbox = Maildir/
            mail_spool_directory = /var/spool/mail

            virtual_mailbox_domains = /etc/postfix/virtual_domains
            virtual_mailbox_base = /var/mail/vhosts
            virtual_mailbox_maps = hash:/etc/postfix/vmailbox
            virtual_minimum_uid = 1001
            virtual_maximum_uid = 1001
            virtual_uid_maps = static:1001
            virtual_gid_maps = static:1001
            virtual_alias_maps = hash:/etc/postfix/virtual
        

    3.3. Виртуальные домены:

        
        vi /etc/postfix/virtual_domains
            tecdistro1.com
            tecdistro2.net
            tecdistro3.org
        
    3.4. Структуру почтовых каталогов:

        mkdir /var/mail/vhosts
        chgrp -R userpostfix /var/mail
        cd /var/mail/vhosts
        mkdir tecdistro1.com
        mkdir tecdistro2.net
        mkdir tecdistro3.org
        cd ..
        chown -R userpostfix:userpostfix vhosts
        
    3.5. Ящики виртуальных пользователей:

        vi /etc/postfix/vmailbox
        @tecdistro1.com          tecdistro1.com/catch-all/
            user1@tecdistro1service postfix reload.com        tecdistro1.com/user1/
            user2@tecdistro1.com       tecdistro1.com/user2/
            user1@tecdistro2.net        tecdistro2.net/user1/
            user1@tecdistro3.org        tecdistro3.org/user1/
        
    3.6. Инициализируем:

        postmap /etc/postfix/virtual
        postmap /etc/postfix/vmailbox
        
    3.7. Перезагружаем postfix

        service postfix reload
        
    3.8. Правим конфиги dovecot

        cd /etc/dovecot/
        vi dovecot.conf
            protocols = imap pop3 
        cd /etc/dovecot/conf.d/
        vi 10-auth.conf
            disable_plaintext_auth = no
            #!include auth-system.conf.ext
            !include auth-passwdfile.conf.ext
        vi 10-logging.conf
            log_path = /var/log/dovecot.log
            auth_verbose = no
            auth_debug = no
            verbose_ssl = no
        vi 10-mail.conf
            mail_location = maildir:/var/mail/vhosts/%d/%n
            mail_uid = 1001
            mail_gid = 1001
            mail_privileged_group = userpostfix
        vi 10-master.conf
            unix_listener auth-userdb {
                mode = 0600
                user = postfix
                group =  postfix
                }
            Postfix smtp-auth
            unix_listener /var/spool/postfix/private/auth {
                mode = 0666
                user = postfix
                group = postfix
                }
        
      Для проверки из вне, с помощью telnet, необходимо:
      
      	vim 10-ssl.conf
        	ssl = yes
      Естественно для боевых серверов необходимо включать шифрование и на получение и отравку почты, ну а так как у нас учебный стенд и без выхода за периметр, то можно пренебречь.
      Для того, чтобы проверять почту по pop3|imap, необходимо правильно заполнить **/etc/dovecot/users**:
      
      	doveadm pw -s SHA512-CRYPT -u user1@tecdistro1.com
	
      Вводим пароль, на выходе получаем такого содержания строку:
        
        {SHA512-CRYPT}$6$WBg0Ss.va62BZrs9$T80778xeN9mBcIpZpnNJy1ZTs0h5Nz.hBVEP4P9jpgPJgx9LB10YsCFxoQ/MFy/j0is4BCG6zBOb.COb35clM1
        
      Копируем ее, открываем на редактирование /etc/dovecot/users и вносим запись для авторизации таким образом:
      
        user1@tecdistro1.com:{SHA512-CRYPT}$6$WBg0Ss.va62BZrs9$T80778xeN9mBcIpZpnNJy1ZTs0h5Nz.hBVEP4P9jpgPJgx9LB10YsCFxoQ/MFy/j0is4BCG6zBOb.COb35clM1:userpostfix:userpostfix
       
      Перезагружаем:
      
        systemctl restart dovecot
      
4. Проверка:
    4.1. Отправляем почту:
    
    	telnet 192.168.10.10 25
        Trying 192.168.10.10...
        Connected to 192.168.10.10.
        Escape character is '^]'.
        220 www.tecdistro.com ESMTP Postfix
            ehlo www.tecdistro.com
        250-www.tecdistro.com
        250-PIPELINING
        250-SIZE 10240000
        250-VRFY
        250-ETRN
        250-ENHANCEDSTATUSCODES
        250-8BITMIME
        250 DSN
            mail from:support@tecdistro.com
        250 2.1.0 Ok
            rcpt to:user1@tecdistro1.com
        250 2.1.5 Ok
            data
        354 End data with <CR><LF>.<CR><LF>
            klsdhflsjkglsjdgl
            dskjfghlkjsdhglkjsdfg
            ^Sвапывлаопрыдвлоарпдлывоап
            вылоапрдлвыопрдлывоа
            .
        250 2.0.0 Ok: queued as 1717C2000067
            quit
        221 2.0.0 Bye
        Connection closed by foreign host.
    
    4.2. Получение почты:
    
    	telnet 192.168.10.10 110
        Trying 192.168.10.10...
        Connected to 192.168.10.10.
        Escape character is '^]'.
        +OK Dovecot ready.
            user user1@tecdistro1.com
        +OK
        pass Test123
        +OK Logged in.
            list
        +OK 3 messages:
        1 541
        2 425
        3 437
        .
            retr 1
        +OK 541 octets
        Return-Path: <support@tecdistro.com>
        X-Original-To: user1@tecdistro1.com
        Delivered-To: user1@tecdistro1.com
        Received: from localhost (localhost [IPv6:::1])
	    by www.tecdistro.com (Postfix) with ESMTP id 7124C2000067
	    for <user1@tecdistro1.com>; Thu, 19 Sep 2019 21:14:15 +0000 (UTC)
        Message-Id: <20190919211440.7124C2000067@www.tecdistro.com>
        Date: Thu, 19 Sep 2019 21:14:15 +0000 (UTC)
        From: support@tecdistro.com
            kljdsaghldfgldaf
            sdfjghsdlkjfghlsdjkfg
            dsfgпывапывапывапывап
            выапывапывапывап
        .
         



    
