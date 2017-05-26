; Test condition that results in assert fail in op_unwind() with a DEBUG build. May have had PRO build
; issues too but none we are aware of at this time. (SE 09/2011).
; What was happening was low order 3 bits of non-GTM message numbers (such as the "1" in the below
; ZMessage command) was being treated as a severity code. The value "1" is the "success" code so no
; $ECODE value was set which caused the assert in op_unwind(). 
;
; C9L03-003376 (aka GTM-6771)
;
        Set $ETrap="Write ""Primary error handler triggered - $ZSTATUS="",$ZSTATUS,! Quit"
        Do sub1
        Write "Returned from sub1 - exiting",!
        Quit
 
sub1
        New $ETrap
        Write "Entered sub1",!
        Set $ETrap="Do sub2"
        Set x=1/0
        Write "Returned from sub2",!
        Quit
 
sub2
        Write "Entered sub2 as an $ETrap",!
        Set $ZTrap="",$ECode=""
        ZMessage 1
        Write "ERROR ** ZMessage returned",!
	ZShow "*"
        Halt

