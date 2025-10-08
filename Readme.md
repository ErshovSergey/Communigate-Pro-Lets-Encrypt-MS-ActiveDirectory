### Включить использование CLI на адресах
*Settings\Srvices\HTTPU параметр Access\CLI* установить *clients*.  
Указать 127.0.0.1 как клиентский адрес.  

### Включить PKI Services
*Settings\Domain\<NameDomain>\Security\SSL\TLS* параметр *PKI Services* установить в *Enabled*.  

### Скрипт для установки ключа, сертификата и цепочки из LE в CGP
```
#!/bin/sh

# файл ключа
private_key=/var/CommuniGate/script/fromLetsEncrypt/privkey.pem

# файл сертификата
cert=/var/CommuniGate/script/fromLetsEncrypt/cert.pem

# файл цепочки
fullchain=/var/CommuniGate/script/fromLetsEncrypt/fullchain.pem

# имя домена
domain_name=<domain_name>
# пользователь с правами достаточными для управления ключами
postmaster_name=postmaster@${domain_name}
postmaster_password=<password>

# адрес сервера
ip_cgp_server=127.0.0.1

# Готовим ключ
private_secure_key=`openssl rsa -in ${private_key} -traditional 2> /dev/null | grep -v '\-\-' | tr -d '\n'`

# Добавляем ключ
echo -n "Add private key .." && \
curl -u $postmaster_name:$postmaster_password -k "http://$ip_cgp_server:8100/cli/" \
  --data-urlencode "command=updatedomainsettings ${domain_name} \
  {PrivateSecureKey=[${private_secure_key}];}" && \
echo ".done."

# Готовим только первый сертификат
secure_sertificate=`cat ${cert=} | sed '/-----END CERTIFICATE-----/q' | grep -v '\-\-' | tr -d '\n'`

# Добавляем только первый сертификат
echo -n "Add cert .." && \
curl -u $postmaster_name:$postmaster_password -k "http://$ip_cgp_server:8100/cli/" \
  --data-urlencode "command=updatedomainsettings ${domain_name} \
  {SecureCertificate=[${secure_sertificate}];}" && \
echo ".done."

# Готовим цепочку
fullchain=`grep -v '\-\-' ${fullchain} | tr -d '\n'`

# Добавляем цепочку
echo -n "Add full chain .."&& \
curl -u $postmaster_name:$postmaster_password -k "http://$ip_cgp_server:8100/cli/" \
  --data-urlencode "command=updatedomainsettings ${domain_name} \
  {CAChain=[${fullchain}];}"&& \
echo ".done."

exit 0
```

### Расписание
Добавить в расписание обновление по мере подхода срока
