; Progressively increases spanning block sizes.
; This is called from loadextract.csh until it hits the upper limit.
load(maxrecsize)
	set span="begin"_$j(" end",maxrecsize\4)
	set nospan="nospan"
	set bogusdummy=$char(0)
	
	set ^a(1)=span
	set ^a(2)=nospan
	set ^a(3)=bogusdummy

	set span=$j(span,maxrecsize\2)
	
	set ^a(11)=nospan
	set ^a(12)=span
	set ^a(13)=bogusdummy
	
	set span=$j(span,maxrecsize\1.75)
	
	set ^a(21)=bogusdummy
	set ^a(22)=span
	set ^a(23)=nospan
	
	
	set span=$j(span,maxrecsize\1.5)
	set ^a(31)=bogusdummy
	set ^a(32)=nospan
	set ^a(33)=span
	
	set span=$j(span,maxrecsize\1.25)
	set ^a(41)=nospan
	set ^a(42)=bogusdummy
	set ^a(43)=span
	
	set span=$j(span,maxrecsize)
	set ^a(51)=span
	set ^a(52)=bogusdummy
	set ^a(53)=nospan
	
	set ^a(54)=bogusdummy
	set ^a(54,0)=nospan
	set ^a(54,1)=span
	set ^a(54,1,1)=span

	set ^a(55,0,1,"abc")=span
	set ^a(55)=bogusdummy

	quit
