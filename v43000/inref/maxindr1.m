maxindr1;
	; Test nested indirections to make sure we can have a "bunch" of them.

	Write "maxindr1 starting",!
        NEW $ZTRAP
        SET $ZT="SET $ZT="""" g ERROR"
        S vara="ROOT"
        set intmax=5
        set fltmax=5
        set nummax=5
        ;
        for i=1:1:intmax s vara(i)="VAL"_i
        for i=intmax+1:1:intmax+fltmax s vara(i)=i*10.5
        for i=intmax+fltmax+1:1:intmax+fltmax+nummax s vara(i)=i
        S X1="vara"
        S X2="@X1"
        S X3="@X2"
        FOR i=3:1:100 DO
        . SET j=i+1
        . SET lhs="X"_j
        . SET rhs="@X"_i
        . SET @lhs=""_rhs_""
        M newa=@X101
        ZWR
        Q
ERROR;
        ZSHOW "*"
        Q
