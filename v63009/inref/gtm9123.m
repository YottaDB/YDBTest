;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gtm9123 ;
	write "should result in true",!
	write +(1!$$zero),!
	write -(1!$$zero),!
	write +(0!$$one),!
	write -(0!$$one),!
	write +'(1&$$zero),!
	write +(1&$$one),!
	write ($$one&1)!+(0!$$zero),!
	write ($$one=1)&+'(0!$$zero),!
	write ($$one=1)&-'(0!$$zero),!
        write ((1=1)&$$one)&+'(1&$$zero),! 
	write ((1=1)&$$one)&-'(1&$$zero),!


	write "should result in false",!
	write +(0!$$zero),!
	write -(0!$$zero),!
	write +(1&$$zero),!
	write -('1&$$zero),!
	write (0!$$zero)!+(0!$$zero),!
	write ($$one!$$zero)&+(0!$$zero),!
	write ($$one!$$zero)&-(0!$$zero),!
	write ((1=$$zero)&$$one)&+'(1&$$zero),!
	write ((1=$$zero)&$$one)&-'(1&$$zero),!
        quit
zero()
        quit 0
one()
	quit 1
