indrex	;
	;
	s zt=$zt,$zt="w !,$p($zs,"","",1,2),!,mes,"" failed"",! s n=1 zg zl:indrex+i"
	s n=1,i=4,zl=$zl
	s i=i+1 w !,"extrinsic test",!!
	s i=i+1 s mes="write, constant as argument" w $$f(1)
	s i=i+1 s mes="write, indirect, constant as argument" w $$@("f")(1)
	s i=i+1 s mes="write, variable as argument" w $$f(n)
	s i=i+1 s mes="write, actualname" w $$f(.n)
	s i=i+1 s mes="write, indirect, variable as argument" w $$@("f")(n)
	s i=i+1 s mes="write, indirect, actualname" w $$@("f")(.n)
	s i=i+1 s mes="set, variable as argument" s a=$$f(n) w a
	s i=i+1 s mes="set, indirect, variable as argument" s a=$$@("f")(n) w a
	s i=i+1 s mes="set, actualname" s a=$$f(.n) w a
	s i=i+1 s mes="set, indirect, actualname" s a=$$@("f")(.n) w a
	s i=i+1 s mes="set, same variable as argument" s n=$$f(n) w n
	s i=i+1 s mes="set, same variable in actualname" s n=$$f(.n) w n
	s i=i+1 s mes="set, indirect, same variable as argument" s n=$$@("f")(n) w n
	s i=i+1 s mes="set, indirect, same variable in actualname" s n=$$@("f")(.n) w n
	s $zt=zt
	q
f(x)	q x*2
