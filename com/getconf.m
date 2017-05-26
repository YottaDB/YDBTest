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
;
; The getconf routine calls out to the getconf command line executable. In it's
; current form, it works for getting PATH related configuration values because it
; implicitly includes $zdirectory. Future additions should take care to remove
; this dependency.
;
; This routine requires extrinsic use.
;
; 'getconf -a' worked on all platforms execpt HP-UX. Ideally, this routine would
; simply use that command and return a M local with the desired information.
;
; Input:
;  - cfgopt - A string containing the name of the desired configuration option.
;
; Output:
;  - The result of the piped command
getconf(cfgopt)
	new pipe,cfg
	set pipe="cfg"
	open pipe:(command="getconf "_cfgopt_" "_$zdirectory)::"PIPE"
	use pipe
	read cfg
	close pipe
	quit cfg
