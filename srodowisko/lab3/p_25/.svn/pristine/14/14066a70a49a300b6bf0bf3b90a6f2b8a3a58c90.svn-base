objects = main.o program_usage.o \
          s0_podprogram.o \
          s999_podprogram.o \
	      s250332_podprogram.o \
          s250346_podprogram.o \
	  s250347_podprogram.o \
	      s250345_podprogram.o\
	      s244932_podprogram.o \
	      s250134_podprogram.o \
	      s250338_podprogram.o

program : $(objects)
	cc -o program $(objects)
main.o : program.h

program_usage.o : program.h

s0_podprogram.o : program.h

s999_podprogram.o : program.h

s250332_podprogram.o : program.h

s250346_podprogram.o : program.h

s250347_podprogram.o : program.h

s250345_podprogram.o : program.h

s250338_podprogram.o : program.h

s244932_podprogram.o : program.h

.PHONY : clean

clean : 
	-rm *.o program

