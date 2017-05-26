/-----------------/	{allow = 1; getline}
(1 == allow) { if (4 == NF) 
		{
		#print "not this line"
		getline;
		file = $1;
		gsub(".*/","",file);
		}
	  else {
		file = $NF
		}
		print  file
}
