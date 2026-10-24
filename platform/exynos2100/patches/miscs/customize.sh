# 암호화
LOG "- 암호화 비활성화 중..."
LINE=$(sed -n "/^\/dev\/block\/by-name\/userdata/=" "$WORK_DIR/vendor/etc/fstab.exynos2100")
sed -i "${LINE}s/,fileencryption=aes-256-xts:aes-256-cts:v2//g" "$WORK_DIR/vendor/etc/fstab.exynos2100"

# ODE
sed -i -e "/ODE/d" -e "/keydata/d" -e "/keyrefuge/d" "$WORK_DIR/vendor/etc/fstab.exynos2100"

# DPI
LOG_STEP_IN "- 벤더 디스플레이 프롭 수정 중..."
if [ "$(GET_PROP "vendor" "ro.sf.lcd_density")" ]; then
    SET_PROP "vendor" "ro.sf.init.lcd_density" "$(GET_PROP "vendor" "ro.sf.lcd_density")"
else
    ABORT "벤더에 ro.sf.lcd_density 프롭이 존재하지 않습니다."
fi
LOG_STEP_OUT

# Codec2
EVAL "uniq \"$WORK_DIR/system/system/build.prop\" \"$WORK_DIR/system/system/tmp\" && mv -f \"$WORK_DIR/system/system/tmp\" \"$WORK_DIR/system/system/build.prop\""
LOG "- /system/system/build.prop에서 \"debug.codec2.stop_hal_before_surface\" 프롭에 대한 값을 \"1\"으로 추가하는 중..."
EVAL "sed -i \"/spatializer_enabled=true/a debug.codec2.stop_hal_before_surface=1\" \"$WORK_DIR/system/system/build.prop\""
EVAL "sed -i \"/stop_hal_before_surface/i ro.audio.spatializer_enabled=true\" \"$WORK_DIR/system/system/build.prop\""
EVAL "sed -i \"/PRODUCT_SYSTEM_DEFAULT_PROPERTIES/a ####################################\" \"$WORK_DIR/system/system/build.prop\""
