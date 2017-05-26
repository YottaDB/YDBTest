VENVIRON ;IW-OK-TS,VV1/2/3/4,VV4TP,MVTS V9.10;15/7/96;UTILITY
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1988-1996
 ;K ^VENVIRON
 D TITL^VENVIRO2
 F %QQQ=1:1:32 D @%QQQ S ^VENVIRON(SUB)=D
 D YES^VENVIRO2
 O ^VENVIRON("OUTPUT OPEN")
 O ^VENVIRON("INPUT OPEN")
 S ^VENVIRON("COMPLETE")=$H
 Q
EDIT D YES^VENVIRO2
 O ^VENVIRON("OUTPUT OPEN")
 O ^VENVIRON("INPUT OPEN")
 S ^VENVIRON("COMPLETE")=$H
 Q
1 W !,"1. " D 1^VENVIRO2 R D I D="" G 1
 Q
2 W !,"2. " D 2^VENVIRO2 R D I D="" G 2
 Q
3 W !,"3. " D 3^VENVIRO2 R D I D="" G 3
 Q
4 W !,"4. " D 4^VENVIRO2 R D I D="" G 4
 Q
5 W !!,"      For the question on the ""Host Computer System"", enter the computer"
 W !,"    system where MUMPS source programs are transformed into executable form."
 W !!,"      For the question on the ""Target Computer System"", enter the computer"
 W !,"    system where the executable form of MUMPS are executed.",!
 W !,"5. " D 5^VENVIRO2 R D I D="" G 5
 Q
6 W !,"6. " D 6^VENVIRO2 R D I D="" G 6
 Q
7 W !,"7. " D 7^VENVIRO2 R D I D="" G 7
 Q
8 W !,"8. " D 8^VENVIRO2 R D I D="" G 8
 Q
9 W !,"9. " D 9^VENVIRO2 R D I D="" G 9
 Q
10 W !,"10.   Its precise OPEN Argument, with Parameters if any."
 W !,"      (Do not place time-out!): "
 S R=48,SUB="INPUT OPEN" R D I D="" G 10
 Q
11 W !,"11. " D 11^VENVIRO2 R D I D="" G 11
 Q
12 S R=29,SUB="DEFAULT"
 W !,"12.    Its default USE Argument (e.g., 0) : " R D I D="" G 12
 Q
13 W !,"13. " D 13^VENVIRO2 R D I D="" G 13
 Q
14 W !,"14.   Its precise OPEN Argument, with Parameters if any."
 W !,"      (Do not place time-out!): "
 S R=25,SUB="OUTPUT OPEN" R D I D="" G 14
 Q
15 W !,"15. " D 15^VENVIRO2 R D I D="" G 15
 Q
16 W !,"16. " D 16^VENVIRO2 R D I D="" G 16
 Q
17 W !!,"       The following questions are only for testing I/O competition "
 W !,"    and multi-job.  Do not use the log-in terminal of the multi-job tests "
 W !,"    as the secondary and the tertiary devices."
 W !,"       If the questions are ignored by only <CR>'s, they will be questioned"
 W !,"    again just before the testings on OPEN, USE, CLOSE, $X, $Y, $IO, and"
 W !,"    Multi-job (V1IO).",!
170 W !,"17. " D 17^VENVIRO2 R D Q
180 ;
18 W !,"18.   Its precise OPEN Argument, with Parameters if any."
 W !,"      (Do not place time-out!): "
 S R=41,SUB="#1 OPEN" R D I D=^VENVIRON("OUTPUT OPEN") G 18
 Q
190 ;
19 W !,"19. " D 19^VENVIRO2 R D
 Q
200 ;
20 W !,"20. " D 20^VENVIRO2 R D
 Q
210 ;
21 W !,"21. " D 21^VENVIRO2 R D
 Q
220 ;
22 W !,"22.   Its precise OPEN Argument, with Parameters if any."
 W !,"      (Do not place time-out!): "
 S R=41,SUB="#2 OPEN"
 R D
 I D="" Q
 I D=^VENVIRON("OUTPUT OPEN") G 22
 I D=^VENVIRON("#1 OPEN") G 22
 Q
230 ;
23 W !,"23. " D 23^VENVIRO2 R D
 Q
240 ;
24 W !,"24. " D 24^VENVIRO2 R D
 Q
250 ;
25 S SUB="TURNED ON"
 W !,"25.   Are the secondary and the tertiary devices, and the log-in terminal"
 R !,"      for the partition of another job turned ON? (Yy/Nn + <CR>): ",D
 I D="Y" S D="YES" Q
 I D="y" S D="YES" Q
 I D="N" S D="OFF" Q
 I D="n" S D="OFF" Q
 G 25
26 S SUB="#3 MODEL"
 W !,"26. The Printer you want the VSR printed (13, 17, 21, or E/lse) ... "
 W !,"    When Else is chosen, its precise OPEN Argument with Parameters, etc."
 W !,"    are asked. Otherwise these parameters will be selected automatically.)"
 R !,"    (13, 17, 21, or E/lse) : ",D
 I D=13 S ^VENVIRON("#3 MODEL")=^VENVIRON("OUTPUT MODEL"),^VENVIRON("#3 OPEN")=^VENVIRON("OUTPUT OPEN"),^VENVIRON("#3 USE")=^VENVIRON("OUTPUT USE"),^VENVIRON("#3 CLOSE")=^VENVIRON("OUTPUT CLOSE") S %QQQ=29,D=^VENVIRON("#3 MODEL") Q
 I D=17 S ^VENVIRON("#3 MODEL")=^VENVIRON("#1 MODEL"),^VENVIRON("#3 OPEN")=^VENVIRON("#1 OPEN"),^VENVIRON("#3 USE")=^VENVIRON("#1 USE"),^VENVIRON("#3 CLOSE")=^VENVIRON("#1 CLOSE") S %QQQ=29,D=^VENVIRON("#3 MODEL") Q
 I D=21 S ^VENVIRON("#3 MODEL")=^VENVIRON("#2 MODEL"),^VENVIRON("#3 OPEN")=^VENVIRON("#2 OPEN"),^VENVIRON("#3 USE")=^VENVIRON("#2 USE"),^VENVIRON("#3 CLOSE")=^VENVIRON("#2 CLOSE") S %QQQ=29,D=^VENVIRON("#3 MODEL") Q
 I D="E" W !,"    " D 26^VENVIRO2 R D Q
 I D="e" W !,"    " D 26^VENVIRO2 R D Q
 G 26
27 W !,"27. " D 27^VENVIRO2 R D
 Q
28 W !,"28. " D 28^VENVIRO2 R D
 Q
29 W !,"29. " D 29^VENVIRO2 R D
 Q
30 W !,"30. The Output Device for VSR as Sequential File is required."
 W !,"               (Do not use an existing filename!)"
 W !,"      Device for the Text File with precise OPEN Argument with Parameters:"
 W !,"      (<CR> to ignore) "
 W !,"         Ex:  51:(""VSR.LOG"":""W""),  10:(file=""VSR.LOG"":mode=""W"")"
 W !,"      "
 S R=48,SUB="#4 OPEN"
 R D I D="" S %QQQ=99,D="Ignore",^VENVIRON("#4 USE")="Ignore",^VENVIRON("#4 CLOSE")="Ignore"
 Q
31 W !,"31. " D 31^VENVIRO2 R D
 Q
32 W !,"32. " D 32^VENVIRO2 R D
 Q
 ;
TBL D TBL1^VENVIRO2 D WL^VENVIRO2 W !
 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
