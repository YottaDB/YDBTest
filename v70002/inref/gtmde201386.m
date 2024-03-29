;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available 	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sigintdiv ;
        write "# perform tricky calculation",!
        set $etrap="goto e01"
        ;
        set N1=26489595746075820900000000000000
        set N2=887952097261892.795
        write ((10**(-N2))*N1)**(-2)
        ;
        write "TEST-E-INTERNAL test error: no DIVZ (crash or error)",!
        quit
e01     ;
        write "error caught: ",$piece($zstatus,",",3,4),!
        quit

vatl1   ; malformed
        ;
        set $etrap="goto errvatl1"
        write "# Perform a VIEW/NOISOLATION command with malformed global name",!
        ;
        set name="glb"
        for i=1:1:32 set name=name_(i#10)
        write "global name: ",name,!
        view "NOISOLATION":name
        ;
        write "# no error, test failed",!
        quit
errvatl1  ;
        set $etrap=""
        set error=$piece($zstatus,",",3,4)
        write "# catch VIEWGVN",!
        write "error caught: ",error,!
        halt

vatl2   ; too long
        ;
        set $etrap="goto errvatl2"
        write "# Perform a VIEW/NOISOLATION command with arg too long",!
        ;
        set list=""
        for i=1:1:126 do
        .if i>1 set list=list_","
        .set list=list_"^glob"_i
        .xecute "set ^glob"_i_"(1)=2"
        write "arg length: ",$length(list),!
        view "NOISOLATION":list
        ;
        ; YDB produces no error, if no SIGSEGV, test is passed
        do vatlokay
        quit
        ;
errvatl2 ;
        ; GT.M produces VIEWARGTOOLONG, if caught, test is passed
        if $zstatus["VIEWARGTOOLONG" do vatlokay quit
        write "unexpected error: ",$zstatus,!
        quit
        ;
vatlokay ;
        write "No SIGSEGV, test passed",!
        quit

fnum    ;
        write "# $fnumber() should produce MAXSTRLEN",!
        set $etrap="goto errfnumjust"
        ;
        set fmt=$fnumber(-1E10,"-",1E40)
        ;
        write "# no error, test failed"
        quit

just    ;
        write "# $justify() should return 1",!
        set $etrap="goto errfnumjust"
        ;
        set fmt=$justify(1,-1E10)
        write $zlength(fmt),!
        ;
        write "# no segfault, test passed"
        quit

errfnumjust ;
        set error=$piece($zstatus,",",3,4)
        write "error caught: ",error,!
        halt
