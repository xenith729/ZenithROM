# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# [
# shellcheck disable=SC1007,SC2164
# https://android.googlesource.com/platform/build/+/refs/tags/android-15.0.0_r1/envsetup.sh#18
_GET_SRC_DIR() {
    local TOPFILE="unica/configs/version.sh"
    if [ -n "$SRC_DIR" ] && [ -f "$SRC_DIR/$TOPFILE" ]; then
        # 다음과 같은 우회적 방식을 통해 SRC_DIR에서 심볼릭 링크를 확실히 제거합니다.
        (cd "$SRC_DIR"; PWD= /bin/pwd)
    else
        if [ -f "$TOPFILE" ]; then
            # 다음 우회 방식(아래에도 반복됨)은 심볼릭 링크 이름으로 조작된 가짜 디렉토리가 아니라, 진짜 디렉토리 이름이 기록되도록 보장합니다.
            PWD= /bin/pwd
        else
            local HERE="$PWD"
            local T=
            while [ \( ! \( -f "$TOPFILE" \) \) ] && [ \( "$PWD" != "/" \) ]; do
                \cd ..
                T="$(PWD= /bin/pwd -P)"
            done
            \cd "$HERE"
            if [ -f "$T/$TOPFILE" ]; then
                echo "$T"
            fi
        fi
    fi
}

_PRINT_USAGE() {
    echo "사용 예제: source buildenv.sh [--debug] <타겟>" >&2
    echo "사용 가능한 디바이스:" >&2
    printf '%s\n' "${TARGETS[@]}" >&2
}

# https://android.googlesource.com/platform/build/+/refs/tags/android-15.0.0_r1/envsetup.sh#806
croot() {
    if [ -d "$SRC_DIR" ]; then
        if [ "$1" ]; then
            cd "$SRC_DIR/$1"
        else
            cd "$SRC_DIR"
        fi
    else
        echo "트리의 최상위 디렉토리를 찾을 수 없습니다. SRC_DIR을 설정해 보세요."
        return 1
    fi
}

run_cmd() {
    local CMD="$1"

    if [ -x "$SRC_DIR/scripts/$CMD.sh" ]; then
        shift
        mkdir -p "$(dirname "$WORK_DIR")"
        (set -o pipefail; "$SRC_DIR/scripts/$CMD.sh" "$@" |& tee \
            >(sed -r -e "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g" -e "/#/d" > "$(dirname "$WORK_DIR")/$CMD-$(date +%Y%m%d_%H%M%S).log"))
        return $?
    else
        local CMDS=()
        while IFS= read -r f; do
            CMDS+=("$f")
        done < <(find "$SRC_DIR/scripts" -maxdepth 1 ! -type d -printf '%f\n' | sort | sed "s/\.sh//")

        if [ "$CMD" ]; then
            if [[ "$CMD" == "--help" ]] || [[ "$CMD" == "-h" ]]; then
                echo "사용 가능한 명령어:" >&2
                for c in "${CMDS[@]}"; do
                    echo -e '\n\033[1;37m'"$c:"'\033[0m'
                    "$SRC_DIR/scripts/$c.sh" --help
                done
                return 0
            else
                echo -e '\033[0;31m'"\"$CMD\"은(는) 유효한 명령어가 아닙니다."'\033[0m' >&2
            fi
        fi

        echo "사용 가능한 명령어:" >&2
        printf '%s\n' "${CMDS[@]}" >&2
        return 1
    fi
}

alias unica=run_cmd
# ]

SRC_DIR="$(_GET_SRC_DIR)"
if [ ! "$SRC_DIR" ]; then
    echo "트리의 최상위 디렉토리를 찾을 수 없습니다. 항상 트리의 루트에서 buildenv.sh를 실행하세요." >&2
    return 1
fi

unset -f _GET_SRC_DIR

export DEBUG=false
export SRC_DIR
export OUT_DIR="$SRC_DIR/out"
export ODIN_DIR="$OUT_DIR/odin"
export FW_DIR="$OUT_DIR/fw"
export TOOLS_DIR="$OUT_DIR/tools"
if [[ ":$PATH:" != *":$TOOLS_DIR/bin:"* ]]; then
    export PATH="$TOOLS_DIR/bin:$PATH"
fi

TARGETS=()
while IFS= read -r t; do
    TARGETS+=("$t")
done < <(find "$SRC_DIR/target" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)

while [[ "$1" == "-"* ]]; do
    if [[ "$1" == "--debug" ]]; then
        export DEBUG=true
    elif [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        _PRINT_USAGE
        return 0
    else
        echo "알 수 없는 옵션입니다: $1" >&2
        _PRINT_USAGE
        return 1
    fi
    shift
done

if [ "$#" -ne 1 ]; then
    echo "타겟이 지정되지 않았습니다. 아래의 사용 가능한 디바이스 중에서 선택해 주세요:"

    select SELECTED_TARGET in "${TARGETS[@]}"; do
        if [ -n "$SELECTED_TARGET" ]; then
            break
        else
            echo "잘못된 선택입니다. 다시 시도해 주세요."
        fi
    done
else
    SELECTED_TARGET="$1"
fi

if [ ! -d "$SRC_DIR/target/$SELECTED_TARGET" ]; then
    echo "\"$SELECTED_TARGET\"은(는) 유효한 디바이스가 아닙니다." >&2
    _PRINT_USAGE
    return 1
fi

unset -f _PRINT_USAGE

export APKTOOL_DIR="$OUT_DIR/target/$SELECTED_TARGET/apktool"
export WORK_DIR="$OUT_DIR/target/$SELECTED_TARGET/work_dir"
export TMP_DIR="$OUT_DIR/target/$SELECTED_TARGET/tmp"

mkdir -p "$OUT_DIR/target/$SELECTED_TARGET"
# shellcheck disable=SC2046
[ -f "$OUT_DIR/config.sh" ] && unset $(sed "/Automatically/d" "$OUT_DIR/config.sh" | cut -d "=" -f 1)
"$SRC_DIR/scripts/internal/gen_config_file.sh" "$SELECTED_TARGET" || return 1
set -o allexport; source "$OUT_DIR/config.sh"; set +o allexport

unset TARGETS SELECTED_TARGET

echo "=============================="
sed "/Automatically/d" "$OUT_DIR/config.sh"
echo "=============================="

return 0
