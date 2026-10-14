/* Provide __riscv_flush_icache for GCC-generated code (libffi closures).
 * Toolchain libgcc lacks it; OHOS device musl lacks both it and
 * riscv_flush_icache. fence.i flushes the whole hart icache (safe
 * superset of the requested range) and is executable in U-mode on K3
 * (V8 JIT relies on the same instruction). Preload via LD_PRELOAD. */
void __riscv_flush_icache(void *start, void *end)
{
    (void)start;
    (void)end;
    __asm__ volatile("fence.i" ::: "memory");
}
