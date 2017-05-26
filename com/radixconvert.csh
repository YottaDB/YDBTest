#!/usr/local/bin/tcsh -f
## Sample Usage:
# radixconvert.csh d2h 20 30 40
# Hexadecimal 14 : Decimal 20
# Hexadecimal 1E : Decimal 30
# Hexadecimal 28 : Decimal 40
#
# radixconvert.csh h2d 0000000000056765 0x56765
# Hexadecimal 0000000000056765 : Decimal 354149
# Hexadecimal 56765 : Decimal 354149

if ($1 == "") exit
set hex=""
set dec=""
set todo="$1"
shift

foreach val ($*)
	set value = "`echo $val | sed 's/0x//'| tr a-f A-F`"
	if ("h2d" == "$todo") then
		set dec=`echo "obase=10; ibase=16; $value" | bc`
		echo "Hexadecimal $value : Decimal $dec "
	else if ("d2h" == "$todo") then
		set hex=`echo "obase=16; ibase=10; $value" | bc`
		echo "Hexadecimal $hex : Decimal $value "
	endif
end
