EXECUTABLE=convert writedata

all: $(EXECUTABLE)

convert: convert.cpp
	g++ convert.cpp -o convert

writedata: combinedata_m2.cpp
	g++ combinedata_m2.cpp -o writedata
	
clean:
	rm $(EXECUTABLE)
