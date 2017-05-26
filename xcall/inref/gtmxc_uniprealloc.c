#include <string.h>
#include "shrenv.h"
#include "gtm_stdio.h"
#include "gtmxc_types.h"

#ifdef __MVS__
#pragma export(xc_pre_alloc_a)
#endif

/* Note that without preallocation by default GT.M allocates 100 bytes for  char * type */
void	xc_pre_alloc_a (int count, char  arg_prealloca[])
{
	strcpy(arg_prealloca, "αβγ Message");
	fflush (stdout);

	return;
}
void	xc_new_alloc_32k (int count, xc_char_t*  arg_prealloca)
{
	char a[32768];
	int i;
	strcpy(a,"β");
	for(i=2;i<=16383;i++) 
		strcat(a,"β");
	strcpy(arg_prealloca,a);	

	return;
}	
void	xc_new_alloc_64k (int count, xc_char_t*  arg_prealloca)
{
	char a[65536];
	int i;
	strcpy(a,"私");
	for(i=2;i<=21845;i++) 
		strcat(a,"私");
	strcpy(arg_prealloca,a);	
	fflush (stdout);

	return;
}	
void	xc_new_alloc_75k (int count, xc_char_t*  arg_prealloca)
{
	char a[75000];
	int i;
	strcpy(a,"は");
	for(i=2;i<=24999;i++) 
		strcat(a,"は");
	strcpy(arg_prealloca,a);	
	fflush (stdout);

	return;
}	
void	xc_new_alloc_1mb (int count, xc_char_t*  arg_prealloca)
{
	char a[1048576];
	int i;
	strcpy(a,"𠞉");
	for(i=2;i<=262143;i++) 
		strcat(a,"𠞉");
	strcpy(arg_prealloca,a);	
	fflush (stdout);

	return;
}

