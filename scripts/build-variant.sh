#!/usr/bin/env bash
# Build one Kujang-Beta variant and update the live Telegram message.
# Usage: build-variant.sh NONKSU | KSU
set -euo pipefail

VARIANT="$1"
KEY="$VARIANT"

bash scripts/tg-live.sh set "$KEY" "🔄 Kernel"

rm -rf out

export PATH="$CLANG_PATH/bin:$GCC64_PATH/bin:$GCC32_PATH/bin:$PATH"
export KBUILD_BUILD_USER=Kujang
export KBUILD_BUILD_HOST=Beta
export KBUILD_COMPILER_STRING="$CLANG_PATH/bin/clang"
export CFLAGS_EXTRA="-DBUILD_DATE=$BUILD_DATE"

make O=out ARCH=arm64 vendor/sweet_defconfig
make -j"$(nproc --all)" O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 CC=clang LD=ld.lld \
  CLANG_TRIPLE=aarch64-linux-gnu- \
  CROSS_COMPILE="$GCC64_PATH/bin/aarch64-elf-" \
  CROSS_COMPILE_ARM32="$GCC32_PATH/bin/arm-eabi-"

cp out/.config "out/sweet_defconfig-${VARIANT}.txt"

bash scripts/tg-live.sh set "$KEY" "🔄 DTBO 90Hz"

cp out/arch/arm64/boot/dtb.img "$RUNNER_TEMP/dtb-stock-${VARIANT}.img"
cp out/arch/arm64/boot/dtbo.img "$RUNNER_TEMP/dtbo-stock-${VARIANT}.img"

git apply arch/arm64/boot/dts/qcom/90hz-dtbo.patch
rm -rf out/arch/arm64/boot/dts out/arch/arm64/boot/dtb.img out/arch/arm64/boot/dtbo.img

make -j"$(nproc --all)" O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 CC=clang LD=ld.lld \
  CLANG_TRIPLE=aarch64-linux-gnu- \
  CROSS_COMPILE="$GCC64_PATH/bin/aarch64-elf-" \
  CROSS_COMPILE_ARM32="$GCC32_PATH/bin/arm-eabi-"

cp out/arch/arm64/boot/dtbo.img "$RUNNER_TEMP/dtbo-90hz-${VARIANT}.img"
cp "$RUNNER_TEMP/dtb-stock-${VARIANT}.img" out/arch/arm64/boot/dtb.img
cp "$RUNNER_TEMP/dtbo-stock-${VARIANT}.img" out/arch/arm64/boot/dtbo.img
git apply -R arch/arm64/boot/dts/qcom/90hz-dtbo.patch

bash scripts/tg-live.sh set "$KEY" "🔄 Kemas ZIP"

[ -d AnyKernel3 ] || git clone --depth=1 -b Kujang-Kernel https://github.com/Kujang-Kernel/Anykernel3.git AnyKernel3
rm -f AnyKernel3/*.zip AnyKernel3/Image.gz AnyKernel3/dtb.img AnyKernel3/dtbo.img AnyKernel3/dtbo-90hz.img
cp out/arch/arm64/boot/{Image.gz,dtbo.img,dtb.img} AnyKernel3/
cp "$RUNNER_TEMP/dtbo-90hz-${VARIANT}.img" AnyKernel3/dtbo-90hz.img

ZIP="Kujang-Beta_${VARIANT}-${BRANCH}-${VERSION}.zip"
(cd AnyKernel3 && zip -r "../${ZIP}" . -x ".git/*")

bash scripts/tg-live.sh set "$KEY" "✅ Selesai"
