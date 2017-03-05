#!/bin/bash

################################################################################
## Feature  : 2048 in BASH
## Author   : Zhang Lue 
## Date     : 2015.07.15
################################################################################

. commonFunctions.sh

################################################################################
## BASE
################################################################################

############################################################
## GLOBAL SETTING
############################################################
TEXT_MODE=0
ORG_BLOCK_NUM=4
PIXEL_WIDTH=2
PIXEL_HEIGHT=1
PIXEL_RATIO=1
BLOCK_RATIO=3
GAP_RATIO=1
BLANK_PIXEL_PATTERN="################################################"
SEPERATOR_LINE="################"
GAP_COLOR=${BLK_B}${BLK_F} 
BBOX_COLOR=${WHT_B}${WHT_F}
BLOCK_COLOR=([0]="${WHT_B}${WHT_F}" \
             [1]="${YEL_B}${YEL_F}" \
             [2]="${SKY_B}${SKY_F}" \
             [4]="${BLU_B}${BLU_F}" \
             [8]="${GRN_B}${GRN_F}" \
             [16]="${PNK_B}${PNK_F}" \
             [32]="${RED_B}${RED_F}" \
             [64]="${RED_B}${RED_F}" \
             [128]="${RED_B}${RED_F}" \
             [256]="${RED_B}${RED_F}" \
             [512]="${RED_B}${RED_F}" \
             [1024]="${RED_B}${RED_F}" \
             [2048]="${RED_B}${RED_F}" \
             [4096]="${RED_B}${RED_F}" \
             [8192]="${RED_B}${RED_F}" \
             [16384]="${RED_B}${RED_F}" \
             [32768]="${RED_B}${RED_F}")

############################################################
## USAGE
############################################################
_usage()
{
    echo "WHAT A FUCK!"
}

############################################################
## INITIALISE
############################################################
_initialise_base()
{
    blockStatusCur=( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 )
    #blockStatusCur=( 0 1 2 4 64 32 16 8 128 256 512 1024 16384 8192 4096 2048)
    blockStatusLst=( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 )
    curMaxNum=0
    score=0

    local i
    local j
    local tmpArrAAA=()
    local tmpArrBBB=()
    for (( i=0; i<4; ++i ))
    do
        tmpArrBBB=()
        for (( j=0; j<4; ++j ))
        do
            tmpArrBBB+=( $(( $i + $j * 4 )) )
        done
        tmpArrAAA+=( "${tmpArrBBB[*]}" )
    done
    TRAVERSE_ARRAY_UP=( "${tmpArrAAA[@]}" )

    tmpArrAAA=()
    for (( i=3; i>=0; --i ))
    do
        tmpArrBBB=()
        for (( j=3; j>=0; --j ))
        do
            tmpArrBBB+=( $(( $i + $j * 4 )) )
        done
        tmpArrAAA+=( "${tmpArrBBB[*]}" )

    done
    TRAVERSE_ARRAY_DOWN=( "${tmpArrAAA[@]}" )

    tmpArrAAA=()
    for (( i=0; i<4; ++i ))
    do
        tmpArrBBB=()
        for (( j=0; j<4; ++j ))
        do
            tmpArrBBB+=( $(( $i * 4 + $j )) )
        done
        tmpArrAAA+=( "${tmpArrBBB[*]}" )
    done
    TRAVERSE_ARRAY_LEFT=( "${tmpArrAAA[@]}" )

    tmpArrAAA=()
    for (( i=3; i>=0; --i ))
    do
        tmpArrBBB=()
        for (( j=3; j>=0; --j ))
        do
            tmpArrBBB+=( $(( $i * 4 + $j )) )
        done
        tmpArrAAA+=( "${tmpArrBBB[*]}" )
    done
    TRAVERSE_ARRAY_RIGHT=( "${tmpArrAAA[@]}" )

    processSeQ=()

    if (( $TEXT_MODE )); then
        REFRESH_DA="_show_current_block_status"
        REFRESH_DA_FORCE=""
        TERM_WIDTH_MIN=$(( ))
        TERM_HEIGHT_MIN=$(( ))
    else
        REFRESH_DA="_refresh_da"
        REFRESH_DA_FORCE="_refresh_da_force"
        TERM_WIDTH_MIN=$(( ))
        TERM_HEIGHT_MIN=$(( ))
    fi
}

_initialise_display()
{
    termWidth=`_get_term_col_num`
    termHeight=`_get_term_row_num`

    if (( $TEXT_MODE )); then
        SEPERATOR_LINE=`_complete_string_with "#" "$termWidth" "#"`
        return
    fi

    PIXEL_WIDTH=$(( $PIXEL_WIDTH * $PIXEL_RATIO ))
    PIXEL_HEIGHT=$(( $PIXEL_HEIGHT * $PIXEL_RATIO ))
    BLOCK_WIDTH=$(( $PIXEL_WIDTH * $BLOCK_RATIO ))
    BLOCK_HEIGHT=$(( $PIXEL_HEIGHT * $BLOCK_RATIO ))
    GAP_WIDTH=$(( $PIXEL_WIDTH * $GAP_RATIO ))
    GAP_HEIGHT=$(( $PIXEL_HEIGHT * $GAP_RATIO ))
    PITCH_WIDTH=$(( $BLOCK_WIDTH + $GAP_WIDTH * 2 ))
    PITCH_HEIGHT=$(( $BLOCK_HEIGHT + $GAP_HEIGHT * 2 ))
    DRAW_AREA_WIDTH=$(( $PITCH_WIDTH * 4 ))
    DRAW_AREA_HEIGHT=$(( $PITCH_HEIGHT * 4 ))
    COORDINATE_ORG_X=$(( ( `_get_term_col_num` - $DRAW_AREA_WIDTH ) / 2 ))
    COORDINATE_ORG_Y=$(( ( `_get_term_row_num` - $DRAW_AREA_HEIGHT ) / 2 ))

    LINE_PIXEL_BBOX_X="${BBOX_COLOR}`_get_blank_pixels $(( $DRAW_AREA_WIDTH + $PIXEL_WIDTH * 2))`${END_S}"
    LINE_PIXEL_BBOX_Y="${BBOX_COLOR}`_get_blank_pixels ${PIXEL_WIDTH}`${END_S}"
    LINE_PIXEL_GAP="${GAP_COLOR}`_get_blank_pixels $PITCH_WIDTH`${END_S}"

    linePixel="${GAP_COLOR}`_get_blank_pixels $GAP_WIDTH`"
    linePixel="${linePixel}${BLOCK_COLOR[0]}`_get_blank_pixels $BLOCK_WIDTH`"
    linePixel="${linePixel}${GAP_COLOR}`_get_blank_pixels $GAP_WIDTH`${END_S}"
    LINE_PIXEL_BLOCK=($linePixel)
    local i=1
    local linePixel=""
    while (( i < 33 ))
    do
        linePixel="${GAP_COLOR}`_get_blank_pixels $GAP_WIDTH`"
        linePixel="${linePixel}${BLOCK_COLOR[$i]}`_get_blank_pixels $BLOCK_WIDTH`"
        linePixel="${linePixel}${GAP_COLOR}`_get_blank_pixels $GAP_WIDTH`${END_S}"
        LINE_PIXEL_BLOCK+=( [$i]=$linePixel )
        i=$(( $i * 2 ))
    done

    i=64
    linePixel="${GAP_COLOR}`_get_blank_pixels $GAP_WIDTH`"
    linePixel="${linePixel}${BLOCK_COLOR[0]}_"
    linePixel="${linePixel}${BLOCK_COLOR[64]}`_get_blank_pixels $(( $BLOCK_WIDTH - 1))`"
    linePixel="${linePixel}${GAP_COLOR}`_get_blank_pixels $GAP_WIDTH`${END_S}"
    LINE_PIXEL_BLOCK+=( [$i]=$linePixel )

    i=128
    local j=1
    while (( i < 2049 ))
    do
        linePixel="${GAP_COLOR}`_get_blank_pixels $GAP_WIDTH`"
        linePixel="${linePixel}${BLOCK_COLOR[$j]}_"
        linePixel="${linePixel}${BLOCK_COLOR[$i]}`_get_blank_pixels $(( $BLOCK_WIDTH - 1))`"
        linePixel="${linePixel}${GAP_COLOR}`_get_blank_pixels $GAP_WIDTH`${END_S}"
        LINE_PIXEL_BLOCK+=( [$i]=$linePixel )
        i=$(( $i * 2 ))
        j=$(( $j * 2 ))
    done

    i=4096
    linePixel="${GAP_COLOR}`_get_blank_pixels $GAP_WIDTH`"
    linePixel="${linePixel}${BLOCK_COLOR[64]}_"
    linePixel="${linePixel}${BLOCK_COLOR[0]}_"
    linePixel="${linePixel}${BLOCK_COLOR[64]}`_get_blank_pixels $(( $BLOCK_WIDTH - 2))`"
    linePixel="${linePixel}${GAP_COLOR}`_get_blank_pixels $GAP_WIDTH`${END_S}"
    LINE_PIXEL_BLOCK+=( [$i]=$linePixel )

    i=8192
    j=1
    while (( i < 16385 ))
    do
        linePixel="${GAP_COLOR}`_get_blank_pixels $GAP_WIDTH`"
        linePixel="${linePixel}${BLOCK_COLOR[64]}_"
        linePixel="${linePixel}${BLOCK_COLOR[$j]}_"
        linePixel="${linePixel}${BLOCK_COLOR[64]}`_get_blank_pixels $(( $BLOCK_WIDTH - 2))`"
        linePixel="${linePixel}${GAP_COLOR}`_get_blank_pixels $GAP_WIDTH`${END_S}"
        LINE_PIXEL_BLOCK+=( [$i]=$linePixel )
        i=$(( $i * 2 ))
        j=$(( $j * 2 ))
    done
}

_initialise()
{
    _initialise_display
    _initialise_base
}

############################################################
## EXIT
############################################################
_exit()
{
    local exitNum=$1
    : ${exitNum:=0}

    _show_input_cursor
    tput clear

    exit $exitNum
}

################################################################################
## DISPLAY
################################################################################

############################################################
## CHECK DISPLAY ENV
############################################################
_check_display_env()
{
    if (( $termWidth != `_get_term_col_num` )) || 
       (( $termHeight != `_get_term_row_num` ))
    then
        echo 0
        return
    fi

    if (( $termWidth < $TERM_WIDTH_MIN )) ||
       (( $termHeight < $TERM_HEIGHT_MIN ))
    then
        echo 1
    fi
}

############################################################
## REFRESH DISPLAY ENV
############################################################
_refresh_display_env()
{
    if (( $termWidth != `_get_term_col_num` )) || 
       (( $termHeight != `_get_term_row_num` ))
    then
        termWidth=`_get_term_col_num`
        termHeight=`_get_term_row_num`

        if (( $TEXT_MODE )); then
            SEPERATOR_LINE=`_complete_string_with "#" "$termWidth" "#"`
        else
            if (( $COORDINATE_ORG_X != \
                $(( ( `_get_term_col_num` - $DRAW_AREA_WIDTH ) / 2 )) )) ||
                (( $COORDINATE_ORG_Y != \ 
                $(( ( `_get_term_row_num` - $DRAW_AREA_HEIGHT ) / 2 )) ))
            then
                _initialise_display
                $REFRESH_DA_FORCE
            fi
        fi
    fi
}

############################################################
## SHOW CURRENT BLOCK STATUS
############################################################
_show_current_block_status()
{
    echo ""
    echo "$SEPERATOR_LINE"
    local yyy=0
    local zzz=0
    local tmpAAA=""
    for (( yyy=0; yyy<4; ++yyy ))
    do
        tmpAAA=""
        for (( zzz=0; zzz<4; ++zzz ))
        do
            tmpAAA=$tmpAAA" ${blockStatusCur[$(( $zzz + $yyy * 4 ))]}"
        done
        echo $tmpAAA
    done
    echo "$SEPERATOR_LINE"
    echo ""
}

############################################################
## TRANS COORD GRAGH2DA
############################################################
_trans_coord_gragh2da()
{
    eval $1=$(( $COORDINATE_ORG_X + $[$1] * $PITCH_WIDTH ))
    eval $2=$(( $COORDINATE_ORG_Y + $[$2] * $PITCH_HEIGHT ))
}

############################################################
## GET BLANK PIXELS
############################################################
_get_blank_pixels()
{
    local requireLength=$1
    if [[ -z $requireLength ]]; then
        echo "_"
        return
    fi

    local result=""
    while (( $requireLength > ${#BLANK_PIXEL_PATTERN} ))
    do
        result=${result}${BLANK_PIXEL_PATTERN}
        requireLength=$(( $requireLength - ${#BLANK_PIXEL_PATTERN} ))
    done

    result=${result}${BLANK_PIXEL_PATTERN:0:$requireLength}
    echo $result
}

############################################################
## FILL A BLOCK
############################################################
_fill_a_block()
{
    local coordX=$1
    local coordY=$2
    local fillColor=$3
    : ${fillColor:=0}
    local i=0
    local linePixel

    coordX=$(( $COORDINATE_ORG_X + $coordX * $PITCH_WIDTH ))
    coordY=$(( $COORDINATE_ORG_Y + $coordY * $PITCH_HEIGHT ))

    i=0
    while (( i < $GAP_HEIGHT ))
    do
        tput cup $coordY $coordX
        echo -ne ${LINE_PIXEL_GAP}
        coordY=$(( $coordY + 1 ))
        i=$(( i + 1 ))
    done

    i=0
    while (( i < $BLOCK_HEIGHT ))
    do
        tput cup $coordY $coordX
        echo -ne ${LINE_PIXEL_BLOCK[$fillColor]}
        coordY=$(( $coordY + 1 ))
        i=$(( i + 1 ))
    done

    i=0
    while (( i < $GAP_HEIGHT ))
    do
        tput cup $coordY $coordX
        echo -ne ${LINE_PIXEL_GAP}
        coordY=$(( $coordY + 1 ))
        i=$(( i + 1 ))
    done
}

############################################################
## DRAW BBOX
############################################################
_draw_bbox()
{
    local coordX=$(( $COORDINATE_ORG_X - $PIXEL_WIDTH ))
    local coordY=$(( $COORDINATE_ORG_Y - $PIXEL_HEIGHT ))

    local i=0
    while (( $i < $PIXEL_HEIGHT ))
    do
        tput cup $coordY $coordX
        echo -ne $LINE_PIXEL_BBOX_X
        coordY=$(( $coordY + 1 ))
        i=$(( i + 1 ))
    done

    i=0
    while (( i < $DRAW_AREA_HEIGHT ))
    do
        tput cup $coordY $coordX
        echo -ne $LINE_PIXEL_BBOX_Y
        tput cup $coordY $(( $coordX + $DRAW_AREA_WIDTH + $PIXEL_WIDTH ))
        echo -ne $LINE_PIXEL_BBOX_Y
        coordY=$(( $coordY + 1 ))
        i=$(( i + 1 ))
    done


    local i=0
    while (( $i < $PIXEL_HEIGHT ))
    do
        tput cup $coordY $coordX
        echo -ne $LINE_PIXEL_BBOX_X
        coordY=$(( $coordY + 1 ))
        i=$(( i + 1 ))
    done
}

############################################################
## REFERSH DA FORCE
############################################################
_refresh_da_force()
{
    local i

    tput clear
    _draw_bbox

    for (( i=0; i < 16; i++ ))
    do
        _fill_a_block $(( i % 4 )) $(( i / 4 )) ${blockStatusCur[$i]}
    done
}

############################################################
## REFERSH DA
############################################################
_refresh_da()
{
    local i
    local changedBlock=()
    for (( i=0; i < 16; i++ ))
    do
        if (( ${blockStatusCur[$i]} != ${blockStatusLst[$i]} )); then
            changedBlock+=( $i )
        fi
    done

    for (( i=0; i < ${#changedBlock[@]}; ++i ))
    do
        _fill_a_block \
            $(( ${changedBlock[$i]} % 4 )) \
            $(( ${changedBlock[$i]} / 4 )) \
            ${blockStatusCur[${changedBlock[$i]}]}
    done

    if (( ${#changedBlock[@]} )); then
        blockStatusLst=( ${blockStatusCur[@]} )
    fi
}

################################################################################
## PROCESS
################################################################################

############################################################
## GET READY
############################################################
_get_ready()
{
    _hide_input_cursor
    $REFRESH_DA_FORCE

    while (( $ORG_BLOCK_NUM ))
    do
        _generate_new_block
        ORG_BLOCK_NUM=$(( $ORG_BLOCK_NUM - 1 ))
    done
    $REFRESH_DA
}

############################################################
## GET BLANK BLOCK CNT
############################################################
_get_blank_block_cnt()
{
    local cnt=0
    local i=0
    while (( i < 16 ))
    do
        if (( ! ${blockStatusCur[$i]} )); then
            cnt=$(( $cnt + 1 ))
        fi
        i=$(( $i + 1 ))
    done

    echo $cnt
}

############################################################
## GET BLANK BLOCK INDEX OF
############################################################
_get_blank_block_index_of()
{
    local cnt=$1
    local index=0
    while (( $cnt ))
    do
        if (( ! ${blockStatusCur[$index]} )); then
            cnt=$(( $cnt - 1 ))
        fi

        index=$(( $index + 1 ))
    done

    while (( ${blockStatusCur[$index]} ))
    do
        index=$(( $index + 1 ))
    done

    echo $index
}

############################################################
## GENERATE NEW BLOCK
############################################################
_generate_new_block()
{
    local blankBlockCnt=`_get_blank_block_cnt`
    if (( ! $blankBlockCnt ));then 
        return
    fi
    local randomNum=$(( `_get_a_random_number 2` % $blankBlockCnt ))
    local newNum=$(( `_get_a_random_number 1` / 8 + 1 ))
    blockStatusCur[`_get_blank_block_index_of $randomNum`]=$newNum
}

############################################################
## READ ACTION
############################################################
_read_action()
{
    local inputKey=()
    read -d '' -t 1 -sn 1 inputKey
    if [[ -z $inputKey ]]; then
        curAction="KEEP"
        return
    fi

    case ${inputKey[0]} in
        A )
            curAction="PUSH"
            processSeQ=( "${TRAVERSE_ARRAY_UP[@]}" )
            ;;
        B )
            curAction="PUSH"
            processSeQ=( "${TRAVERSE_ARRAY_DOWN[@]}" )
            ;;
        C )
            curAction="PUSH"
            processSeQ=( "${TRAVERSE_ARRAY_RIGHT[@]}" )
            ;;
        D )
            curAction="PUSH"
            processSeQ=( "${TRAVERSE_ARRAY_LEFT[@]}" )
            ;;
        q )
            curAction="QUIT"
            ;;
        *)
            curAction="KEEP"
            ;;
    esac
}

############################################################
## PUSH BLOCKS
############################################################
_push_blocks()
{
    local i=""
    local j=0
    local singleSeQ=""
    local numSeQ=()
    local numSeQResult=()
    local curIndex=0
    local singleSuccessFlag=0
    local totalSuccessFlag=0

    for singleSeQ in "${processSeQ[@]}"
    do
        numSeQ=()
        singleSuccessFlag=0
        local hasZeroFlag=0
        for i in $singleSeQ
        do
            if (( ${blockStatusCur[$i]} )); then
                numSeQ+=( ${blockStatusCur[$i]} )
                if (( $hasZeroFlag )); then
                    singleSuccessFlag=1
                fi
            else
                hasZeroFlag=1
            fi
        done

        if (( ! ${#numSeQ[@]} )); then
            continue
        fi

        curIndex=0
        numSeQResult=()
        while (( $curIndex < ${#numSeQ[@]} ))
        do
            if (( $curIndex == $(( ${#numSeQ[@]} - 1 )) )); then
                numSeQResult+=( $(( ${numSeQ[$curIndex]} )) )
                break
            fi

            if (( ${numSeQ[$curIndex]} == ${numSeQ[$(( $curIndex + 1 ))]} ))
            then
                numSeQResult+=( $(( ${numSeQ[$curIndex]} * 2 )) )
                score=$(( $score + ${numSeQ[$curIndex]} * 2 ))
                singleSuccessFlag=1
                curIndex=$(( $curIndex + 2 ))
            else
                numSeQResult+=( $(( ${numSeQ[$curIndex]} )) )
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
            j=0
            for i in $singleSeQ
            do
                blockStatusCur[$i]=${numSeQResult[$j]}
                j=$(( $j + 1))
            done
        fi
    done

    eval $1=$totalSuccessFlag
}

############################################################
## IS ALIVE
############################################################
_no_way_else_to_go()
{
    local curScore=$score
    local testArray=( "${TRAVERSE_ARRAY_UP[@]}"     \
                      "${TRAVERSE_ARRAY_DOWN[@]}"   \
                      "${TRAVERSE_ARRAY_RIGHT[@]}"  \
                      "${TRAVERSE_ARRAY_LEFT[@]}" )

    local blockStatusTmp=( ${blockStatusCur[@]} )
    local stepResult=0
    local cnt=0
    for step in "${testArray[@]}"
    do
        cnt=$(( $cnt + 1 ))
        if (( $cnt % 4 )); then
            processSeQ+=( "$step" )
            continue
        fi

        blockStatusTmp=( ${blockStatusCur[@]} )
        _push_blocks setupResult
        blockStatusCur=( ${blockStatusTmp[@]} )
        score=$curScore

        if (( $setupResult )); then
            echo 0
            return
        fi
    done

    echo 1
}

################################################################################
## MAIN
################################################################################

while (( $# ))
do
    case $1 in 
        -t | --textmode )
            TEXT_MODE=1
            ;;
        -m | --magnify )
            shift
            if (( ! `_is_unsigned_int $1` )); then
                _usage
                _exit
            fi
            PIXEL_RATIO=$1
            ;;
        * )
            ;;
    esac
    shift
done

_initialise
_get_ready
while :
do
    _refresh_display_env
    _read_action
    case ${curAction} in
        "KEEP" )
            continue
            ;;
        "QUIT" )
            break
            ;;
        "PUSH" )
            stepResult=0
            _push_blocks stepResult

            if (( ! $stepResult )); then
                continue
            fi

            _generate_new_block
            $REFRESH_DA

            if (( `_no_way_else_to_go` )); then
                _exit
            fi
            ;;
    esac
done

_exit
