# 앱 압축 비활성화
# 원본 펌웨어에서 이 기능이 이미 비활성화되어 있을 수 있으므로 패치 적용 여부 확인
LOG "- /system/system/framework/services.jar에 \"앱 압축 비활성화\" 적용 중"
APPLY_PATCH "system" "system/framework/services.jar" \
    "$MODPATH/appcompactor/services.jar/0001-Disable-app-compaction.patch" | true \
    > /dev/null

# 설정에서 배터리 규제 정보 표시
# SEM_BATTERY_PROPERTY_IC_AUTHENTICATION_RESULT 지원 필요
if [ "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_BATTERY_SUPPORT_BSOH_SETTINGS")" ]; then
    SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_BATTERY_SUPPORT_BSOH_SETTINGS" --delete
fi
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_SETTINGS_ENABLE_EU_BATTERY_REGULATORY" "true"

# One UI 마이너 버전 항상 표시
SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali_classes4/com/samsung/android/settings/deviceinfo/softwareinfo/OneUIVersionPreferenceController.smali" "replace" \
    'isDeviceWithMicroVersion()Z' \
    'move-result p0' \
    'const/4 p0, 0x1'

# 디바이스 순정 모델 번호 표시
SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
    "smali_classes4/com/samsung/android/settings/deviceinfo/aboutphone/ModelNameGetter.smali" "replace" \
    'getModelName()Ljava/lang/String;' \
    'ro.product.model' \
    'ro.boot.em.model'

# FM 라디오 지역 제한 비활성화
if [[ "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_FMRADIO_CONFIG_CHIP_VENDOR")" != "0" ]]; then
    SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_FMRADIO_CONFIG_AVOID_REGION" --delete

    SMALI_PATCH "system" "system/framework/samsungfmradiolib.jar" \
        "smali/com/samsung/frameworks/fmradio/FMRadioImpl.smali" "return" \
        'isRadioNotSupportedInRegion()Z' \
        'false'
fi

# Perfetto 추적 비활성화
if [ -f "$WORK_DIR/system/system/etc/init/perfetto.rc" ]; then
    sed -i \
        -e 's/^\([[:space:]]*\)setprop persist\.traced\.enable 1$/\1# setprop persist.traced.enable 1/g' \
        -e 's/^\([[:space:]]*\)start traced$/\1# start traced/g' \
        -e 's/^\([[:space:]]*\)start traced_relay$/\1# start traced_relay/g' \
        -e 's/^\([[:space:]]*\)start traced_probes$/\1# start traced_probes/g' \
        -e 's/^\([[:space:]]*\)wait_for_prop sys\.trace\.traced_started 1$/\1# wait_for_prop sys.trace.traced_started 1/g' \
        "$WORK_DIR/system/system/etc/init/perfetto.rc"
    SET_PROP_IF_DIFF "system" "persist.traced.enable" "0"
fi

# 로그 비활성화
if ! $DEBUG; then
    SET_PROP "system" "logcat.live" "disable"
    SET_PROP "system" "profiler.force_disable_err_rpt" "1"
    SET_PROP "system" "profiler.force_disable_ulog" "1"
    SET_PROP "system" "ro.kernel.checkjni" "0"
    SET_PROP "system" "ro.kernel.android.checkjni" "0"
    SET_PROP "system" "persist.android.strictmode" "0"
fi

# ROM 프롭 지정
VALUE="$(GET_PROP "$WORK_DIR/system/system/build.prop" "ro.build.display.id")"
SET_PROP "system" "ro.build.display.id" "ZenithROM $ROM_VERSION for $TARGET_CODENAME ($VALUE)"
SET_PROP "system" "ro.zenith.version" "$ROM_VERSION"
EVAL "echo \"ro.zenith.version u:object_r:build_prop:s0 exact string\" >> \"$WORK_DIR/system/system/etc/selinux/plat_property_contexts\""
SET_PROP "system" "ro.zenith.device" "$TARGET_CODENAME"
EVAL "echo \"ro.zenith.device u:object_r:build_prop:s0 exact string\" >> \"$WORK_DIR/system/system/etc/selinux/plat_property_contexts\""

# build.prop 트윅
SET_PROP_IF_DIFF "vendor" "ro.incremental.enable" "yes"
SET_PROP_IF_DIFF "vendor" "ro.apk_verity.mode" "2"
SET_PROP_IF_DIFF "system" "ro.config.hw_quickpoweron" "true"
SET_PROP_IF_DIFF "system" "persist.device_config.activity_manager_native_boot.use_freezer" "true"
SET_PROP_IF_DIFF "system" "persist.device_config.runtime_native_boot.iorap_perfetto_enable" "true"
SET_PROP_IF_DIFF "system" "persist.sys.fuse.passthrough.enable" "true"
SET_PROP_IF_DIFF "system" "persist.sys.shutdown.mode" "hibernate"