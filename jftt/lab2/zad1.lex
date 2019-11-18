%%
^[ \t]*\n
^[ \t]+
[ \t]+$
[ \t]+  putchar(' ');
%%
int yywrap(){}
int main(int argc,char **argv){
    if(argc < 2){
        return 1;
    }
    FILE *fp;
    fp = fopen(argv[1],"r");
    yyin = fp;
    yylex();
    fclose(fp);
    return 0;
}