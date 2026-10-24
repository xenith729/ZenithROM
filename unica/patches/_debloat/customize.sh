# shellcheck disable=SC2016

# Dexpreopt
find "$WORK_DIR/product" -type d -name "oat" -print0 | xargs -0 -I "{}" -P "$(nproc)" \
    bash -c 'source "$SRC_DIR/scripts/utils/module_utils.sh"; DELETE_FROM_WORK_DIR "product" "${1//$WORK_DIR\/product\//}"' "bash" "{}"
find "$WORK_DIR/system" -type d -name "oat" -print0 | xargs -0 -I "{}" -P "$(nproc)" \
    bash -c 'source "$SRC_DIR/scripts/utils/module_utils.sh"; DELETE_FROM_WORK_DIR "system" "${1//$WORK_DIR\/system\//}"' "bash" "{}"
DELETE_FROM_WORK_DIR "system" "system/etc/boot-image.bprof"
DELETE_FROM_WORK_DIR "system" "system/etc/boot-image.prof"
DELETE_FROM_WORK_DIR "system" "system/framework/arm"
DELETE_FROM_WORK_DIR "system" "system/framework/arm64"
find "$WORK_DIR/system/system/framework" -type f -name "*.vdex" -print0 | xargs -0 -I "{}" -P "$(nproc)" \
    bash -c 'source "$SRC_DIR/scripts/utils/module_utils.sh"; DELETE_FROM_WORK_DIR "system" "${1//$WORK_DIR\/system\//}"' "bash" "{}"
if $TARGET_OS_BUILD_SYSTEM_EXT_PARTITION; then
    find "$WORK_DIR/system_ext" -type d -name "oat" -print0 | xargs -0 -I "{}" -P "$(nproc)" \
        bash -c 'source "$SRC_DIR/scripts/utils/module_utils.sh"; DELETE_FROM_WORK_DIR "system_ext" "${1//$WORK_DIR\/system_ext\//}"' "bash" "{}"
fi

# ROM & 디바이스 전용 블로트웨어 제거 목록
for file in \
    "$SRC_DIR/unica/debloat.sh" \
    "$SRC_DIR/platform/$TARGET_PLATFORM/debloat.sh" \
    "$SRC_DIR/taerget/$TARGET_CODENAME/debloat.sh"
do
    if [ -f "$file" ]; then
        source "$file"
    fi
done

# 블로트웨어 제거 목록 정리
ODM_DEBLOAT="$(sed '/^$/d' <<< "$ODM_DEBLOAT" | sort -u)"
PRODUCT_DEBLOAT="$(sed '/^$/d' <<< "$PRODUCT_DEBLOAT" | sort -u)"
SYSTEM_DEBLOAT="$(sed '/^$/d' <<< "$SYSTEM_DEBLOAT" | sort -u)"
SYSTEM_EXT_DEBLOAT="$(sed '/^$/d' <<< "$SYSTEM_EXT_DEBLOAT" | sort -u)"
VENDOR_DEBLOAT="$(sed '/^$/d' <<< "$VENDOR_DEBLOAT" | sort -u)"

# 파티션별 블로트웨어 제거
REMOVE_DEBLOAT() {
    local partition="$1"
    local entries="$2"

    [ -n "$entries" ] || return 0

    xargs -I "{}" -P "$(nproc)" \
        bash -c 'source "$SRC_DIR/scripts/utils/module_utils.sh"; DELETE_FROM_WORK_DIR "$1" "$2"' \
        bash "$partition" "{}" \
        <<< "$entries" 2>&1 |
        sed '/파일이 존재하지 않습니다/d'
}

REMOVE_DEBLOAT "odm"       "$ODM_DEBLOAT"
REMOVE_DEBLOAT "product"   "$PRODUCT_DEBLOAT"
REMOVE_DEBLOAT "system"    "$SYSTEM_DEBLOAT"
REMOVE_DEBLOAT "system_ext" "$SYSTEM_EXT_DEBLOAT"
REMOVE_DEBLOAT "vendor"    "$VENDOR_DEBLOAT"

unset ODM_DEBLOAT PRODUCT_DEBLOAT SYSTEM_DEBLOAT SYSTEM_EXT_DEBLOAT VENDOR_DEBLOAT REMOVE_DEBLOAT
