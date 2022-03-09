;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Set 3 levels of subscripts for ^x and some ^y subscripts to thoroughly test %JSWRITE
fillDB
	set ^x=0
	for i=1:1:5  do
	. set ^x(i)=i
	. for j=1:1:5  do
	. .set ^x(i,j)=i*j
	. . for k=1:1:5  set ^x(i,j,k)=i*j*k
	set ^y(1)=100
	set ^y="why"
 	quit

; This routine tests various %JSWRITE parameters for ^x with 0, 1, 2 and 3
; subscripts. After writing output to a file, it runs the checkfile routine
; to check the output for correctness.
jswrite
	; ^%JSWRITE does not include a new line at the end of its output hence lines after ^%JSWRITE calls need
	; to start with 2 blank lines to ensure a blank line in between.
	set count=0
	for glvn="^x","^x(2)","^x(3,1)","^x(1,5,2)"  do
	. write "*******************************************************************",!
	. write "# glvn set to ",glvn,!
	. write "# do ^%JSWRITE(glvn,""#"")",!
	. write "# this should return JS Object Strings: All descendants of ",glvn," starting from ",glvn,!
	. set file="jswrite.out"_count
	. open file
	. use file
	. do ^%JSWRITE(glvn,"#")
	. close file
	. use $p
	. if $increment(count)
	. do checkfile(file,glvn,"#","")
	. write !,"# do ^%JSWRITE(glvn,""*"")",!
	. write "# this should return JS Object Strings: All descendants of ",glvn,!
	. set file="jswrite.out"_count
	. open file
	. use file
	. do ^%JSWRITE(glvn,"*")
	. close file
	. use $p
	. if $increment(count)
	. do checkfile(file,glvn,"*","")
	. write !,"# do ^%JSWRITE(glvn,""[#]"")",!
	. write "# this should return Array: All descendants of ",glvn," starting from ",glvn,!
	. set file="jswrite.out"_count
	. open file
	. use file
	. do ^%JSWRITE(glvn,"[#]")
	. close file
	. use $p
	. if $increment(count)
	. do checkfile(file,glvn,"[#]","")
	. write !,"# do ^%JSWRITE(glvn,""[*]"")",!
	. write "# this should return Array: All descendants of ",glvn,!
	. set file="jswrite.out"_count
	. open file
	. use file
	. do ^%JSWRITE(glvn,"[*]")
	. close file
	. use $p
	. if $increment(count)
	. do checkfile(file,glvn,"[*]","")
	. write !,"# do ^%JSWRITE(glvn,""*"",""noglvname"")",!
	. write "# this should return JS Object Strings: All descendants of ",glvn," omitting the global ^x",!
	. set file="jswrite.out"_count
	. open file
	. use file
	. do ^%JSWRITE(glvn,"*","noglvname")
	. close file
	. use $p
	. if $increment(count)
	. do checkfile(file,glvn,"*","noglvname")
	. write !
	quit

; This routine verifies that the contents of file, a file containing %JSWRITE output, are correct by verifying
; that the contents of the file match the database and that the correct lines were written. To do this, the
; root glvn and the %JSWRITE parameters need to be passed as arguments. Once it is done calling the routines
; parseandcheckline and checkifrightline to check lines, it checks the next variable in the database in $query
; order to make sure that it was correctly excluded from the output.
checkfile(file,glvn,param1,param2)
	set nlines=0 ; This counter needs to be reset or previously read files will still be stored in line
	open file:(readonly)
	use file
	for  read line($increment(nlines)) quit:$zeof
	close file
	kill line(nlines) if $increment(nlines,-1)
	use $p
	for i=1:1:nlines do
	. if "[]"=line(i)  quit
	. do parseandcheckline(line(i),param2,glvn)
	. do checkifrightline(param1,glvn,i,var)
	; Check if $query for the last var = "" or (for * only) a non-direct descendent
	set nextvar=$query(var)
	if ""'=nextvar  do
	. set incorrect=1
	. if ("*"=param1)!("[*]"=param2)  do
	. . set stop=0
	. . set nextvarsubs=$zextract(nextvar,$zlength($zpiece(nextvar,"("))+2,$zlength(nextvar)-1)
	. . for i=1:1  quit:1=stop  do
	. . . if ""=$zpiece(glvnsubs,",",j) set stop=1
	. . . else  if $zpiece(nextvarsubs,",",j)>$zpiece(glvnsubs,",",j)  set stop=1,incorrect=0
	. . . else  if $zpiece(nextvarsubs,",",j)<$zpiece(glvnsubs,",",j)  set stop=1
	. if 1=incorrect  do
	. . write "FAIL: next variable in tree ",nextvar," is a descendent of ",glvn
	. . write " and should have been included in the %JSWRITE output.",!
	write "Done with checks on file ",file," created from glvn ",glvn," with params ",param1," ",param2,!
	quit

; The parseandcheckline routine parses %JSWRITE output to determine the variable name (including subscripts)
; and the value of the variable. The checkfile routine passes %JSWRITE input to this file line by line. The
; param here is param2 and the glvn is needed if param2 is "noglvname". Finally, it checks if the value of
; the variable (var) in the database is equal to its value in the %JSWRITE input (val). If it is, this routine
; quietly succeeds. If it isn't, it prints a failure message.
parseandcheckline(inputline,param,glvn)
	;if noglvname, determine variable name from glvn and add it to inputline
	set:"noglvname"=param inputline="{"""_$zpiece(glvn,"(")_""":"_inputline_"}"
	; The format of the inputline resembles '{"^x":{"3":{"1":{"1":3}}}}' but we need to change it to something like
	; '"^x":{"3":{"1":{"1":3' to be parseable by a simple $zpiece(inputline,"}:") command. The last zpiece will
	; contain both the last subscript and the value stored within ('"1":3' in the above example). Hence we know
	; we're done with the $zpiece loop to parse the line when a ':' appears in the zpiece we just parsed.
	set curline=$zextract($zpiece(inputline,"}"),2,$zlength($zpiece(inputline,"}")))
	if ""=$zpiece(curline,":{",2) set var=$zpiece($zpiece(curline,":{"),"""",2),stop=1,val=$zpiece(curline,":",2)
	else  set var=$zpiece($zpiece(curline,":{"),"""",2)_"(",stop=0
	for j=2:1  quit:1=stop  do
	. set x=$zpiece(curline,":{",j)
	. if ""=$zpiece(x,":",2) do
	. . if 2=j set var=var_x
	. . else  set var=var_","_x
	. else  do
	. . set stop=1
	. . if 2=j set var=var_$zpiece(x,":")_")"
	. . else  set var=var_","_$zpiece(x,":")_")"
	. . set val=$zpiece(x,":",2)
	if @var'=val write "FAIL: incorrect value of ",var,": expected ",@var," vs actual ",val,!
	quit

; This routine checks if the variable var that was printed on linenum of the %JSWRITE output should have
; been printed on that line number. To do this, it needs the value of param1 (param) and the glvn. If it
; is correct, it passes silently. If the variable in the output was incorrect, it fails with an appropriate
; error message.
checkifrightline(param,glvn,linenum,var)
	quit:("zwr"=param)&(1=linenum)
	if "zwr"=param,$increment(linenum,-1)
	set curvar=glvn
	for j=1:1:linenum  do
	. set curvar=$query(@curvar)
	; var may be in the format ^x("1","2") whereas the value of curvar will be in the format ^x(1,2)
	; thus we need to remove the quotes from var before checking. Since all globals in this test have
	; numeric subscripts, this is fine
	set stop=0
	set actvar=""
	for j=1:1  quit:1=stop  do
	. set x=$zpiece(var,"""",j)
	. set:""=x stop=1
	. set actvar=actvar_x
	write:curvar'=actvar "FAIL: Incorrect variable written, expected ",curvar," vs actual ",actvar,!
	; extract subscripts in format 1,2,5
	set curvarsubs=$zextract(curvar,$zlength($zpiece(curvar,"("))+2,$zlength(curvar)-1)
	set glvnsubs=$zextract(glvn,$zlength($zpiece(glvn,"("))+2,$zlength(glvn)-1)
	if $zpiece(curvar,"(")'=$zpiece(glvn,"(")  do
	. write "FAIL: ",$zpiece(curvar,"(")," is not a descendent of ",$zpiece(glvn,"("),!
	else  if ("*"=param)!("[*]"=param) do
	. set stop=0
	. for j=1:1  quit:1=stop  do
	. . if ""=$zpiece(glvnsubs,",",j) do
	. . . set stop=1
	. . . if ""=$zpiece(curvarsubs,",",j) write "FAIL: ",curvarsubs," is not a direct descendent of ",glvnsubs,!
	. . else  if $zpiece(curvarsubs,",",j)'=$zpiece(glvnsubs,",",j)  do
	. . . set stop=1
	. . . write "FAIL: ",curvarsubs," is not a direct descendent of ",glvnsubs,!
	else  if ("#"=param)!("[#]"=param)!("zwr"=param) do
	. set stop=0
	. for j=1:1  quit:1=stop  do
	. . if ""=$zpiece(glvnsubs,",",j) do
	. . . set stop=1
	. . . if ""=$zpiece(curvarsubs,",",j) write "FAIL: ",curvarsubs," is not a descendent of ",glvnsubs,!
	. . else  if $zpiece(curvarsubs,",",j)>$zpiece(glvnsubs,",",j)  set stop=1
	. . else  if $zpiece(curvarsubs,",",j)<$zpiece(glvnsubs,",",j)  do
	. . . set stop=1
	. . . write "FAIL: ",curvarsubs," is not a descendent of ",glvnsubs,!
	else  write "ERROR: Invalid value ",param1," for param1",!
	quit
