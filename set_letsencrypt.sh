#!/bin/sh

# файл ключа
le_key=/home/DOCKER_DATA/guacomole/nginx-le/etc/ssl/le-key.pem
# файл сертификата
le_crt=/home/DOCKER_DATA/guacomole/nginx-le/etc/ssl/le-crt.pem
# файл цепочки
le_chain_crt=/home/DOCKER_DATA/guacomole/nginx-le/etc/ssl/le-chain-crt.pem

domain_name=domain..ru
postmaster_name=postmaster@${domain_name}
postmaster_password=PassWoRds

# Готовим ключ
private_secure_key=`openssl rsa -in ${le_key} 2> /dev/null | grep -v '\-\-' | tr -d '\n'`

# Добавляем ключ
curl -u postmaster:$postmaster_password -k 'https://127.0.0.1:9100/cli/' \
  --data-urlencode "command=updatedomainsettings ${domain_name} \
  {PrivateSecureKey=[${private_secure_key}];}"

# Готовим сертификат
secure_sertificate=`cat ${le_crt=} | grep -B1000 'BEGIN CERTIFICATE' | grep -B1000 'END ' | grep -v '\-\-' | tr -d '\n'`

# Добавляем сертификат
curl -u postmaster:$postmaster_password -k 'https://127.0.0.1:9100/cli/' \
  --data-urlencode "command=updatedomainsettings ${domain_name} \
  {SecureCertificate=[${secure_sertificate}];}"

# Готовим цепочку
le_chain_crt=`grep -v '\-\-' ${le_chain_crt} | tr -d '\n'`
# Добавляем цепочку
curl -u postmaster:$postmaster_password -k 'https://127.0.0.1:9100/cli/' \
  --data-urlencode "command=updatedomainsettings ${domain_name} \
  {CAChain=[${le_chain_crt}];}"
cp ${le_key} /etc/pve/nodes/mail/pve-ssl.key

cp ${le_crt} /etc/pve/nodes/mail/pve-ssl.pem
