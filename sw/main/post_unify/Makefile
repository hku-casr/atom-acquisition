EXECUTABLE=8bitLineToBig tsharkTo8bitLine

all: $(EXECUTABLE)

8bitLineToBig: 8bitLineToBig.cpp
	g++ -o 8bitLineToBig 8bitLineToBig.cpp

tsharkTo8bitLine: tsharkTo8bitLine.cpp
	g++ tsharkTo8bitLine.cpp -o tsharkTo8bitLine
	
clean:
	rm $(EXECUTABLE)
