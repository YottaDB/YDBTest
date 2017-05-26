/-----------------/	{allow = 1; getline}
(1 == allow) { if (4 == NF) 
		{
		#print "not this line"
		getline;
		file = $1;
		}
	  else {
		file = $NF
		}
		print  file
}
