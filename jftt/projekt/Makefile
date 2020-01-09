.PHONY = all clean cleanall

all: kompilator

kompilator: kompilator.y kompilator.l
	bison -o kompilator_y.cpp -d kompilator.y
	flex -o kompilator_l.cpp kompilator.l
	g++ -o kompilator kompilator_y.cpp kompilator_l.cpp

clean:
	rm -f *.cpp *.hpp

cleanall: clean
	rm -f kompilator