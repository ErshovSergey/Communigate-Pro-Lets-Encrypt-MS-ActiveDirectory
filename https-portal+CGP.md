### Использование сертификата полученного от LetsEncrypt в CommunigatePro  
#### На хосте CGP https-portal  
- Разворачивается "прокси" [https-portal](https://github.com/SteveLTN/https-portal).  
- Полученные сертификаты ssl копируются на сервер CGP (нужны файлы domain.csr, domain.key, signed.crt)  
```/usr/bin/rsync -a --copy-links /path/to/folde/https-portal-data/<DOMAINNAME>/production/ USERNAME@HOSTNAME:/path/to/folder/CommuniGate_DATA/path/to/cert/```
- Добавляем в cron

#### На хосте CGP
- Скрипт для добавления сертификата в CGP  
_add_cert.sh_
```
#!/bin/sh

# файл ключа
le_key=/path/to/folder/CommuniGate_DATA/path/to/cert/domain.key
# файл сертификата
le_crt=/path/to/folder/CommuniGate_DATA/path/to/cert/signed.crt
# файл цепочки
le_chain_crt=/path/to/folder/CommuniGate_DATA/path/to/cert/signed.crt
domain_name=DOMAINNAME
postmaster_name=postmaster@DOMAINNAME
postmaster_password=PASSWORD
ip_cgp_server=127.0.0.1

# Готовим ключ
private_secure_key=`openssl rsa -in ${le_key} 2> /dev/null | grep -v '\-\-' | tr -d '\n'`

# Добавляем ключ
curl -u $postmaster_name:$postmaster_password -k "http://$ip_cgp_server:8100/cli/" \
  --data-urlencode "command=updatedomainsettings ${domain_name} \
  {PrivateSecureKey=[${private_secure_key}];}"

# Готовим сертификат
secure_sertificate=`cat ${le_crt=} | grep -B1000 'BEGIN CERTIFICATE' | grep -B1000 'END ' | grep -v '\-\-' | tr -d '\n'`

# Добавляем сертификат
curl -u $postmaster_name:$postmaster_password -k "http://$ip_cgp_server:8100/cli/" \
  --data-urlencode "command=updatedomainsettings ${domain_name} \
  {SecureCertificate=[${secure_sertificate}];}"

# Готовим цепочку
le_chain_crt=`grep -v '\-\-' ${le_chain_crt} | tr -d '\n'`
# Добавляем цепочку
curl -u $postmaster_name:$postmaster_password -k "http://$ip_cgp_server:8100/cli/" \
  --data-urlencode "command=updatedomainsettings ${domain_name} \
  {CAChain=[${le_chain_crt}];}"
```
- Добавляем в cron строки (две строки) на хосте CGP  
```
7 8 * * * /path/to/script/folder/add_cert.sh
8 8 * * * /path/to/script/folder/add_cert.sh
```

