;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm9452 ;
replace; Test the deviceparameter REPLACE
	; Create file names
	new filex set filex="x.txt"
	new filey set filey="y.txt"
	new filez set filez="z.txt"
	new filer set filer="rename.txt"
	;
	; Create a file x.txt to be overwritten via replace (open, use, close)
	open filex:newversion
	use filex
	write "x",!
	close filex
	;
	; Create another file y.txt to be written and then use replace to become x.txt
	open filey:newversion
	use filey
	write "y",!
	close filey:replace=filex
	;
	; Create another file z.txt and replace it to itself
	open filez:newversion
	use filez
	write "z",!
	close filez:replace=filez
	;
	; Create file rename.txt and rename it to itself
	open filer:newversion
	use filer
	write "rename",!
	close filer:rename=filer
	;
	; Verify that y.txt does not exist and that x.txt's contents are "y"
	new ye set ye=$zsearch(filey)
	new xcontents
	open filex:readonly
	use filex
	read xcontents
	close filex
	set pass=0
	if ye="",xcontents="y" set pass=1
	if 1=pass write "PASS from CLOSE:REPLACE on a different file",!
        else  write "FAIL from CLOSE:REPLACE on a different file",! zwrite
	;
	; Verify that z.txt still exists and contains the letter z
	new ze set ze=$zsearch(filez)
	new zcontents
	open filez:readonly
	use filez
	read zcontents
	close filez
	set pass=0
	if ze'="",zcontents="z" set pass=1
	if 1=pass write "PASS from CLOSE:REPLACE on the same file",!
        else  write "FAIL from CLOSE:REPLACE on on the same file",! zwrite
	;
	;
	; Verify that rename.txt still exists and contains the text "rename"
	new re set re=$zsearch(filer)
	new rcontents
	open filer:readonly
	use filer
	read rcontents
	close filer
	set pass=0
	if re'="",rcontents="rename" set pass=1
	if 1=pass write "PASS from CLOSE:RENAME on the same file",!
        else  write "FAIL from CLOSE:RENAME on on the same file",! zwrite
	quit
