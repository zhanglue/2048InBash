#!/bin/bash

################################################################################
## Feature  : 2048 in bash
## Author   : Zhang Lue 
## Date     : 2015.11.18
################################################################################

. ./commonFunctions.sh

################################################################################
## CONST VARIABLES
################################################################################
INITIAL_BLOCK_NUM=4
OUTPUT_SEPERATOR="########################################"

################################################################################
## BLANK_BLOCKS_COUNT
################################################################################
_blank_blocks_count()
{
    local i=0
    local count=0
    for ((; i < 16; ++i ))
    do
        if (( ! ${blockStatus[$i]} )); then
            count=$(( ${count} + 1 ))
        fi
    done

    echo $count
}

################################################################################
## SOLVE POSITION AT
################################################################################
_solve_position_at()
{
    local blankCount=$1
    local i=0

    while (( $blankCount ))
    do
        if (( ! ${blockStatus[$i]} )); then
            blankCount=$(( $blankCount - 1 ))
        fi
        i=$(( $i + 1 ))
    done

    while (( $i < 16 )) && (( ${blockStatus[$i]} ))
    do
        i=$(( $i + 1 ))
    done

    echo $i
}

################################################################################
## GENERATE NEW BLOCK
################################################################################
_generate_new_block()
{
    local blankBlocksCount=`_blank_blocks_count`

    if (( ! $blankBlocksCount )); then
        echo ""
        echo "~YOU HAS ARRIVED THE END~"
        echo ""
        exit 0
    fi

    local newBlockPositionWide=$(( `_get_a_random_number 2` % $blankBlocksCount ))

    local newBlockPositionNarrow=`_solve_position_at $newBlockPositionWide`

    blockStatus[$newBlockPositionNarrow]=$((`_get_a_random_number 1` % 2 + 1 ))
}

################################################################################
## INITIALISE
################################################################################
_initialise()
{
    blockStatus=( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 )
    #blockStatus=( 0 1 1 1 1 0 1 0 0 1 1 1 1 1 1 0 )

    local i=0
    for ((; i < $INITIAL_BLOCK_NUM; ++i))
    do
        _generate_new_block
    done

}

################################################################################
## READ ACTION
################################################################################
_read_action()
{
    local input=""
    read -sn 1 -t 1 input 
    echo $input
}

################################################################################
## SHOW
################################################################################
_show()
{
    local i=0
    local j=0
    local rowString=""
    echo ""
    echo $OUTPUT_SEPERATOR
    for (( i=0; i < 4; ++i ))
    do
        rowString=""
        for (( j=0; j < 4; ++j ))
        do
            rowString="$rowString ${blockStatus[$(( $i * 4 + $j ))]}"
        done
        echo $rowString
    done
    case $curAction in 
        W | w)
            echo "UP"
            ;;
        S | s)
            echo "DOWN"
            ;;
        A | a)
            echo "LEFT"
            ;;
        D | d)
            echo "RIGHT"
            ;;
        Q | q)
            echo "QUIT"
            break
            ;;
        *)
            echo "HEHE"
            ;;
    esac
    echo $OUTPUT_SEPERATOR
}

################################################################################
## MAIN
################################################################################

_initialise

while :
do
    curAction=`_read_action`
    _show

    _generate_new_block
done
