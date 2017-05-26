extgbl1;
	s (a,b,c)=12
        f i=1:1:2 f j=1:1:2 s a(i,j)=i_j
        f i=1:1:2 f j=1:1:2 s b(i,j)=i+j
        f i=1:1:2 f j=1:1:2 s c(i,j)=i*j
        m ^|"second"|asecond=a
        m ^|"second"|bsecond=b
        m ^|"second"|csecond=c
	m ^|"second"|alongsecondvariablesworkformerg=a
	m ^|"second"|blongsecondvariablesworkformerg=b
	m ^|"second"|clongsecondvariablesworkformerg=c
other	m aa=^|"second"|asecond
	m bb=^|"second"|bsecond
	m cc=^|"second"|csecond
	m aalongsecondvariablesworkformrg=^|"second"|alongsecondvariablesworkformerg
	m bblongsecondvariablesworkformrg=^|"second"|blongsecondvariablesworkformerg
	m cclongsecondvariablesworkformrg=^|"second"|clongsecondvariablesworkformerg
	zwr
        q
