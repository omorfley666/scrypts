#!/bin/bash

cp /etc/ca-certificates/ca.*

read -p "Введите имя хоста, для которого создаете сертификат: " hostname

cat > $hostname.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names 
[alt_names]
# Локальные хостинги
DNS.1 = localhost
DNS.2 = 127.0.0.1
DNS.3 = ::1 
# Перечислите доменные имена
DNS.4 = $hostname
DNS.5 = $hostname.antereal.com
DNS.6 = $hostname.it-an.ru
EOF

openssl req -new -nodes -newkey rsa:4096 \
  -keyout $hostname.key -out $hostname.csr \
  -subj "/C=RU/ST=Russia/L=Tomsk/O=ANTEREAL/CN=$hostname"

openssl x509 -req -sha512 -days 365 \
-extfile $hostname.ext \
-CA ca.crt -CAkey ca.key -CAcreateserial \
-in $hostname.csr \
-out $hostname.crt

echo "Введите тип ОС сервера: "
echo "Введите 1, если сервер на Windows"
echo "Введите 2, если сервер на Linux"
read -p "" os

if [ "$os" == "1" ] 
then
	openssl pkcs12 -export -out $hostname.ru.pfx -inkey $hostname.key -in $hostname.crt
fi
