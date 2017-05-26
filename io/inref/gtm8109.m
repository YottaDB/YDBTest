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
gtm8109
	; Test changes for GTM-8109
	; Test READ x#n:t and READ *x:t in FOLLOW mode for M, UTF-8 and UTF-16 in non-FIXED mode to verify correct
	; values of $TEST
	; In particular, $TEST should be set to 1 if "n" characters are returned and 0 if the READ times out with
	; less than "n" characters in the case of READ x#n:t or 1 code point in the case of READ *x:t
	set key=$ztrnlnm("gtmcrypt_key")
	set iv=$ztrnlnm("gtmcrypt_iv")
	if "M"=$zchset do
	. set p="Mread"
	. open p:(newversion:key=key_" "_iv)
	. use p
	. write "ABCDEFGHI0ABCDEFGHI1ABCDEFGHI2ABCDEFGHI3ABCDEFGHI4",!
	. write "ABCDEFGHI0ABCDEFGHI1ABCDEFGHI2ABCDEFGHI3ABCDEFGHI4"
	. set $x=0
	. do test(p)
	. quit
	else  do
	. write "UTF-8 data:",!
	. set p="UTF8read"
	. open p:(newversion:chset="UTF-8":key=key_" "_iv)
	. use p
	. write "ABCDEFGHIՇABCDEFGHIՇABCDEFGHIՇABCDEFGHIՇABCDEFGHIՇ",!
	. write "ABCDEFGHIՇABCDEFGHIՇABCDEFGHIՇABCDEFGHIՇABCDEFGHIՇ"
	. set $x=0
	. do test(p)
	. close p
	. write "UTF-16 data:",!
	. set p="UTF16read"
	. open p:(newversion:chset="UTF-16":key=key_" "_iv)
	. use p
	. write "ABCDEFGHIՇABCDEFGHIՇABCDEFGHIՇABCDEFGHIՇABCDEFGHIՇ",!
	. write "ABCDEFGHIՇABCDEFGHIՇABCDEFGHIՇABCDEFGHIՇABCDEFGHIՇ"
	. set $x=0
	. do test(p)
	quit

test(file)
	use file:(rewind:follow)
	; expect read to complete with 40 characters with $test=1
	read x#40:1
	do results(x)
	; expect read to complete with 10 characters with $test=1 because EOL seen
	read x#40:1
	do results(x)
	; ask for more than 50 chars to expect read to complete with 50 characters with $test=0 because it times out
	read x#60:1
	do results(x)
	; rewind and do a couple of read * tests with timeout
	use file:rewind
	; expect $test=1 because it reads one character (value will be ascii or codepoint)
	read *x:1
	do results(x)
	; go to EOF and try and read one character and expect -1 for the value and $test=0 because it times out
	if (""'=key) do
	. use file:nofollow
	. for  read x quit:$zeof
	. use file:follow
	else  do
	. use file:seek="500"
	read *x:1
	do results(x)
	quit

results(x)
	set t=$test
	new %io
	set %io=$io
	use $p
	write "x= "_x_" length(x)= "_$length(x)," $test= ",t,!
	use %io
	quit
