/*improvised combine1.cpp...it outputs 8 bits in a line in the right format. First file is op1 and op2 which have 1024 interleaved data so as to maintain 10gbps */ 
/* no need to use 2bit1.sh */
#include <iostream>
#include <string>
#include <fstream>

int main()
{
    std::ifstream myfile1("op1");  //op3 if you use 2ADCs
		std::ifstream myfile2("op2"); //op4 if you use 2 ADCs
		int i,j,k;
		int numlines=1024;
    std::string data1[2048],data2[2048];
    
    while((! myfile1.eof()) && (! myfile2.eof())) {
            
						for(i=1;i<=numlines;i++){
								getline(myfile1, data1[i]);
            		getline(myfile2, data2[i]);
						}
						for(i=1;i<=numlines;i++){
								k=0;
  	            for(j=1;j<=16;j++) {
									std::cout<<data1[i][k]<<data1[i][k+1]<<"\n";
								//	std::cout<<data1[i]<<"\n";
 									k=k+2;
								}
						}
						//std::cout<<"\n\n";
						for(i=1;i<=numlines;i++){
          		k=0;
              for(j=1;j<=16;j++) {
                 std::cout<<data2[i][k]<<data2[i][k+1]<<"\n";
                 k=k+2;
              }



						}     	       


    }
    
   // std::cin.get();
    return 0;
}
