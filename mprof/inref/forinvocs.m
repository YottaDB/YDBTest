forinvocs ;
        ; A part of mprof/D9L06002815 test. Verifies that generic label info as well as
	; individual lines are recorded correctly when mixed with various types of FOR loops
	;
	view "trace":1:"^forinvocstrace"
	set intstart=1
	set extstart=1
	set intincr=1
	set extincr=1
	set intlimit=5
	set extlimit=10

	for i=1:1:10 do lab0
	for i=1:1:10 do lab1
	for i=1:1:10 do lab2
	for i=1:1:10 do lab3
	for i=1:1:10 do lab4
	for i=1:1:10 do lab5
	for i=1:1:10 do lab6
	for i=1:1:10 do lab7
	for i=1:1:10 do lab8
	for i=1:1:10 do lab9
	for i=1:1:10 do lab10
	for i=1:1:10 do lab11

	for i=1:1:10 do 
	.	do lab0
	for i=1:1:10 do 
	.	do lab1
	for i=1:1:10 do 
	.	do lab2
	for i=1:1:10 do 
	.	do lab3
	for i=1:1:10 do 
	.	do lab4
	for i=1:1:10 do 
	.	do lab5
	for i=1:1:10 do 
	.	do lab6
	for i=1:1:10 do 
	.	do lab7
	for i=1:1:10 do 
	.	do lab8
	for i=1:1:10 do 
	.	do lab9
	for i=1:1:10 do 
	.	do lab10
	for i=1:1:10 do 
	.	do lab11

	;------------------------------

	for i=1:1:extlimit do lab0
	for i=1:1:extlimit do lab1
	for i=1:1:extlimit do lab2
	for i=1:1:extlimit do lab3
	for i=1:1:extlimit do lab4
	for i=1:1:extlimit do lab5
	for i=1:1:extlimit do lab6
	for i=1:1:extlimit do lab7
	for i=1:1:extlimit do lab8
	for i=1:1:extlimit do lab9
	for i=1:1:extlimit do lab10
	for i=1:1:extlimit do lab11

	for i=1:1:extlimit do 
	.	do lab0
	for i=1:1:extlimit do 
	.	do lab1
	for i=1:1:extlimit do 
	.	do lab2
	for i=1:1:extlimit do 
	.	do lab3
	for i=1:1:extlimit do 
	.	do lab4
	for i=1:1:extlimit do 
	.	do lab5
	for i=1:1:extlimit do 
	.	do lab6
	for i=1:1:extlimit do 
	.	do lab7
	for i=1:1:extlimit do 
	.	do lab8
	for i=1:1:extlimit do 
	.	do lab9
	for i=1:1:extlimit do 
	.	do lab10
	for i=1:1:extlimit do 
	.	do lab11

	;------------------------------

	for i=1:extincr:10 do lab0
	for i=1:extincr:10 do lab1
	for i=1:extincr:10 do lab2
	for i=1:extincr:10 do lab3
	for i=1:extincr:10 do lab4
	for i=1:extincr:10 do lab5
	for i=1:extincr:10 do lab6
	for i=1:extincr:10 do lab7
	for i=1:extincr:10 do lab8
	for i=1:extincr:10 do lab9
	for i=1:extincr:10 do lab10
	for i=1:extincr:10 do lab11

	for i=1:extincr:10 do 
	.	do lab0
	for i=1:extincr:10 do 
	.	do lab1
	for i=1:extincr:10 do 
	.	do lab2
	for i=1:extincr:10 do 
	.	do lab3
	for i=1:extincr:10 do 
	.	do lab4
	for i=1:extincr:10 do 
	.	do lab5
	for i=1:extincr:10 do 
	.	do lab6
	for i=1:extincr:10 do 
	.	do lab7
	for i=1:extincr:10 do 
	.	do lab8
	for i=1:extincr:10 do 
	.	do lab9
	for i=1:extincr:10 do 
	.	do lab10
	for i=1:extincr:10 do 
	.	do lab11

	;------------------------------

	for i=1:extincr:extlimit do lab0
	for i=1:extincr:extlimit do lab1
	for i=1:extincr:extlimit do lab2
	for i=1:extincr:extlimit do lab3
	for i=1:extincr:extlimit do lab4
	for i=1:extincr:extlimit do lab5
	for i=1:extincr:extlimit do lab6
	for i=1:extincr:extlimit do lab7
	for i=1:extincr:extlimit do lab8
	for i=1:extincr:extlimit do lab9
	for i=1:extincr:extlimit do lab10
	for i=1:extincr:extlimit do lab11

	for i=1:extincr:extlimit do 
	.	do lab0
	for i=1:extincr:extlimit do 
	.	do lab1
	for i=1:extincr:extlimit do 
	.	do lab2
	for i=1:extincr:extlimit do 
	.	do lab3
	for i=1:extincr:extlimit do 
	.	do lab4
	for i=1:extincr:extlimit do 
	.	do lab5
	for i=1:extincr:extlimit do 
	.	do lab6
	for i=1:extincr:extlimit do 
	.	do lab7
	for i=1:extincr:extlimit do 
	.	do lab8
	for i=1:extincr:extlimit do 
	.	do lab9
	for i=1:extincr:extlimit do 
	.	do lab10
	for i=1:extincr:extlimit do 
	.	do lab11

	;------------------------------

	for i=extstart:1:10 do lab0
	for i=extstart:1:10 do lab1
	for i=extstart:1:10 do lab2
	for i=extstart:1:10 do lab3
	for i=extstart:1:10 do lab4
	for i=extstart:1:10 do lab5
	for i=extstart:1:10 do lab6
	for i=extstart:1:10 do lab7
	for i=extstart:1:10 do lab8
	for i=extstart:1:10 do lab9
	for i=extstart:1:10 do lab10
	for i=extstart:1:10 do lab11

	for i=extstart:1:10 do 
	.	do lab0
	for i=extstart:1:10 do 
	.	do lab1
	for i=extstart:1:10 do 
	.	do lab2
	for i=extstart:1:10 do 
	.	do lab3
	for i=extstart:1:10 do 
	.	do lab4
	for i=extstart:1:10 do 
	.	do lab5
	for i=extstart:1:10 do 
	.	do lab6
	for i=extstart:1:10 do 
	.	do lab7
	for i=extstart:1:10 do 
	.	do lab8
	for i=extstart:1:10 do 
	.	do lab9
	for i=extstart:1:10 do 
	.	do lab10
	for i=extstart:1:10 do 
	.	do lab11

	;------------------------------

	for i=extstart:extincr:10 do lab0
	for i=extstart:extincr:10 do lab1
	for i=extstart:extincr:10 do lab2
	for i=extstart:extincr:10 do lab3
	for i=extstart:extincr:10 do lab4
	for i=extstart:extincr:10 do lab5
	for i=extstart:extincr:10 do lab6
	for i=extstart:extincr:10 do lab7
	for i=extstart:extincr:10 do lab8
	for i=extstart:extincr:10 do lab9
	for i=extstart:extincr:10 do lab10
	for i=extstart:extincr:10 do lab11

	for i=extstart:extincr:10 do 
	.	do lab0
	for i=extstart:extincr:10 do 
	.	do lab1
	for i=extstart:extincr:10 do 
	.	do lab2
	for i=extstart:extincr:10 do 
	.	do lab3
	for i=extstart:extincr:10 do 
	.	do lab4
	for i=extstart:extincr:10 do 
	.	do lab5
	for i=extstart:extincr:10 do 
	.	do lab6
	for i=extstart:extincr:10 do 
	.	do lab7
	for i=extstart:extincr:10 do 
	.	do lab8
	for i=extstart:extincr:10 do 
	.	do lab9
	for i=extstart:extincr:10 do 
	.	do lab10
	for i=extstart:extincr:10 do 
	.	do lab11

	;------------------------------

	for i=extstart:1:extlimit do lab0
	for i=extstart:1:extlimit do lab1
	for i=extstart:1:extlimit do lab2
	for i=extstart:1:extlimit do lab3
	for i=extstart:1:extlimit do lab4
	for i=extstart:1:extlimit do lab5
	for i=extstart:1:extlimit do lab6
	for i=extstart:1:extlimit do lab7
	for i=extstart:1:extlimit do lab8
	for i=extstart:1:extlimit do lab9
	for i=extstart:1:extlimit do lab10
	for i=extstart:1:extlimit do lab11

	for i=extstart:1:extlimit do 
	.	do lab0
	for i=extstart:1:extlimit do 
	.	do lab1
	for i=extstart:1:extlimit do 
	.	do lab2
	for i=extstart:1:extlimit do 
	.	do lab3
	for i=extstart:1:extlimit do 
	.	do lab4
	for i=extstart:1:extlimit do 
	.	do lab5
	for i=extstart:1:extlimit do 
	.	do lab6
	for i=extstart:1:extlimit do 
	.	do lab7
	for i=extstart:1:extlimit do 
	.	do lab8
	for i=extstart:1:extlimit do 
	.	do lab9
	for i=extstart:1:extlimit do 
	.	do lab10
	for i=extstart:1:extlimit do 
	.	do lab11

	;------------------------------

	for i=extstart:extincr:extlimit do lab0
	for i=extstart:extincr:extlimit do lab1
	for i=extstart:extincr:extlimit do lab2
	for i=extstart:extincr:extlimit do lab3
	for i=extstart:extincr:extlimit do lab4
	for i=extstart:extincr:extlimit do lab5
	for i=extstart:extincr:extlimit do lab6
	for i=extstart:extincr:extlimit do lab7
	for i=extstart:extincr:extlimit do lab8
	for i=extstart:extincr:extlimit do lab9
	for i=extstart:extincr:extlimit do lab10
	for i=extstart:extincr:extlimit do lab11

	for i=extstart:extincr:extlimit do 
	.	do lab0
	for i=extstart:extincr:extlimit do 
	.	do lab1
	for i=extstart:extincr:extlimit do 
	.	do lab2
	for i=extstart:extincr:extlimit do 
	.	do lab3
	for i=extstart:extincr:extlimit do 
	.	do lab4
	for i=extstart:extincr:extlimit do 
	.	do lab5
	for i=extstart:extincr:extlimit do 
	.	do lab6
	for i=extstart:extincr:extlimit do 
	.	do lab7
	for i=extstart:extincr:extlimit do 
	.	do lab8
	for i=extstart:extincr:extlimit do 
	.	do lab9
	for i=extstart:extincr:extlimit do 
	.	do lab10
	for i=extstart:extincr:extlimit do 
	.	do lab11

	view "trace":0:"^forinvocstrace"
	do ^examin("^forinvocstrace")
	
	quit

lab0	; no code on the same line, no code except for quit
	quit

lab1	; no code on the same line
	write "1 "
	quit

lab2	write "2 "
	quit

lab3	write "3a "
	write "3b"
	quit

lab4	for j=1:1:5 write j
	write " "
	quit

lab5	for j=1:1:intlimit write j
	write " "
	quit

lab6	for j=1:intincr:5 write j
	write " "
	quit

lab7	for j=1:intincr:intlimit write j
	write " "
	quit

lab8	for j=intstart:1:5 write j
	write " "
	quit

lab9	for j=intstart:intincr:5 write j
	write " "
	quit

lab10	for j=intstart:1:intlimit write j
	write " "
	quit

lab11	for j=intstart:intincr:intlimit write j
	write " "
	quit
