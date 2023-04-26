По мотивам https://just-4.fun/blog/howto/letsencrypt-rsa-keys/  
Для уже работающего контейнера надо изменить параметры запроса ключа.  
Для этого на работающем контейнере выполнить  
```sudo docker container exec -it nginx-proxy-manager sed -i 's/key-type = ecdsa/key-type = rsa/g' /etc/letsencrypt.ini```  
```sudo docker container exec -it nginx-proxy-manager sed -i 's/elliptic-curve = secp384r1/rsa-key-size = 2048/g' /etc/letsencrypt.ini```  
Через веб интерфейс перезапросить ключи (название папки можно уточнить на вкладке _SSL Certificates_, троеточие, верхняя строка, напрмер Certifate #18).  
Полученные ключи будут находится в <path to folder>/nginx-proxy-manager/letsencrypt/live/npm-18/

openssl pkey -in <path to folder>/nginx-proxy-manager/letsencrypt/live/npm-18/privkey4.pem -text

  
