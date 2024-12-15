#!/bin/bash


curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

sudo usermod -aG docker $(whoami)

# Pedir la contraseña
echo "Introduce la contraseña:"
read -s contrasena

# Obtener el hash de la contraseña
passhash=$(docker run --rm -it ghcr.io/wg-easy/wg-easy wgpw "$contrasena")

# Mostrar el hash para verificarlo
echo "El hash de la contraseña es: $passhash"

# Pedir la IP
echo "Introduce la IP:"
read ip

# Ejecutar el comando Docker con las variables adecuadas
docker run --detach \
  --name wg-easy \
  --env LANG=de \
  --env WG_HOST=$ip \
  --env $passhash \
  --env PORT=51821 \
  --env WG_PORT=51820 \
  --volume ~/.wg-easy:/etc/wireguard \
  --publish 51820:51820/udp \
  --publish 51821:51821/tcp \
  --cap-add NET_ADMIN \
  --cap-add SYS_MODULE \
  --sysctl 'net.ipv4.conf.all.src_valid_mark=1' \
  --sysctl 'net.ipv4.ip_forward=1' \
  --restart unless-stopped \
  ghcr.io/wg-easy/wg-easy
