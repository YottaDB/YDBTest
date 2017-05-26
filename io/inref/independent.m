;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2008, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
independent
	; call: independent "shellpath"
	; The ntestin executable is a c program which echoes back input to stdout.  It is run here in order to test
	; the "independent" deviceparameter.  The ntestin executable is designed to run after the pipe is closed.
	; This test will save the process id of this executable to be killed by the test script after this m
	; routine has run.
	set shellpath=$zcmdline
	set shellname=$zparse($zcmdline,"name")
	set a="test"
	open a:(shell=shellpath:comm="./ntestin":inde)::"pipe"
	use a
	set key=$key
	write "simple test"
	read x#11
	use $p
	write x,!
	; add debugging ps output
	zsystem "ps -ef > "_shellname_".psef.outx"
	; set k to be a ps command to capture the child of the "key" process as the first line in ntestin.pid and if there is
	; a shell process parent for ntestin it will be saved as the second line in ntestin.pid.
	set k="ps -ef | grep -v grep | grep -v "_shellname_" | grep -w '"_key_"' | grep ntestin | awk '{print $2}' > ntestin.pid"
	set k=k_";ps -ef | grep -v grep | grep "_shellname_" | grep -w '"_key_"' | grep ntestin | awk '{print $2}' >> ntestin.pid"
	set b="getpid"
	open b:(comm=k:writeonly)::"pipe"
	; make sure the long command string defined in k has time to process ntestin.pid by adding a timeout to close
	close b:timeout=20
	close a
	quit
