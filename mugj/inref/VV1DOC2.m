VV1DOC2	;VV1DOC V.7.1 -2-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;     24. V1UO3B ---- Unary operator -6-   '
	;     25. V1UO4A ---- Unary operator -7-   +, -, '
	;     26. V1UO4B ---- Unary operator -8-   +, -, '
	;     27. V1UO5A ---- Unary operator -9-   +, -, '
	;     28. V1UO5B ---- Unary operator -10-  +, -, '
	;     29. V1BOA ----- Sub driver
	;     30. V1BOA1 ---- Binary operator -1.1-   +
	;     31. V1BOA2 ---- Binary operator -1.2-   -
	;     32. V1BOA3 ---- Binary operator -1.3-   *
	;     33. V1BOA4 ---- Binary operator -1.4-   /
	;     34. V1BOA5 ---- Binary operator -1.5-   #
	;     35. V1BOA6 ---- Binary operator -1.6-   \(integer division)
	;     36. V1BOB ----- Sub driver
	;     37. V1BOB1 ---- Binary operator -2.1-   <
	;     38. V1BOB2 ---- Binary operator -2.2-   '<
	;     39. V1BOB3 ---- Binary operator -2.3-   >
	;     40. V1BOB4 ---- Binary operator -2.4-   '>
	;     41. V1BOB5A --- Binary operator -2.5.1-   =
	;     42. V1BOB5B --- Binary operator -2.5.2-   =
	;     43. V1BOB6A --- Binary operator -2.6.1-   '=
	;     44. V1BOB6B --- Binary operator -2.6.2-   '=
	;     45. V1BOB7 ---- Binary operator -2.1-   [
	;     46. V1BOB8 ---- Binary operator -2.1-   '[
	;     47. V1BOB9 ---- Binary operator -2.1-   ]
	;     48. V1BOB10 --- Binary operator -2.1-   ']
	;     49. V1BOC ----- Sub driver
	;     50. V1BOC1 ---- Binary operator -3.1-   &
	;     51. V1BOC2 ---- Binary operator -3.2-   !
	;     52. V1BOC3 ---- Binary operator -3.3-   _
	;     53. V1FN ------ Sub driver
	;     54. V1FNE1 ---- Functions    $EXTRACT -1-
	;     55. V1FNE2 ---- Functions    $EXTRACT -2-
	;     56. V1FNF1 ---- Functions    $FIND -1-
	;     57. V1FNF2 ---- Functions    $FIND -2-
	;     58. V1FNF3 ---- Functions    $FIND -3-
	;     59. V1FNL ----- Functions    $LENGTH
	;     60. V1FNP1 ---- Functions    $PIECE -1-
	;     61. V1FNP2 ---- Functions    $PIECE -2-
	;     62. V1AC  ----- Sub driver
	;     63. V1AC1 ----- $ASCII and $CHAR functions -1-
	;     64. V1AC2 ----- $ASCII and $CHAR functions -2-
	;     65. V1LVN ----- Local variable name
	;     66. V1GVN ----- Global variable name
	;     67. V1DLA ----- $DATA and KILL of local variables -1-
	;                       $DATA of unsubscripted local variable and KILL command
