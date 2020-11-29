objects = main.o program_usage.o \
          s0_podprogram.o \
          s999_podprogram.o \
	      s250332_podprogram.o \
          s250346_podprogram.o \
	      s250345_podprogram.o\
	      s244932_podprogram.o \
	      s250134_podprogram.o \
	      s250338_podprogram.o \
          s244947_podprogram.o \
		  s250339_podprogram.o \
		  s244748_podprogram.o \
		  s250335_podprogram.o \
		  s250337_podprogram.o


program : $(objects)
	cc -o program $(objects)
main.o : program.h

program_usage.o : program.h

s0_podprogram.o : program.h

s999_podprogram.o : program.h

s250332_podprogram.o : program.h

s250346_podprogram.o : program.h

s250345_podprogram.o : program.h

s250338_podprogram.o : program.h

s244932_podprogram.o : program.h

s244947_podprogram.o : program.h

s250339_podprogram.o : program.h

s244748_podprogram.o : program.h

s250335_podprogram.o : program.h

s250337_podprogram.o : program.h

.PHONY : clean

clean : 
	-rm *.o program

