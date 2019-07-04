#!/bin/bash
jiraUnit="[Unit]
Description=JIRA Atlassian Service
After=network.target
[Service]
Type=forking
PIDFile=/opt/atlassian/jira/work/catalina.pid
WorkingDirectory=/opt/atlassian/jira/bin
ExecStart=/opt/atlassian/jira/bin/start-jira.sh
ExecStop=/opt/atlassian/jira/bin/stop-jira.sh
KillMode=process
Restart=on-failure
RestartSec=42s
[Install]
WantedBy=multi-user.target"
jiraVersion=8.2.2
echo "Prepear enviroment/r/n"
wget_is=$(rpm -qa | grep wget -c)
if [[ $wget_is -eq "0" ]]; then
 yum install wget -y
fi

x64=$(uname -a | grep x86_64 -c)
if [[ $x64 -eq '1' ]]; then
 jirabinExists=$(find ./ -name atlassian-jira-software-$jiraVersion-x64.bin | wc -l)
 if [[ $jirabinExists -eq "0" ]]; then
  wget  --limit-rate=1024K -O atlassian-jira-software-$jiraVersion-x64.bin  https://product-downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-$jiraVersion-x64.bin
  chmod +x ./atlassian-jira-software-$jiraVersion-x64.bin
 else
  chmod +x ./atlassian-jira-software-$jiraVersion-x64.bin
 fi
else
 echo "You need update OS to x64 bit edition"
 exit
fi

echo "app.install.service\$Boolean=true
existingInstallationDir=/opt/JIRA Software
httpPort\$Long=8070
launch.application\$Boolean=false
portChoice=custom
rmiPort\$Long=8005
sys.adminRights\$Boolean=true
sys.confirmedUpdateInstallationString=false
sys.installationDir=/opt/atlassian/jira
sys.languageId=en" > response.varfile

jiraInstall=$(./atlassian-jira-software-$jiraVersion-x64.bin -q -varfile ./response.varfile)
jiraIsPID=$(find /opt/atlassian/jira/work/ -name catalina.pid | wc -l)
if [[ $jiraIsPID -eq "1" ]];then
 cd /opt/atlassian/jira/bin
 ./stop-jira.sh
 echo "$jiraUnit" > /etc/systemd/system/jira.service
  systemctl daemon-reload
 rm -f /etc/init.d/jira
 chown -R jira:jira /var/atlassian/application-data/
 chown -R jira:jira /opt/atlassian/jira/
 systemctl start jira.service
 isJiraStart=$(systemctl is-active jira.service | grep active -c)
 if [[ $isJiraStart -eq "1" ]];then
  echo "JIRA Atlassian installed and running!"
 else
  echo "Something is wrong"
 fi
else
 echo "$jiraUnit" > /etc/systemd/system/jira.service
 systemctl daemon-reload
 rm -f /etc/init.d/jira
 chown -R jira:jira /var/atlassian/application-data/
 chown -R jira:jira /opt/atlassian/jira/
 systemctl start jira.service
 isJiraStart=$(systemctl is-active jira.service | grep active -c)
 if [[ $isJiraStart -eq "1" ]];then
  echo "JIRA Atlassian installed and running!"
 else
  echo "Something is wrong"
 fi
fi