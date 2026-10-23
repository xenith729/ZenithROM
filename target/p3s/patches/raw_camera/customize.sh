# RAW 지원 활성화
# 패치 전: [cbz r0, #0x157d66]
# 패치 후: [nop]
HEX_PATCH "$WORK_DIR/vendor/lib/libexynoscamera3.so" "e8b13a49" "00bf3a49"

# 패치 전: [tbz w8, #0, 0x59fd3c]
# 패치 후: [nop]
HEX_PATCH "$WORK_DIR/vendor/lib64/libexynoscamera3.so" "88020036a10d0090" "1f2003d5a10d0090"
