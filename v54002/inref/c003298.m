; c003298 serves two purposes.
; (a) First time it is invoked, it does an update to ^a and hangs itself for sometime till it is Kill -9'ed
; (b) The next time it is invoked, the shared memory has been removed after the kill -9 and hence the first attempt at attaching
;     to the database will fail in db_init with a REQRUNDOWN error. This will invoke the $etrap which will print the error and
;     hang itself for some more time until a MUPIP STOP is issued
c003298 ;
        set $etrap="do error^c003298"
        set ^a=1
        hang 300
        quit

error   ;
        write $zstatus,!
        set $ecode=""
        hang 300
        quit
