VV2DOC3	;VV2DOC V.7.1 -3-;TS,VV2DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-II
	;
	;Lower case letter function names ( less $data )
	;and special variable names -1-
	;     (VV2LCF1)
	;
	;     II-33. $ascii
	;     II-34. $a
	;     II-35. $char
	;     II-36. $c
	;     II-37. $extract
	;     II-38. $e
	;     II-39. $find
	;     II-40. $f
	;     II-41. $justify
	;     II-42. $j
	;     II-43. $length
	;     II-44. $l
	;     II-45. $next
	;     II-46. $n
	;     II-47. $order
	;     II-48. $o
	;     II-49. $piece
	;     II-50. $p
	;
	;
	;Lower case letter function names ( less $data )
	;and special variable names -2-
	;     (VV2LCF2)
	;
	;     II-51. $random
	;     II-52. $r
	;     II-53. $select
	;     II-54. $s
	;     II-55. $text
	;     II-56. $t
	;     II-57. $x
	;     II-58. $y
	;     II-59. $io
	;     II-60. $i
	;     II-61. $job
	;     II-62. $j
	;     II-63. $horolog
	;     II-64. $h
	;     II-65. $storage
	;     II-66. $s
	;     II-67. $test
