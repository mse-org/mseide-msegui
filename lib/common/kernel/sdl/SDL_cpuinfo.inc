{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
  * # CategoryCPUInfo
  *
  * CPU feature detection for SDL.
  *
  * These functions are largely concerned with reporting if the system has
  * access to various SIMD instruction sets, but also has other important info
  * to share, such as system RAM size and number of logical CPU cores.
  *
  * CPU instruction set checks, like SDL_HasSSE() and SDL_HasNEON(), are
  * available on all platforms, even if they don't make sense (an ARM processor
  * will never have SSE and an x86 processor will never have NEON, for example,
  * but these functions still exist and will simply return false in these
  * cases).
  }

{*
 * A guess for the cacheline size used for padding.
 *
 * Most x86 processors have a 64 byte cache line. The 64-bit PowerPC
 * processors have a 128 byte cache line. We use the larger value to be
 * generally safe.
 *
 * \since This macro is available since SDL 3.1.3.
  }
const
  SDL_CACHELINE_SIZE = 128;

{*
 * Get the number of logical CPU cores available.
 *
 * \returns the total number of logical CPU cores. On CPUs that include
 *          technologies such as hyperthreading, the number of logical cores
 *          may be more than the number of physical cores.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.1.3.
  }
function SDL_GetNumLogicalCPUCores: cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetNumLogicalCPUCores' {$ENDIF} {$ENDIF};

{*
 * Determine the L1 cache line size of the CPU.
 *
 * This is useful for determining multi-threaded structure padding or SIMD
 * prefetch sizes.
 *
 * \returns the L1 cache line size of the CPU, in bytes.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.1.3.
  }
function SDL_GetCPUCacheLineSize: cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetCPUCacheLineSize' {$ENDIF} {$ENDIF};

{*
 * Determine whether the CPU has AltiVec features.
 *
 * This always returns false on CPUs that aren't using PowerPC instruction
 * sets.
 *
 * \returns true if the CPU has AltiVec features or false if not.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.1.3.
  }
function SDL_HasAltiVec: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasAltiVec' {$ENDIF} {$ENDIF};

{*
 * Determine whether the CPU has MMX features.
 *
 * This always returns false on CPUs that aren't using Intel instruction sets.
 *
 * \returns true if the CPU has MMX features or false if not.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.1.3.
  }
function SDL_HasMMX: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasMMX' {$ENDIF} {$ENDIF};

{*
 * Determine whether the CPU has SSE features.
 *
 * This always returns false on CPUs that aren't using Intel instruction sets.
 *
 * \returns true if the CPU has SSE features or false if not.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.1.3.
 *
 * \sa SDL_HasSSE2
 * \sa SDL_HasSSE3
 * \sa SDL_HasSSE41
 * \sa SDL_HasSSE42
  }
function SDL_HasSSE: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasSSE' {$ENDIF} {$ENDIF};

{*
 * Determine whether the CPU has SSE2 features.
 *
 * This always returns false on CPUs that aren't using Intel instruction sets.
 *
 * \returns true if the CPU has SSE2 features or false if not.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.1.3.
 *
 * \sa SDL_HasSSE
 * \sa SDL_HasSSE3
 * \sa SDL_HasSSE41
 * \sa SDL_HasSSE42
  }
function SDL_HasSSE2: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasSSE2' {$ENDIF} {$ENDIF};

{*
 * Determine whether the CPU has SSE3 features.
 *
 * This always returns false on CPUs that aren't using Intel instruction sets.
 *
 * \returns true if the CPU has SSE3 features or false if not.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.1.3.
 *
 * \sa SDL_HasSSE
 * \sa SDL_HasSSE2
 * \sa SDL_HasSSE41
 * \sa SDL_HasSSE42
  }
function SDL_HasSSE3: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasSSE3' {$ENDIF} {$ENDIF};

{*
 * Determine whether the CPU has SSE4.1 features.
 *
 * This always returns false on CPUs that aren't using Intel instruction sets.
 *
 * \returns true if the CPU has SSE4.1 features or false if not.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.1.3.
 *
 * \sa SDL_HasSSE
 * \sa SDL_HasSSE2
 * \sa SDL_HasSSE3
 * \sa SDL_HasSSE42
  }
function SDL_HasSSE41: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasSSE41' {$ENDIF} {$ENDIF};

{*
 * Determine whether the CPU has SSE4.2 features.
 *
 * This always returns false on CPUs that aren't using Intel instruction sets.
 *
 * \returns true if the CPU has SSE4.2 features or false if not.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.1.3.
 *
 * \sa SDL_HasSSE
 * \sa SDL_HasSSE2
 * \sa SDL_HasSSE3
 * \sa SDL_HasSSE41
  }
function SDL_HasSSE42: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasSSE42' {$ENDIF} {$ENDIF};

{*
 * Determine whether the CPU has AVX features.
 *
 * This always returns false on CPUs that aren't using Intel instruction sets.
 *
 * \returns true if the CPU has AVX features or false if not.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.1.3.
 *
 * \sa SDL_HasAVX2
 * \sa SDL_HasAVX512F
  }
function SDL_HasAVX: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasAVX' {$ENDIF} {$ENDIF};

{*
 * Determine whether the CPU has AVX2 features.
 *
 * This always returns false on CPUs that aren't using Intel instruction sets.
 *
 * \returns true if the CPU has AVX2 features or false if not.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.1.3.
 *
 * \sa SDL_HasAVX
 * \sa SDL_HasAVX512F
  }
function SDL_HasAVX2: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasAVX2' {$ENDIF} {$ENDIF};

{*
 * Determine whether the CPU has AVX-512F (foundation) features.
 *
 * This always returns false on CPUs that aren't using Intel instruction sets.
 *
 * \returns true if the CPU has AVX-512F features or false if not.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.1.3.
 *
 * \sa SDL_HasAVX
 * \sa SDL_HasAVX2
  }
function SDL_HasAVX512F: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasAVX512F' {$ENDIF} {$ENDIF};

{*
 * Determine whether the CPU has ARM SIMD (ARMv6) features.
 *
 * This is different from ARM NEON, which is a different instruction set.
 *
 * This always returns false on CPUs that aren't using ARM instruction sets.
 *
 * \returns true if the CPU has ARM SIMD features or false if not.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.1.3.
 *
 * \sa SDL_HasNEON
  }
function SDL_HasARMSIMD: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasARMSIMD' {$ENDIF} {$ENDIF};

{*
 * Determine whether the CPU has NEON (ARM SIMD) features.
 *
 * This always returns false on CPUs that aren't using ARM instruction sets.
 *
 * \returns true if the CPU has ARM NEON features or false if not.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.1.3.
  }
function SDL_HasNEON: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasNEON' {$ENDIF} {$ENDIF};

{*
 * Determine whether the CPU has LSX (LOONGARCH SIMD) features.
 *
 * This always returns false on CPUs that aren't using LOONGARCH instruction
 * sets.
 *
 * \returns true if the CPU has LOONGARCH LSX features or false if not.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.1.3.
  }
function SDL_HasLSX: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasLSX' {$ENDIF} {$ENDIF};

{*
 * Determine whether the CPU has LASX (LOONGARCH SIMD) features.
 *
 * This always returns false on CPUs that aren't using LOONGARCH instruction
 * sets.
 *
 * \returns true if the CPU has LOONGARCH LASX features or false if not.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.1.3.
  }
function SDL_HasLASX: Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasLASX' {$ENDIF} {$ENDIF};

{*
 * Get the amount of RAM configured in the system.
 *
 * \returns the amount of RAM configured in the system in MiB.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.1.3.
  }
function SDL_GetSystemRAM: cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSystemRAM' {$ENDIF} {$ENDIF};

{*
 * Report the alignment this system needs for SIMD allocations.
 *
 * This will return the minimum number of bytes to which a Pointer must be
 * aligned to be compatible with SIMD instructions on the current machine. For
 * example, if the machine supports SSE only, it will return 16, but if it
 * supports AVX-512F, it'll return 64 (etc). This only reports values for
 * instruction sets SDL knows about, so if your SDL build doesn't have
 * SDL_HasAVX512F(), then it might return 16 for the SSE support it sees and
 * not 64 for the AVX-512 instructions that exist but SDL doesn't know about.
 * Plan accordingly.
 *
 * \returns the alignment in bytes needed for available, known SIMD
 *          instructions.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.1.3.
 *
 * \sa SDL_aligned_alloc
 * \sa SDL_aligned_free
  }
function SDL_GetSIMDAlignment: csize_t; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSIMDAlignment' {$ENDIF} {$ENDIF};

{*
 * Report the size of a page of memory.
 *
 * Different platforms might have different memory page sizes. In current
 * times, 4 kilobytes is not unusual, but newer systems are moving to larger
 * page sizes, and esoteric platforms might have any unexpected size.
 *
 * Note that this function can return 0, which means SDL can't determine the
 * page size on this platform. It will _not_ set an error string to be
 * retrieved with SDL_GetError() in this case! In this case, defaulting to
 * 4096 is often a reasonable option.
 *
 * \returns the size of a single page of memory, in bytes, or 0 if SDL can't
 *          determine this information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.4.0.
  }
function SDL_GetSystemPageSize: cint; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetSystemPageSize' {$ENDIF} {$ENDIF};

