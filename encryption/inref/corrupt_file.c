#include <sys/types.h>
#include <stdio.h>
#include <errno.h>

int main(int argc, char *argv[])
{
        int offset;
	FILE *fp;
	char buff;
        if (argc != 3)
        {
             printf("usage:<filename> <Offset value>");
             return 1;
        }
        else
        {
	     if((fp=fopen(argv[1],"rb+"))==NULL)
	     {
	            printf("file not found");
	            return 1;
	     }
	      else
		{
		        offset = atoi(argv[2]);
                	fseek(fp,offset,0);
                	buff=fgetc(fp);
                	buff=buff+1;
                	fseek(fp,offset,0);
			fputc(buff,fp);
         	}      	fclose(fp);
        } 	
         return 0;
 }
