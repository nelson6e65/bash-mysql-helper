#!/bin/bash

# Realiza operaciones de importar, exportar y hacer respaldos de la base de datos.

declare SCRIPT_DIR=
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -z $DB_NAME ]]; then
    declare -x DB_NAME=
fi

if [[ -z $DB_USERNAME ]]; then
    declare -x DB_USERNAME=
fi

if [[ -z $DB_PASSWORD ]]; then
    declare -x DB_PASSWORD=
fi

declare file=

declare -i r=0
declare -i opt_b=0 # Respaldo (por defecto si no se pasa --no-backup)
declare -i opt_e=-1 # Exportar
declare -i opt_i=-1 # Importar



# Hace un respaldo del estado actual de la DB
function f_backup
{
    declare hora=

    hora=$(date +%Y-%m-%d_%H.%M.%S)

    file="${SCRIPT_DIR}/backups/${DB_NAME}_${hora}.sql.gz"

    mysqldump -v --opt --events --routines --triggers --default-character-set=utf8mb4 -u ${DB_USERNAME} --password=${DB_PASSWORD} ${DB_NAME} | gzip -c > "${file}"

    return $?
}

# Reemplaza el SQL actual
function f_export
{
    file="${SCRIPT_DIR}/${DB_NAME}.sql"

    mysqldump -v --opt --events --routines --triggers --default-character-set=utf8mb4 -u ${DB_USERNAME} --password=${DB_PASSWORD} ${DB_NAME} > "${file}"

    return $?
}

##*

function f_import
{
    file="${SCRIPT_DIR}/${DB_NAME}.sql"

    mysql -u ${DB_USERNAME} --password=${DB_PASSWORD} ${DB_NAME} < "${file}"

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
    echo "Respaldando Base de Datos '${DB_NAME}'..."

    f_backup
    r=$?

    echo
    if [[ $r -eq 0 ]]; then
        echo "  Respaldo creado: ${file}."
    else
        echo '  Error: No se pudo crear el respaldo'
        rm "${file}"
    fi
    echo
fi

if [[ $r -eq 0 ]]; then
    if [[ $opt_e -eq 0 ]]; then
        echo "Exportando Base de Datos '${DB_NAME}'..."

        f_export
        r=$?

        echo
        if [[ $r -eq 0 ]]; then
            echo "  Exportación exitosa: '${file}'."
        else
            echo '  Error: No se pudo exportar la base de datos'
        fi
        echo
    fi
fi

if [[ $r -eq 0 ]]; then
    if [[ $opt_i -eq 0 ]]; then
        echo "Importando Base de Datos '${DB_NAME}'..."

        f_import
        r=$?

        echo
        if [[ $r -eq 0 ]]; then
            echo "  Importanción exitosa desde '${file}'."
        else
            echo '  Error: No se pudo importar la base de datos'
        fi
        echo
    fi
fi

exit $r
