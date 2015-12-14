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
MATRIX_DEGREE=4
INITIAL_BLOCK_NUM=4
OUTPUT_SEPERATOR="########################################"

################################################################################
## INITIALISE
################################################################################
_initialise()
{
    local i=0
    local j=0
    local tmpArrAAA=()
    local tmpArrBBB=()

    tmpArrAAA=()
    for (( i=0; i<${MATRIX_DEGREE}; ++i ))
    do
        tmpArrBBB=()
        for (( j=0; j<${MATRIX_DEGREE}; ++j ))
        do 
            tmpArrBBB+=( $(( $i + $j * ${MATRIX_DEGREE} )) )
        done
        tmpArrAAA+=( "${tmpArrBBB[*]}" )
    done
    TRAVERSE_ARRAY_UP=( "${tmpArrAAA[@]}" )

    tmpArrAAA=()
    for (( i=$(( ${MATRIX_DEGREE} - 1 )); i>=0; --i ))
    do
        tmpArrBBB=()
        for (( j=$(( ${MATRIX_DEGREE} - 1 )); j>=0; --j ))
        do 
            tmpArrBBB+=( $(( $i + $j * ${MATRIX_DEGREE} )) )
        done
        tmpArrAAA+=( "${tmpArrBBB[*]}" )
    done
    TRAVERSE_ARRAY_DOWN=( "${tmpArrAAA[@]}" )

    tmpArrAAA=()
    for (( i=0; i<${MATRIX_DEGREE}; ++i ))
    do
        tmpArrBBB=()
        for (( j=0; j<${MATRIX_DEGREE}; ++j ))
        do 
            tmpArrBBB+=( $(( $i * ${MATRIX_DEGREE} + $j )) )
        done
        tmpArrAAA+=( "${tmpArrBBB[*]}" )
    done
    TRAVERSE_ARRAY_LEFT=( "${tmpArrAAA[@]}" )

    tmpArrAAA=()
    for (( i=$(( ${MATRIX_DEGREE} - 1 )); i>=0; --i ))
    do
        tmpArrBBB=()
        for (( j=$(( ${MATRIX_DEGREE} - 1 )); j>=0; --j ))
        do 
            tmpArrBBB+=( $(( $i * ${MATRIX_DEGREE} + $j )) )
        done
        tmpArrAAA+=( "${tmpArrBBB[*]}" )
    done
    TRAVERSE_ARRAY_RIGHT=( "${tmpArrAAA[@]}" )

    processSeQ=( )
    stepResult=0

    blockStatus=( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 )

    local tmp=$INITIAL_BLOCK_NUM
    while (( $tmp ))
    do
        _generate_new_block
        tmp=$(( $tmp - 1 ))
    done
}

################################################################################
## SHOW STATUS IN TEXT
################################################################################
_show_status_in_text()
{
    local i=0
    local j=0
    local rowString=""
    clear
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
    echo $OUTPUT_SEPERATOR
}

################################################################################
## READ ACTION
################################################################################
_read_action()
{
    local inputKey=""
    read -sn 1 -t 1 inputKey 
    if [[ -z $inputKey ]]; then
        curAction=KEEP
    fi

    case $inputKey in 
        W | w)
            curAction="PUSH"
            processSeQ=( "${TRAVERSE_ARRAY_UP[@]}" )
            ;;
        S | s)
            curAction="PUSH"
            processSeQ=( "${TRAVERSE_ARRAY_DOWN[@]}" )
            ;;
        A | a)
            curAction="PUSH"
            processSeQ=( "${TRAVERSE_ARRAY_LEFT[@]}" )
            ;;
        D | d)
            curAction="PUSH"
            processSeQ=( "${TRAVERSE_ARRAY_RIGHT[@]}" )
            ;;
        Q | q)
            curAction="QUIT"
            break
            ;;
        *)
            curAction="HEHE"
            ;;
    esac
}

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
        return
    fi
    local newBlockPositionWide=$(( `_get_a_random_number 2` % $blankBlocksCount ))
    local newBlockPositionNarrow=`_solve_position_at $newBlockPositionWide`
    blockStatus[$newBlockPositionNarrow]=$((`_get_a_random_number 1` % 2 + 1 ))
}

################################################################################
## PUSH BLOCKS
################################################################################
_push_blocks()
{
    local executeFlag=$1
    local numSeQ=()
    local numSeQResult=()
    local i=""
    local j=0
    local curIndex=0
    local hasZeroFlag=0
    local singleSuccessFlag=0
    local totalSuccessFlag=0

    for singleSeQ in "${processSeQ[@]}"
    do
        numSeQ=()
        singleSuccessFlag=0
        hasZeroFlag=0
        for i in $singleSeQ
        do
            if (( ${blockStatus[$i]} )); then
                numSeQ+=( ${blockStatus[$i]} )
                if (( $hasZeroFlag )); then
                    singleSuccessFlag=1
                fi
            else
                hasZeroFlag=1
            fi
        done

        curIndex=0
        numSeQResult=()
        while (( $curIndex < ${#numSeQ[@]} ))
        do
            if (( $curIndex == $(( ${#numSeQ[@]} - 1 )) )); then
                numSeQResult+=( $(( ${numSeQ[$curIndex]}     )) )
                break
            fi

            if (( ${numSeQ[$curIndex]} == ${numSeQ[$(( $curIndex + 1 ))]} )); then
                numSeQResult+=( $(( ${numSeQ[$curIndex]} * 2 )) )
                singleSuccessFlag=1
                curIndex=$(( $curIndex + 2 ))
            else
                numSeQResult+=( $(( ${numSeQ[$curIndex]}     )) )
                curIndex=$(( $curIndex + 1 ))
            fi
        done

        curIndex=${#numSeQResult[@]}
        while (( $curIndex < 4 ))
        do
            numSeQResult+=( 0 )
            curIndex=$(( $curIndex + 1 ))
        done

        if (( $singleSuccessFlag )); then
            totalSuccessFlag=1
            if (( $executeFlag )); then
                j=0
                for i in $singleSeQ
                do
                    blockStatus[$i]=${numSeQResult[$j]}
                    j=$(( $j + 1 ))
                done
            fi
        fi
    done

    eval $2=$totalSuccessFlag
}

################################################################################
## NO WAY ELSE TO GO
################################################################################
_no_way_else_to_go()
{
    if (( `_blank_blocks_count` )); then
        echo 0
        return
    fi

    local testArray=( "${TRAVERSE_ARRAY_UP[@]}"    \
                      "${TRAVERSE_ARRAY_DOWN[@]}"  \
                      "${TRAVERSE_ARRAY_LEFT[@]}"  \
                      "${TRAVERSE_ARRAY_RIGHT[@]}" )

    local tmpStepResult=0
    local step=""
    local cnt=0

    processSeQ=()

    for step in "${testArray[@]}"
    do
        cnt=$(( $cnt + 1 ))
        if (( $cnt % 4 )); then
            processSeQ+=( "$step" )
            continue
        fi

        _push_blocks 0 tmpStepResult

        if (( $tmpStepResult )); then
            echo 0
            return
        fi

        processSeQ=()
    done

    echo 1
}

################################################################################
## MAIN
################################################################################

_initialise
_show_status_in_text

while :
do
    _read_action
    _show_status_in_text

    case ${curAction} in
        "KEEP" )
            continue
            ;;
        "QUIT" )
            break
            ;;
        "PUSH" )
            _push_blocks 1 stepResult

            if (( ! $stepResult )); then
                continue
            fi

            _generate_new_block
            _show_status_in_text

            if (( `_no_way_else_to_go` )); then
                exit
            fi
            ;;
    esac
done

exit 0
