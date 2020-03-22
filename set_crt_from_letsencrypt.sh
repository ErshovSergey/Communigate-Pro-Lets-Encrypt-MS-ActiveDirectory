#!/bin/sh

# для работы необходимо включить доступ для CLI для 127.0.0.1
# для этого указать адрес 127.0.0.1 в качестве клиентского - Users\Domains\<Domain name>\Domain Settings поле Client IP Adreesses
# разрешить CLI для клиентских адресов - Settings\Services\HTTPU секция Sub-protocols параметр CLI установить в clients
# После первого успешного выполнения установить 
# Users\Domains\<Domain name>\Security\SSL\TLS параметр PKI Services в Enabled
# получение ключа, сертификата и цепочки остается за пределами этого скрипта

# файл ключа
le_key=/home/DOCKER_DATA/guacomole/nginx-le/etc/ssl/le-key.pem
# файл сертификата
le_crt=/home/DOCKER_DATA/guacomole/nginx-le/etc/ssl/le-crt.pem
# файл цепочки
le_chain_crt=/home/DOCKER_DATA/guacomole/nginx-le/etc/ssl/le-chain-crt.pem

domain_name=mail.dimain.ru
postmaster_name=postmaster@${domain_name}
postmaster_password=PassWordS
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
cp ${le_key} /etc/pve/nodes/mail/pve-ssl.key

cp ${le_crt} /etc/pve/nodes/mail/pve-ssl.pem
