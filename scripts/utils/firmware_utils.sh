# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# [
source "$SRC_DIR/scripts/utils/build_utils.sh" || return 1
# ]

# COMPARE_SEC_BUILD_VERSION <문자열 1> <문자열 2>
# `문자열 1`의 빌드 번호가 `문자열 2`의 것보다 이전인지 여부를 반환합니다.
COMPARE_SEC_BUILD_VERSION()
{
    local STRING1="$1"
    local STRING2="$2"

    STRING1="$(cut -d "/" -f 1 -s <<< "$STRING1")"
    STRING2="$(cut -d "/" -f 1 -s <<< "$STRING2")"

    # 삼성의 Android OS 빌드 버전 형식은 아래와 같습니다. (ex: S901NKSS9GZH3):
    # - S901N: 모델 번호
    # - KS: 지역 (KS = KOR_SINGLEX)
    # - S: 펌웨어 유형 (U = 메이저 업데이트, S = 보안 업데이트)
    # - 9: 롤백 보호 비트
    # - G: One UI 버전 (G = 7번째 One UI 업데이트)
    # - Z: 연도 (Z = 2026)
    # - H: 개월 (H = 8월)
    # - 3: 증분 버전
    local STRING1_MAJOR="${STRING1:${#STRING1}-4:1}"
    local STRING1_YEAR="${STRING1:${#STRING1}-3:1}"
    local STRING1_MONTH="${STRING1:${#STRING1}-2:1}"
    local STRING1_INCREMENTAL="${STRING1:${#STRING1}-1:1}"

    local STRING2_MAJOR="${STRING2:${#STRING2}-4:1}"
    local STRING2_YEAR="${STRING2:${#STRING2}-3:1}"
    local STRING2_MONTH="${STRING2:${#STRING2}-2:1}"
    local STRING2_INCREMENTAL="${STRING2:${#STRING2}-1:1}"

    [[ "$STRING1_MAJOR" > "$STRING2_MAJOR" ]] && return 0
    [[ "$STRING1_MAJOR" < "$STRING2_MAJOR" ]] && return 1
    [[ "$STRING1_YEAR" > "$STRING2_YEAR" ]] && return 0
    [[ "$STRING1_YEAR" < "$STRING2_YEAR" ]] && return 1
    [[ "$STRING1_MONTH" > "$STRING2_MONTH" ]] && return 0
    [[ "$STRING1_MONTH" < "$STRING2_MONTH" ]] && return 1
    [[ "$STRING1_INCREMENTAL" > "$STRING2_INCREMENTAL" ]] && return 0
    [[ "$STRING1_INCREMENTAL" < "$STRING2_INCREMENTAL" ]] && return 1

    return 0
}

# EXTRACT_FILE_FROM_TAR <tar> <파일>
# 지정된 tar 파일에서 지정된 파일을 추출합니다.
EXTRACT_FILE_FROM_TAR() {
    _CHECK_NON_EMPTY_PARAM "MODEL" "$MODEL" || return 1
    _CHECK_NON_EMPTY_PARAM "CSC" "$CSC" || return 1
    _CHECK_NON_EMPTY_PARAM "TAR" "$1" || return 1
    _CHECK_NON_EMPTY_PARAM "FILE" "$2" || return 1

    local TAR="$1"
    local FILE="$2"

    if [ ! -f "$TAR" ]; then
        LOGE "파일이 존재하지 않습니다: ${TAR//$SRC_DIR\//}"
        return 1
    fi

    [ -f "$FW_DIR/${MODEL}_${CSC}/$FILE" ] && rm -rf "$FW_DIR/${MODEL}_${CSC}/$FILE"
    [ -f "$FW_DIR/${MODEL}_${CSC}/$FILE.ext4" ] && rm -rf "$FW_DIR/${MODEL}_${CSC}/$FILE.ext4"
    [ -f "$FW_DIR/${MODEL}_${CSC}/$FILE.lz4" ] && rm -rf "$FW_DIR/${MODEL}_${CSC}/$FILE.lz4"

    if FILE_EXISTS_IN_TAR "$TAR" "$FILE"; then
        LOG "- $FILE 추출 중..."
        EVAL "tar xf \"$TAR\" -C \"$FW_DIR/${MODEL}_${CSC}\" \"$FILE\"" || return 1
    elif FILE_EXISTS_IN_TAR "$TAR" "$FILE.ext4"; then
        LOG "- $FILE.ext4 추출 중..."
        EVAL "tar xf \"$TAR\" -C \"$FW_DIR/${MODEL}_${CSC}\" \"$FILE.ext4\"" || return 1
        EVAL "mv -f \"$FW_DIR/${MODEL}_${CSC}/$FILE.ext4\" \"$FW_DIR/${MODEL}_${CSC}/$FILE\"" || return 1
    elif FILE_EXISTS_IN_TAR "$TAR" "$FILE.lz4"; then
        LOG "- $FILE.lz4 추출 중..."
        EVAL "tar xf \"$TAR\" -C \"$FW_DIR/${MODEL}_${CSC}\" \"$FILE.lz4\"" || return 1
        LOG "- $FILE.lz4 압축 해제 중..."
        EVAL "lz4 -d --rm \"$FW_DIR/${MODEL}_${CSC}/$FILE.lz4\" \"$FW_DIR/${MODEL}_${CSC}/$FILE\"" || return 1
    fi

    return 0
}

# FILE_EXISTS_IN_TAR <tar> <파일>
# 제공된 tar 파일에서 지정된 파일이 존재하는지 여부를 반환합니다.
FILE_EXISTS_IN_TAR() {
    _CHECK_NON_EMPTY_PARAM "TAR" "$1" || return 1
    _CHECK_NON_EMPTY_PARAM "FILE" "$2" || return 1

    tar tf "$1" "$2" &> /dev/null
    return $?
}

# GET_LATEST_FIRMWARE <모델> <CSC>
# PDA/CSC/MODEM 형식에 따라 지정된 모델 및 CSC에 대한 사용 가능한 최신 펌웨어를 반환합니다.
GET_LATEST_FIRMWARE() {
    _CHECK_NON_EMPTY_PARAM "MODEL" "$1" || return 1
    _CHECK_NON_EMPTY_PARAM "CSC" "$2" || return 1

    curl -s --retry 3 -m 3 -A "samsung $1 SyncML DM Client" \
        "https://fota-cloud-dn.ospserver.net/firmware/$2/$1/version.xml" \
        | perl -nE 'say $1 if /<latest[^>]*>(.*?)<\/latest>/'
}

# PARSE_FIRMWARE_STRING <문자열>
# 지정된 문자열을 파싱하여 각 값을 MODEL, CSC, IMEI, SERIAL_NO 변수에 저장합니다.
# 지정되는 문자열은 다음과 같은 형식이여야 합니다: <MODEL>/<CSC>/<IMEI/SN>
# FUS에서 펌웨어를 다운로드하기 위해 지정된 모델과 일치하는 IMEI/SN 값이 필요합니다.
PARSE_FIRMWARE_STRING() {
    local STRING="$1"

    if [ ! "$STRING" ]; then
        LOGE "펌웨어 값은 비어있을 수 없습니다."
        return 1
    fi

    MODEL="$(cut -d "/" -f 1 -s <<< "$STRING")"
    if [ ! "$MODEL" ]; then
        LOGE "\"$STRING\"에 디바이스 모델 값이 존재하지 않습니다."
        return 1
    fi

    CSC="$(cut -d "/" -f 2 -s <<< "$STRING")"
    if [ ! "$CSC" ]; then
        LOGE "\"$STRING\"에 CSC 값이 존재하지 않습니다."
        return 1
    elif [[ "${#CSC}" != "3" ]]; then
        LOGE "\"$STRING\"에 CSC 값이 유효하지 않습니다: $CSC"
        return 1
    fi

    local THIRD
    THIRD="$(cut -d "/" -f 3 -s <<< "$STRING")"
    if [ ! "$THIRD" ]; then
        LOGE "\"$STRING\"에 IMEI/SN 값이 존재하지 않습니다."
        return 1
    elif [[ "${#THIRD}" == "11" ]] && [[ "$THIRD" == "R"* ]]; then
        # shellcheck disable=SC2034
        SERIAL_NO="$THIRD"
    elif [[ "${#THIRD}" -ge "8" ]] && [[ "${#THIRD}" -le "15" ]] && [[ "$THIRD" =~ ^[+-]?[0-9]+$ ]]; then
        # shellcheck disable=SC2034
        # 불완전한 IMEI를 허용합니다. samloader는 IMEI의 처음 8자리(TAC)만 입력받아도 전체 IMEI를 생성할 수 있습니다.
        IMEI="$THIRD"
    else
        LOGE "\"$STRING\"에 IMEI/SN 값이 유효하지 않습니다: $THIRD"
        return 1
    fi

    return 0
}

# UNSPARSE_IMAGE <파일> [출력]
# 지정된 파일의 sparse를 해제합니다. 선택적으로 다른 출력 경로를 지정할 수 있습니다.
UNSPARSE_IMAGE() {
    _CHECK_NON_EMPTY_PARAM "FILE" "$1" || exit 1

    local FILE="$1"
    local OUTPUT_PATH="$2"
    local REPLACE=false

    if [ ! -f "$FILE" ]; then
        LOGE "파일이 존재하지 않습니다: ${FILE//$SRC_DIR\//}"
        return 1
    fi

    if ! IS_SPARSE_IMAGE "$FILE"; then
        LOGW "Android sparse 이미지가 아닙니다: ${FILE//$SRC_DIR\//}"
        return 0
    fi

    if [ ! "$OUTPUT_PATH" ]; then
        OUTPUT_PATH="$(dirname "$FILE")/unsparse_$(basename "$FILE")"
        REPLACE=true
    fi

    LOG "- $(basename "$FILE") 스파스 해제 중..."

    EVAL "simg2img \"$FILE\" \"$OUTPUT_PATH\"" || return 1
    if $REPLACE; then
        mv -f "$OUTPUT_PATH" "$FILE"
    fi

    return 0
}
