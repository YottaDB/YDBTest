MPTDAT	;validation of %date/time conversions
	S PASS=0,FAIL=0,ITEM=""
	W !!,"MPTDAT: TEST OF %DATE/TIME CONVERSIONS"

153	W !,"I-162/153  date conversions"
	S ITEM="I-162/153.0  current date"
	D INT^%D
	S VCOMP=%DAT
	S VCORR=$$FUNC^%D
	D EXAMINER
	S ITEM="I-162/153.1  %DATE, %H - date to horolog and reverse"
	S VCOMP=""
	S %DT=$$FUNC^%DATE("2/29/1884")  D %CDS^%H  S VCOMP=VCOMP_%DT_"|"_%DAT_" "
	S %DT=$$FUNC^%DATE("2-29-84")    D %CDS^%H  S VCOMP=VCOMP_%DT_"|"_%DAT_" "
	S %DT=$$FUNC^%DATE("01/31/1985") D %CDS^%H  S VCOMP=VCOMP_%DT_"|"_%DAT_" "
	S %DT=$$FUNC^%DATE("31 Mar 84")  D %CDS^%H  S VCOMP=VCOMP_%DT_"|"_%DAT_" "
	S %DT=$$FUNC^%DATE("31 DEC 1999")  D %CDS^%H  S VCOMP=VCOMP_%DT_"|"_%DAT_" "
	S %DT=$$FUNC^%DATE("31 Dec, 2000") D %CDS^%H  S VCOMP=VCOMP_%DT_"|"_%DAT_" "
	S %DT=$$FUNC^%DATE("02/28/02")     D %CDS^%H  S VCOMP=VCOMP_%DT_"|"_%DAT_" "
	S VCORR="15765|2/29/1884 52289|2/29/1984 52626|1/31/1985 52320|3/31/1984 58073|12/31/1999 58439|12/31/2000 22338|2/28/1902 "
	D EXAMINER
	S ITEM="I-162/153.2  %H - date to horolog and reverse"
	S VCOMP=""
	S %DT="2/29/1884"   D %CDN^%H  S %DT=%DAT D %CDS^%H  S VCOMP=VCOMP_%DT_"|"_%DAT_" "
	S %DT="2/29/84"     D %CDN^%H  S %DT=%DAT D %CDS^%H  S VCOMP=VCOMP_%DT_"|"_%DAT_" "
	S %DT="01/31/1985"  D %CDN^%H  S %DT=%DAT D %CDS^%H  S VCOMP=VCOMP_%DT_"|"_%DAT_" "
	S %DT="03/31/84"   D %CDN^%H  S %DT=%DAT D %CDS^%H  S VCOMP=VCOMP_%DT_"|"_%DAT_" "
	S %DT="12/31/1999"  D %CDN^%H  S %DT=%DAT D %CDS^%H  S VCOMP=VCOMP_%DT_"|"_%DAT_" "
	S %DT="12/31/2000" D %CDN^%H  S %DT=%DAT D %CDS^%H  S VCOMP=VCOMP_%DT_"|"_%DAT_" "
	S %DT="02/28/02"     D %CDN^%H  S %DT=%DAT D %CDS^%H  S VCOMP=VCOMP_%DT_"|"_%DAT_" "
	S VCORR="15765|2/29/1884 52289|2/29/1984 52626|1/31/1985 52320|3/31/1984 58073|12/31/1999 58439|12/31/2000 22338|2/28/1902 "
 	D EXAMINER
154	W !,"I-162/154  time conversions"
	S ITEM="I-162/154.0  current time"
	D INT^%T
	S VCOMP=%TIM
	S VCORR=$$FUNC^%T
	D EXAMINER
	S ITEM="I-162/153.1  %TI, %H - time to horolog and reverse"
	S VCOMP=""
	S %TN=$$FUNC^%TI("M")       D ^%TO  S VCOMP=VCOMP_%TN_"|"_%TS_"  "
	S %TN=$$FUNC^%TI("12:00 A") D ^%TO  S VCOMP=VCOMP_%TN_"|"_%TS_"  "
	S %TN=$$FUNC^%TI("12:00 P") D ^%TO  S VCOMP=VCOMP_%TN_"|"_%TS_"  "
	S %TN=$$FUNC^%TI("12:00AM")   D ^%TO  S VCOMP=VCOMP_%TN_"|"_%TS_"  "
	S %TN=$$FUNC^%TI("N")       D ^%TO  S VCOMP=VCOMP_%TN_"|"_%TS_"  "
	S %TN=$$FUNC^%TI("1959")    D ^%TO  S VCOMP=VCOMP_%TN_"|"_%TS_"  "
	S %TN=$$FUNC^%TI("03:39P")   D ^%TO  S VCOMP=VCOMP_%TN_"|"_%TS_"  "
	S VCORR="0|12:00 AM  0|12:00 AM  43200|12:00 PM  0|12:00 AM  43200|12:00 PM  71940|7:59 PM  56340|3:39 PM  "
	D EXAMINER
	S ITEM="I-162/153.2  %H - time to horolog and reverse"
	S VCOMP=""
	S %TM="00:00:01A"       D %CTN^%H  S VCOMP=VCOMP_%TIM_" "
	S %TM="12:00 A" D %CTN^%H  S VCOMP=VCOMP_%TIM_" "
	S %TM="12:00 P" D %CTN^%H  S VCOMP=VCOMP_%TIM_" "
	S %TM="12:00PM" D %CTN^%H  S VCOMP=VCOMP_%TIM_" "
	S %TM="11:59:59AM"       D %CTN^%H  S VCOMP=VCOMP_%TIM_" "
	S %TM="07:59P"    D %CTN^%H  S VCOMP=VCOMP_%TIM_" "
	S %TM="12:59:59PM" D %CTN^%H  S VCOMP=VCOMP_%TIM_" "
	S VCORR="1 43200 43200 43200 43199 28740 46799 "
	D EXAMINER
	;
END	W !!,"END OF MPTDAT",!
	K  Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
