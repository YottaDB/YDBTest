RESTORE ;RESTORE VALIDATION ROUTINES (SAMPLE PROGRAM)
 ;
OPEN S DEV=47
 OPEN DEV:("AVL4":0:2048)
 S AA="X BB Q:%TP=""""  ZINSERT %TP"
 S BB=$P($T(READ)," ",2,999)
RTNS D READ
 I %TP="" G DONE ;EXIT RTNS
 D RSTOR G RTNS
RSTOR ;
 S %Q=0
 S TYP=$P(%TP," ",2) ;"START ROUTINES"
 D READ S DAT=%TP
 D READ S TTL=%TP
 W !!,TYP," SAVED ",DAT
 W !,"TITLED: ",TTL,!
R2 D READ
 I %TP="END ROUTINES" Q  ;EXIT RSTOR
 S RTN=%TP X ("ZREMOVE  F I=0:0 X AA I %TP="""" ZSAVE @RTN Q")
 U 0 W ?%Q#8*10,RTN S %Q=%Q+1 W:'(%Q#8) !
 G R2
 ;
READ U DEV R %TP U 0
 Q
DONE CLOSE DEV
 K  Q  ;EXIT
 ;
 ;ZREMOVE .......... Delete all the lines in the partition.
 ;ZINSERT strling .. Insert a sting literal in the partition as a routine line,
 ;                   Next ZINSRT does the same immediately following the
 ;                   previous line.
 ;ZSAVE rnam ......  The program in the partition is saved as a routine with
 ;                   the same of rnam.
