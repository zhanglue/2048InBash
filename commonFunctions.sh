#!/bin/bash

################################################################################
## Feature  : Common functions
## Author   : Zhang Lue 
## Date     : 2015.12.01
################################################################################

################################################################################
## CONTENTS
## 
##      _is_an_unsigned_int
##      _get_a_random_number
##
################################################################################

################################################################################
## IS AN UNSIGNED INT
################################################################################
_is_an_unsigned_int()
{
    local inputNum="$1"

    if [[ -z $inputNum ]]; then
        echo 0
        return
    fi

    if [[ ${inputNum} =~ ^[[:digit:]]+$ ]]; then
        echo 1
        return
    fi

    echo 0
}

################################################################################
## GET A RANDOM NUMBER
################################################################################
_get_a_random_number()
{
    local width="$1"
    if [[ -z "$width" ]] || 
        (( ! `_is_an_unsigned_int "${width}"` ))
    then
        width=5
    fi

    local result=$RANDOM
    while (( ${#result} < $width ))
    do
        result=${result}${RANDOM}
    done

    local randomWidth=$(( $RANDOM % $width + 1 ))

    result=${result:0:${randomWidth}}

    echo $result
}

