;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ; Tests that %HO conversions for input with or without a "0x" or "0X" prefix are converted
 ; to the same octal result by converting randomly generated values with both prefixes and without
 ; a prefix and comparing the results. The conversions are run for 2 seconds.
 ; get back the original input. This uses 1-16 digit random hexadecimal numbers where each digit
 ; is between between 0 and F with random values of 10-15 being mapped to A-F.
 write "Checking that %HO ignores '0x' and '0X' prefixes and converts them exactly the same as if the prefix "
 write "was omitted for 2 seconds",!
 set interval=2000000 ; 2 seconds in mili seconds
 set iend=$zut+interval
 set istart=1
 set inp=""
 set char=""
 set asciofa=$ascii("A")
 for  do  quit:iend<istart
 . set len=$random(16)+1
 . for j=1:1:len  do
 . . set i=$random(16),char=i
 . . set:i>9 char=$char((i#10)+asciofa)	; ascii value of 'A' is added to the i#10 value resulting in characters 'A-F'
 . . set inp=inp_char
 . set inp0x="0x"_inp
 . set inp0X="0X"_inp
 . set istart=$zut
 . quit:iend<istart
 . set %HO=inp
 . do ^%HO
 . set g=%HO
 . set %HO=inp0x
 . do ^%HO
 . set k=%HO
 . set %HO=inp0X
 . do ^%HO
 . set l=%HO
 . if (g'=k)!(g'=l)!(k'=l) do
 . . write "%HO Conversions for input ",inp," do not match. No prefix = ",g,", 0x prefix = ",k,", 0X preefix = ",l,!
 . . quit
 write "Completed",!
 quit
