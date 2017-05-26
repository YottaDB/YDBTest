;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Update up to four regions, wait until we write a free epoch, set a flag to indicate that we found it, and wait to be killed.
; Determines the free epoch state using $zpeek (via zpeekhelper) to monitor the associated journal buffer fields.
; For this to work, no other processes may be updating the database(s).
updatesyncndie
  set f="PID"_+$ztrnlnm("gtm_test_jobid")_".mjo"
  open f use f write "PID: ",$J,! close f use $P
  set (^a,^b,^c,^d)=5
  write "will now wait for a free epoch on all regions...",!
  set reg="",maxhangs=30
  for  set reg=$view("GVNEXT",reg)  quit:reg=""  do
  . set synced=0,hangs=0
  . for  do  quit:synced  quit:$incr(hangs)=maxhangs  hang 1
  . . set freeaddr=$$getfldmulti^zpeekhelper("CSAREG:"_reg,"sgmnt_addrs.jnl|jnl_private_control.jnl_buff|jnl_buffer.freeaddr","U")
  . . set fsyncaddr=$$getfldmulti^zpeekhelper("CSAREG:"_reg,"sgmnt_addrs.jnl|jnl_private_control.jnl_buff|jnl_buffer.fsync_dskaddr","U")
  . . set epochaddr=$$getfldmulti^zpeekhelper("CSAREG:"_reg,"sgmnt_addrs.jnl|jnl_private_control.jnl_buff|jnl_buffer.post_epoch_freeaddr","U")
  . . write "For region "_reg_" @ "_$h_": got freeaddr="_freeaddr_", fsyncaddr="_fsyncaddr_", epochaddr="_epochaddr,!
  . . ; freeaddr=fsyncaddr indicates that the file is fully written to disk
  . . ; freeaddr=epochaddr indicates that the last thing that we wrote was an epoch
  . . ; Both together mean that we've written a free epoch, which means the db and jnl updates have been flushed/hardened to disk
  . . ; and it is safe for us to be kill -9ed by the test driver script without causing db integ errors.
  . . set:(freeaddr=fsyncaddr)&(freeaddr=epochaddr) synced=1
  . if hangs=maxhangs  write "TEST-E-syncndie_TIMEOUT, could not sync region "_reg,!
  write "will now wait for the test to kill...",!
  set donefile="updatesyncndie_done.txt"
  open donefile:NEWVERSION
  close donefile
  hang 120
  write "TEST-E-NEVER, this script should be killed by now"
  halt
