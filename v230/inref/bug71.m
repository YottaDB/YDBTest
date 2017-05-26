	;indirect $SELECT
	s mmfncd="abc",x="$s(mmfncd'="""":("">""_mmfncd),1:""no got it"")"
	w $s(mmfncd'="":(">"_mmfncd),1:"no got it")
	s @("t="_x)
	w t
