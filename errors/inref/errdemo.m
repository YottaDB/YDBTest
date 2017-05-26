err ; test $e* variables
 w !,"Start, $stack should be 1: ",$STACK," / ",$ESTACK
 w !,"Initial error code is '",$ECODE,"'."
 w !,"Initial $STack(-1) = ",$STACK(-1),"."
 w !,$STACK(1,"PLACE"),": ",$STACK(1,"MCODE"),!?5,$STACK(1,"ECODE")
 s $ETRAP="w !,""Error trapped: '"",$ECODE,""', '"",$ZSTATUS,""'."" s $ECODE="""" G conti1"
 w !,"Attempt to set invalid value into $ecode: " s $ECODE="abcdefg"
 w !,"This line should not be executed."
 ;
conti1 ;
 s $ETRAP="W !,""User-trap: '"",$ECODE,""', '"",$ZSTATUS,""'."" G conti2"
 w !,"Set $ecode correctly: " s $ECODE=",U1test,"
 w !,"This line should not be executed."
 ;
conti2 ;
 w !,"$ecode is now '",$ECODE,"'."
 s $ECODE="",$ETRAP="",iterate=0,release=0
 d 1
 w !,"Back from 1"
 w !
 s $ETRAP=""
 d 4
 s x=$CHAR(65)
 q
 ;
1 w !,"In subroutine 1, $stack is ",$STACK," / ",$ESTACK
 s $ETRAP="d etr^"_$TEXT(+0)
 ;;s release=$STACK
 s test=12345
 s zz=$$2()
 w !,"Back from 2, return value is ",zz,", $ECODE = ",$ECODE
 w !,"$Ztrap is now ",$ZTRAP,", $Etrap is now ",$ETRAP
 ;d 2+5()
 s x="" f i=1:1 s x=x_(i#10)
 s $ZTRAP="",$ETRAP="",$ECODE=""
 w !,"End of error trap, $STACK = ",$STACK," / ",$ESTACK
 q
 ;
2() ;
 n $ESTACK
 ;;s release=$STACK
 w !,"In subroutine 2, $stack is ",$STACK," / ",$ESTACK,", iteration ",iterate
 w !,"$Ztrap is now ",$ZTRAP
 w !,"$ETrap is now ",$ETRAP
 d 3
 w !,"Back from 3"
 s:iterate=1 x=undefined
 q "Normal return"
 ;
3 ;
 w !,"$ecode is ",$ECODE
 w !,"---- stack ----",!
 zshow "S"
 w "--- end of stack ---"
 s release=$STACK
 s x=1/0
 w !,"Back from error, $quit=",$QUIT
 q ""
 ;
4 ;
 n $ETRAP
 n $ZTRAP
 w !,"In 4",!
 q
 ;
etr ;
 s z=$ZSTATUS
 s iterate=iterate+1 i iterate>6 h
 w !,"At error trap, $ecode is '",$ECODE,"',",!,"$zstatus=",z
 w !,"$STack(-1) = ",$STACK(-1),", $STACK = ",$STACK,", $ESTACK = ",$ESTACK,", release=",release
 w ", $ETRAP=",$ETRAP
 f i=0:1:$STACK(-1)+1 d
 . w !,i,": "
 . w $STACK(i,"PLACE"),": "
 . w $STACK(i,"MCODE")
 . s e=$STACK(i,"ECODE") w:e'="" !?5,e
 . q
 s:$STACK'>release $ECODE=""
 w !,"Leaving error trap with $ECODE=",$ECODE
 q:$q "dummy result" q 
