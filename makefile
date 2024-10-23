# CMSC 430 Compiler Theory and Design
# Project 4 
# UMGC CITE, Summer 2023
# Robert Carswell
# 5 March 2024

# Added cmd 'make clean' for repeat compiles.

compile: scanner.o parser.o listing.o types.o
	g++ -o compile scanner.o parser.o listing.o types.o
	
scanner.o: scanner.c types.h listing.h tokens.h
	g++ -c scanner.c

scanner.c: scanner.l	
	flex scanner.l
	mv lex.yy.c scanner.c

parser.o: parser.c types.h listing.h symbols.h
	g++ -c parser.c

parser.c tokens.h: parser.y
	bison -d -v parser.y
	mv parser.tab.c parser.c
	cp parser.tab.h tokens.h

listing.o: listing.cc listing.h
	g++ -c listing.cc

types.o: types.cc types.h
	g++ -c types.cc

all: $(OUTPUT)

clean:
	$(if $(findstring Windows_NT, $(OS)), rm *.o && rm *.c && rm *.exe)