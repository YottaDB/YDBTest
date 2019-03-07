;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	write (0&("1E47"*10))
        write (0&"1E47")
        write (0&(10*"1E47"))
        write (0&(10*10*"1E46"))
        write (0&(10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10*10))
        write 0!("1E46"*10)
        write 0!("1E47"*10)
        write +(-(+(-(+(-("1E47"))))))
        write 1+(1+"1E47")
        write 1+(1+(("1E47")))
        write (((("1E47"))+1)+1)
        write 1+"1E47"
        write 0&(1+"1E47")
	write 5!$$^true()
        write 5!$$^true()!("1E47"*10)
        write 5!("1E47"*10)
        write 5!(10*(10*1E45_"ok"))
        write 5!(10*(10*"1E45ok"))
        write 1!$s($$^true&0:"","1E57"*10:"ok",1:1)
        write 1!(1/(1-1))
