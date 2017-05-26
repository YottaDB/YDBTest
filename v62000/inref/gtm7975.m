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
gtm7975	;
	; Test m**n operator for negative values of m and huge integer values of n
	;
	new str,i,j
	; Test case (1) : -1**n where n is a huge even or odd number
	write !,"Test case 1",!
	write "------------------------------------",!
	set str="1234567891234567891"
	for i=1:1:$length(str) set str(i)=$extract(str,1,i)
	for j=1:1:i  do
	. write "-1**"_(str(j)-1)," = ",?26,@("-1**"_(str(j)-1)),!
	. write "-1**"_str(j)," = ",?26,@("-1**"_str(j)),!
	;
	; Test case (2) : m**n where m is a negative number > -1 and n is a huge even/odd number.
	write !,"Test case 2",!
	write "------------------------------------",!
	kill str
	set str="9999999999999999999"
	for i=1:1:$length(str) set str(i)="-0."_$extract(str,1,i)_"**1234567"
	for j=1:1:i  write str(j)," = ",?35,@(str(j)),!
	for i=1:1:$length(str) set str(i)="-0."_$extract(str,1,i)_"**1234568"
	for j=1:1:i  write str(j)," = ",?35,@(str(j)),!
	;
	; Test case (3) : m**n where m is a negative number infinitesimally < -1 and n is a huge even/odd number.
	; Cannot consider the general case where m is a negative number < -1 since that causes a NUMOFLOW error if n is huge.
	write !,"Test case 3",!
	write "------------------------------------",!
	kill str
	set str="000000000000"
	for i=1:1:$length(str) set str(i)="-1.00"_$extract(str,1,i)_"1**1000001"
	for j=1:1:i  write str(j)," = ",?35,@(str(j)),!
	for i=1:1:$length(str) set str(i)="-1.00"_$extract(str,1,i)_"1**1000002"
	for j=1:1:i  write str(j)," = ",?35,@(str(j)),!
	;
	; Test case (4) : Miscellaneous test case
	write !,"Test case 4",!
	kill str,i
	write "------------------------------------",!
	set str($incr(i))="(-11234599931410234943)**(-3341329483120349)"
	write str(i)," = ",?26,@(str(i)),!
	;
	write !
	quit
