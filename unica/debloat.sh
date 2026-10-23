# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# ZenithROM 블로트웨어 제거 목록
# - 해당 파일이 포함된 파티션의 항목에 추가하세요. (<PARTITION>_DEBLOAT+="")
# - 항목 앞에 파티션 이름을 추가하지 마세요. (예: "/system/dpolicy_system" 대신 "dpolicy_system")
# - 항목 앞에 슬래시(/)를 추가하지 마세요. (예: "/dpolicy_system" 대신 "dpolicy_system")

# AppUpdateCenter
SYSTEM_DEBLOAT+="
system/etc/permissions/privapp-permissions-com.samsung.android.app.updatecenter.xml
system/priv-app/AppUpdateCenter
"

# BCService
SYSTEM_DEBLOAT+="
system/etc/permissions/privapp-permissions-com.sec.bcservice.xml
system/priv-app/BCService
"

# CallLogBackup
SYSTEM_DEBLOAT+="
system/etc/permissions/privapp-permissions-com.samsung.android.calllogbackup.xml
system/priv-app/CallLogBackup
"

# ccinfo
SYSTEM_DEBLOAT+="
system/app/ccinfo
"

# ChromeCustomizations
SYSTEM_DEBLOAT+="
system/app/ChromeCustomizations
"

# EnhancedAttestationAgent
SYSTEM_DEBLOAT+="
system/priv-app/EnhancedAttestationAgent
"

# Fast
SYSTEM_DEBLOAT+="
system/app/Fast
"

# Gaming Hub
SYSTEM_DEBLOAT+="
system/etc/permissions/privapp-permissions-com.samsung.android.game.gamehome.xml
system/priv-app/GameHome
"
ADD_TO_WORK_DIR "pa2qxxx" "system" \
    "system/etc/permissions/signature-permissions-com.samsung.android.game.gamehome.xml" \
    0 0 644 "u:object_r:system_file:s0"

# HwModuleTest
SYSTEM_DEBLOAT+="
system/app/Cameralyzer
system/app/FactoryAirCommandManager
system/app/FactoryCameraFB
system/app/HMT
system/app/WlanTest
system/app/DRParser
system/app/BluetoothAgent
system/etc/permissions/privapp-permissions-com.samsung.android.providers.factory.xml
system/etc/permissions/privapp-permissions-com.sec.facatfunction.xml
system/etc/sysconfig/preinstalled-packages-com.sec.android.app.bluetoothagent.xml
system/priv-app/FacAtFunction
system/priv-app/FactoryTestProvider
system/priv-app/SEMFactoryApp
"

# Microsoft OneDrive
SYSTEM_DEBLOAT+="
system/etc/permissions/privapp-permissions-com.microsoft.skydrive.xml
system/priv-app/OneDrive_Samsung_v3
"

# My Galaxy
SYSTEM_DEBLOAT+="
system/etc/permissions/privapp-permissions-com.mygalaxy.service.xml
system/etc/sysconfig/preinstalled-packages-com.mygalaxy.service.xml
system/priv-app/MyGalaxyService
"

# Samsung Language Core
SYSTEM_DEBLOAT+="
system/etc/permissions/signature-permissions-com.samsung.android.offline.languagemodel.xml
system/priv-app/OfflineLanguageModel_stub
"

# Samsung Visit In
SYSTEM_DEBLOAT+="
system/etc/permissions/com.samsung.feature.ipsgeofence.xml
system/etc/permissions/privapp-permissions-com.samsung.android.ipsgeofence.xml
system/priv-app/IpsGeofence
"

# SamsungPositioning
SYSTEM_DEBLOAT+="
system/etc/sysconfig/preinstalled-packages-com.samsung.android.samsungpositioning.xml
system/etc/permissions/privapp-permissions-com.samsung.android.samsungpositioning.xml
system/priv-app/SamsungPositioning
"

# SettingsHelper
SYSTEM_DEBLOAT+="
system/etc/permissions/privapp-permissions-com.samsung.android.settingshelper.xml
system/etc/sysconfig/settingshelper.xml
system/priv-app/SHClient
"

# Smart Touch Call
SYSTEM_DEBLOAT+="
system/etc/default-permissions/default-permissions-com.samsung.android.visualars.xml
system/etc/permissions/privapp-permissions-com.samsung.android.visualars.xml
system/priv-app/SmartTouchCall
"

# Smart Tutor
SYSTEM_DEBLOAT+="
system/hidden/SmartTutor
"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_COMMON_CONFIG_SMARTTUTOR_PACKAGES_NAME" --delete
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_COMMON_CONFIG_SMARTTUTOR_PACKAGES_PATH" --delete

# SmartFPSAdjuster
[ "$TARGET_LCD_CONFIG_HFR_MODE" -lt "1" ] && SYSTEM_DEBLOAT+="
system/priv-app/IntelligentDynamicFpsService
"

# SVC Agent
SYSTEM_DEBLOAT+="
system/etc/permissions/privapp-permissions-com.samsung.android.svcagent.xml
system/priv-app/SVCAgent
"

# SVoiceIME
SYSTEM_DEBLOAT+="
system/priv-app/SVoiceIME
"
# TalkBack
SYSTEM_DEBLOAT+="
system/app/TalkBack
"

# Bluetooth Midi 서비스
SYSTEM_DEBLOAT+="
system/app/BluetoothMidiService
"

# Google 앱
PRODUCT_DEBLOAT+="
app/AssistantShell
app/BardShell
app/Chrome
app/DuoStub
app/Gmail2
app/Maps
app/YouTube
overlay/GmsConfigOverlaySearchSelector.apk
priv-app/Messages
priv-app/SearchSelector
"

SYSTEM_DEBLOAT+="
system/app/LiveTranscribe
system/app/PlayAutoInstallConfig
system/app/VoiceAccess
system/etc/sysconfig/feature-a11y-preload.xml
system/etc/sysconfig/feature-a11y-preload-voacc.xml
"

# IMS 로깅
SYSTEM_DEBLOAT+="
system/etc/sysconfig/preinstalled-packages-com.sec.imslogger
system/etc/permissions/privapp-permissions-com.sec.imslogger.xml
system/priv-app/ImsLogger
"

# Silent 로깅
SYSTEM_DEBLOAT+="
system/app/SilentLog
"

# SIM 앱 다이얼로그
SYSTEM_DEBLOAT+="
system/app/SimAppDialog
"

# Wi-Fi 가이드
SYSTEM_DEBLOAT+="
system/app/WifiGuider
"

# Windows와 연결
# 공간을 절약하기 위해 stub 앱으로 교체
SYSTEM_DEBLOAT+="
system/priv-app/YourPhone_P1_5
"
ADD_TO_WORK_DIR "gta9pxxx" "system" "system/priv-app/YourPhone_Stub/YourPhone_Stub.apk" 0 0 644 "u:object_r:system_file:s0"

# 리마인더
SYSTEM_DEBLOAT+="
system/app/SmartReminder
"

# 메타 앱
SYSTEM_DEBLOAT+="
system/app/FBAppManager_NS
system/etc/default-permissions/default-permissions-meta.xml
system/etc/permissions/privapp-permissions-meta.xml
system/etc/sysconfig/meta-hiddenapi-package-allowlist.xml
system/priv-app/FBInstaller_NS
system/priv-app/FBServices
"

# 보안 정책
SYSTEM_DEBLOAT+="
system/app/AASAservice
"

# 복구 모드 복원 스크립트
VENDOR_DEBLOAT+="
recovery-from-boot.p
bin/install-recovery.sh
etc/init/vendor_flash_recovery.rc
"

# 북마크 공급자
SYSTEM_DEBLOAT+="
system/app/BookmarkProvider
system/app/PartnerBookmarksProvider
"

# 사전 로딩된 앱
SYSTEM_DEBLOAT+="
system/preload
"
truncate -s 0 "$WORK_DIR/system/system/etc/vpl_apks_count_list.txt"

# eSIM
[[ "$TARGET_COMMON_SUPPORT_EMBEDDED_SIM" == "false" ]] && SYSTEM_DEBLOAT+="
system/etc/permissions/privapp-permissions-com.samsung.android.app.esimkeystring.xml
system/etc/permissions/privapp-permissions-com.samsung.euicc.xml
system/etc/sysconfig/preinstalled-packages-com.samsung.android.app.esimkeystring.xml
system/etc/sysconfig/preinstalled-packages-com.samsung.euicc.xml
system/priv-app/EsimKeyString
system/priv-app/EuiccService
"

# 삼성 AR 이모지
SYSTEM_DEBLOAT+="
system/etc/default-permissions/default-permissions-com.sec.android.mimage.avatarstickers.xml
system/etc/permissions/privapp-permissions-com.samsung.android.aremojieditor.xml
system/etc/permissions/privapp-permissions-com.sec.android.mimage.avatarstickers.xml
system/etc/permissions/signature-permissions-com.sec.android.mimage.avatarstickers.xml
system/priv-app/AREmojiEditor
system/priv-app/AvatarEmojiSticker
"

# 삼성 Defex 정책
SYSTEM_DEBLOAT+="
dpolicy_system
"
VENDOR_DEBLOAT+="
etc/dpolicy
"

# 삼성 PROCA 인증 DB
SYSTEM_DEBLOAT+="
system/etc/proca.db
"

# 삼성 SIM 잠금 해제
SYSTEM_DEBLOAT+="
system/bin/ssud
system/etc/init/ssu_$(GET_PROP "system" "ro.product.system.name").rc
system/etc/init/ssu.rc
system/etc/permissions/privapp-permissions-com.samsung.ssu.xml
system/etc/sysconfig/samsungsimunlock.xml
system/lib64/android.security.securekeygeneration-ndk.so
system/lib64/libssu_keystore2.so
system/priv-app/SsuService
"

# 삼성 녹스
SYSTEM_DEBLOAT+="
system/etc/permissions/privapp-permissions-com.skms.android.agent.xml
system/etc/sysconfig/preinstalled-packages-com.samsung.android.bbc.bbcagent.xml
system/etc/sysconfig/preinstalled-packages-com.samsung.android.mdm.xml
system/priv-app/knoxanalyticsagent
system/priv-app/SKMSAgent
system/app/BBCAgent
system/app/Rampart
system/app/MDMApp
system/app/UniversalMDMClient
"

# 삼성 뉴스
SYSTEM_DEBLOAT+="
system/app/MinusOnePage
"

# 삼성 데이터 분석
SYSTEM_DEBLOAT+="
system/app/DsmsAPK
system/etc/permissions/privapp-permissions-com.samsung.android.dqagent.xml
system/etc/permissions/privapp-permissions-com.sec.android.diagmonagent.xml
system/etc/permissions/privapp-permissions-com.sec.android.soagent.xml
system/etc/sysconfig/preinstalled-packages-com.sec.android.soagent.xml
system/priv-app/DeviceQualityAgent36
system/priv-app/DiagMonAgent95
system/priv-app/SOAgent76
"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CONTEXTSERVICE_ENABLE_SURVEY_MODE" --delete

# 삼성 월렛
SYSTEM_DEBLOAT+="
system/etc/init/digitalkey_init_ble_tss2.rc
system/etc/permissions/org.carconnectivity.android.digitalkey.rangingintent.xml
system/etc/permissions/org.carconnectivity.android.digitalkey.secureelement.xml
system/etc/permissions/privapp-permissions-com.samsung.android.carkey.xml
system/etc/permissions/privapp-permissions-com.samsung.android.dkey.xml
system/etc/permissions/privapp-permissions-com.samsung.android.spayfw.xml
system/etc/permissions/signature-permissions-com.samsung.android.spay.xml
system/etc/permissions/signature-permissions-com.samsung.android.spayfw.xml
system/etc/sysconfig/digitalkey.xml
system/etc/sysconfig/preinstalled-packages-com.samsung.android.dkey.xml
system/etc/sysconfig/preinstalled-packages-com.samsung.android.spayfw.xml
system/priv-app/DigitalKey
system/priv-app/PaymentFramework
system/priv-app/SamsungCarKeyFw
"
SYSTEM_EXT_DEBLOAT+="
framework/org.carconnectivity.android.digitalkey.rangingintent.jar
framework/org.carconnectivity.android.digitalkey.secureelement.jar
"

# 삼성 키즈
SYSTEM_DEBLOAT+="
system/app/KidsHome_Installer
"

# 삼성 패스
SYSTEM_DEBLOAT+="
system/app/SamsungPassAutofill_v1
system/etc/init/samsung_pass_authenticator_service.rc
system/etc/permissions/authfw.xml
system/etc/permissions/privapp-permissions-com.samsung.android.authfw.xml
system/etc/permissions/privapp-permissions-com.samsung.android.samsungpass.xml
system/etc/permissions/signature-permissions-com.samsung.android.samsungpass.xml
system/etc/permissions/signature-permissions-com.samsung.android.samsungpassautofill.xml
system/etc/sysconfig/samsungauthframework.xml
system/etc/sysconfig/samsungpassapp.xml
system/priv-app/AuthFramework
system/priv-app/SamsungPass
"

# 소프트웨어 업데이트
SYSTEM_DEBLOAT+="
system/etc/permissions/privapp-permissions-com.wssyncmldm.xml
system/priv-app/FotaAgent
"

# 시계
SYSTEM_DEBLOAT+="
system/app/ClockPackage
"

# 시스템 추적
SYSTEM_DEBLOAT+="
system/priv-app/Traceur
"

# 애플리케이션 추천
SYSTEM_DEBLOAT+="
system/app/MAPSAgent
"

# 언어 팩
SYSTEM_DEBLOAT+="$(find "$WORK_DIR/system" -type d -name "*TTSVoice*" | sed "s|$WORK_DIR/system/||g")"

# LED 커버 서비스
[ "$(GET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_FRAMEWORK_CONFIG_NFC_LED_COVER_LEVEL")" -lt "30" ] && SYSTEM_DEBLOAT+="
system/etc/permissions/privapp-permissions-com.sec.android.cover.ledcover.xml
system/priv-app/LedCoverService
"

# 연락처 위젯
SYSTEM_DEBLOAT+="
system/app/EasymodeContactsWidget81
"

# 자녀 보호
SYSTEM_DEBLOAT+="
system/app/ParentalCare
"

# 캐리어 앱
SYSTEM_DEBLOAT+="
system/app/CarrierDefaultApp
system/etc/permissions/privapp-permissions-com.samsung.android.cidmanager.xml
system/etc/permissions/privapp-permissions-com.samsung.android.app.omcagent.xml
system/etc/sysconfig/preinstalled-packages-com.samsung.android.cidmanager.xml
system/etc/sysconfig/preinstalled-packages-com.samsung.android.app.omcagent.xml
system/priv-app/CIDManager
system/priv-app/OMCAgent5
"

# 캘린더
SYSTEM_DEBLOAT+="
system/app/SamsungCalendar
"
