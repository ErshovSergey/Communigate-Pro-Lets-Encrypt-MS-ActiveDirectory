## Использование сертификатов от Nginx Proxy Manager в CommunigatePro
По мотивам https://just-4.fun/blog/howto/letsencrypt-rsa-keys/  
### Для уже работающего контейнера Nginx Proxy Manager надо изменить параметры запроса ключа(изменять каждый раз при пересборке).  
#### Для этого на работающем контейнере выполнить  
```sudo docker container exec -it nginx-proxy-manager sed -i 's/key-type = ecdsa/key-type = rsa/g' /etc/letsencrypt.ini```  
```sudo docker container exec -it nginx-proxy-manager sed -i 's/elliptic-curve = secp384r1/rsa-key-size = 2048/g' /etc/letsencrypt.ini```  
#### Через веб интерфейс перезапросить ключи (название папки можно уточнить на вкладке _SSL Certificates_, троеточие, верхняя строка, напрмер Certifate #18).  
Полученные ключи будут находится в <path to folder>/nginx-proxy-manager/letsencrypt/live/npm-18/

#### Проверить что ключ RSA можно командой:  
```openssl pkey -in <path to folder>/nginx-proxy-manager/letsencrypt/live/npm-18/privkey4.pem -text```  

### Скрипт для добавления в CommunigatePro  
```#!/bin/sh

# файл ключа
private_key=/var/CommuniGate/script/fromLetsEncrypt/privkey.pem

# файл сертификата
cert=/var/CommuniGate/script/fromLetsEncrypt/cert.pem

# файл цепочки
fullchain=/var/CommuniGate/script/fromLetsEncrypt/fullchain.pem

# имя домена
domain_name=mail.domain.ru
# пользователь с правами достаточными для управления ключами
postmaster_name=postmaster@${domain_name}
postmaster_password=PSSwoRD
# адрес сервера
ip_cgp_server=127.0.0.1

# Готовим ключ
echo -n "Add private key .."
private_secure_key=`openssl rsa -in ${private_key}  2> /dev/null | grep -v '\-\-' | tr -d '\n'`
# Добавляем ключ
curl -u $postmaster_name:$postmaster_password -k "http://$ip_cgp_server:8100/cli/" \
  --data-urlencode "command=updatedomainsettings ${domain_name} \
  {PrivateSecureKey=[${private_secure_key}];}"
echo ".done."

# Готовим сертификат
echo -n "Add cert .."
# только первый сертификат
secure_sertificate=`cat ${cert=} | sed '/-----END CERTIFICATE-----/q' | grep -v '\-\-' | tr -d '\n'`

# Добавляем сертификат
curl -u $postmaster_name:$postmaster_password -k "http://$ip_cgp_server:8100/cli/" \
  --data-urlencode "command=updatedomainsettings ${domain_name} \
  {SecureCertificate=[${secure_sertificate}];}"
echo ".done."

# Готовим цепочку
echo -n "Add full chain .."
fullchain=`grep -v '\-\-' ${fullchain} | tr -d '\n'`
# Добавляем цепочку
curl -u $postmaster_name:$postmaster_password -k "http://$ip_cgp_server:8100/cli/" \
  --data-urlencode "command=updatedomainsettings ${domain_name} \
  {CAChain=[${fullchain}];}"
echo ".done."
exit 0
```
