#!/bin/bash

if [ "$(uname -s)" != "Linux" ]; then
#---------------------------------------------------
# COMPATIBILITY WITH WINDOWS
#---------------------------------------------------

    @echo off
    echo Ejecutando en Windows...
    echo %USERNAME%
    exit /B
fi


#---------------------------------------------------
# COMPATIBILITY WITH LINUX
#---------------------------------------------------

echo -e "\033[38;5;6m$(cat banner.txt)\033[0m"

if ! command -v docker &> /dev/null
then
    echo -e "\033[38;5;9m"
    echo "[x] Docker no está instalado. Por favor, instálalo primero."
    echo -e "\033[0m"
    exit 1
fi

if ! command -v docker-compose &> /dev/null
then
    echo -e "\033[38;5;9m"
    echo "[x] Docker Compose no está instalado. Por favor, instálalo primero."
    echo -e "\033[0m"
    exit 1
fi

echo -e "\033[38;5;228m"
echo "Selecciona una opción:"


echo -e "\033[38;5;26m1. PostgreSQL"
echo -e "\033[38;5;82m2. MySQL"
echo -e "\033[38;5;220m3. MongoDB"
echo -e "\033[38;5;161m4. Redis"
echo -e "\033[38;5;93m5. MariaDB"  
echo -e "\033[0m"


read -p "Opción: " option

echo -e "\033[38;5;10m"
echo "Has seleccionado la opción $option"
echo -e "\033[0m"


if [ "$option" == "1" ]; then
    echo -e "\033[38;5;10m"
    echo "Iniciando PostgreSQL..."

    read -p "¿Quieres definir un usuario y contraseña para PostgreSQL? (y/n): " define_user

    if [ "$define_user" == "y" ]; then

    fi

    echo -e "\033[0m"

elif [ "$option" == "2" ]; then
    echo -e "\033[38;5;10m"
    echo "Iniciando MySQL..."
    echo -e "\033[0m"

elif [ "$option" == "3" ]; then
    echo -e "\033[38;5;10m"
    echo "Iniciando MongoDB..."
    echo -e "\033[0m"

elif [ "$option" == "4" ]; then
    echo -e "\033[38;5;10m"
    echo "Iniciando Redis..."
    echo -e "\033[0m"
elif [ "$option" == "5" ]; then
    echo -e "\033[38;5;10m"
    echo "Iniciando MariaDB..."
    echo -e "\033[0m"
    
else
    echo -e "\033[38;5;9m"
    echo "[x] Opción no válida. Por favor, selecciona una opción válida."
    echo -e "\033[0m"
    exit 1
fi