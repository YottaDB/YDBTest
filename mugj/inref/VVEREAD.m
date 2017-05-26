VVEREAD	;READ COMMAND;TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	;
READ	W !,"III-18  P.I-43 I-3.6.14  READ command"
	W !,"When the form of the argument is lvn # intexpr [timeout], let n be the"
	W !,"value of intexpr. It is erroneous if n <=0."
	Q
	;
1	W !,"III-18  P.I-43 I-3.6.14  READ command"
	W !,"        When the form of the argument is lvn # intexpr [timeout], let n be the"
	W !,"        value of intexpr. It is erroneous if n <=0."
	W !!,"III-18.1  K A READ A#-1   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEREAD^1^III-18.1"
	K A READ A#-1
	W !!,"** Failure in producing ERROR for III-18.1",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEREAD^1^III-18.1^defect"
	Q
	;
2	W !,"III-18  P.I-43 I-3.6.14  READ command"
	W !,"        When the form of the argument is lvn # intexpr [timeout], let n be the"
	W !,"        value of intexpr. It is erroneous if n <=0."
	W !!,"III-18.2  S A=99 R A#-999999999   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEREAD^2^III-18.2"
	S A=99 R A#-999999999
	W !!,"** Failure in producing ERROR for III-18.2",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEREAD^2^III-18.2^defect"
	Q
	;
3	W !,"III-18  P.I-43 I-3.6.14  READ command"
	W !,"        When the form of the argument is lvn # intexpr [timeout], let n be the"
	W !,"        value of intexpr. It is erroneous if n <=0."
	W !!,"III-18.3  S A=123,B=0 R A#B   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEREAD^3^III-18.3"
	S A=123,B=0 R A#B
	W !!,"** Failure in producing ERROR for III-18.3",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEREAD^3^III-18.3^defect"
	Q
	;
4	W !,"III-18  P.I-43 I-3.6.14  READ command"
	W !,"        When the form of the argument is lvn # intexpr [timeout], let n be the"
	W !,"        value of intexpr. It is erroneous if n <=0."
	W !!,"III-18.4  K B S A=-3 R B#A:10   (visual)",!
	S ^VREPORT(0)=^VREPORT(0)+1
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEREAD^4^III-18.4"
	K B S A=-3 R B#A:10
	W !!,"** Failure in producing ERROR for III-18.4",!
	S SEQ=^VREPORT(0)
	S ^VREPORT(SEQ)="VVEREAD^4^III-18.4^defect"
	Q
	;
