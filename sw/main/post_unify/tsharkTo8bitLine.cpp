/* adds new lines to the tshark generated data file (the tshark file is continuous data), so as to do further processing*/
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <string.h>

#include <unistd.h>
#include <sys/types.h>

using namespace std;
int main(int argc, char ** argv){
    
    if (argc != 3){
        cout<<"usage: "<< argv[0] <<" <inputFileName> <onputFileName>\n";
    }
    remove(argv[2]);
    
    ifstream infile(argv[1]);     // open file
    ofstream ofile(argv[2]);

   // ifstream infile(filename, fstream::in);
    int cnt=0;
    unsigned char a,b;
	while(infile.good()){
		cnt++;
		infile >> a;

		ofile << a;
		if (cnt ==16) {
			ofile<<"\n";
			cnt=0;
		}
	}

    infile >> hex >> b;
    ofile << a<<" "<< b;
    
    infile.close();
    ofile.close();
    
    //delete the last line
    FILE * pFile; char tmp;
    pFile = fopen (argv[2],"r");
    
    fseek(pFile, 0 ,SEEK_END);
    int sz = ftell(pFile);
    for (int i = 0; i < sz; i++ ){
        fseek(pFile, -(i*sizeof(char)),SEEK_END);
        tmp = fgetc (pFile);
   
        if (tmp == '\n'){
            fclose(pFile);
            truncate(argv[2], sz-(i-1)*sizeof(char));
            break;
        }
    }
    /*char command[300];
    char * fileName = argv[2];
    sprintf(command, "dd if=/dev/null of=%s bs=1 seek=$(echo $(stat --format=%%s %s ) - $( tail -n1 %s | wc -c) | bc )", argv[2], argv[2], argv[2]);*/
    
    
    
    //cout<<command;
    //system(command);
}
