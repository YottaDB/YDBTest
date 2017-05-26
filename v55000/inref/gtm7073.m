;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2012, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lockandwait(numlock)
	write $job
	for i=1:1:numlock DO
	.   lock @("+a"_i_":0")
	lock -(a1,a2)
	set ^grabbed=1
	for i=1:1:600 quit:^die  hang 1
	write:i=600 "TEST-E-TIMEOUT lockandwait^gtm7073 exited after waiting ",i," seconds",!
	quit

waitlocks
	for i=1:1:300 quit:^grabbed  hang 1
	write:i=300 "TEST-E-TIMEOUT locks where not grabbed after waiting ",i," seconds",!
	quit
