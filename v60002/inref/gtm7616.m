;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; In an argumentless MUPIP RUNDOWN, MUPIP calls out to IPCS relying on the PATH to pick up
; the correct binary. This test abuses the PATH to feed MUPIP a bogus IPCS script that it
; creates. The bogus script uses SHMID and KEY values greater than 128 bytes, the maximum
; length of the parsed value. Currently V990 PRO may or may not SIG-11. DBG hits this assert:
; %GTM-F-ASSERT, Assert failed in /usr/library/V990/inc/gtm_malloc_src.h line 946 for expression (0 == memcmp(trailerMarker, markerChar, SIZEOF(markerChar)))
; This test should not create a core file
gtm7616
	do text^dollartext("ipcs^gtm7616","ipcs")
	zsystem "chmod 755 ipcs ; env PATH=${PWD}:${PATH} $gtm_dist/mupip rundown"
	quit

ipcs
 ;#!/usr/local/bin/tcsh
 ;# KEY and SHMID are 255 bytes long. The current maximum length for the valus is 128 bytes (MAX_PARM_LEN)
 ;set KEY   = 0x222b86e8232b86e8232b86e823b86e82322b86e8232b86e8232b86e823b8222b86e8232b86e8232b86e823b86e82322b86e8232b86e8232b86e823b86e82322b86e8232b86e8232b86e823b86e8232b86e8232b86e8232b86e823b86e8230000000000000000000000000000000000000000000000000000000000000000
 ;set SHMID = 18803916801880391681880391680018803916818803916818803916800188039168188039168188039168001880391680001880391681880391680018803916801880391680188039168018803916801880391680188039168018803916801880391680188039168018803916801880391680188039168018803916801880
 ;#
 ;# On Linux $KEY is in the first column, but on other platforms, it is in the third column
 ;# This string should not exceed 1024 bytes, the current value for MAX_ENTRY_LEN
 ;echo "m  $SHMID $KEY --rw-rw-rw-  $USER      gtc"
 ;echo "s  $SHMID $KEY --ra-ra-ra-  $USER      gtc"
 ;echo "$KEY $SHMID $USER      777        393216     3          dest"
 ;echo "$KEY $SHMID $USER      777        3"
 quit
