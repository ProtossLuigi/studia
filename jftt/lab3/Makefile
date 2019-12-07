.PHONY = all clean cleanall

all: kalkulator

kalkulator: kalkulator.y kalkulator.l
	bison -o kalkulator_y.cpp -d kalkulator.y
	flex -o kalkulator_l.cpp kalkulator.l
	g++ -o kalkulator kalkulator_y.cpp kalkulator_l.cpp

clean:
	rm -f *.cpp *.hpp

cleanall: clean
	rm -f kalkulator