# Свой веб-сервер на nginx

> Развёртывание nginx на виртуальной машине, настройка автозапуска, отдача статичной HTML-страницы и открытие доступа через файрвол.

## Описание проекта

Базовый проект по настройке веб-сервера с нуля на чистой Linux-виртуалке (Ubuntu Server). Цель — пройти полный путь: установка nginx → размещение собственной статической страницы → включение автозапуска сервиса → настройка файрвола → проверка доступности снаружи.

## Стек

- Ubuntu Server 22.04 LTS
- nginx
- systemd (автозапуск)
- ufw (файрвол)

## Структура репозитория

```
nginx-static-server/
├── README.md
├── site/
│   └── index.html          # статическая страница, которую отдаёт nginx
├── nginx/
│   └── my-site.conf         # конфигурация виртуального хоста nginx
└── scripts/
    └── setup.sh              # скрипт автоматизации всех шагов ниже
```

## Пошаговая настройка

### 1. Установка nginx

```bash
sudo apt update
sudo apt install -y nginx
```

### 2. Размещение статической страницы

```bash
sudo mkdir -p /var/www/my-site
sudo cp site/index.html /var/www/my-site/index.html
sudo chown -R www-data:www-data /var/www/my-site
```

### 3. Конфигурация виртуального хоста

Файл `nginx/my-site.conf` копируется в `/etc/nginx/sites-available/` и активируется симлинком:

```bash
sudo cp nginx/my-site.conf /etc/nginx/sites-available/my-site
sudo ln -s /etc/nginx/sites-available/my-site /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default   # отключаем дефолтный конфиг
sudo nginx -t                                  # проверка синтаксиса
sudo systemctl reload nginx
```

### 4. Автозапуск сервиса

```bash
sudo systemctl enable nginx
sudo systemctl start nginx
systemctl status nginx     # убедиться, что сервис активен (active/running)
```

Проверка, что автозапуск включён:

```bash
systemctl is-enabled nginx   # должно вывести "enabled"
```

### 5. Открытие порта в файрволе (ufw)

```bash
sudo ufw allow 80/tcp
sudo ufw allow OpenSSH   # чтобы не потерять доступ по SSH при включении ufw
sudo ufw enable
sudo ufw status verbose
```

### 6. Проверка доступа

С самой машины:

```bash
curl -I http://localhost
```

С другого устройства в сети:

```bash
curl -I http://<IP-виртуалки>
```

Ожидаемый результат — код ответа `HTTP/1.1 200 OK` и корректная отдача `index.html`.

## Автоматизация (scripts/setup.sh)

Все шаги выше также собраны в один идемпотентный скрипт `scripts/setup.sh`, который можно запустить на чистой Ubuntu Server одной командой:

```bash
sudo bash scripts/setup.sh
```

## Что было отработано

- Установка и базовая настройка nginx как сервиса systemd.
- Настройка виртуального хоста под собственный домен/статическую страницу.
- Управление автозапуском сервисов через systemd (`enable`/`is-enabled`).
- Базовая настройка файрвола ufw с сохранением доступа по SSH.
- Проверка работоспособности сервиса снаружи виртуальной машины.
