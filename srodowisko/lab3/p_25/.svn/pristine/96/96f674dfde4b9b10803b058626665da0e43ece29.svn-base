objects = main.o program_usage.o \
          s0_podprogram.o \
          s999_podprogram.o \
	      s250332_podprogram.o \
		  s242639_podprogram.o \
          s250346_podprogram.o \
          s250344_podprogram.o \
	      s250345_podprogram.o\
	      s244932_podprogram.o \
	      s250134_podprogram.o \
	      s250338_podprogram.o \
              s250342_podprogram.o \
          s244947_podprogram.o \
		  s250339_podprogram.o \
		  s250127_podprogram.o \
		  s244748_podprogram.o \
		  s250335_podprogram.o \
		  s250337_podprogram.o \
		  s250138_podprogram.o \
		  s250136_podprogram.o \
		  s250125_podprogram.o \
		  s243434_podprogram.o \
		  s244949_podprogram.o \
		  s231236_podprogram.o \
		  s250135_podprogram.o \
		  s250349_podprogram.o \
          s244931_podprogram.o \
		  s251536_podprogram.o \
	  s245128_podprogram.o \
		  s244946.podprogram.o
		  
program : $(objects)
	cc -o program $(objects)
main.o : program.h

program_usage.o : program.h

s0_podprogram.o : program.h

s999_podprogram.o : program.h

s250332_podprogram.o : program.h

s250342_podprogram.o : program.h

s242639_podprogram.o : program.h

s250346_podprogram.o : program.h

s250344_podprogram.o : program.h

s250345_podprogram.o : program.h

s250338_podprogram.o : program.h

s244932_podprogram.o : program.h

s244947_podprogram.o : program.h

s250127_podprogram.o : program.h

s250339_podprogram.o : program.h

s244748_podprogram.o : program.h

s250335_podprogram.o : program.h

s250337_podprogram.o : program.h

s250138_podprogram.o : program.h

s250136_podprogram.o : program.h

s250125_podprogram.o : program.h

s243434_podprogram.o : program.h

s244949_podprogram.o : program.h

s231236_podprogram.o : program.h

s250135_podprogram.o : program.h

s250349_podprogram.o : program.h

s244931_podprogram.o : program.h

s251536_podprogram.o : program.h

s245128_podprogram.o : program.h

s244946_podprogram.o : program.h

.PHONY : clean

clean : 
	-rm *.o program
