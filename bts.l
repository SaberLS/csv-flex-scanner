/*** Definition Section has one variable
which can be accessed inside yylex()
and main() ***/
%s KOL1 KOL2 KOL3 KOL4 KOL5 KOL6 KOL7 KOL8 KOL9 KOL10 KOL11
%%
#.*			;
<KOL1>^([0-9]{2}:){2}[0-9]{2} { printf("Godzina: %s\n", yytext); BEGIN(KOL2); }
<KOL2>([0-9]{2}.){2}[0-9]{4}  {printf("Data: %s\n", yytext);BEGIN(KOL3);}
<KOL3>[0-9]{2}  { printf("Id: %s\n", yytext); BEGIN(KOL4); }
<KOL4>-?[0-9]+,[0-9]+  { printf("Dlugosc geogr %s\n", yytext); BEGIN(KOL5); }
<KOL5>-?[0-9]+,[0-9]+   { printf("Szerokosc geogr: %s\n", yytext); BEGIN(KOL6); }
<KOL6>[0-9]{9}  { printf("Nr inicjujacy: %s\n", yytext); BEGIN(KOL7); }
<KOL7>[0-9]{9}  { printf("Nr odbierajacy: %s\n", yytext); BEGIN(KOL8); }
<KOL8>([0-9]?)+  { printf("Czas polaczenia: %s\n", yytext); BEGIN(KOL9); }
<KOL9>rozm|SMS  { printf("Rodzaj polaczenia: %s\n", yytext); BEGIN(KOL10); }
<KOL10>[0-9]{2}  { printf("Kierunek: %s\n", yytext); BEGIN(KOL11); }
<KOL11>[0-9]{4}  { printf("Zasieg: %s\n", yytext); }
.			;
\n			{ printf("\n"); BEGIN(KOL1); }
%%
//Godzina;Data;Id;Dlugosc geogr.;Szerokosc geogr.;Nr inicjujacy;Nr odbierajacy;Czas polaczenia;Rodzaj polaczenia;Kierunek;Zasieg
//08:14:45;18.10.2024;1;19,94018;50,04435;501501502;601601601;78;rozm;90;5500

/*** Code Section prints the number of
capital letter present in the given input***/
int yywrap(){}
int main(){

// Explanation:
// yywrap() - wraps the above rule section
/* yyin - takes the file pointer
          which contains the input*/
/* yylex() - this is the main flex function
          which runs the Rule Section*/
// yytext is the text in the buffer

// Uncomment the lines below
// to take input from file

// FILE *fp;
// char filename[50];
// printf("Enter the filename: \n");
// scanf("%s",filename);
// fp = fopen(filename,"r");
// yyin = fp;

yylex();

return 0;
}
