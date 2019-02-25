#!/bin/bash

declare HELP_DETAILS='
Note: It uses the .env file in the current directory to load DB name and credentials.

Commands available (<command>):
    i, import       Import DB from SQL.
    e, export       Export DB to SQL ({database}.sql).
    b, backup       Backup DB to gzip format ({database}-{timestamp}.sql.gz).
'

declare DESCRIPTION='Export, import and backup MySQL/MariaDB databases'


function f_version
{
    declare version
    declare -i r=0


    # Intentar usar git describe para una versión más exacta
    which git >/dev/null 2> /dev/null
    r=$? # ¿Git está instalado?
    if [[ $r -eq 0 ]]; then
        t="$(cd ${SCRIPT_DIR:?} && git describe 2> /dev/null)"
        r=$? # ¿Fue instalado como repositorio git y tiene nombres para describir?
    fi

    if [[ $r -eq 0 ]]; then
        version="$(cd ${SCRIPT_DIR} && git describe --abbrev=1)"
        version="${version%-g*}"
    else
        version=${1:-Undefined}
    fi

    echo " ${version}"
}


# DEFINE_SCRIPT_DIR
# ARG_POSITIONAL_SINGLE([command], [Command to perform.], )
# ARG_POSITIONAL_SINGLE([target-dir], [Target directory to search/place SQL.], [.])
# ARG_OPTIONAL_SINGLE([target], [t], [[DEPRECATED] Use «<target-dir>» instead.], )
# ARG_OPTIONAL_BOOLEAN([auto-backup], , [Run «backup» before «import».], [on])
# ARG_HELP([$DESCRIPTION\n], [$HELP_DETAILS])
#
# ARG_VERBOSE([v])
#
# ARGBASH_WRAP([version], [filename])
#
# ARGBASH_GO
# [ <-- needed because of Argbash


declare -x run_backup=off
declare -x run_export=off
declare -x run_import=off
declare -x c_target_directory='.'
declare -x _PRINT_HELP=yes

function f_setup_command
{
    declare -r action="$1"

    case $action in
        -e|--export)
            echo -e "\nWARNING: «${action}» option as <command> is DEPRECATED. Use «export» instead."
            run_export=on
        ;;

        e|export)
            run_export=on
        ;;


        -b|--backup)
            echo -e "\nWARNING: «${action}» option as <command> is DEPRECATED. Use «backup» instead."
            run_backup=on
        ;;

        b|backup)
            run_backup=on
        ;;


        -i|--import)
            echo -e "\nWARNING: «${action}» option as <command> is DEPRECATED. Use «import» instead."
            run_import=on
        ;;
        i|import)
            run_import=on
        ;;

        *)    # Acción desconocida
            echo
            die "ERROR: <command> not recognized: «${action}»".
        ;;
    esac

    # Configurar auto-backup sólo si es para importar
    if [[ $run_import == on && ${_arg_auto_backup:?} == on ]]; then
        run_backup=on
    fi
}


function f_setup_target
{
    declare dir="${_arg_target_dir:?}"
    declare -i r=$?

    if [[ ! -z ${_arg_target} ]]; then
        echo -e "\nWARNING: «--target» option is DEPRECATED. Use <target-dir> instead."

        if [[ ${_arg_target_dir} == '.' ]]; then
            dir="${_arg_target}"
        fi
    fi

    # Comprobar/normalizar directorio
    c_target_directory=$(realpath "${dir}")
    r=$?

    if [[ $r -ne 0 ]]; then
        die "ERROR: <target-dir> «${dir}». Ruta inválida." 3
    fi

    if [[ ! -d $c_target_directory ]]; then
        echo "Directorio «${c_target_directory}» no existe. Intentando crear..."
        mkdir -p "${c_target_directory}"
        r=$?

        if [[ $r -ne 0 ]]; then
            die "ERROR: <target-dir> «${dir}». No se pudo crear el directorio «${c_target_directory}»" 3
        fi
    fi
}

f_setup_command "${_arg_command:?}"

f_setup_target "${_arg_target_dir:?}"

echo "${_arg_target_dir}"
echo "${_arg_target}"

# ] <-- needed because of Argbash
