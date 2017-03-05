#!/bin/bash

################################################################################
## Feature  : The common functions need by other [.sh]s
## Author   : Zhang Lue 
## Date     : 2015.06.29
################################################################################

################################################################################
## USAGE: 
##      
##      Add the following line to the top of the .sh you need.
##      . .../commFunc.sh
################################################################################

################################################################################
## CONTENTS:
##
##  BASE:
##      _hide_input_cursor
##      _show_input_cursor
##      _get_term_row_num
##      _get_term_col_num
##      _echo_error
##      _echo_warning
##      _echo_usage
##      _get_script_path
##
##  STRING:
##      _is_legal_string
##      _delete_prefix
##      _delete_postfix
##      _complete_string_with
##
##  NUMERIC: 
##      _is_unsigned_int
##      _is_signed_int
##      _is_double
##      _get_a_random_number
##  
##  VARIABLES: 
##      END_S BLD_S DRK_S UDL_S TWK_S RVT_S FAD_S 
##      HID_S SHO_S
##      BLK_F RED_F GRN_F YEL_F BLU_F PNK_F SKY_F WHT_F
##      BLK_B RED_B GRN_B YEL_B BLU_B PNK_B SKY_B WHT_B
##
################################################################################

################################################################################
## BASE
################################################################################

############################################################
## DISPLAY STYLE
############################################################
export END_S="\033[0m"
export BLD_S="\033[1m"
export DRK_S="\033[2m"
export UDL_S="\033[4m"
export TWK_S="\033[5m"
export RVT_S="\033[7m"
export FAD_S="\033[8m"
export HID_S="\033[?25l"
export SHO_S="\033[?25h"
export BLK_F="\033[30m"
export RED_F="\033[31m"
export GRN_F="\033[32m"
export YEL_F="\033[33m"
export BLU_F="\033[34m"
export PNK_F="\033[35m"
export SKY_F="\033[36m"
export WHT_F="\033[37m"
export BLK_B="\033[40m"
export RED_B="\033[41m"
export GRN_B="\033[42m"
export YEL_B="\033[43m"
export BLU_B="\033[44m"
export PNK_B="\033[45m"
export SKY_B="\033[46m"
export WHT_B="\033[47m"

_hide_input_cursor()
{
    echo -ne "${HID_S}"
}

_show_input_cursor()
{
    echo -ne "${SHO_S}"
}

_get_term_row_num()
{
    tput lines
}

_get_term_col_num()
{
    tput cols
}

_echo_error()
{
    echo -e "${RED_B}ERROR:${END_S}"
}

_echo_warning()
{
    echo -e "${YEL_B}WARNING:${END_S}"
}

_echo_usage()
{
    echo -e "${BLK_F}${SKY_B}USAGE:${END_S}"
}

############################################################
## GET SCRIPT NAME
############################################################
_get_script_name()
{
    /usr/sbin/lsof +p $$ | tail -n 1 | cut -d ' ' -f 1
}

############################################################
## GET SCRIPT PATH
############################################################
_get_script_path()
{
    local scriptName=`_get_script_name`
    local fullLocation=`/usr/sbin/lsof +p $$ | \grep -o "/.*$scriptName$"`
    dirname $fullLocation
}

################################################################################
## STRING
################################################################################

############################################################
## IS LEGAL STRING
############################################################
_is_legal_string()
{
    while (( $# ))
    do
        if [[ ! "$1" =~ "^[_[:alnum:]]+$" ]]; then
            echo 0
            return
        fi
        shift
    done

    echo 1
}

############################################################
## DELETE PREFIX
############################################################
_delete_prefix()
{
    local orgStr="$1"
    local prefix="$2"

    local lenStr=${#orgStr}
    local lenPrefix=${#prefix}

    echo ${orgStr:$lenPrefix:$lenStr}
}

############################################################
## DELETE POSTFIX
############################################################
_delete_postfix()
{
    local orgStr="$1"
    local postfix="$2"
    local lenResult=$(( ${#orgStr} - ${#postfix} ))

    echo ${orgStr:0:$lenResult}
}

############################################################
## COMPLETE STRING
############################################################
_complete_string_with()
{
    local result="$1"
    local strLen="$2"
    local comChar="$3"
    
    local orgLen=${#result}
    local comCharLen=${#comChar}

    if (( $strLen < $orgLen )); then
        echo $result 
    fi

    local remainNum=$(( (strLen - orgLen ) % comCharLen ))
    (( $remainNum )) && result="${comChar:0:$remainNum}${result}"

    local reqNum=$(( (strLen - orgLen ) / comCharLen ))
    while (( $reqNum ))
    do
        result="${comChar}${result}"
        reqNum=$(( $reqNum - 1 ))
    done

    echo $result
}


################################################################################
## NUMBERIC
################################################################################

############################################################
## IS UNSIGNED INT
############################################################
_is_unsigned_int()
{
    if [[ -z $@ ]]; then
        echo 0
        return
    fi

    while (( $# ))
    do
        if [[ ! "$1" =~ ^[[:digit:]]*$ ]]; then
            echo 0
            return
        fi
        shift
    done
    echo 1
}

############################################################
## IS SIGNED INT
############################################################
_is_signed_int()
{
    if [[ -z $@ ]]; then
        echo 0
        return
    fi

    while (( $# ))
    do
        if [[ ! "$1" =~ ^[+-]?[[:digit:]]*$ ]]; then
            echo 0
            return
        fi
        shift
    done
    echo 1
}

############################################################
## IS DOUBLE
############################################################
_is_double()
{
    if [[ -z $@ ]]; then
        echo 0
        return
    fi

    while (( $# ))
    do
        if [[ ! "$1" =~ ^[+-]?[[:digit:]]+\.[[:digit:]]*$ ]]; then
            echo 0
            return
        fi
        shift
    done
    echo 1
}

############################################################
## GET A RANDOM NUMBER
############################################################
_get_a_random_number()
{
    local length=5
    if (( `_is_signed_int $1` )); then
        length="$1"
    fi

    local result=$RANDOM

    while (( ${#result} < $length ))
    do
        result=${result}${RANDOM}
    done

    if (( ${#result} > $length )); then
        result=${result:0:$length}
    fi

    echo $result
}

