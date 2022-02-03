CC = gcc
BISON = bison
FLEX = flex
ALFA=./alfa
NASM = nasm -g -o

BIN = alfa
CFLAGS = -Wall -g
CYYFLAGS =

FLEXFLAGS =

BISONFLAGS = -dyv

NASMFLAGS = -f elf32

OBJ = tabla_hash.o generacion.o compilador.o

TESTS = tests/ejemplo_
CONDICIONALES_DIR=$(TESTS)condicionales/condicionales
FACTORIAL_DIR=$(TESTS)factorial/factorial
FUNCIONES_DIR=$(TESTS)funciones/funciones
FIBONACCI_DIR=$(TESTS)fibonacci/fibonacci
FUNC_VECT_DIR=$(TESTS)funciones_vectores/funciones_vectores
MAS_DIR=$(TESTS)mas/


LIB=lib/alfalib.o

VALGRIND=valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --verbose --log-file=valgrind-out.txt

all: ${BIN}

alfa: y.tab.o lex.yy.o $(OBJ)
	$(CC) -o $(ALFA) $^

lex.yy.o: lex.yy.c
	$(CC) ${CYYFLAGS} -c -o $@ $<

y.tab.o: y.tab.c
	$(CC) ${CYYFLAGS} -c -o $@ $<

%.o: %.c
	$(CC) ${CFLAGS} -c -o $@ $<

y.tab.c: alfa.y
	$(BISON) $(BISONFLAGS) alfa.y

y.tab.h: alfa.y
	$(BISON) $(BISONFLAGS) alfa.y

lex.yy.c: alfa.l y.tab.h
	$(FLEX) $(FLEXFLAGS) alfa.l


run_condicionales: all
	$(ALFA) $(CONDICIONALES_DIR).alfa $(CONDICIONALES_DIR)_output.asm

run_funciones: all
	$(ALFA) $(FUNCIONES_DIR).alfa $(FUNCIONES_DIR)_output.asm

run_fibonacci: all
	$(ALFA) $(FIBONACCI_DIR).alfa $(FIBONACCI_DIR)_output.asm

run_factorial: all
	$(ALFA) $(FACTORIAL_DIR).alfa $(FACTORIAL_DIR)_output.asm

run_funciones_vectores: all
	$(ALFA) $(FUNC_VECT_DIR).alfa $(FUNC_VECT_DIR)_output.asm


clean:
	@rm -rvf $(BIN) $(OBJ) lex.yy.c lex.yy.o y.tab.h y.tab.c y.tab.o y.output alfa
