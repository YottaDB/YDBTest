; This program verifies that incremental rollback creates the room for additional read-block, ; 7/5/11 3:15pm
; write-block operations.
incrb; 
    write "Testing nested read/write",!
    set $ETRAP="do incrberr^incrollback"
    set r=64792-64 ; read-set limit in single transaction
    set w=510-64   ; write-set limit in single transaction
    tstart
        tstart
            set op="read"
            for i=1:1:r do
            .   set tmp=^x(i)
            tstart
                for i=r+1:1:(r+64+1) quit:$tlevel<3  do
                .   set tmp=^x(i)
            for i=r+1:1:(r+64) do
            .   set tmp=^x(i)
            write i_" blocks successfully read",!
        tcommit
        tstart
            set op="write"
            for i=1:1:w  do
            .   set ^x(i)=$j(i,989)	; use value different from 990 to avoid duplicate set behavior from interfering with test
            tstart
                for i=w+1:1:(w+64+1) quit:$tlevel<3  do
                .   set ^x(i)=$j(i,988)	; use value != 990,989 to avoid duplicate set behavior from interfering with test
            for i=w+1:1:(w+64)
                .   set ^x(i)=$j(i,987)	; use value != 990,989,988 to avoid duplicate set behavior from interfering with test
            write i_" blocks successfully written",!
        tcommit
    tcommit
    quit
incrberr;
    write "ERROR HANDLER STARTS",!
    write $zstatus,!
    if $zstatus["TRANS2BIG" set $ECODE=""
    write $r,!
    write "transaction failed to "_op_" with block #"_i,!
    write "$tlevel="_$tlevel,!
    trollback -1
    write "ERROR HANDLER ENDS",!
    quit
