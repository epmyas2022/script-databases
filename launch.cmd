#!/bin/bash

if [ "$(uname -s)" != "Linux" ]; then
#---------------------------------------------------
# COMPATIBILITY WITH WINDOWS
#---------------------------------------------------

    @echo off
    echo Actualemente no es compatible con Windows pero se esta trabajando en ello.

    exit /B
fi


#---------------------------------------------------
# COMPATIBILITY WITH LINUX
#---------------------------------------------------

load_sql(){
    local container_name=$1
    local driver=$2
    local db_name=$3
    local user=$4
    local password=$5
    local file_sql=$6

    if [ "$driver" == "postgres" ]; then
        echo -e "\033[38;5;10m"
        echo "Cargando archivo SQL en PostgreSQL..."
        echo -e "\033[0m"
        cat $file_sql | docker exec -i $container_name psql -U $user -d $db_name
    elif [ "$driver" == "mysql" ]; then
        echo -e "\033[38;5;10m"
        echo "Cargando archivo SQL en MySQL..."
        echo -e "\033[0m"
        cat $file_sql | docker exec -i $container_name mysql -u $user -p$password $db_name

    elif [ "$driver" == "mariadb" ]; then
         echo -e "\033[38;5;10m"
         echo "Cargando archivo SQL en MariaDB..."
         cat $file_sql | docker exec -i $container_name mysql -u $user -p$password $db_name

    else 
        echo -e "\033[38;5;9m"
        echo "[x] Driver no soportado."
        echo -e "\033[0m"
        exit 1
    fi
}

start_load_sql(){

    echo -e "\033[38;5;155m"
    read -p "¿Quieres cargar un archivo SQL? (y/n): " load_sql_option

    if [ "$load_sql_option" == "y" ]; then
        echo -e "\033[38;5;10m"
        read -p "Introduce la ruta del archivo SQL: " file_sql

        if [ ! -f "$file_sql" ]; then
            echo -e "\033[38;5;9m"
            echo "[x] El archivo SQL no existe."
            echo -e "\033[0m"
            exit 1
        fi

        load_sql $CONTAINER_NAME $DB_DRIVER $DB_NAME $DB_USER $DB_PASSWORD $file_sql
    fi
}

up(){
   local file=$1
   local default_port=$2

   echo -e "\033[38;5;155m"
   read -p "¿Cual es el nombre del contenedor? " container_name

   if( [ -z "$container_name" ] ); then
      echo -e "\033[38;5;9m"
      echo "[x] El nombre del contenedor no puede estar vacío."
      echo -e "\033[0m"
      exit 1
   fi

   export CONTAINER_NAME=$container_name

   echo -e "\033[38;5;155m"
   read -p "¿Quieres definir un usuario y contraseña? (y/n): " define_user

   #user and password

   if [ "$define_user" == "y" ]; then
        echo -e "\033[38;5;10m"
         read -p "Introduce el nombre de usuario: " username
         read -p "Introduce la contraseña: " password
    
         export DB_USER=$username
         export DB_PASSWORD=$password

    else
         export DB_USER=postgres
         export DB_PASSWORD=postgres
    fi

   echo -e "\033[38;5;155m"
   read -p "¿Quieres definir un puerto? (y/n): " define_port

  #port

   if [ "$define_port" == "y" ]; then
        echo -e "\033[38;5;220m"
        read -p "Introduce el puerto: " port
        export DB_PORT=$port
   else
        export DB_PORT=$default_port
   fi

   echo -e "\033[38;5;155m"
   read -p "¿Quieres definir un nombre de base de datos? (y/n): " define_db

   #database

    if [ "$define_db" == "y" ]; then
        echo -e "\033[38;5;220m"
        read -p "Introduce el nombre de la base de datos: " db_name
        export DB_NAME=$db_name
    else
        export DB_NAME=postgres
    fi
 
  echo -e "\033[38;5;84m \n"
  echo -e "Levantando contenedor..."
  echo -e "\033[0m"

  docker-compose -f "$file" up -d

  if [ $? -ne 0 ]; then
      echo -e "\033[38;5;9m"
      echo "[x] Error al levantar el contenedor."
      echo -e "\033[0m"
      exit 1
   fi

   show_info_service "127.0.0.1" "$DB_PORT" "$DB_USER" "$DB_PASSWORD" "$DB_NAME"  
}


show_info_service(){
    local host=$1
    local port=$2
    local user=$3
    local password=$4
    local db_name=$5

    echo -e "\033[38;5;222m"
    echo "----------------------------------------------------------"
    echo "| Información de conexión al servicio:"
    echo "| - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo "| Host: $host"
    echo "| Puerto: $port"
    echo "| Usuario: $user"
    echo "| Contraseña: $password"
    echo "| Base de datos: $db_name"
    echo "----------------------------------------------------------"
    echo -e "\033[0m"
}

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
echo -e "Selecciona una opción: \n"


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

    echo -e "Iniciando PostgreSQL... \n"

    export DB_DRIVER="postgres"

    up "sources/postgres-compose.yml" 5432

    start_load_sql

    echo -e "\033[0m"

elif [ "$option" == "2" ]; then
    echo -e "\033[38;5;10m"

    echo - e "Iniciando MySQL... \n"

    export DB_DRIVER="mysql"

    up "sources/mysql-compose.yml" 3306

    start_load_sql

    echo -e "\033[0m"

elif [ "$option" == "3" ]; then
    echo -e "\033[38;5;10m"

    echo -e "Iniciando MongoDB... \n"

    up "sources/mongo-compose.yml" 27017

    echo -e "\033[0m"

elif [ "$option" == "4" ]; then
    echo -e "\033[38;5;10m"

    echo -e "Iniciando Redis... \n"

    up "sources/redis-compose.yml" 6379

    echo -e "\033[0m"

elif [ "$option" == "5" ]; then
    echo -e "\033[38;5;10m"

    echo -e "Iniciando MariaDB... \n"

    export DB_DRIVER="mariadb"

    up "sources/mariadb-compose.yml" 3306

    start_load_sql
 
    echo -e "\033[0m"
    
else
    echo -e "\033[38;5;9m"
    echo "[x] Opción no válida. Por favor, selecciona una opción válida."
    echo -e "\033[0m"
    exit 1
fi