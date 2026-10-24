# RAW 지원 활성화
# 패치 전: [cbz r0, #0x157d66]
# 패치 후: [nop]
HEX_PATCH "$WORK_DIR/vendor/lib/libexynoscamera3.so" "f0b12649" "00bf2649"

# 패치 전: [tbz w8, #0, 0x59fd3c]
# 패치 후: [nop]
HEX_PATCH "$WORK_DIR/vendor/lib64/libexynoscamera3.so" "88020036c10d00b0" "1f2003d5c10d00b0"
