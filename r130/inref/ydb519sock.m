;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This tests to ensure that user-specified timeouts are honored by attempting
; to connect to a non-existent IP address 5 times. The specific IP address used
; is part of TEST-NET-3 which is a block of IP addresses assigned for use in
; documentation and examples. Each connection attempt should time out in about
; 10 seconds.
connect
    for i=1:1:5 do
    . set time=$&getMonoTimer()
    . set devTimeout=10
    . open "devName1":(CONNECT="203.0.113.203:49999:TCP"):devTimeout:"SOCKET"
    . close "devName1"
    . write $&getMonoTimer()-time,!
    . write $test,!
    . set %TM=$P($H,",",2) d %CTS^%H
    . write %TIM,!
