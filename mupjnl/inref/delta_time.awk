# delta_time.awk 100 .5 -> 50 seconds -> 0:0:50
# rounds down (to the sec.)
{
	input=$1
	multiply = $2
	input = input * multiply
	gsub(/\..*/,"",input)
	x = input % 3600
	h = (input - x) / 60
	input = x
	x = input % 60
	m = (input - x) / 60
	s = x
	print "0 " h ":" m ":" s
}
