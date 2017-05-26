locks101	; Very simple testing
		w "very basic locks testing",!
		L
		w "noone:",!
		zshow "l"
		l ^A
		w "lock ^A (local)",!
		zshow "l"
		w "Lock ^B (server 2)",!
		l ^B
		lock +^BLONGGLOBALVARIBALE
		lock +^BLONGGLO
		zshow "l"
		w "Lock ^C (server 1)",!
		l ^C
		lock +^CLONGGLOBALVARIBALE
		lock +^CLONGGLO
		zshow "l"
		w "Release all",!
		l
		zshow "l"
		q
