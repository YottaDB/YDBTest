c002863	;
	; Test to create a REPLOFFJNLON error.
ST      ;Test
        K ^XTEST
        S $ZT="ERR^"_$T(+0),VAR="SCHNULLI",YM=0
        D set^%GBLDEF("^XTEST",1,0)
        S ^XTEST(YM)="Test"
        W $D(^XTEST(YM))
        D TEST2
        Q
TEST2   W $D(^XTEST(YM))
        D @VAR
        Q
ERR     W $D(^XTEST(YM))
        Q
