# ARM64 guest -> x86_64 host

This branch uses AArch64/ARM64 as the guest ISA and x86_64 as the host ISA.

## Upstream

- Project: DigitalisX64/platform_frameworks_libs_binary_translation
- Ref: `android-latest-release`
- Synchronized commit: `9e7f4407e0e32a582fe2a56f87492443ca55d6fa`
- Sync helper: `tools/sync-digitalis.sh`

The original snapshot was `6f199667f039ff5f33c1d80fe52b59300ec1b663`; the branch now includes the seven upstream commits that followed it.

## Runtime

The native bridge library is `libberberis_arm64.so`.

The Android ISA mapping is:

`ro.dalvik.vm.isa.arm64=x86_64`

The CI builds and executes `berberis_arm64_host_tests`; a build without the test binary is treated as a failure.
