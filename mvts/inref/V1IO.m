V1IO ;IW-KO-MM-TS,V1IO,MVTS V9.10;15/6/96;I/O CONTROL
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !,"  The following table shows the parameters to use the Secondary, "
 W !,"the Tertiary, and the Log-in terminals during I/O and Multi-job testings."
 W !,"  Please fill in the blanks and/or edit if there are incorrect parameters."
 W !!,"       The following questions are only for testing I/O competition "
 W !,"    and multi-job.  Do not use the log-in terminal of the multi-job tests "
 W !,"    as the secondary and the tertiary devices."
 D YES17^VENVIRO2
 ;
 W !!,"194---V1IO: Various I/O control",!
 S ^NEXT="V1MJA^VV1"
 S SAVEIO=$IO ;(test corrected in V7.3;20/6/88)
 S DEFAULT=^VENVIRON("DEFAULT") ;(test changed in V7.5;20/8/90)
 S X("OPEN")=^VENVIRON("#1 OPEN")
 S X("USE")=^VENVIRON("#1 USE")
 S X("CLOSE")=^VENVIRON("#1 CLOSE")
 ;
 W !,"THIS ROUTINE (194---V1IO) OPEN, USE, CLOSE, $X, $Y, $IO and $JOB."
START U DEFAULT ;(test corrected in V7.3;20/6/88)
 S JOB(0)=$JOB,IO(0)=$IO,XCOR(0)=$X,YCOR(0)=$Y ;DEFAULT DEVICE
 ;
 OPEN X("OPEN")
 S JOB(532)=$JOB,IO(532)=$IO,XCOR(532)=$X,YCOR(532)=$Y ;= = = =
 USE X("USE") W #
 S JOB(533)=$JOB,IO(533)=$IO,XCOR(533)=$X,YCOR(533)=$Y ;= X 0 0
 CLOSE X("CLOSE")
 S JOB(534)=$JOB,IO(534)=$IO I $IO'="" S XCOR(534)=$X,YCOR(534)=$Y ;= = = = ;(test corrected in V7.3;20/6/88)
 ;
 U DEFAULT ;(test corrected in V7.3;20/6/88)
 ;
 O:0 X("OPEN")
 S JOB(5380)=$JOB,IO(5380)=$IO,XCOR(5380)=$X,YCOR(5380)=$Y ;= = = =
 O:1 X("OPEN")
 S JOB(5381)=$JOB,IO(5381)=$IO,XCOR(5381)=$X,YCOR(5381)=$Y ;= = = =
 U:0 X("USE")
 S JOB(5390)=$JOB,IO(5390)=$IO,XCOR(5390)=$X,YCOR(5390)=$Y ;= = = =
 U:1 X("USE")
 S JOB(5391)=$JOB,IO(5391)=$IO,XCOR(5391)=$X,YCOR(5391)=$Y ;= X 0 0
 C:0 X("CLOSE")
 S JOB(5400)=$JOB,IO(5400)=$IO,XCOR(5400)=$X,YCOR(5400)=$Y ;= X 0 0
 C:2 X("CLOSE")
 S JOB(5401)=$JOB,IO(5401)=$IO I $IO'="" S XCOR(5401)=$X,YCOR(5401)=$Y ;= = = = ;(test corrected in V7.3;20/6/88)
 ;
 U DEFAULT ;(test corrected in V7.3;20/6/88)
 ;
 S ARG=X("OPEN") I ARG'[":(" S ARG=ARG_":"
 S ARG=ARG_":10"
 I 0 ;$TEST <-- 0
 ;OPEN X("OPEN")::10
 OPEN ARG
 S JOB(5411)=$JOB,IO(5411)=$IO,T(5411)=$TEST,XCOR(5411)=$X,YCOR(5411)=$Y
 USE X("USE")
 S JOB(5412)=$J,IO(5412)=$I,T(5412)=$T,XCOR(5412)=$X,YCOR(5412)=$Y
 CLOSE X("CLOSE")
 S JOB(5413)=$J,IO(5413)=$I,T(5413)=$T I $I'="" S XCOR(5413)=$X,YCOR(5413)=$Y ;(test corrected in V7.3;20/6/88)
 ;
 U DEFAULT ;(test corrected in V7.3;20/6/88)
 ;
 OPEN X("OPEN")
 S JOB(551)=$JOB,IO(548)=$IO
 W #!!,"THIS OUTPUT SHOULD BE ON THE PRINCIPAL DEVICE",!,"    "
 S XCOR(1)=$X,YCOR(1)=$Y ;4 3
 U X("USE") ;0 0
 S JOB(5521)=$JOB,IO(5491)=$IO
 W !!
 S XCOR(2)=$X,YCOR(2)=$Y ;0 2
 W !?10
 S XCOR(3)=$X,YCOR(3)=$Y ;10 3
 W "THIS LINE SHOULD BE ON THE OTHER DEVICE",!,"   "
 S XCOR(4)=$X,YCOR(4)=$Y ;3 4
 W ?11,"GRAPHICS"
 S XCOR(5)=$X,YCOR(5)=$Y ;19 4
 ;
 U DEFAULT ;(test corrected in V7.3;20/6/88)
 ;
 S JOB(5520)=$JOB,IO(5490)=$IO
 U X("USE") S JOB(5522)=$JOB,IO(5492)=$IO
 S XCOR(6)=$X,YCOR(6)=$Y ;19 4
 W !,"ABC"
 S XCOR(7)=$X,YCOR(7)=$Y ;3 5
 ;
 W !!,"End of V1IO" W #
 ;
 C X("CLOSE") ;U 0 ;-del- (test corrected in V7.3;20/6/88)
 S JOB(553)=$JOB,IO(550)=$IO I $IO'="" S XCOR(8)=$X,YCOR(8)=$Y ;4 3 ;(test corrected in V7.3;20/6/88)
 ;
 I $D(^VENVIRON("OUTPUT OPEN"))=1 I X("OPEN")=^VENVIRON("OUTPUT OPEN") O X("OPEN") ;(test corrected in V7.3;20/6/88)
 I $D(^VENVIRON("INPUT OPEN"))=1 I X("OPEN")=^VENVIRON("INPUT OPEN") O X("OPEN")
 I X("OPEN")=SAVEIO O X("OPEN")
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE")
 E  U SAVEIO ;(test corrected in V7.3;20/6/88)
 ;
 D ^V1IO1
 D ^V1IO2
END ;U 0 ;(test corrected in V7.3;20/6/88)
 I $D(^VENVIRON("OUTPUT USE"))=1 U ^VENVIRON("OUTPUT USE") ;(test corrected in V7.3;20/6/88)
 E  U SAVEIO
 ;
 W !!,"End of 194---V1IO",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
