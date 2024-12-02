PROG = bts

all : ${PROG}

lex.yy.c : ${PROG}.l
	flex ${PROG}.l

${PROG} : lex.yy.c
	gcc -o ${PROG} lex.yy.c -lfl
	./${PROG} test_bts.csv


clean:
	rm lex.yy.c ${PROG}

