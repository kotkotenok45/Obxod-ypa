FROM alpine:latest

# Устанавливаем нужные утилиты
RUN apk add --no-cache wget unzip jq

# Скачиваем и распаковываем официальный Xray-core
RUN wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip -d /usr/local/bin && \
    rm -f Xray-linux-64.zip

# Render автоматически подставляет системный порт в переменную среды PORT.
# Мы заставим Xray слушать именно тот порт, который выдаст Render.
CMD jq -n --arg port "$PORT" '{\
  "inbounds": [{\
    "port": ($port | tonumber),\
    "protocol": "vless",\
    "settings": {\
      "clients": [{"id": "00000000-0000-0000-0000-000000000000"}],\
      "decryption": "none"\
    },\
    "streamSettings": {\
      "network": "ws",\
      "wsSettings": {"path": "/ws"}\
    }\
  }],\
  "outbounds": [{"protocol": "freedom"}]\
}' > /tmp/config.json && /usr/local/bin/xray -config /tmp/config.json
