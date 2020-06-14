############################################################################
#!/bin/bash                                                                #
#            Instalacao Automatizada do Nagios Core 4.4.6 - CENTOS 7       #
# -------------------------------------------------------------------------#
#Autor:   Rodrigo Nunes                                                    #
#Github:  https://github.com/rodricknunes/                                 #
#Contato: rodrigonunes@id.uff.br                                           #
############################################################################
echo ".#####################################################."
echo "|              DESABILITANDO O SELINUX                |"
echo ".#####################################################."
cat /etc/selinux/config |grep SELINUX=e 
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
cat /etc/selinux/config |grep SELINUX=d
sed -i --follow-symlinks 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux && cat /etc/sysconfig/selinux
echo ".#####################################################."
echo "| ADICIONANDO REPOSITORIOS E ATUALIZANDO SEU CENTOS_7 |"
echo ".#####################################################."
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
yum install epel-release -y
clear
echo ".#####################################################."
echo "|        ATUALIZANDO SEU SISTEMA OPERACIONAL          |"
echo ".#####################################################."
yum update -y
clear
echo ".#####################################################."
echo "|       INSTALANDO PACOTES QUE SERAO NECESSARIOS      |"
echo ".#####################################################."
yum install gcc glibc glibc-common gd gd-devel openssl-devel bzip2-devel libffi-devel postfix groupinstall "Development Tools" -y
yum install httpd -y
yum install php php-common php-cli php-devel php-zts php-peclapc-devel php-pecl-memcache php-calendar php-shmop php-mysqlnd php-pear php-bcmath php-gd php-imap php-intl php-ldap php-xml php-xmlrpc php-mbstring php-odbc php-pdo php-pecl-apc phppspell php-zlib php-soap -y
yum install perl perl-Data-Dumper perl-CGI perl-FCGI perl-IO-Socket-INET6 perl-LDAP perl-Switch nagios-plugins-perl perl-Nagios-Plugin perl-Net-SNMP perl-SNMP_Session php-snmp cpanspec snmptt net-snmp-python net-snmp net-snmp-utils -y
yum install python python-pip python-wheel -y
pip install --upgrade pip
yum install git unzip net-tools -y
clear
echo ".#####################################################."
echo "| HABILITANDO O APACHE PARA INICIALIZACAO AUTOMATICA  |"
echo ".#####################################################."
make install-daemoninit
chkconfig httpd on
systemctl daemon-reload
systemctl start httpd
systemctl enable httpd
clear
echo ".######################################################."
echo "|               ABRINDO AS PORTAS 80;443               |"
echo ".######################################################."
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload
clear
# Configuraco do usuario NAGIOS
# _Acesso_ao_Shell_
/usr/sbin/useradd -m -s /bin/bash nagios
echo ".######################################################."
echo "|        CRIE UMA SENHA PARA O NOVO USUARIO: NAGIOS    |"
echo ".######################################################."
passwd nagios
/usr/sbin/groupadd nagcmd
/usr/sbin/usermod -a -G nagcmd nagios
/usr/sbin/usermod -a -G nagcmd apache
echo ".######################################################."
echo "|               INSTALANDO O NAGIOS CORE               |"
echo ".######################################################."
cd /tmp
wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.6.tar.gz -O /tmp/nagioscore.tar.gz
wget --no-check-certificate -O nagios-plugins.tar.gz https://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz

# Instalando o Nagios
cd /tmp
tar xzf nagioscore.tar.gz
cd /tmp/nagioscore-nagios-4.4.6
./configure --with-command-group=nagcmd
make all
make install
make install-init
make install-config
make install-commandmode
# Configuracao do acesso WEB do nagios
make install-webconf
make install-exfoliation
echo ".######################################################."
echo "|    CRIE UMA SENHA PARA O ACESSO WEB: NAGIOSADMIN     |"
echo ".######################################################."
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
systemctl restart httpd
# Instalando os pluguins de uso do nagios
echo ".######################################################."
echo "|          INSTALANDO OS PLUGINS DO NAGIOS             |"
echo ".######################################################."
cd /tmp
tar xzf nagios-plugins.tar.gz
cd /tmp/nagios-plugins-2.2.1
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
make install

/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
clear
# Habilitando & Iniciando o Nagios
chkconfig --add nagios
chkconfig nagios on
systemctl daemon-reload
systemctl enable nagios.service
systemctl start nagios

clear
cat /etc/selinux/config |grep SELINUX=e 
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
cat /etc/selinux/config |grep SELINUX=d
clear
systemctl restart httpd
systemctl restart nagios
clear
echo ".                                                                   ."
echo ".###################################################################."
echo "|       O NAGIOS FOI INSTALADO COM SUCESSO EM SEU CENTOS 7          |"
echo "|  ACESSE SEU NAGIOS PELO SEU NAVEGADOR http://IP_DO_NAGIOS/nagios  |"
echo ".###################################################################."
echo ".                                                                   ."

