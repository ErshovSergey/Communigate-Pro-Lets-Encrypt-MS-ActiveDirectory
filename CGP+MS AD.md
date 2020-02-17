[По мотивам](http://backend.wiki.val.bmstu.ru/doku.php?id=communigate_pro_new#%D0%B2%D0%BD%D0%B5%D1%88%D0%BD%D1%8F%D1%8F_%D0%B0%D1%83%D1%82%D0%B5%D0%BD%D1%82%D0%B8%D1%84%D0%B8%D0%BA%D0%B0%D1%86%D0%B8%D1%8F_%D1%81%D0%BA%D1%80%D0%B8%D0%BF%D1%82_%D0%B4%D0%BB%D1%8F_microsoft_ad)  

### Скачиваем файлы, устанавливаем недостающее  
```
wget http://www.communigate.ru/CGAUTH/authLDAPNewAD.pl
wget https://raw.githubusercontent.com/gitpan/CGP-CLI/master/lib/CGP/CLI.pm
apt install libauthen-simple-ldap-perl ldap-utils
```
### Настраиваем  
проверяем, что пользователи из нужной группы ищутся на хосте
```
ldapsearch -x -D "UserForAuth@ELAVT" -W -h DomainController -b "dc=company,dc=name,dc=ru" "sAMAccountName=DomainUser"
```
UserForAuth - пользователь домена с минимальными правами для получения списка пользователей.  

#### Настраиваем хелпер  

*cat authLDAPNewAD.pl*  
```
...
my %domains=( # e-mail domains
  'corpX.un' => {
    address=>'ldap://DomainController:389',  #the URI or address of LDAP server
    timeout=>5, # timeout in seconds, 20 by default
    adminDN=>'UserForAuth@ELAVT',     # the DN for admin bind
    adminPassword=>'Pa$$w0rd',

    searchBase=>'dc=company,dc=name,dc=ru',
    searchFilter=>'(&(sAMAccountName=<user>)(objectclass=*))',
    updatePasswords=>1,  #if need to update CommuniGate internal password
  },
);

my $CGServerAddress =  '127.0.0.1';   # You should redefine these values
my $CLILogin = 'postmaster';
my $CLIPassword = 'Pa$$w0rd';
...
```
Помечаем на исполнение и переносим на на постонное место
```
chmod +x authLDAPNewAD.pl
```
#### Подключаем хелпер к CGP
В поле *Settings->General->Helpers->External Authentication*  
```
Program Path: /root/authLDAPNewAD.pl
```
или
```
Program Path: C:\Perl\bin\perl C:\var\CommuniGate\authLDAPNewAD.pl
```
Проверяем, что хелпер запущен
```
ps ax | grep authLDAPNewAD
```
#### Последние настроки
*Users->Domains->corpX.ru->Domain Settings*  
Consult External for Unknown: *Yes*  
Consult External on Provision: *Yes*  

Users->Domains->corpX.un->Account Defaults->Settings  
External Password: *Enabled*  


