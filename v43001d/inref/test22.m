test22	;
	; execute a couple of DO commands, and at an execution level three deep cause an error (1/0, division by zero).
	; inside the error trap causes a new error, at the level of the error trap
	;
etst3 ;
 s $et="g er1^"_$t(+0),$ec=""
 w !,"$et=",$et
 s x=1 d
 . s x=2 d
 . . s x=3 d
 . . . s x=1/0
 . . . w !,"3 dots after error"
 . . . q
 . . w !,"2 dots after error"
 . . q
 . w !,"1 dots after error"
 . q
 w !,"no dots after error"
 q
er1 w !,"in error trap, $st=",$st," (",$st($st,"ECODE")," and ",$ec,")"
 f i=1:1:$st(-1) w !,i,": ",$st(i),!?4,$st(i,"PLACE"),": ",$st(i,"MCODE") w:$st(i,"ECODE")'="" !?4,$st(i,"ECODE")
 s $et="g er2^"_$t(+0)
 w !,"$et=",$et
 s x=2/0
 q
er2 w !,"in other error trap, $st=",$st," (",$st($st,"ECODE")," and ",$ec,")"
 f i=1:1:$st(-1) w !,i,": ",$st(i),!?4,$st(i,"PLACE"),": ",$st(i,"MCODE") w:$st(i,"ECODE")'="" !?4,$st(i,"ECODE")
 q
