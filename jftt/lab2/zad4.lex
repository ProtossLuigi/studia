%{
    #include<stack>
    #include<iostream>
    #include<cmath>

    std::stack<std::string> stk;

    void reset_stack(){
        stk = std::stack<std::string>();
    }

    int make_number(){
        if (stk.empty()){
            throw 0;
        }
        std::string s = stk.top();
        stk.pop();
        if (s[0] >= '0' && s[0] <= '9'){
            return std::stoi(s,nullptr);
        }
        try{
            int arg = make_number();
            switch(s[0]){
            case '+':
                return make_number() + arg;
                break;
            case '-':
                return make_number() - arg;
                break;
            case '*':
                return make_number() * arg;
                break;
            case '/':
                if (arg == 0){
                    throw 1;
                }
                return make_number() / arg;
                break;
            case '^':
                return (int)pow(make_number(), arg);
                break;
            case '%':
                if (arg == 0){
                    throw 1;
                }
                return make_number()%arg;
                break;
            }
        }
        catch(int e){
            throw e;
        }
    }

    void error_handler(int e){
        switch(e){
        case 0:
            std::cout << "Error: Not enough arguments." << std::endl;
            break;
        case 1:
            std::cout << "Error: Cannot divide by 0." << std::endl;
            break;
        default:
            std::cout << "Error: Error." << std::endl;
        }
    }

    void calculate(){
        int result;
        try{
            result = make_number();
        }
        catch(int e){
            error_handler(e);
            return;
        }
        std::cout << "= " << result << std::endl;
    }

    void wrong_symbol(std::string s){
        std::cout << "Error: Wrong symbol \"" << s << "\"." << std::endl;
    }
%}
%x CLEANUP
%%
-?[0-9]+|[\+\-\*\/\^\%] stk.push(yytext);
<<EOF>>                 calculate(); return 0;
\n                      calculate();
[ \t]
.                       wrong_symbol(yytext); BEGIN(CLEANUP);
<CLEANUP>.*\n           BEGIN(INITIAL);
%%
int yywrap(){}
int main(){
    yyout = stdout;
    yylex();
    return 0;
}