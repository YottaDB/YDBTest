autotp1(iterate);
	FOR i=1:1:iterate DO
	. TStart ():(serial:transaction="BA")
	. FOR j=1:1:400 SET ^a(i)=$j(i,3200)
	. FOR j=1:1:1200 SET ^b(i)=$j(i,3200)
	. FOR j=1:1:400 SET ^c(i)=$j(i,3200)
	. FOR j=1:1:400 SET ^d(i)=$j(i,3200)
	. FOR j=1:1:400 SET ^e(i)=$j(i,3200)
	. FOR j=1:1:400 SET ^f(i)=$j(i,3200)
	. FOR j=1:1:400 SET ^g(i)=$j(i,3200)
	. FOR j=1:1:400 SET ^h(i)=$j(i,3200)
	. FOR j=1:1:400 SET ^i(i)=$j(i,3200)
	. TC
	FOR i=1:1:iterate DO
	. FOR j=1:1:400 SET ^a(i)=$j(i,3200)
	. FOR j=1:1:1200 SET ^b(i)=$j(i,3200)
	. FOR j=1:1:400 SET ^c(i)=$j(i,3200)
	. FOR j=1:1:400 SET ^d(i)=$j(i,3200)
	. FOR j=1:1:400 SET ^e(i)=$j(i,3200)
	. FOR j=1:1:400 SET ^f(i)=$j(i,3200)
	. FOR j=1:1:400 SET ^g(i)=$j(i,3200)
	. FOR j=1:1:400 SET ^h(i)=$j(i,3200)
	. FOR j=1:1:400 SET ^i(i)=$j(i,3200)
	FOR i=1:1:iterate DO
	. TStart ():(serial)
	. FOR j=1:1:400 SET ^a(i)=$j(i,2400)
	. FOR j=1:1:400 SET ^b(i)=$j(i,2400)
	. FOR j=1:1:400 SET ^c(i)=$j(i,2400)
	. FOR j=1:1:400 SET ^d(i)=$j(i,2400)
	. FOR j=1:1:400 SET ^e(i)=$j(i,2400)
	. FOR j=1:1:400 SET ^f(i)=$j(i,2400)
	. FOR j=1:1:400 SET ^g(i)=$j(i,2400)
	. FOR j=1:1:400 SET ^h(i)=$j(i,2400)
	. FOR j=1:1:400 SET ^i(i)=$j(i,2400)
	. TC
	Q
