        Use 0
        W !,"M1 -> C -> M2"
	W !,"M2: $ZLEVEL = ",$ZLEVEL
        K ^CUST
	K ^ACCT
	S FCNUM=10001,LCNUM=10006
	S FDNUM=2221001,LDNUM=2221003
	S FLNUM=2221004,LLNUM=2221006
	S DEPGL=11110,LNGL=11111
	W !," Do ^CUST "
	D CUST
	D ACCT
	Q
CUST    
	W !,"M1 -> C -> M2 -> M3"
	W !,"M3: $ZLEVEL = ",$ZLEVEL
	S cnt=1
	N cnt S cnt=1
	S FNM(1)="One"
	S FNM(2)="Two"
	S FNM(3)="Three"
	S FNM(4)="Four"
	S FNM(5)="Five"
	S FNM(6)="Six"
	F I=FCNUM:1:LCNUM  D
	. S $P(^CUST(I,1),"|",1)=FNM(cnt)       
        . S $P(^CUST(I,1),"|",2)="Customer"     
	. I I<10 S $P(^CUST(I,2),"|",1)=cnt_(cnt-1)_cnt_"-"_(cnt-1)_(cnt\1)_"-"_(cnt#2)_(cnt\3)_(cnt-1)_cnt  
        . E  S $P(^CUST(I,2),"|",1)=(cnt-5)_(cnt-1)_(cnt-2)_"-"_(cnt-1)_(cnt\2)_"-"_(cnt#2)_(cnt\3)_(cnt-1)_(cnt-4)  
	. I I<10 S $P(^CUST(I,3),"|",1)="("_cnt_cnt_cnt_")"_"-"_(cnt#3)_(cnt\2)_cnt_"-"_(cnt#2)_(cnt\3)_(cnt\4)_cnt  
	. E  S $P(^CUST(I,3),"|",1)=(cnt-3)_(cnt-7)_(cnt-5)_"-"_(cnt-1)_(cnt\2)_(cnt-6)_"-"_(cnt#2)_(cnt\3)_(cnt-9)_(cnt-2)  
	. S $P(^CUST(I,4),"|",1)=cnt_" Customer"_cnt_" Street"
        . S $P(^CUST(I,4),"|",2)="Malvern, PA" 
        . S $P(^CUST(I,4),"|",3)=19999
	. S cnt=cnt+1 
	Q 
	;
ACCT    ; Build customer acct records
	W !,"M1 -> C -> M2 -> M3"
	W !,"M3: $ZLEVEL = ",$ZLEVEL
        N ATM1,ATM2,CODE1,CODE2,FNM,INT1,INT2,LNM,TYPE1,TYPE2
        N CNUM
	N cnt,datcnt
        S cnt=1,datcnt=1
	S TYPE1="DEP",TYPE2="LOAN"
	S CODE1="Regular",CODE2="Preferred"
	S INT1=0.05,INT2=0.09
	S ATM1="L",ATM2="N"
	S CNUM=FCNUM
	;
        F I=FDNUM:1:LDNUM  D
	. S ^ACCT(I,1)=CNUM
	. S FNM=$P(^CUST(CNUM,1),"|",2)
        . S LNM=$P(^CUST(CNUM,1),"|",1)
        . S $P(^ACCT(I,2),"|",1)=LNM_", "_FNM 
        . S $P(^ACCT(I,3),"|",1)=TYPE1 
        . I I#2 S $P(^ACCT(I,3),"|",2)=CODE1
        . E  S $P(^ACCT(I,3),"|",2)=CODE2
        . S $P(^ACCT(I,4),"|",1)=FDNUM/100
	. S $P(^ACCT(I,4),"|",2)=ATM1
        . S $P(^ACCT(I,4),"|",3)=INT1
        . S $P(^ACCT(I,5),"|",2)=""
	. S $P(^ACCT(I,6),"|",1)=FDNUM/100
	. S $P(^ACCT(I,6),"|",2)=0
	. S $P(^ACCT(I,7),"|",1)=DEPGL
	. S cnt=cnt+1
	. S CNUM=CNUM+2
	;
	S CNUM=FCNUM+1
	F I=FLNUM:1:LLNUM  D
	. S ^ACCT(I,1)=CNUM   
	. S FNM=$P(^CUST(CNUM,1),"|",2)
	. S LNM=$P(^CUST(CNUM,1),"|",1)
	. S $P(^ACCT(I,2),"|",1)=LNM_", "_FNM      
	. S $P(^ACCT(I,3),"|",1)=TYPE2 
	. I I#2 S $P(^ACCT(I,3),"|",2)=CODE2
	. E  S $P(^ACCT(I,3),"|",2)=CODE1
	. S $P(^ACCT(I,4),"|",1)=FLNUM/100
	. S $P(^ACCT(I,4),"|",2)=ATM2
	. S $P(^ACCT(I,4),"|",3)=INT2
       	. S $P(^ACCT(I,5),"|",2)=""
	. S $P(^ACCT(I,6),"|",1)=FLNUM/100
	. S $P(^ACCT(I,6),"|",2)=0
	. S $P(^ACCT(I,7),"|",1)=LNGL
	. S cnt=cnt+1 
	. S CNUM=CNUM+2
	Q
	



