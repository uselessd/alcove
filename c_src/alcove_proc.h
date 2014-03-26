/* Copyright (c) 2014, Michael Santos <michael.santos@gmail.com>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */
typedef struct {
    u_char type;
    unsigned long arg;
    char *data;
    size_t len;
} alcove_prctl_arg_t;

#define PRARG(x) ((x.type) ? (unsigned long)x.data : x.arg)
#define PRVAL(x) ((x.type) ? erl_mk_binary(x.data, x.len) : \
        erl_mk_ulonglong(x.arg))

#define PROPT(_term, _arg) do { \
        if (ERL_IS_INTEGER(_term)) { \
                    _arg.arg = ERL_INT_UVALUE(_term); \
                } \
        else if (ALCOVE_IS_IOLIST(_term)) { \
                    ETERM *bin = NULL; \
                    bin = erl_iolist_to_binary(_term); \
                    _arg.type = 1; \
                    _arg.len = ERL_BIN_SIZE(bin); \
                    _arg.data = alcove_malloc(_arg.len); \
                    (void)memcpy(_arg.data, ERL_BIN_PTR(bin), \
                            ERL_BIN_SIZE(bin)); \
                } \
} while (0)

alcove_define_t alcove_prctl_constants[] = {
#ifdef PR_SET_PDEATHSIG
    ALCOVE_DEFINE(PR_SET_PDEATHSIG),
#endif
#ifdef PR_GET_PDEATHSIG
    ALCOVE_DEFINE(PR_GET_PDEATHSIG),
#endif
#ifdef PR_GET_DUMPABLE
    ALCOVE_DEFINE(PR_GET_DUMPABLE),
#endif
#ifdef PR_SET_DUMPABLE
    ALCOVE_DEFINE(PR_SET_DUMPABLE),
#endif
#ifdef PR_GET_UNALIGN
    ALCOVE_DEFINE(PR_GET_UNALIGN),
#endif
#ifdef PR_SET_UNALIGN
    ALCOVE_DEFINE(PR_SET_UNALIGN),
#endif
#ifdef PR_UNALIGN_NOPRINT
    ALCOVE_DEFINE(PR_UNALIGN_NOPRINT),
#endif
#ifdef PR_UNALIGN_SIGBUS
    ALCOVE_DEFINE(PR_UNALIGN_SIGBUS),
#endif
#ifdef PR_GET_KEEPCAPS
    ALCOVE_DEFINE(PR_GET_KEEPCAPS),
#endif
#ifdef PR_SET_KEEPCAPS
    ALCOVE_DEFINE(PR_SET_KEEPCAPS),
#endif
#ifdef PR_GET_FPEMU
    ALCOVE_DEFINE(PR_GET_FPEMU),
#endif
#ifdef PR_SET_FPEMU
    ALCOVE_DEFINE(PR_SET_FPEMU),
#endif
#ifdef PR_FPEMU_NOPRINT
    ALCOVE_DEFINE(PR_FPEMU_NOPRINT),
#endif
#ifdef PR_FPEMU_SIGFPE
    ALCOVE_DEFINE(PR_FPEMU_SIGFPE),
#endif
#ifdef PR_GET_FPEXC
    ALCOVE_DEFINE(PR_GET_FPEXC),
#endif
#ifdef PR_SET_FPEXC
    ALCOVE_DEFINE(PR_SET_FPEXC),
#endif
#ifdef PR_FP_EXC_SW_ENABLE
    ALCOVE_DEFINE(PR_FP_EXC_SW_ENABLE),
#endif
#ifdef PR_FP_EXC_DIV
    ALCOVE_DEFINE(PR_FP_EXC_DIV),
#endif
#ifdef PR_FP_EXC_OVF
    ALCOVE_DEFINE(PR_FP_EXC_OVF),
#endif
#ifdef PR_FP_EXC_UND
    ALCOVE_DEFINE(PR_FP_EXC_UND),
#endif
#ifdef PR_FP_EXC_RES
    ALCOVE_DEFINE(PR_FP_EXC_RES),
#endif
#ifdef PR_FP_EXC_INV
    ALCOVE_DEFINE(PR_FP_EXC_INV),
#endif
#ifdef PR_FP_EXC_DISABLED
    ALCOVE_DEFINE(PR_FP_EXC_DISABLED),
#endif
#ifdef PR_FP_EXC_NONRECOV
    ALCOVE_DEFINE(PR_FP_EXC_NONRECOV),
#endif
#ifdef PR_FP_EXC_ASYNC
    ALCOVE_DEFINE(PR_FP_EXC_ASYNC),
#endif
#ifdef PR_FP_EXC_PRECISE
    ALCOVE_DEFINE(PR_FP_EXC_PRECISE),
#endif
#ifdef PR_GET_TIMING
    ALCOVE_DEFINE(PR_GET_TIMING),
#endif
#ifdef PR_SET_TIMING
    ALCOVE_DEFINE(PR_SET_TIMING),
#endif
#ifdef PR_TIMING_STATISTICAL
    ALCOVE_DEFINE(PR_TIMING_STATISTICAL),
#endif
#ifdef PR_TIMING_TIMESTAMP
    ALCOVE_DEFINE(PR_TIMING_TIMESTAMP),
#endif
#ifdef PR_SET_NAME
    ALCOVE_DEFINE(PR_SET_NAME),
#endif
#ifdef PR_GET_NAME
    ALCOVE_DEFINE(PR_GET_NAME),
#endif
#ifdef PR_GET_ENDIAN
    ALCOVE_DEFINE(PR_GET_ENDIAN),
#endif
#ifdef PR_SET_ENDIAN
    ALCOVE_DEFINE(PR_SET_ENDIAN),
#endif
#ifdef PR_ENDIAN_BIG
    ALCOVE_DEFINE(PR_ENDIAN_BIG),
#endif
#ifdef PR_ENDIAN_LITTLE
    ALCOVE_DEFINE(PR_ENDIAN_LITTLE),
#endif
#ifdef PR_ENDIAN_PPC_LITTLE
    ALCOVE_DEFINE(PR_ENDIAN_PPC_LITTLE),
#endif
#ifdef PR_GET_SECCOMP
    ALCOVE_DEFINE(PR_GET_SECCOMP),
#endif
#ifdef PR_SET_SECCOMP
    ALCOVE_DEFINE(PR_SET_SECCOMP),
#endif
#ifdef PR_CAPBSET_READ
    ALCOVE_DEFINE(PR_CAPBSET_READ),
#endif
#ifdef PR_CAPBSET_DROP
    ALCOVE_DEFINE(PR_CAPBSET_DROP),
#endif
#ifdef PR_GET_TSC
    ALCOVE_DEFINE(PR_GET_TSC),
#endif
#ifdef PR_SET_TSC
    ALCOVE_DEFINE(PR_SET_TSC),
#endif
#ifdef PR_TSC_ENABLE
    ALCOVE_DEFINE(PR_TSC_ENABLE),
#endif
#ifdef PR_TSC_SIGSEGV
    ALCOVE_DEFINE(PR_TSC_SIGSEGV),
#endif
#ifdef PR_GET_SECUREBITS
    ALCOVE_DEFINE(PR_GET_SECUREBITS),
#endif
#ifdef PR_SET_SECUREBITS
    ALCOVE_DEFINE(PR_SET_SECUREBITS),
#endif
#ifdef PR_SET_TIMERSLACK
    ALCOVE_DEFINE(PR_SET_TIMERSLACK),
#endif
#ifdef PR_GET_TIMERSLACK
    ALCOVE_DEFINE(PR_GET_TIMERSLACK),
#endif
#ifdef PR_TASK_PERF_EVENTS_DISABLE
    ALCOVE_DEFINE(PR_TASK_PERF_EVENTS_DISABLE),
#endif
#ifdef PR_TASK_PERF_EVENTS_ENABLE
    ALCOVE_DEFINE(PR_TASK_PERF_EVENTS_ENABLE),
#endif
#ifdef PR_MCE_KILL
    ALCOVE_DEFINE(PR_MCE_KILL),
#endif
#ifdef PR_MCE_KILL_CLEAR
    ALCOVE_DEFINE(PR_MCE_KILL_CLEAR),
#endif
#ifdef PR_MCE_KILL_SET
    ALCOVE_DEFINE(PR_MCE_KILL_SET),
#endif
#ifdef PR_MCE_KILL_LATE
    ALCOVE_DEFINE(PR_MCE_KILL_LATE),
#endif
#ifdef PR_MCE_KILL_EARLY
    ALCOVE_DEFINE(PR_MCE_KILL_EARLY),
#endif
#ifdef PR_MCE_KILL_DEFAULT
    ALCOVE_DEFINE(PR_MCE_KILL_DEFAULT),
#endif
#ifdef PR_MCE_KILL_GET
    ALCOVE_DEFINE(PR_MCE_KILL_GET),
#endif
#ifdef PR_SET_MM
    ALCOVE_DEFINE(PR_SET_MM),
#endif
#ifdef PR_SET_MM_START_CODE
    ALCOVE_DEFINE(PR_SET_MM_START_CODE),
#endif
#ifdef PR_SET_MM_END_CODE
    ALCOVE_DEFINE(PR_SET_MM_END_CODE),
#endif
#ifdef PR_SET_MM_START_DATA
    ALCOVE_DEFINE(PR_SET_MM_START_DATA),
#endif
#ifdef PR_SET_MM_END_DATA
    ALCOVE_DEFINE(PR_SET_MM_END_DATA),
#endif
#ifdef PR_SET_MM_START_STACK
    ALCOVE_DEFINE(PR_SET_MM_START_STACK),
#endif
#ifdef PR_SET_MM_START_BRK
    ALCOVE_DEFINE(PR_SET_MM_START_BRK),
#endif
#ifdef PR_SET_MM_BRK
    ALCOVE_DEFINE(PR_SET_MM_BRK),
#endif
#ifdef PR_SET_PTRACER
    ALCOVE_DEFINE(PR_SET_PTRACER),
#endif
#ifdef PR_SET_PTRACER_ANY
    ALCOVE_DEFINE(PR_SET_PTRACER_ANY),
#endif
#ifdef PR_SET_NO_NEW_PRIVS
    ALCOVE_DEFINE(PR_SET_NO_NEW_PRIVS),
#endif
#ifdef PR_GET_NO_NEW_PRIVS
    ALCOVE_DEFINE(PR_GET_NO_NEW_PRIVS),
#endif
    {NULL, 0}
};
