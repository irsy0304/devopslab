FROM nginx:alpine

# Копируем HTML страницу
COPY index.html /usr/share/nginx/html/index.html

# Создаём простой API для получения информации о поде
RUN apk add --no-cache curl jq

# Добавляем endpoint /pod-info
RUN echo '#!/bin/sh\n\
HOSTNAME=$(hostname)\n\
IP=$(hostname -i)\n\
echo "{\"hostname\":\"$HOSTNAME\",\"ip\":\"$IP\"}"' > /usr/share/nginx/html/pod-info && \
    chmod +x /usr/share/nginx/html/pod-info

# Настраиваем nginx для обработки /pod-info
RUN echo 'server {\n\
    listen 80;\n\
    server_name localhost;\n\
    location / {\n\
        root /usr/share/nginx/html;\n\
        index index.html;\n\
    }\n\
    location /pod-info {\n\
        default_type application/json;\n\
        return 200 "{\\"hostname\\":\\"$HOSTNAME\\",\\"ip\\":\\"$(hostname -i)\\"}";\n\
    }\n\
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80
