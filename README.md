### Установка и настройка

1. Выключить доступ по паролю через ssh и перезапустить сервис
```bash
sed -i -E 's/#?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd
```
2. Установить [docker и docker-compose](https://docs.docker.com/engine/install/ubuntu/)
3. Установить зависимости
```bash
apt install sqlite3 p7zip-full rclone
```
4. Настроить [rclone на яндекс диск](https://rclone.org/yandex/)
5. Скопировать в папку /srv/vaultwarden следующие файлы и папки
```
f2b-data/
backup.sh
Caddyfile
docker-compose.yml
```
6. Создать файл /srv/vaultwarden/.env со следующим содержимым
```bash
TZ=<таймзона>  # Europe/Moscow
DOMAIN=https://<домен>  # https://vaultwarden.mydomain.ru
SMTP_HOST=<хост smtp сервера почты>  # smtp.yandex.ru
SMTP_PORT=<порт smtp сервера почты>  # 465
SMTP_FROM=<почтовый ящик от чьего имени будут отправляться письма>  # v.pupkin@yandex.ru
SMTP_USERNAME=<логин для smtp сервера>
SMTP_PASSWORD=<пароль для smtp сервера>
ADMIN_TOKEN=<токен для доступа к админке>  # openssl rand -base64 48
EMAIL=<почта для ACME HTTP-01 challenge>  # v.pupkin@yandex.ru
BACKUP_PASSWORD=<пароль для 7zip архивов бэкапа>  # openssl rand -base64 48
```
7. Разрешить на запуск backup.sh
```bash
chmod +x backup.sh
```
8. Скопировать systemd сервисы и таймер в /etc/systemd/system и включить
```bash
systemctl enable vaultwarden-backup.timer
systemctl start vaultwarden-backup.timer
systemctl enable vaultwarden
systemctl start vaultwarden
```
9. После добавления всех клиентов выключить доступ к админке через `.env` файл и перезагрузить сервис
```bash
ADMIN_TOKEN=

systemctl restart vaultwarden
```

### Fail2Ban
Забаненные ip можно увидеть в логе /srv/vaultwarden/f2b-data/fail2ban.log. Для разбана ip выполните следующую команду
```bash
docker exec -t fail2ban fail2ban-client set vaultwarden unbanip XX.XX.XX.XX
```