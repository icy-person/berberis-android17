# ARM64 guest → x86_64 host

This branch contains the ARM64/AArch64 guest backend for Berberis, targeting an x86_64 Android host.

## Source synchronization

The ARM64 implementation is derived from:

- Repository: `https://github.com/DigitalisX64/platform_frameworks_libs_binary_translation`
- Current synchronized ref: `android-latest-release`
- Current synchronized commit: `9e7f4407e0e32a582fe2a56f87492443ca55d6fa`

The synchronized range includes the post-snapshot Digitalis fixes for:

- narrow integer/enum JNI results;
- AndroidHardwareBuffer Vulkan `pNext` preservation;
- guest linker path and `/proc/self/maps` coherence;
- ARM64 thread/TLS handling;
- current ARM64 tier-coverage data.

Run `tools/sync-digitalis.sh` before updating the pinned commit. The script refuses an unrelated history and refuses unresolved merge conflicts; it never silently replaces the RISC-V implementation.

## Build

From an Android checkout with this repository overlaid at
`frameworks/libs/binary_translation`:

```bash
source build/envsetup.sh
lunch sdk_phone64_x86_64_riscv64-trunk_staging-eng

export SOONG_CONFIG_berberis_translation_arch=arm64_to_x86_64
m libberberis_arm64 libberberis_heavy_optimizer_arm64 berberis_arm64_host_tests
```

The translated library is:

```
libberberis_arm64.so
```

It is an x86_64 host library whose guest ISA is AArch64.

## Host tests

Run:

```bash
out/host/linux-x86/nativetest64/berberis_arm64_host_tests/berberis_arm64_host_tests
```

The CI treats absence of this binary as a failure; a successful compile without tests is not considered green.

## Coverage gate

`heavy_optimizer/arm64/arm64_tier_coverage.txt` is a regression baseline. A tier may not silently lose previously covered encodings. Coverage gains should regenerate the table in the same change.

## Runtime notes

The ARM64 path deliberately presents a coherent guest view for facilities that would otherwise expose the x86_64 host:

- ARM64 linker paths in `/proc/self/maps`;
- guest linker ELF opens;
- guest `/proc/cpuinfo`;
- guest TLS/thread state;
- ARM64 futex addresses with top-byte-ignore handling;
- RNDR/RNDRRS availability and carry semantics.

These compatibility layers are guest-ABI behavior, not generic x86_64 host emulation.

## Upstream maintenance

Do not copy a new Digitalis tree over the repository. Use the synchronization script and inspect the resulting merge. Keep ARM64 changes in auditable commits so `git log`, `git blame`, and `git bisect` remain useful.
