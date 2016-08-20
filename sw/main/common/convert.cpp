/* adds new lines to the tshark generated data file (the tshark file is continuous data), so as to do further processing*/
#include <iostream>
#include <fstream>
using namespace std;
int main()
{
     char str[256];
    // const char *filename = "pcapdir/outfile.raw";
    std::cout << "Enter the name of an existing text file: ";
    std::cin.get (str,256);    // get c-string

    std::ifstream infile(str);     // open file

    std::ofstream ofile("temp");

   // ifstream infile(filename, fstream::in);
    int cnt=0;
    unsigned char a,b;
	while(infile.good()){
		cnt++;
		infile>> a;
//		cout<<a;
		ofile<<a;
		if (cnt ==16) {
//			cout<<"\n";
			ofile<<"\n";
			cnt=0;
		}
	}

    infile >>hex>>b;	
  //  cout <<a<<" "<<b; 
    ofile<<a<<" "<<b;
}
