init(glo,begin,end)
	set a="^"_glo_"(val)"
	for val=begin:1:end d
	. set @a=val+val
	quit
