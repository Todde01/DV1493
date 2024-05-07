# Filnamn på ditt I/O-bibliotek (ändra namn om du vill)
LIB_FILE=lab3_lib.s

# Namn på körbara testprogram (ändra namn om du vill)
OUT_ASM=asmTest
OUT_C=cTest

# Kompilator, assemblator och länkare
CC=gcc
AS=as
LD=ld

# Options för kompilering och länkning
CFLAGS=-g
LFLAGS=-no-pie

# Kompilera för båda testprogrammen
all: $(OUT_ASM) $(OUT_C)

# Kompilera med testprogrammet Mprov64.s (assembler-programmet)
$(OUT_ASM): *.s
	$(CC) $(CFLAGS) $(LFLAGS) $^ -o $@ 

# Kompilera med testprogrammet test_prog.c (C-programmet)
$(OUT_C): $(LIB_FILE) *.c *.h
	$(CC) $(CFLAGS) $(LFLAGS) $^ -o $@ 

# Packar ihop alla filer inför inlämning
submission: *.s *.c *.h Makefile
	tar czf submission.tgz *.s *.c *.h Makefile

# Rensa projektkatalogen från temporära filer
clean:
		rm -f $(OUT_ASM)
		rm -f $(OUT_C)
		rm -f *.o
