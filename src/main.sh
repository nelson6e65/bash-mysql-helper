#!/usr/bin/env bash

# Realiza operaciones de importar, exportar y hacer respaldos de la base de datos.

declare SCRIPT_DIR=
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Variables de configuración
declare -x c_host
declare -ix c_port
declare -x c_database
declare -x c_username
declare -x c_password

function f_import_env()
{
    declare -i errors=0

    if [[ -f .env ]]; then
        # shellcheck disable=SC1091
        . .env
        errors=$?
    else
        echo 'Error: No ".env" file found'
        errors=0
    fi

    if [[ $errors -eq 0 ]]; then
        if [[ -z $DB_HOST ]]; then
            declare DB_HOST='localhost'
        fi

        if [[ -z $DB_PORT ]]; then
            declare DB_PORT=3306
        fi

        if [[ -z $DB_DATABASE ]]; then
            if [[ -z $DB_NAME ]]; then
                echo 'Error: No se encontró "DB_NAME" o "DB_DATABASE"'
                errors=$(( errors | 2 ))
            else
                declare DB_DATABASE="$DB_NAME"
            fi
        fi

        if [[ -z $DB_USERNAME ]]; then
            echo 'Error: No se encontró "DB_USERNAME"'
            errors=$(( errors | 2 ))
        fi

        if [[ -z $DB_PASSWORD ]]; then
            echo 'Error: No se encontró "DB_PASSWORD"'
            errors=$(( errors | 2 ))
        fi

        if [[ $errors -eq 0 ]]; then
            c_host=$DB_HOST
            c_port=$DB_PORT
            c_database=$DB_DATABASE
            c_username=$DB_USERNAME
            c_password=$DB_PASSWORD
        fi
    fi

    return $errors
}

f_import_env
r=$?

if [[ $r -ne 0   ]]; then
    echo 'Ocurrió un error al obtener los credenciales de la base de datos'
    exit $r
fi

declare t_file=

declare -i r=0
declare -i opt_b=0 # Respaldo (por defecto si no se pasa --no-backup)
declare -i opt_e=-1 # Exportar
declare -i opt_i=-1 # Importar



# Hace un respaldo del estado actual de la DB
function f_backup
{
    declare hora=

    hora=$(date +%Y-%m-%d_%H.%M.%S)

    t_file="backups/${c_database}_${hora}.sql.gz"
    t_file="${c_database}_${hora}.sql.gz"

    mysqldump -v --opt --events --routines --triggers --default-character-set=utf8mb4 -h "${c_host}" -u "${c_username}" --password="${c_password}" "${c_database}" | gzip -c > "${t_file}"

    return $?
}

# Reemplaza el SQL actual
function f_export
{
    t_file="${c_database}.sql"

    mysqldump -v --opt --events --routines --triggers --default-character-set=utf8mb4 -h "${c_host}" -u "${c_username}" --password="${c_password}" "${c_database}" > "${t_file}"

    return $?
}

##*

function f_import
{
    t_file="${c_database}.sql"

    mysql -h "${c_host}" -u "${c_username}" --password="${c_password}" "${c_database}" < "${t_file}"

    return $?
}


while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -e|--export|export)
            opt_e=0
            opt_i=-1
            shift
        ;;

        # -b|--backup|backup)
        #     opt_b=0
        #     shift
        # ;;
        --no-backup)
            opt_b=-1
            shift
        ;;
        -i|--import|import)
            opt_i=0
            opt_e=-1
            shift
        ;;

        *)    # Opción desconocida
            shift
        ;;
    esac
done

r=0
if [[ $opt_b -eq 0 ]]; then
    echo "Respaldando Base de Datos '${c_database}'..."

    f_backup
    r=$?

    echo
    if [[ $r -eq 0 ]]; then
        echo "  Respaldo creado: ${t_file}."
    else
        echo '  Error: No se pudo crear el respaldo'
        rm "${t_file}"
    fi
    echo
fi

if [[ $r -eq 0 ]]; then
    if [[ $opt_e -eq 0 ]]; then
        echo "Exportando Base de Datos '${c_database}'..."

        f_export
        r=$?

        echo
        if [[ $r -eq 0 ]]; then
            echo "  Exportación exitosa: '${t_file}'."
        else
            echo '  Error: No se pudo exportar la base de datos'
        fi
        echo
    fi
fi

if [[ $r -eq 0 ]]; then
    if [[ $opt_i -eq 0 ]]; then
        echo "Importando Base de Datos '${c_database}'..."

        f_import
        r=$?

        echo
        if [[ $r -eq 0 ]]; then
            echo "  Importanción exitosa desde '${t_file}'."
        else
            echo '  Error: No se pudo importar la base de datos'
        fi
        echo
    fi
fi

exit $r
