rjob
        w $j,!
        for i=1:1:10000 s ^a(i)=$j(i,100)
        for i=1:1:10000 s ^b(i)=$j(i,100)
        for i=1:1:10000 s ^c(i)=$j(i,100)
	w "I am done my dear parent ....",!
	h 100		; I should be killed during this hang (by my parent)
