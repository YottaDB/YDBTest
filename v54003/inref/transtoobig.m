;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2011-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Test the read write limit for number of buffers in one transaction
dbread;
    WRITE "Test the read-set limit for number of blocks in single transaction is 64K",!
    SET $ETRAP="do readerr^transtoobig"
    TSTART
    FOR i=1:1:((64*1024)+1) do
    .   SET tmp=^x(i)
    TCOMMIT
    QUIT
readerr;
    WRITE "inside read-error handler",!
    WRITE "read block number="_i,!
    QUIT
dbwrite1;
    WRITE "Test the write-set limit is less than or equal to half of the number of global buffers",!
    SET $ETRAP="do dbwrite1err^transtoobig"
    TSTART
    FOR i=1:1:511 DO
    .      SET ^x(i)=$j(i,989)	; set ^x(i) to a different value than what was set in trans2big1.csh
    .				; as otherwise we will have a duplicate set and wont count towards the write-set
    TCOMMIT
    QUIT
dbwrite1err;
    WRITE "inside write1-error handler",!
    WRITE "write block number="_i,!
    QUIT
dbwrite2;
    WRITE "Test the write-set limit is less than 32K",!
    SET $ETRAP="do dbwrite2err^transtoobig"
    TSTART
    FOR i=1:1:((32*1024)+1) DO
    .      SET ^x(i)=$j(i,989)	; set ^x(i) to a different value than what was set in trans2big1.csh
    .				; as otherwise we will have a duplicate set and wont count towards the write-set
    TCOMMIT
    QUIT
dbwrite2err;
    WRITE "inside write1-error handler",!
    WRITE "write block number="_i,!
    QUIT
