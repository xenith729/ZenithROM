# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# [
source "$SRC_DIR/scripts/utils/smali_utils.sh"
# ]

# ABORT <메세지>
# 빌드 프로세스를 중단합니다, 지정된 경우 로그 메세지를 출력합니다.
ABORT() {
    if [ "$1" ]; then
        LOGE "$1"
    fi
    return 1
}

# APPLY_PATCH <파티션> <apk/jar> <패치>
# 디코딩된 APK/JAR의 디렉토리에 unified diff 패치를 적용합니다.
APPLY_PATCH() {
    _CHECK_NON_EMPTY_PARAM "PARTITION" "$1" || return 1
    _CHECK_NON_EMPTY_PARAM "FILE" "$2" || return 1
    _CHECK_NON_EMPTY_PARAM "PATCH" "$3" || return 1

    local PARTITION="$1"
    local FILE="$2"
    local PATCH="$3"

    if ! IS_VALID_PARTITION_NAME "$PARTITION"; then
        LOGE "\"$PARTITION\" 은(는) 유효한 파티션 이름이 아닙니다."
        return 1
    fi

    if [ ! -f "$PATCH" ]; then
        LOGE "파일이 존재하지 않습니다: ${PATCH//$SRC_DIR\//}"
        return 1
    fi

    while [[ "${FILE:0:1}" == "/" ]]; do
        FILE="${FILE:1}"
    done

    DECODE_APK "$PARTITION" "$FILE" || return 1

    LOG "- "/$PARTITION/$FILE"에 \"$(grep "^Subject:" "$PATCH" | sed "s/.*PATCH] //")\" 적용 중..."
    EVAL "LC_ALL=C git apply --directory=\"$APKTOOL_DIR/$PARTITION/${FILE//system\//}\" --verbose --unsafe-paths \"$PATCH\"" || return 1
}

# DECODE_APK <파티션> <apk/jar>
# 'run_cmd apktool d <파티션> <apk/jar>'와 동일한 사용법을 가집니다.
DECODE_APK() {
    _CHECK_NON_EMPTY_PARAM "PARTITION" "$1" || return 1
    _CHECK_NON_EMPTY_PARAM "FILE" "$2" || return 1

    if [ ! -d "$APKTOOL_DIR/$1/${2//system\/}" ]; then
        "$SRC_DIR/scripts/apktool.sh" d "$1" "$2"
        return $?
    fi

    return 0
}

# GET_GALAXY_STORE_DOWNLOAD_URL "<패키지 이름/ID>"
# 삼성 서버에서 원하는 앱을 다운로드할 수 있는 URL을 반환합니다.
GET_GALAXY_STORE_DOWNLOAD_URL() {
    _CHECK_NON_EMPTY_PARAM "PACKAGE" "$1" || return 1

    local PACKAGE="$1"
    local DEVICES
    local OS
    local ONEUI
    local SYSTEMID
    local PROTOCOL

    # Galaxy S22 KOR_SINGLEX
    # Galaxy S25 Ultra KOR_SINGLEX
    DEVICES=("SM-S901N" "SM-S938N")

    OS="$(GET_PROP "system" "ro.build.version.sdk")"
    ONEUI="$(GET_PROP "system" "ro.build.version.oneui")"
    SYSTEMID="$(date "+%s")"

    if [ ! "$OS" ]; then
        # Android 16으로 설정
        OS="36"
    fi
    if [ ! "$ONEUI" ]; then
        # One UI 8.0으로 설정
        ONEUI="80000"
    fi

    PROTOCOL+="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>"
    PROTOCOL+="<SamsungProtocol networkType=\"0\" openApiVersion=\"$OS\" deviceModel=\"DEVICE\""
    PROTOCOL+=" mcc=\"262\" mnc=\"01\" csc=\"KOO\" version=\"7.7\" systemId=\"$SYSTEMID\""
    PROTOCOL+=" deviceFeature=\"locale=ko_KR||abi32=armeabi-v7a:armeabi||abi64=arm64-v8a||oneUiVersion=$ONEUI\">"
    PROTOCOL+="<request id=\"2303\" numParam=\"2\">"
    PROTOCOL+="<param name=\"stduk\">0</param>"
    PROTOCOL+="<param name=\"productID\">PRODUCTID</param>"
    PROTOCOL+="</request>"
    PROTOCOL+="</SamsungProtocol>"

    local OUT
    local REQUEST
    for i in "${DEVICES[@]}"; do
        if [[ "$PACKAGE" =~ ^[+-]?[0-9]+$ ]]; then
            OUT="$PACKAGE"
        else
            OUT="$(curl -L -s "https://vas.samsungapps.com/stub/stubUpdateCheck.as?appId=$PACKAGE&versionCode=0&deviceId=$i&mcc=262&mnc=01&csc=EUX&sdkVer=$OS&oneUiVersion=$ONEUI&systemId=$SYSTEMID")"
            OUT="$(grep -o -P "(?<=<productId>)[^<]+" <<< "$OUT")"
            if [ ! "$OUT" ]; then
                continue
            fi
        fi

        REQUEST="$PROTOCOL"
        REQUEST="${REQUEST//DEVICE/$i}"
        REQUEST="${REQUEST//PRODUCTID/$OUT}"

        OUT="$(curl -L -s "https://uk-odc.samsungapps.com/ods.as" -H "Content-Type: text/plain" -d "$REQUEST")"
        OUT="$(grep -o -P "(?<=<value name=\"downLoadURI\">)[^<]+" <<< "$OUT")"
        if [ "$OUT" ]; then
            echo "${OUT//amp;/}"
            return 0
        fi
    done

    LOGE "\"$PACKAGE\" 앱에 대한 다운로드 URI가 존재하지 않습니다."
    return 1
}

# GET_FLOATING_FEATURE_CONFIG "<파일>" "<구성>"
# 지정된 구성에 대한 값을 반환합니다. 파일은 생략할 수 있습니다.
GET_FLOATING_FEATURE_CONFIG() {
    local FILE
    if [ "$2" ]; then
        FILE="$1"
        shift
    else
        FILE="$WORK_DIR/system/system/etc/floating_feature.xml"
    fi

    _CHECK_NON_EMPTY_PARAM "CONFIG" "$1" || return 1

    local CONFIG="$1"

    if [ ! -f "$FILE" ]; then
        LOGE "파일이 존재하지 않습니다: ${FILE//$WORK_DIR/}"
        return 1
    fi

    grep -o -P "(?<=<$CONFIG>)[^<]+" "$FILE" 2> /dev/null || true
}

# HEX_PATCH "<파일>" "<기존 패턴>" "<새 패턴>"
# 지정된 Hex 패치를 파일에 적용합니다.
HEX_PATCH() {
    _CHECK_NON_EMPTY_PARAM "FILE" "$1" || return 1
    _CHECK_NON_EMPTY_PARAM "FROM" "$2" || return 1
    _CHECK_NON_EMPTY_PARAM "TO" "$3" || return 1

    local FILE="$1"
    local FROM="$2"
    local TO="$3"

    if [ ! -f "$FILE" ]; then
        LOGE "파일이 존재하지 않습니다: ${FILE//$WORK_DIR/}"
        return 1
    fi

    FROM="${FROM// /}"
    TO="${TO// /}"

    FROM="$(tr "[:upper:]" "[:lower:]" <<< "$FROM")"
    TO="$(tr "[:upper:]" "[:lower:]" <<< "$TO")"

    if ! xxd -p -c 0 "$FILE" | grep -q "$FROM"; then
        LOGE "${FILE//$WORK_DIR/}에 \"$FROM\"와 일치하는 값이 없습니다."
        return 1
    fi

    if [[ "$(echo -n "$FROM" | wc -c)" != "$(echo -n "$TO" | wc -c)" ]]; then
        LOGE "바이트 문자열의 길이는 같아야 합니다."
        return 1
    fi

    LOG "- ${FILE//$WORK_DIR/}에서 \"$FROM\"을 \"$TO\"로 패치하는 중..."
    xxd -p -c 0 "$FILE" | sed "s/$FROM/$TO/" | xxd -r -p > "$FILE.tmp"
    mv "$FILE.tmp" "$FILE"

    return 0
}

# SET_FLOATING_FEATURE_CONFIG "<구성>" "<값>"
# 지정된 구성에 대한 값을 교체합니다.
# "-d"  또는 "--delete"를 사용하여 값을 제거할 수 있습니다.
SET_FLOATING_FEATURE_CONFIG() {
    _CHECK_NON_EMPTY_PARAM "CONFIG" "$1" || return 1
    _CHECK_NON_EMPTY_PARAM "VALUE" "$2" || return 1

    local CONFIG="$1"
    local VALUE="$2"
    local FILE="$WORK_DIR/system/system/etc/floating_feature.xml"

    if [ ! -f "$FILE" ]; then
        LOGE "파일이 존재하지 않습니다: ${FILE//$WORK_DIR/}"
        return 1
    fi

    if grep -q "<$CONFIG>" "$FILE"; then
        if [[ "$VALUE" == "-d" ]] || [[ "$VALUE" == "--delete" ]]; then
            LOG "- /system/system/etc/floating_feature.xml에서 \"$CONFIG\" 구성 제거 중..."
            sed -i "/<$CONFIG>/d" "$FILE"
        else
            LOG "- /system/system/etc/floating_feature.xml에서 \"$CONFIG\" 구성을 \"$VALUE\" 값으로 교체하는 중..."
            sed -i "$(sed -n "/<${CONFIG}>/=" "$FILE") c\ \ \ \ <${CONFIG}>${VALUE}</${CONFIG}>" "$FILE"
        fi
    elif [[ "$VALUE" != "-d" ]] && [[ "$VALUE" != "--delete" ]]; then
        LOG "- /system/system/etc/floating_feature.xml에서 \"$CONFIG\" 구성을 \"$VALUE\" 값으로 추가하는 중..."
        sed -i "/<\/SecFloatingFeatureSet>/d" "$FILE"
        if ! grep -q "Added by ZenithROM custom script" "$FILE"; then
            echo "    <!-- Added by ZenithROM custom script -->" >> "$FILE"
        fi
        echo "    <${CONFIG}>${VALUE}</${CONFIG}>" >> "$FILE"
        echo "</SecFloatingFeatureSet>" >> "$FILE"
    fi

    return 0
}

# SET_PROP_IF_DIFF "<파티션>" "<프롭>" "<값>"
# 현재 값이 지정된 값과 일치하지 않는 경우 SET_PROP을 호출합니다. 파티션 이름은 생략될 수 없습니다.
SET_PROP_IF_DIFF() {
    _CHECK_NON_EMPTY_PARAM "PARTITION" "$1" || return 1
    _CHECK_NON_EMPTY_PARAM "PROP" "$2" || return 1
    _CHECK_NON_EMPTY_PARAM "EXPECTED" "$3" || return 1

    local PARTITION="$1"
    local PROP="$2"
    local EXPECTED="$3"

    if ! IS_VALID_PARTITION_NAME "$PARTITION"; then
        LOGE "\"$PARTITION\" 은(는) 유효한 파티션 이름이 아닙니다."
        return 1
    fi

    local CURRENT
    CURRENT="$(GET_PROP "$PARTITION" "$PROP")"
    [ -z "$CURRENT" ] || [ "$CURRENT" = "$EXPECTED" ] || SET_PROP "$PARTITION" "$PROP" "$EXPECTED"
}
