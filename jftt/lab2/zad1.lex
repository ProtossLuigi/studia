%{
    #include<stdio.h>
    int wordCount = 0;
    int lineCount = 0;
%}
%%
^.*[^ \t\n].*$  lineCount++; REJECT;
[^ \t\n]+       wordCount++; ECHO;
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
    printf("%d words, %d lines\n",wordCount,lineCount);
    return 0;
}