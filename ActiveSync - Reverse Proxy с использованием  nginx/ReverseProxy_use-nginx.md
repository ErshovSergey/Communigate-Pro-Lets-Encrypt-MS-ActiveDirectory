##Синхронизация по ActiveSync ( протокол Exchange) -  Reverse Proxy с использованием  nginx  
[По мотивам1](https://blog.kempkens.io/posts/exchange-reverse-proxy-using-nginx/)  
[По мотивам2](https://stackoverflow.com/questions/14839712/nginx-reverse-proxy-passthrough-basic-authenication/19714696#19714696)  
[По мотивам3](https://stackoverflow.com/questions/35384245/nginx-as-exchange-proxy)  

Для корректной работы по протоколу Microsoft для синхронизации клиентов по ActiveSync (в терминологии CommunigatePro называется AirSync) необходимо для нового пользователя создавать папки:  
- Calendar  
- Contacts  
- Drafts  
- Notes  
- Sent Items  
- Tasks  
- Trash
