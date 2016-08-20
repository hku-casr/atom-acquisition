/*improvised combine1.cpp...it outputs 8 bits in a line in the right format. First file is op1 and op2 which have 1024 interleaved data so as to maintain 10gbps */ 
/* no need to use 2bit1.sh */

#define NONE 0
#define PUTA 1
#define PUTB 2
#define PUTAB 3


#include <iostream>
#include <string>
#include <fstream>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

using namespace std;

void finalCombine(char * A, char * B, char * out){
    FILE *fileA;
    FILE *fileB;
    FILE *fileOut;
    
    fileA = fopen(A, "r");
    fileB = fopen(B, "r");
    remove(out);
    fileOut = fopen(out, "w");
    
    int i,j,k;
    int numlines=1024;
    char dataA[2048][40],dataB[2048][40];
    
    printf("Forming Big Plot\n");
    
    while(! feof (fileA) && ! feof (fileB)){
            
        for(i=1;i<=numlines;i++){
            fgets(dataA[i], sizeof(dataA[i]), fileA);
            fgets(dataB[i], sizeof(dataB[i]), fileB);
        }
        
        for(i=1;i<=numlines;i++){
            k=0;
            for(j=1;j<=16;j++) {
                fprintf (fileOut, "%c%c\n", dataA[i][k], dataA[i][k+1]);
                k=k+2;
            }
        }
        
        for(i=1;i<=numlines;i++){
            k=0;
            for(j=1;j<=16;j++) {
                fprintf (fileOut, "%c%c\n", dataB[i][k], dataB[i][k+1]);
                k=k+2;
            }
        }         
    }
    printf("Done forming Big Plot\n");
    
    fclose(fileA);
    fclose(fileB);
    fclose(fileOut);
    
}

int getNumOfFile(char* dir){
    FILE *fpipe;
    char command[100];
    sprintf(command, "cd %s ;ls | grep tmp | wc -l; cd ..", dir);
    
    char c[100];
    
    if (0 == (fpipe = (FILE*)popen(command, "r")))
    {
        perror("popen() failed.");
        exit(1);
    }
    
    fgets(c, sizeof(c), fpipe);
    int i = atoi(c);
    
    pclose(fpipe);
        
    return i;
   
}

void interleave(char* dirA, char* dirB, char* out){
    int state = NONE;
    
    remove(out);
    FILE *fOut;
    fOut = fopen(out, "w");
    
    
    int numA = getNumOfFile(dirA);
    int numB = getNumOfFile(dirB);
    
    char fileNameA[50];FILE* fileA; char lineA[20]; char * retA=0;
    char fileNameB[50];FILE* fileB; char lineB[20]; char * retB=0;
    
      
    int fileCountA = 0; int fileCountB = 0;
    while (fileCountA <= numA && fileCountB <= numB){
        
        if (state == PUTA || state == PUTAB) {
            retA = fgets(lineA, sizeof(lineA), fileA);
        }
        if (state == PUTB || state == PUTAB) {
            retB = fgets(lineB, sizeof(lineB), fileB);
        }
        
        
        
        if (retA == 0 && retB != 0){//A got nothing but B is with content
            fclose(fileA);
            fileCountA++;
            sprintf(fileNameA, "%s/%d.tmp", dirA, fileCountA);
            fileA = fopen(fileNameA, "r"); 
            
            state = PUTA;//assume a newer file would consist of content  
            
            if (fileCountA>numA){
                cerr<<"Interleaving ended because of missing "<<fileNameA<<"\n";
            }else{
                cerr<<"Missing Data, proceed "<<fileNameA<<"\n";   
            }
            
        }else if (retA != 0 && retB == 0){
            fclose(fileB);
            fileCountB++;
            sprintf(fileNameB, "%s/%d.tmp", dirB, fileCountB);
            fileB = fopen(fileNameB, "r");  
            
            state = PUTB;//assume a newer file would consist of content 
            
            if (fileCountB>numB){
                cerr<<"Interleaving ended because of missing "<<fileNameB<<"\n";
            }else{
                cerr<<"Missing Data, proceed "<<fileNameB<<"\n";  
            }    
        }else if (retA != 0 && retB != 0){
            state = PUTAB;
            lineA[strlen(lineA)-1] = '\0';
            fputs(lineA, fOut);
            fputs(lineB, fOut);
        }else{

            fileCountA++;
            sprintf(fileNameA, "%s/%d.tmp", dirA, fileCountA);
            fileA = fopen(fileNameA, "r"); 
            
            fileCountB++;
            sprintf(fileNameB, "%s/%d.tmp", dirB, fileCountB);
            fileB = fopen(fileNameB, "r"); 
            
            state = PUTAB;    
            
                        
        }


    }
    fclose(fOut);

}

int main(int argc, char ** argv){
    if (argc != 6){
        cout<<"usage: "<< argv[0] <<" <inputDirectory1> <inputDirectory2> <inputDirectory3> <inputDirectory4> <onputFileName>\n";
    }
    char tmp1[]= "temp1";
    char tmp2[]= "temp2";
    interleave(argv[1], argv[2], tmp1);
    interleave(argv[3], argv[4], tmp2);
    
    
    finalCombine(tmp1, tmp2, argv[5]);
    
    remove(tmp1);
    remove(tmp2);
    
}


