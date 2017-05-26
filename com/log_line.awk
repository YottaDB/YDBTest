BEGIN{total = split(ENVIRON[ "tst_options_all" ],option_names," ")
	for (i=1;i<=total;i++)
	{ x=option_names[i]
	  envir[i] = ENVIRON[x]
	}
}
{printf $0; 
for (i=1;i<=total;i++) printf "," envir[i]
}
