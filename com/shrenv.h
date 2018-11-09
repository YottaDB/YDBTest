#ifndef __SHRENV_H__
#define __SHRENV_H__
#ifdef __MVS__
#define _SHR_ENVIRON
#include <math.h>
#endif

/* Conditional macro to have some things different on 64 bit platforms. */
#if defined(__ia64) || defined(_AIX) || defined(__x86_64__) || defined(__sparc) || defined(__MVS__) || defined (__s390__) || defined(__aarch64__)
#       define GTM64_ONLY(X)    X
#       define NON_GTM64_ONLY(X)
#else
#       define GTM64_ONLY(X)
#       define NON_GTM64_ONLY(X)        X
#endif /* __ia64 */

#if defined(__osf__)
#	define XC_LONG_FMTSTR	"%d"
#	define XC_ULONG_FMTSTR	"%u"
#else
#	define XC_LONG_FMTSTR	"%ld"
#	define XC_ULONG_FMTSTR	"%lu"
#endif

#endif
