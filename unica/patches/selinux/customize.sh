# ZenithROM SELinux 엔트리 제거 목록
# ENTRIES 목록에 새로운 타입 항목을 추가하세요.
# 정확한 타입 항목을 추가하세요. 일반적인 패턴만 추가하지 마세요.
# (예: "fabriccrypto", "fabriccrypto_exec"를 추가하고 "fabriccrypto"만 추가하지 마세요.)
# 항목 끝에 API 버전을 추가하지 마세요.
# (예: "fabriccrypto"로 작성하고 "fabriccrypto_30_0"으로 작성하지 마세요.)
# 괄호나 명령문을 추가하지 마세요.
# (예: "fabriccrypto"로 작성하고 "expanttypeattribute ... (fabriccrypto)"로 작성하지 마세요.)
# 불필요한 타입을 추가하거나, 모든 기기에서 더 이상 필요하지 않은 경우가 아니라면 기존 항목을 제거하지 마세요.

# One UI 8.0 추가
ENTRIES+="
heatmap_default
heatmap_default_exec
"

DUPLICATES+="
init.svc.vendor.wvkprov_server_hal
"

# One UI 7.0 추가
ENTRIES+="
attiqi_app
attiqi_app_data_file
ker_app
kpp_app
kpp_data_file
"

# One UI 6.1.1 추가
ENTRIES+="
hal_dsms_default
hal_dsms_default_exec
proc_compaction_proactiveness
sbauth
sbauth_exec
"

# One UI 5.1.1 추가
ENTRIES+="
audiomirroring
audiomirroring_exec
audiomirroring_service
fabriccrypto
fabriccrypto_exec
fabriccrypto_data_file
hal_dsms_service
uwb_regulation_skip_prop
"

# [
GET_SYSTEM_EXT() {
    if $TARGET_OS_BUILD_SYSTEM_EXT_PARTITION; then
        echo "system_ext"
    else
        echo "system/system/system_ext"
    fi
}

CIL_NAME="$(head -n 1 "$WORK_DIR/vendor/etc/selinux/plat_sepolicy_vers.txt")"
PATCHED=false
VENDOR_API_LIST="$(find "$WORK_DIR/$(GET_SYSTEM_EXT)/etc/selinux/mapping" -type f -printf "%f\n" | \
                    sed '/.compat./d' | sed 's/.cil//' | sed 's/\./_/' | sort)"
# ]

for e in $ENTRIES; do
    if grep -q -F "($e)" "$WORK_DIR/$(GET_SYSTEM_EXT)/etc/selinux/mapping/$CIL_NAME.cil" || \
         grep -q -F "${e}_${CIL_NAME//./_}" "$WORK_DIR/$(GET_SYSTEM_EXT)/etc/selinux/mapping/$CIL_NAME.cil"; then
        # 문제가 되는 항목이 system_ext에 포함된 경우 제거해야 하는지 확인
        if ! grep -q -F "(type $e)" "$WORK_DIR/vendor/etc/selinux/plat_pub_versioned.cil"; then
            PATCHED=true
            # 타겟 디바이스에서 지원되지 않는 엔트리가 존재하는 경우
            LOG "- \"$e\" SELinux 엔트리가 지원되지 않습니다. 제거합니다."
            sed -i "/($e)/d" "$WORK_DIR/$(GET_SYSTEM_EXT)/etc/selinux/mapping/$CIL_NAME.cil"
            for a in $VENDOR_API_LIST; do
                sed -i "/${e}_${a}/d" "$WORK_DIR/$(GET_SYSTEM_EXT)/etc/selinux/mapping/$CIL_NAME.cil"
            done
            if grep -q "genfscon.*$e" "$WORK_DIR/$(GET_SYSTEM_EXT)/etc/selinux/system_ext_sepolicy.cil"; then
                sed -i "/genfscon.*$e/d" "$WORK_DIR/$(GET_SYSTEM_EXT)/etc/selinux/system_ext_sepolicy.cil"
            fi
            if grep -q "genfscon.*$e" "$WORK_DIR/system/system/etc/selinux/plat_sepolicy.cil"; then
                sed -i "/genfscon.*$e/d" "$WORK_DIR/system/system/etc/selinux/plat_sepolicy.cil"
            fi
        fi
    fi
done

for e in $DUPLICATES; do
    if grep -q "^$e.*" "$WORK_DIR/$(GET_SYSTEM_EXT)/etc/selinux/system_ext_property_contexts"; then
        # 문제가 되는 항목이 system_ext에 포함된 경우 제거해야 하는지 확인
        if grep -q "^$e.*" "$WORK_DIR/vendor/etc/selinux/vendor_property_contexts"; then
            PATCHED=true
            # 중복된 항목을 타겟 SELinux에서 발견한 경우
            LOG "- \"$e\" SELinux 엔트리가 중복되었습니다. 제거합니다."
            sed -i "s/^$e/#SEC_DUPLICATE: $e/g" "$WORK_DIR/vendor/etc/selinux/vendor_property_contexts"
        fi
    fi
done

if ! $PATCHED; then
    LOG "\033[0;33m! 아무 작업도 하지 않음\033[0m"
fi

unset ENTRIES DUPLICATES CIL_NAME PATCHED VENDOR_API_LIST
unset -f GET_SYSTEM_EXT
