#!/usr/bin/awk -f
# This should preferably be called through the shell wrapper genrandnumbers.csh
BEGIN {
	srand ()
}
{
  for(i=1;i<=count;i++)
  print lower + int(rand() * (1 + upper-lower)); 
}

