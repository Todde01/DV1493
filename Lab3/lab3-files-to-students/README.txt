Datorteknik Lab 3 - "Bibliotek för in- och utmatning (Intel x64 assembler)"
---------------------------------------------------------------------------

I denna katalog finns de filer ni kan utgå från för att jobba med laborationen.

Följande filer finns (modifiera inte dessa!):
---------------------------------------------
Mprov64.s   - testprogram i assembler
test_prog.c - testprogram i C
my_iolib.h  - headerfil för test_prog.c
Makefile    - används för kompilering etc med vertyget "make" (beskrivs längre ner)


Ni ska själva implementera ett antal funtioner som beskrivs i
Laborations-instruktionen (t.ex. inImage(), getInt(), getText() etc.).
Detta gör ni i en separat fil som kan heta t.ex. "lab3_lib.s".

Till er hjälp har ni testprogram som använder era funktioner och som förväntas
göra vissa utskrifter. Det är dessa testprogram som kommer att köras vid redovisning
av laborationen.

Det finns två olika testprogram, ett assemblerprogram och ett C-program.
Ni väljer själva vilket av dessa ni vill använda. Det kan dock vara lite enklare att
följa och modifiera C-programmet!

Testprogrammen får inte modifieras inför redovisningen!

Däremot är det förstås ok att kopiera testprogrammet och modifiera lite under utvecklingen,
för att t.ex. köra en del i taget. Det brukar bli enklare så!

KOMPILERING
-----------
Vi använder kompilatorn "gcc".
Det finns två sätt att kompilera ert program.
1. Antingen gör ni det "manuellt" genom att köra gcc direkt från terminalen.
2. Alternativ använder ni verktyget "make" som kan göra det lite enklare för er.

Närmare beskrivning av alternativen följer här.

1. Kompilering direkt med gcc
-----------------------------
Antag att din fil heter "lab3_lib.s".
Antag också att ditt körbara program ska heta "prog".

-Kompilera ditt "lib" med assembler-testprogrammet Mprov64.s:
   gcc -g -no-pie lab3_lib.s Mprov64.s -o prog

-Kompilera alla assemblerfiler (*.s), inkl. testprogrammet Mprov64.s:
   gcc -g -no-pie *.s -o prog

-Kompilera med C-testprogrammet test_prog.c:
   gcc -g -no-pie lab3_lib.s test_prog.c -o prog



2. Användning av verktyget "make" med Makefile
----------------------------------------------
Vertyget "make" används för att "automatisera" och förenkla speciellt
vid kompilering av stora program med många olika filer.
I en så kallad "Makefile" definierar man vad som kan göras med "make".
I makefilen specificeras vilka filer som finns och vilka beroenden som finns mellan dessa.
En av finesserna med "make" är att kompilering bara sker om någon ingående fil har ändrats!
Makefilen byggs upp av olika "targets", vilket kan ses som de olika "kommandon"
man vill kunna köra med "make".

Det finns en färdig enkel "Makefile" i katalogen.
Du kan modifiera denna med namn på ditt lib (default lab3_lib.s) och utfiler (asmTest, cTest).

-Kompilering för båda testprogrammen (asmTest, cTest):
   make
alternativt:
   make all

-Kompilera med testprogrammet Mprov64.s (assembler-programmet):
   make asmTest

-Kompilera med testprogrammet test_prog.c (C-programmet):
   make cTest

-Rensa projektkatalogen från temporära filer:
   make clean

-Packar ihop alla filer inför inlämning (submission.tgz)
   make submission

