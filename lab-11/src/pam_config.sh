#!/usr/bin/env bash
pamCheckScript="pam_check.sh"
HolyDayTableFile="holydays_table"
pam_check_path="/etc/pam_check.sh"

newUser=testuser
if [ -s "/tmp/$pamCheckScript" ];then
 cp "/tmp/$pamCheckScript" "/etc/$pamCheckScript"
else 
 echo "cannt find src file $pamCheckScript"
 exit
fi
if [ -s "/tmp/$HolyDayTableFile" ];then
 cp "/tmp/$HolyDayTableFile" "/etc/$HolyDayTableFile"
else 
 echo "cannt find src file $HolyDayTableFile"
 exit
fi
if [ -s $pam_check_path ];then
    if [ ! -x $pam_check_path ];then
     chmod +x $pam_check_path
    fi
    #create admin group
     addgroup admin
     #add vagrant to admin group
     usermod -G admin vagrant
     #add tesuser out of group admin
     useradd $newUser
     #setuo def password with changing in the next logon
     echo 0000 | passwd  $newUser --stdin
     passwd -e $newUser
     #allow to ssh login via password
     #sshByPasswd=$(grep PasswordAuthentication /etc/ssh/sshd_config)
     sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
     #sed -i 's/UsePAM no/UsePAM yes/g'/etc/ssh/sshd_config
     systemctl restart sshd
     #configure pam_check account by script
     #sed -i "2i account     required       pam_exec.so    /etc/pam_check.sh" /etc/pam.d/sshd
     sed -i "2i account     required       pam_exec.so    /etc/pam_check.sh" /etc/pam.d/login
     #install docker
     yum install docker -y
     #allow testuser restart docker daemon and use docker via SUDO command
     visudoForUser=$(grep $newUser /etc/sudoers)

     echo "s/$visudoForUser/$newUser ALL=/bin/systemctl stop docker, /bin/systemctl start docker, /usr/bin/docker/g" /etc/sudoers
else
 echo "not found $pam_check_path OR it's empty"
 exit 1
fi
