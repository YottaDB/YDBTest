#!/usr/local/bin/tcsh -f
## Sample Usage:
#  eval.csh 2^5
#  Hexadecimal [20] : Decimal [32]

if ($1 == "") exit

foreach value ($*)
	$gtm_tst/com/radixconvert.csh d2h $value
end
