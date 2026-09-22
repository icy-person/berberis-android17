# Development notes

This repository contains the Android 17 Berberis base plus an ARM64/AArch64 guest
translation backend targeting an x86_64 host.

## Build

Use the normal AOSP checkout and Soong. For the ARM64 guest backend:

```bash
source build/envsetup.sh
lunch sdk_phone64_x86_64_riscv64-trunk_staging-eng
export SOONG_CONFIG_berberis_translation_arch=arm64_to_x86_64
m libberberis_arm64 libberberis_heavy_optimizer_arm64 berberis_arm64_host_tests
```

Run the ARM64 host test binary after building it. CI intentionally fails if the
test binary is missing.

## Upstream synchronization

Use:

```bash
bash tools/sync-digitalis.sh
```

Do not replace the ARM64 tree with a blind copy. Preserve the RISC-V64 implementation
and resolve shared-file conflicts explicitly.

## Style

- Keep Blueprint lists sorted where practical.
- Keep ARM64-only changes under the existing ARM64-specific modules/guards.
- Run `git diff --check` before committing.
- Prefer focused commits so ARM64 regressions remain bisectable.
