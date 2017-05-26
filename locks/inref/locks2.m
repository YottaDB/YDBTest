locks2	; Locks regression test.  
		; Test locks :  storage ( i.e. invisible to the user )
		;		basic function
		;		timed response
		;		multiple user interaction
		;		multiple region interaction
	u 0 
	s cnt=120,$zt=""
	s unix=$zv'["VMS"
	w $zgbldir,!
	w "d TEST3",!  d TEST3
	w "d TEST8",!  d TEST8
	q


TEST3   s ^Fail=0,^["mumps1.gld"]ITEM="TEST3"
	k ^X
	f i=1:1:10000 d
	. l ^A l  
	. i i=1 d 
	. . s x=$s 
	. e  d
	. . i x'=$s  w "Error in  1, memory usage not stable.  $S was: ",x," is ",$S,! s ^Fail=^Fail+1 q
	f i=1:1:100 za ^A zd
	s ^A=5
	s ^["mumps1.gld"]A=1
	l ^A
	i ^A'=5  do EXAM("Error in extended global reference.",5,^A)
	;
	i unix d
	. job EXTREFTEST:(nodet:out="job3.log":gbl="mumps1.gld"):30 s dt=$t
	e  d
	. job EXTREFTEST:(nodet:out="job3.log":gbl="mumps1.gld":startup="startup.com"):30 s dt=$t
	i 'dt w "3 Job command timed out",! q
	f k=1:1:cnt q:$d(^D)  h 1
	i k=cnt  w "TEST3 timed out",!  s ^Fail=^Fail+1
	k ^D
	if '^Fail w "TEST3 Passed",!
	q


TEST8
	s ^Fail=0,^["mumps1.gld"]ITEM="TEST8"
	k ^B
	l (^A,a)
	i unix d
	. job DIFREGION:(nodet:out="job8.log":gbl="mumps1.gld"):30 s dt=$t
	e  d
	. job DIFREGION:(nodet:out="job8.log":gbl="mumps1.gld":startup="startup.com"):30 s dt=$t
	i 'dt w "8 Job command timed out",! q
	f k=1:1:cnt q:$d(^B)  h 1
	i k=cnt w "TEST8 timed out",!  s ^Fail=^Fail+1
	k ^B
	if '^Fail w "TEST8 Passed",!
	q


EXTREFTEST 
	w "Extended Global Reference test ",^ITEM,!
	s ^Fail=0
	s $zgbldir="mumps1.gld"
	zallocate (^A):5
	i '$T w "Extended Global reference disrupts lock management." s ^Fail=^Fail+1	
	zdeallocate
	s ^["mumps.gld"]D=1
	i '^Fail w "  PASS",!
	q

DIFREGION
	w "Different Regions test ",^ITEM,!
	s ^Fail=0
	l ^A:5 s x=$T
	i 'x w "Different Regions test failed.",! s ^Fail=^Fail+1
	l a:5 s x=$T
	i 'x w "Local lock direction failed.",! s ^Fail=^Fail+1
	s ^["mumps.gld"]B=1
	i '^Fail w "  PASS",!
	q	

EXAM(lbl,corr,comp)
	w lbl,!
	w "     COMPUTED=",comp,!
	w "     CORRECT =",corr,!
	s ^Fail=^Fail+1
	q
