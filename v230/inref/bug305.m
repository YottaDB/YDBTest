;5) It appears that some incorrect code is being generated for certain
;   branching conditions.  the file [maxifile]sctm01.m contains a
;   code fragment (this can be compiled and linked) that when run
;   seems to produce impossible results (or at least incorrect).
;   Note the following:  
;	a) the node ^cdx("dv","ch",%io) is defined (you may have to do this).
;	b) none the less, the line after the g: (sttm2>) is never executed.
;        c) The line at zi7+1 (sttm4>) indicates that $t is 1.  This is
;  	   impossible since the line above it sets it to 0.
;	d) as a result of the above dtcd is never given a value.
;   Code follows:
sctm01 	s %io="xy99",^cdx("dv","ch",%io)="data"
	s ^cd("dv","data","in")="hi\there"
sttm 	
 w !,"sttm1> ",$d(^cdx("dv","ch",%io)),!
 g:'($d(^cdx("dv","ch",%io))[0) zi7 w 111 i 1	
 w !,"sttm2> z1055",!
 s dtcd="z1055"	
 w !,"sttm3> ",$d(dtcd),!
 i 1 w 222 g zi8
zi7 i 0	
 w !,"sttm4> $t=",$t,!
zi8 	
 w !,"sttm4a> ",$t,!
 g:$t zi9
 w !,"sttm5> cdx",!
 s dtcd=$p(^cd("dv",^cdx("dv","ch",%io),"in"),"\",1)	
 w !,"sttm6> ",$d(dtcd),!
zi9 	
 w !,"sttm7> ",$d(dtcd),!
 q	
