%code top{
    #include <iostream>
    #define RESERVED_SLOTS 7
}
%code requires{
    #include <string>
    #include <vector>
    #include <unordered_map>

    struct YYSTYPE{
        long long       intval;
        std::string     str;
        int             lineno;

        std::vector<std::pair<std::string,std::string>>   instructions;
        std::unordered_map<std::string,bool> local_variables;
        std::unordered_map<std::string,int> used_variables;
        std::unordered_map<std::string,bool> initialized_variables;
        bool            literal = false;
        bool            double_identifier = false;
        long long       second_identifier;
        bool            local_var = false;
    };
}
%code {
    int yylex();
    int yyerror(const char *);
    extern FILE *yyin;
    extern FILE *yyout;

    struct global_variable {
        std::string     name;
        long long       loc;
        bool            arr = false;
        long long       begin;
        long long       end;
        bool            initialized = false;
    };

    bool error = false;
    std::string error_message;
    long long no_global_variables = 0;
    std::unordered_map<std::string,struct global_variable> global_variables;

    std::vector<std::pair<std::string,std::string>> ll_to_instructions(long long x) {
        std::vector<std::pair<std::string,std::string>> v;
        v.emplace_back("SUB","0");
        if (x != 0) {
            bool neg = x < 0;
            if (neg) {
                x = -x;
            }
            std::vector<bool> bin;
            while (x > 0) {
                bin.push_back(x & 1);
                x = x >> 1;
            }
            for (int i = bin.size()-1; i >= 0; i--) {
                if (bin[i]) {
                    if (neg) {
                        v.emplace_back("DEC","0");
                    } else {
                        v.emplace_back("INC","0");
                    }
                }
                if (i > 0) {
                    v.emplace_back("SHIFT","1");
                }
            }
        }
        return v;
    }

    void move_jumps(int n, std::vector<std::pair<std::string,std::string>> &instructions){
        for (std::pair<std::string,std::string> &instruction : instructions) {
            if (instruction.first.compare("JUMP") == 0 || instruction.first.compare("JPOS") == 0 || instruction.first.compare("JZERO") == 0 || instruction.first.compare("JNEG") == 0) {
                instruction.second = std::to_string(std::stoi(instruction.second)+n);
            }
        }
    }

    void print_instructions(std::vector<std::pair<std::string,std::string>> instructions) {
        std::string program;
        for (std::pair<std::string,std::string> instruction : instructions) {
            if (instruction.first.compare("GET") == 0 || instruction.first.compare("PUT") == 0 || instruction.first.compare("INC") == 0 || instruction.first.compare("DEC") == 0){
                program += instruction.first + "\n";
            } else {
                program += instruction.first + " " + instruction.second + "\n";
            }
        }
        program += "HALT";
        fprintf(yyout,"%s",program.c_str());
    }

    template <typename T> std::vector<T> operator+(const std::vector<T> &a, const std::vector<T> &b){
        std::vector<T> v = a;
        v.insert(v.end(),b.begin(),b.end());
        return v;
    }

    template <typename T> std::vector<T> operator+=(std::vector<T> &a, const std::vector<T> &b){
        a.insert(a.end(),b.begin(),b.end());
        return a;
    }

    template <typename K,typename V> std::unordered_map<K,V> operator+(const std::unordered_map<K,V> &a, const std::unordered_map<K,V> &b) {
        std::unordered_map<K,V> m = a;
        m.insert(b.begin(),b.end());
        return m;
    }

    template <typename K,typename V> std::unordered_map<K,V> operator+=(std::unordered_map<K,V> &a, const std::unordered_map<K,V> &b) {
        a.insert(b.begin(),b.end());
        return a;
    }

    void print_error(int line,std::string message) {
        message = "Error in line " + std::to_string(line) + ": " + message;
        yyerror(message.c_str());
    }

    void allocate_local_variables(YYSTYPE &token) {
        long long memory_slot = RESERVED_SLOTS + no_global_variables;
        for (std::unordered_map<std::string,bool>::iterator it = token.local_variables.begin(); it != token.local_variables.end(); it++) {
            if (it->second) {
                for (std::pair<std::string,std::string> &instr : token.instructions) {
                    if (instr.second.compare(it->first) == 0) {
                        instr.second = std::to_string(memory_slot);
                    } else if (instr.second.compare(it->first + "+1") == 0) {
                        instr.second = std::to_string(memory_slot+1);
                    }
                }
                memory_slot += 2;
            } else {
                print_error(token.used_variables[it->first],"undeclared variable '" + it->first + "'");
            }
        }
    }

    void check_initializations(YYSTYPE &token) {
        for (auto it = global_variables.begin(); it != global_variables.end(); it++) {
            if (!it->second.arr && token.used_variables.count(it->first) && (!token.initialized_variables.count(it->first) || !token.initialized_variables[it->first])) {
                print_error(token.used_variables[it->first],"uninitialized variable '" + it->first + "' used");
            }
        }
    }

    std::unordered_map<std::string,bool> sync_local_vars(YYSTYPE a,YYSTYPE b) {
        std::vector<std::string> faulty_vars;
        for (auto it = a.local_variables.begin(); it != a.local_variables.end(); it++) {
            if (b.local_variables.count(it->first) && it->second != b.local_variables[it->first]) {
                int line;
                if (it->second) {
                    line = b.used_variables[it->first];
                } else {
                    line = a.used_variables[it->first];
                }
                print_error(line,"local variable '" + it->first + "' undeclared or used out of its scope");
                faulty_vars.push_back(it->first);
            } 
        }
        std::unordered_map<std::string,bool> m = a.local_variables + b.local_variables;
        for (std::string to_remove : faulty_vars) {
            m.erase(to_remove);
        }
        return m;
    }
}
%define api.value.type {struct YYSTYPE}
%define parse.error verbose
%locations
%token num
%token pidentifier
%token DECLARE BEG END
%token COMMA COLON SEMICOLON
%token READ WRITE
%token ASSIGN
%token LPAR RPAR
%token PLUS MINUS TIMES DIV MOD
%token EQ NEQ LE GE LEQ GEQ
%token IF ELSE THEN ENDIF
%token WHILE ENDWHILE DO ENDDO FOR FROM TO DOWNTO ENDFOR
%%
program:          DECLARE declarations BEG commands END                                         {
                                                                                                $$.used_variables = $4.used_variables;
                                                                                                $$.initialized_variables = $4.initialized_variables;
                                                                                                $$.local_variables = $4.local_variables;
                                                                                                $$.instructions.emplace_back("SUB","0");
                                                                                                $$.instructions.emplace_back("INC","");
                                                                                                $$.instructions.emplace_back("STORE","1");
                                                                                                move_jumps(3,$4.instructions);
                                                                                                $$.instructions += $4.instructions;
                                                                                                allocate_local_variables($$);
                                                                                                check_initializations($$);
                                                                                                if (!error) {
                                                                                                    print_instructions($$.instructions);
                                                                                                }
                                                                                                }
                | BEG commands END                                                              {
                                                                                                $$.used_variables = $2.used_variables;
                                                                                                $$.initialized_variables = $2.initialized_variables;
                                                                                                $$.local_variables = $2.local_variables;
                                                                                                $$.instructions.emplace_back("SUB","0");
                                                                                                $$.instructions.emplace_back("INC","");
                                                                                                $$.instructions.emplace_back("STORE","1");
                                                                                                move_jumps(3,$2.instructions);
                                                                                                $$.instructions += $2.instructions;
                                                                                                allocate_local_variables($$);
                                                                                                check_initializations($$);
                                                                                                if (!error) {
                                                                                                    print_instructions($$.instructions);
                                                                                                }
                                                                                                }
;
declarations:     declarations COMMA pidentifier                                                {
                                                                                                if (global_variables.count($3.str)) {
                                                                                                    print_error($3.lineno,"variable '" + $3.str + "' declared multiple times");
                                                                                                } else {
                                                                                                    struct global_variable new_var = {$3.str,no_global_variables+RESERVED_SLOTS,false,0,0};
                                                                                                    global_variables.emplace(new_var.name,new_var);
                                                                                                    no_global_variables++;
                                                                                                }
                                                                                                }
                | declarations COMMA pidentifier LPAR num COLON num RPAR                        {
                                                                                                if (global_variables.count($3.str)) {
                                                                                                    print_error($3.lineno,"variable '" + $2.str + "' declared multiple times");
                                                                                                } else if ($5.intval > $7.intval) {
                                                                                                    print_error($5.lineno,"invalid array bounds");
                                                                                                } else {
                                                                                                    struct global_variable new_var = {$3.str,RESERVED_SLOTS-$5.intval,true,$5.intval,$7.intval};
                                                                                                    global_variables.emplace(new_var.name,new_var);
                                                                                                    no_global_variables += new_var.end - new_var.begin + 1;
                                                                                                }
                                                                                                }
                | pidentifier                                                                   {
                                                                                                struct global_variable new_var = {$1.str,RESERVED_SLOTS,false,0,0};
                                                                                                global_variables.emplace(new_var.name,new_var);
                                                                                                no_global_variables = 1;
                                                                                                }
                | pidentifier LPAR num COLON num RPAR                                           {
                                                                                                if ($3.intval > $5.intval) {
                                                                                                    print_error($3.lineno,"invalid array bounds");
                                                                                                } else {
                                                                                                    struct global_variable new_var = {$1.str,RESERVED_SLOTS-$3.intval,true,$3.intval,$5.intval};
                                                                                                    global_variables.emplace(new_var.name,new_var);
                                                                                                    no_global_variables = new_var.end - new_var.begin + 1;
                                                                                                }
                                                                                                }
;
commands:         commands command                                                              {
                                                                                                $$.used_variables = $1.used_variables + $2.used_variables;
                                                                                                $$.initialized_variables = $1.initialized_variables + $2.initialized_variables;
                                                                                                $$.local_variables = sync_local_vars($1,$2);
                                                                                                move_jumps($1.instructions.size(),$2.instructions);
                                                                                                $$.instructions = $1.instructions + $2.instructions;
                                                                                                }
                | command                                                                       {
                                                                                                $$.local_variables = $1.local_variables;
                                                                                                $$.used_variables = $1.used_variables;
                                                                                                $$.initialized_variables = $1.initialized_variables;
                                                                                                $$.instructions = $1.instructions;
                                                                                                }
;
command:          identifier ASSIGN expression SEMICOLON                                        {
                                                                                                $$.lineno = $1.lineno;
                                                                                                $$.used_variables = $1.used_variables + $3.used_variables;
                                                                                                $$.local_variables = $3.local_variables;
                                                                                                if ($1.local_var && !$1.double_identifier) {
                                                                                                    print_error($1.lineno,"cannot assign local or undeclared variable '" + $1.str + "'");
                                                                                                } else if (!$1.local_var && !$1.double_identifier) {
                                                                                                    $$.initialized_variables[$1.str] = true;
                                                                                                }
                                                                                                $$.initialized_variables += $3.initialized_variables;
                                                                                                if ($1.double_identifier) {
                                                                                                    $$.instructions = ll_to_instructions($1.intval);
                                                                                                    if ($1.local_var) {
                                                                                                        $$.instructions.emplace_back("ADD",$1.str);
                                                                                                    } else {
                                                                                                        $$.instructions.emplace_back("ADD",std::to_string($1.second_identifier));
                                                                                                    }
                                                                                                    $$.instructions.emplace_back("STORE","2");
                                                                                                    move_jumps($$.instructions.size(),$3.instructions);
                                                                                                    $$.instructions += $3.instructions;
                                                                                                    $$.instructions.emplace_back("STOREI","2");
                                                                                                } else {
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("STORE",std::to_string($1.intval));
                                                                                                }
                                                                                                }
                | IF condition THEN commands ELSE commands ENDIF                                {
                                                                                                $$.used_variables = $2.used_variables + $4.used_variables + $6.used_variables;
                                                                                                $$.initialized_variables = $2.initialized_variables + $4.initialized_variables + $6.initialized_variables;
                                                                                                $$.local_variables = sync_local_vars($2,$4);
                                                                                                $$.local_variables = sync_local_vars($$,$6);
                                                                                                if ($2.literal) {
                                                                                                    if ($2.intval) {
                                                                                                        $$.instructions = $4.instructions;
                                                                                                    } else {
                                                                                                        $$.instructions = $6.instructions;
                                                                                                    }
                                                                                                } else {
                                                                                                    $$.instructions = $2.instructions;
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()+$4.instructions.size()+2));
                                                                                                    move_jumps($$.instructions.size(),$4.instructions);
                                                                                                    $$.instructions += $4.instructions;
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()+$6.instructions.size()+1));
                                                                                                    move_jumps($$.instructions.size(),$6.instructions);
                                                                                                    $$.instructions += $6.instructions;
                                                                                                }
                                                                                                }
                | IF condition THEN commands ENDIF                                              {
                                                                                                $$.used_variables = $2.used_variables + $4.used_variables;
                                                                                                $$.initialized_variables = $2.initialized_variables + $4.initialized_variables;
                                                                                                $$.local_variables = sync_local_vars($2,$4);
                                                                                                if ($2.literal) {
                                                                                                    if ($2.intval) {
                                                                                                        $$.instructions = $4.instructions;
                                                                                                    }
                                                                                                } else {
                                                                                                    $$.instructions = $2.instructions;
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()+$4.instructions.size()+1));
                                                                                                    move_jumps($$.instructions.size(),$4.instructions);
                                                                                                    $$.instructions += $4.instructions;
                                                                                                }
                                                                                                }
                | WHILE condition DO commands ENDWHILE                                          {
                                                                                                $$.used_variables = $2.used_variables + $4.used_variables;
                                                                                                $$.initialized_variables = $2.initialized_variables + $4.initialized_variables;
                                                                                                $$.local_variables = sync_local_vars($2,$4);
                                                                                                if ($2.literal) {
                                                                                                    if ($2.intval) {
                                                                                                        $$.instructions = $4.instructions;
                                                                                                        $$.instructions.emplace_back("JUMP","0");
                                                                                                    }
                                                                                                } else {
                                                                                                    $$.instructions = $2.instructions;
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()+$4.instructions.size()+2));
                                                                                                    move_jumps($$.instructions.size(),$4.instructions);
                                                                                                    $$.instructions += $4.instructions;
                                                                                                    $$.instructions.emplace_back("JUMP","0");
                                                                                                }
                                                                                                }
                | DO commands WHILE condition ENDDO                                             {
                                                                                                $$.used_variables = $2.used_variables + $4.used_variables;
                                                                                                $$.initialized_variables = $2.initialized_variables + $4.initialized_variables;
                                                                                                $$.local_variables = sync_local_vars($2,$4);
                                                                                                $$.instructions = $2.instructions;
                                                                                                if ($4.literal) {
                                                                                                    if ($4.intval) {
                                                                                                        $$.instructions.emplace_back("JUMP","0");
                                                                                                    }
                                                                                                } else {
                                                                                                    move_jumps($$.instructions.size(),$4.instructions);
                                                                                                    $$.instructions += $4.instructions;
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()+2));
                                                                                                    $$.instructions.emplace_back("JUMP","0");
                                                                                                }
                                                                                                }
                | FOR pidentifier FROM value TO value DO commands ENDFOR                        {
                                                                                                $$.used_variables[$2.str] = $2.lineno;
                                                                                                $$.used_variables = $$.used_variables + $4.used_variables + $6.used_variables + $8.used_variables;
                                                                                                $$.initialized_variables = $4.initialized_variables + $6.initialized_variables + $8.initialized_variables;
                                                                                                $$.local_variables = sync_local_vars($4,$6);
                                                                                                $$.local_variables = sync_local_vars($$,$8);
                                                                                                if ($$.local_variables[$2.str] || global_variables.count($2.str)) {
                                                                                                    print_error($2.lineno,"variable '" + $2.str + "' declared multiple times");
                                                                                                } else {
                                                                                                    if ($4.literal && $6.literal && $4.intval > $6.intval) {
                                                                                                        print_error($4.lineno,"invalid for loop bounds");
                                                                                                    } else {
                                                                                                        $$.local_variables[$2.str] = true;
                                                                                                        $$.instructions = $6.instructions;
                                                                                                        $$.instructions.emplace_back("STORE",$2.str + "+1");
                                                                                                        $$.instructions += $4.instructions;
                                                                                                        $$.instructions.emplace_back("STORE",$2.str);
                                                                                                        $$.instructions.emplace_back("SUB",$2.str + "+1");
                                                                                                        $$.instructions.emplace_back("JPOS",std::to_string($$.instructions.size()+$8.instructions.size()+4));
                                                                                                        move_jumps($$.instructions.size(),$8.instructions);
                                                                                                        $$.instructions += $8.instructions;
                                                                                                        $$.instructions.emplace_back("LOAD",$2.str);
                                                                                                        $$.instructions.emplace_back("INC","");
                                                                                                        $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()-$8.instructions.size()-5));
                                                                                                    }
                                                                                                }
                                                                                                }
                | FOR pidentifier FROM value DOWNTO value DO commands ENDFOR                    {
                                                                                                $$.used_variables[$2.str] = $2.lineno;
                                                                                                $$.used_variables = $$.used_variables + $4.used_variables + $6.used_variables + $8.used_variables;
                                                                                                $$.initialized_variables = $4.initialized_variables + $6.initialized_variables + $8.initialized_variables;
                                                                                                $$.local_variables = sync_local_vars($4,$6);
                                                                                                $$.local_variables = sync_local_vars($$,$8);
                                                                                                if ($$.local_variables[$2.str] || global_variables.count($2.str)) {
                                                                                                    print_error($2.lineno,"variable '" + $2.str + "' declared multiple times");
                                                                                                } else {
                                                                                                    if ($4.literal && $6.literal && $4.intval < $6.intval) {
                                                                                                        print_error($4.lineno,"invalid for loop bounds");
                                                                                                    } else {
                                                                                                        $$.local_variables[$2.str] = true;
                                                                                                        $$.instructions = $6.instructions;
                                                                                                        $$.instructions.emplace_back("STORE",$2.str + "+1");
                                                                                                        $$.instructions += $4.instructions;
                                                                                                        $$.instructions.emplace_back("STORE",$2.str);
                                                                                                        $$.instructions.emplace_back("SUB",$2.str + "+1");
                                                                                                        $$.instructions.emplace_back("JNEG",std::to_string($$.instructions.size()+$8.instructions.size()+4));
                                                                                                        move_jumps($$.instructions.size(),$8.instructions);
                                                                                                        $$.instructions += $8.instructions;
                                                                                                        $$.instructions.emplace_back("LOAD",$2.str);
                                                                                                        $$.instructions.emplace_back("DEC","");
                                                                                                        $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()-$8.instructions.size()-5));
                                                                                                    }
                                                                                                }
                                                                                                }
                | READ identifier SEMICOLON                                                     {
                                                                                                $$.used_variables = $2.used_variables;
                                                                                                if ($2.double_identifier) {
                                                                                                    if ($2.local_var) {
                                                                                                        $$.local_variables.emplace($2.str,false);
                                                                                                        $$.instructions = ll_to_instructions($2.intval);
                                                                                                        $$.instructions.emplace_back("ADD",$2.str);
                                                                                                        $$.instructions.emplace_back("STORE","2");
                                                                                                        $$.instructions.emplace_back("GET","0");
                                                                                                        $$.instructions.emplace_back("STOREI","2");
                                                                                                    } else {
                                                                                                        $$.instructions = ll_to_instructions($2.intval);
                                                                                                        $$.instructions.emplace_back("ADD",std::to_string($2.second_identifier));
                                                                                                        $$.instructions.emplace_back("STORE","2");
                                                                                                        $$.instructions.emplace_back("GET","0");
                                                                                                        $$.instructions.emplace_back("STOREI","2");
                                                                                                    }
                                                                                                } else {
                                                                                                    if ($2.local_var) {
                                                                                                        print_error($2.lineno,"cannot assign local or undeclared variable '" + $2.str + "'");
                                                                                                    } else {
                                                                                                        $$.instructions.emplace_back("GET","0");
                                                                                                        $$.instructions.emplace_back("STORE",std::to_string($2.intval));
                                                                                                        $$.initialized_variables[$2.str] = true;
                                                                                                    }
                                                                                                    
                                                                                                }
                                                                                                }
                | WRITE value SEMICOLON                                                         {
                                                                                                $$.local_variables = $2.local_variables;
                                                                                                $$.used_variables = $2.used_variables;
                                                                                                $$.initialized_variables = $2.initialized_variables;
                                                                                                $$.instructions = $2.instructions;
                                                                                                $$.instructions.emplace_back("PUT","0");
                                                                                                }
;
expression:       value                                                                         {
                                                                                                $$ = $1;
                                                                                                }
                | value PLUS value                                                              {
                                                                                                $$.used_variables = $1.used_variables + $3.used_variables;
                                                                                                $$.initialized_variables = $1.initialized_variables + $2.initialized_variables;
                                                                                                $$.local_variables = sync_local_vars($1,$3);
                                                                                                if ($1.literal && $3.literal) {
                                                                                                    $$.instructions = ll_to_instructions($1.intval + $3.intval);
                                                                                                } else {
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("STORE","3");
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("ADD","3");
                                                                                                }
                                                                                                }
                | value MINUS value                                                             {
                                                                                                $$.used_variables = $1.used_variables + $3.used_variables;
                                                                                                $$.initialized_variables = $1.initialized_variables + $2.initialized_variables;
                                                                                                $$.local_variables = sync_local_vars($1,$3);
                                                                                                if ($1.literal && $3.literal) {
                                                                                                    $$.instructions = ll_to_instructions($1.intval - $3.intval);
                                                                                                } else {
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("STORE","3");
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("SUB","3");
                                                                                                }
                                                                                                }
                | value TIMES value                                                             {
                                                                                                $$.used_variables = $1.used_variables + $3.used_variables;
                                                                                                $$.initialized_variables = $1.initialized_variables + $2.initialized_variables;
                                                                                                $$.local_variables = sync_local_vars($1,$3);
                                                                                                if ($1.literal && $3.literal) {
                                                                                                    $$.instructions = ll_to_instructions($1.intval * $3.intval);
                                                                                                } else {
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("STORE","4");
                                                                                                    $$.instructions.emplace_back("JPOS",std::to_string($$.instructions.size()+3));
                                                                                                    $$.instructions.emplace_back("SUB","4");
                                                                                                    $$.instructions.emplace_back("SUB","4");
                                                                                                    $$.instructions.emplace_back("STORE","5");
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("STORE","3");
                                                                                                    $$.instructions.emplace_back("JPOS",std::to_string($$.instructions.size()+3));
                                                                                                    $$.instructions.emplace_back("SUB","3");
                                                                                                    $$.instructions.emplace_back("SUB","3");
                                                                                                    $$.instructions.emplace_back("SUB","5");
                                                                                                    $$.instructions.emplace_back("JPOS",std::to_string($$.instructions.size()+13));
                                                                                                    $$.instructions.emplace_back("SUB","0");
                                                                                                    $$.instructions.emplace_back("STORE","5");
                                                                                                    $$.instructions.emplace_back("SUB","3");
                                                                                                    $$.instructions.emplace_back("JPOS",std::to_string($$.instructions.size()+22));
                                                                                                    $$.instructions.emplace_back("JZERO",std::to_string($$.instructions.size()+36));
                                                                                                    $$.instructions.emplace_back("STORE","6");
                                                                                                    $$.instructions.emplace_back("LOAD","5");
                                                                                                    $$.instructions.emplace_back("ADD","4");
                                                                                                    $$.instructions.emplace_back("STORE","5");
                                                                                                    $$.instructions.emplace_back("LOAD","6");
                                                                                                    $$.instructions.emplace_back("INC","0");
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()-7));
                                                                                                    $$.instructions.emplace_back("SUB","0");
                                                                                                    $$.instructions.emplace_back("STORE","5");
                                                                                                    $$.instructions.emplace_back("SUB","4");
                                                                                                    $$.instructions.emplace_back("JPOS",std::to_string($$.instructions.size()+18));
                                                                                                    $$.instructions.emplace_back("JZERO",std::to_string($$.instructions.size()+24));
                                                                                                    $$.instructions.emplace_back("STORE","6");
                                                                                                    $$.instructions.emplace_back("LOAD","5");
                                                                                                    $$.instructions.emplace_back("ADD","3");
                                                                                                    $$.instructions.emplace_back("STORE","5");
                                                                                                    $$.instructions.emplace_back("LOAD","6");
                                                                                                    $$.instructions.emplace_back("INC","0");
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()-7));
                                                                                                    $$.instructions.emplace_back("JZERO",std::to_string($$.instructions.size()+16));
                                                                                                    $$.instructions.emplace_back("STORE","6");
                                                                                                    $$.instructions.emplace_back("LOAD","5");
                                                                                                    $$.instructions.emplace_back("SUB","4");
                                                                                                    $$.instructions.emplace_back("STORE","5");
                                                                                                    $$.instructions.emplace_back("LOAD","6");
                                                                                                    $$.instructions.emplace_back("DEC","0");
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()-7));
                                                                                                    $$.instructions.emplace_back("JZERO",std::to_string($$.instructions.size()+8));
                                                                                                    $$.instructions.emplace_back("STORE","6");
                                                                                                    $$.instructions.emplace_back("LOAD","5");
                                                                                                    $$.instructions.emplace_back("SUB","3");
                                                                                                    $$.instructions.emplace_back("STORE","5");
                                                                                                    $$.instructions.emplace_back("LOAD","6");
                                                                                                    $$.instructions.emplace_back("DEC","0");
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()-7));
                                                                                                    $$.instructions.emplace_back("LOAD","5");
                                                                                                }
                                                                                                }
                | value DIV value                                                               {
                                                                                                $$.used_variables = $1.used_variables + $3.used_variables;
                                                                                                $$.initialized_variables = $1.initialized_variables + $2.initialized_variables;
                                                                                                $$.local_variables = sync_local_vars($1,$3);
                                                                                                if ($3.literal && $3.intval == 0) {
                                                                                                    $$.instructions.emplace_back("SUB","0");
                                                                                                } else if ($1.literal && $3.literal) {
                                                                                                    $$.instructions = ll_to_instructions($1.intval / $3.intval);
                                                                                                } else {
                                                                                                    $$.instructions.emplace_back("SUB","0");
                                                                                                    $$.instructions.emplace_back("STORE","5");
                                                                                                    $$.instructions += $3.instructions;
                                                                                                    $$.instructions.emplace_back("JZERO",std::to_string($$.instructions.size()+$1.instructions.size()*2+47));
                                                                                                    $$.instructions.emplace_back("STORE","4");
                                                                                                    $$.instructions.emplace_back("JNEG",std::to_string($$.instructions.size()+$1.instructions.size()+23));
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("JZERO",std::to_string($$.instructions.size()+$1.instructions.size()+44));
                                                                                                    $$.instructions.emplace_back("JNEG",std::to_string($$.instructions.size()+11));
                                                                                                    $$.instructions.emplace_back("INC","0");
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()+6));
                                                                                                    $$.instructions.emplace_back("STORE","3");
                                                                                                    $$.instructions.emplace_back("LOAD","5");
                                                                                                    $$.instructions.emplace_back("INC","0");
                                                                                                    $$.instructions.emplace_back("STORE","5");
                                                                                                    $$.instructions.emplace_back("LOAD","3");
                                                                                                    $$.instructions.emplace_back("SUB","4");
                                                                                                    $$.instructions.emplace_back("JPOS",std::to_string($$.instructions.size()-6));
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()+$1.instructions.size()+35));
                                                                                                    $$.instructions.emplace_back("DEC","0");
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()+6));
                                                                                                    $$.instructions.emplace_back("STORE","3");
                                                                                                    $$.instructions.emplace_back("LOAD","5");
                                                                                                    $$.instructions.emplace_back("DEC","0");
                                                                                                    $$.instructions.emplace_back("STORE","5");
                                                                                                    $$.instructions.emplace_back("LOAD","3");
                                                                                                    $$.instructions.emplace_back("ADD","4");
                                                                                                    $$.instructions.emplace_back("JNEG",std::to_string($$.instructions.size()-6));
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()+$1.instructions.size()+25));
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("JZERO",std::to_string($$.instructions.size()+22));
                                                                                                    $$.instructions.emplace_back("JNEG",std::to_string($$.instructions.size()+11));
                                                                                                    $$.instructions.emplace_back("INC","0");
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()+6));
                                                                                                    $$.instructions.emplace_back("STORE","3");
                                                                                                    $$.instructions.emplace_back("LOAD","5");
                                                                                                    $$.instructions.emplace_back("DEC","0");
                                                                                                    $$.instructions.emplace_back("STORE","5");
                                                                                                    $$.instructions.emplace_back("LOAD","3");
                                                                                                    $$.instructions.emplace_back("ADD","4");
                                                                                                    $$.instructions.emplace_back("JPOS",std::to_string($$.instructions.size()-6));
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()+13));
                                                                                                    $$.instructions.emplace_back("DEC","0");
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()+6));
                                                                                                    $$.instructions.emplace_back("STORE","3");
                                                                                                    $$.instructions.emplace_back("LOAD","5");
                                                                                                    $$.instructions.emplace_back("INC","0");
                                                                                                    $$.instructions.emplace_back("STORE","5");
                                                                                                    $$.instructions.emplace_back("LOAD","3");
                                                                                                    $$.instructions.emplace_back("SUB","4");
                                                                                                    $$.instructions.emplace_back("JNEG",std::to_string($$.instructions.size()-6));
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()+3));
                                                                                                    $$.instructions.emplace_back("SUB","0");
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()+2));
                                                                                                    $$.instructions.emplace_back("LOAD","5");
                                                                                                }
                                                                                                }
                | value MOD value                                                               {
                                                                                                $$.used_variables = $1.used_variables + $3.used_variables;
                                                                                                $$.initialized_variables = $1.initialized_variables + $2.initialized_variables;
                                                                                                $$.local_variables = sync_local_vars($1,$3);
                                                                                                if ($3.literal && $3.intval == 0) {
                                                                                                    $$.instructions.emplace_back("SUB","0");
                                                                                                } else if ($1.literal && $3.literal) {
                                                                                                    long long val = $1.intval % $3.intval;
                                                                                                    if (val * $3.intval < 0) {
                                                                                                        val += $3.intval;
                                                                                                    }
                                                                                                    $$.instructions = ll_to_instructions(val);
                                                                                                } else {
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("JZERO",std::to_string($$.instructions.size()+$1.instructions.size()*2+22));
                                                                                                    $$.instructions.emplace_back("STORE","3");
                                                                                                    $$.instructions.emplace_back("JNEG",std::to_string($$.instructions.size()+$1.instructions.size()+11));
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("JZERO",std::to_string($$.instructions.size()+$1.instructions.size()+19));
                                                                                                    $$.instructions.emplace_back("JNEG",std::to_string($$.instructions.size()+6));
                                                                                                    $$.instructions.emplace_back("SUB","3");
                                                                                                    $$.instructions.emplace_back("JPOS",std::to_string($$.instructions.size()-1));
                                                                                                    $$.instructions.emplace_back("JZERO",std::to_string($$.instructions.size()+$1.instructions.size()+15));
                                                                                                    $$.instructions.emplace_back("ADD","3");
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()+$1.instructions.size()+13));
                                                                                                    $$.instructions.emplace_back("ADD","3");
                                                                                                    $$.instructions.emplace_back("JNEG",std::to_string($$.instructions.size()-1));
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()+$1.instructions.size()+10));
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("JZERO",std::to_string($$.instructions.size()+9));
                                                                                                    $$.instructions.emplace_back("JNEG",std::to_string($$.instructions.size()+4));
                                                                                                    $$.instructions.emplace_back("ADD","3");
                                                                                                    $$.instructions.emplace_back("JPOS",std::to_string($$.instructions.size()-1));
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()+5));
                                                                                                    $$.instructions.emplace_back("SUB","3");
                                                                                                    $$.instructions.emplace_back("JNEG",std::to_string($$.instructions.size()-1));
                                                                                                    $$.instructions.emplace_back("JZERO",std::to_string($$.instructions.size()+2));
                                                                                                    $$.instructions.emplace_back("ADD","3");
                                                                                                }
                                                                                                }
;
condition:        value EQ value                                                                {
                                                                                                $$.used_variables = $1.used_variables + $3.used_variables;
                                                                                                $$.initialized_variables = $1.initialized_variables + $2.initialized_variables;
                                                                                                $$.local_variables = sync_local_vars($1,$3);
                                                                                                if ($1.literal && $2.literal) {
                                                                                                    $$.literal = true;
                                                                                                    $$.intval = $1.intval == $2.intval;
                                                                                                    if ($$.intval) {
                                                                                                        $$.instructions.emplace_back("JUMP","2");
                                                                                                    }
                                                                                                } else {
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("STORE","3");
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("SUB","3");
                                                                                                    $$.instructions.emplace_back("JZERO",std::to_string($$.instructions.size()+2));
                                                                                                }
                                                                                                }
                | value NEQ value                                                               {
                                                                                                $$.used_variables = $1.used_variables + $3.used_variables;
                                                                                                $$.initialized_variables = $1.initialized_variables + $2.initialized_variables;
                                                                                                $$.local_variables = sync_local_vars($1,$3);
                                                                                                if ($1.literal && $2.literal) {
                                                                                                    $$.literal = true;
                                                                                                    $$.intval = $1.intval != $2.intval;
                                                                                                    if ($$.intval) {
                                                                                                        $$.instructions.emplace_back("JUMP","2");
                                                                                                    }
                                                                                                } else {
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("STORE","3");
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("SUB","3");
                                                                                                    $$.instructions.emplace_back("JZERO",std::to_string($$.instructions.size()+2));
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()+2));
                                                                                                }
                                                                                                }
                | value LE value                                                                {
                                                                                                $$.used_variables = $1.used_variables + $3.used_variables;
                                                                                                $$.initialized_variables = $1.initialized_variables + $2.initialized_variables;
                                                                                                $$.local_variables = sync_local_vars($1,$3);
                                                                                                if ($1.literal && $2.literal) {
                                                                                                    $$.literal = true;
                                                                                                    $$.intval = $1.intval < $2.intval;
                                                                                                    if ($$.intval) {
                                                                                                        $$.instructions.emplace_back("JUMP","2");
                                                                                                    }
                                                                                                } else {
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("STORE","3");
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("SUB","3");
                                                                                                    $$.instructions.emplace_back("JNEG",std::to_string($$.instructions.size()+2));
                                                                                                }
                                                                                                }
                | value GE value                                                                {
                                                                                                $$.used_variables = $1.used_variables + $3.used_variables;
                                                                                                $$.initialized_variables = $1.initialized_variables + $2.initialized_variables;
                                                                                                $$.local_variables = sync_local_vars($1,$3);
                                                                                                if ($1.literal && $2.literal) {
                                                                                                    $$.literal = true;
                                                                                                    $$.intval = $1.intval > $2.intval;
                                                                                                    if ($$.intval) {
                                                                                                        $$.instructions.emplace_back("JUMP","2");
                                                                                                    }
                                                                                                } else {
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("STORE","3");
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("SUB","3");
                                                                                                    $$.instructions.emplace_back("JPOS",std::to_string($$.instructions.size()+2));
                                                                                                }
                                                                                                }
                | value LEQ value                                                               {
                                                                                                $$.used_variables = $1.used_variables + $3.used_variables;
                                                                                                $$.initialized_variables = $1.initialized_variables + $2.initialized_variables;
                                                                                                $$.local_variables = sync_local_vars($1,$3);
                                                                                                if ($1.literal && $2.literal) {
                                                                                                    $$.literal = true;
                                                                                                    $$.intval = $1.intval <= $2.intval;
                                                                                                    if ($$.intval) {
                                                                                                        $$.instructions.emplace_back("JUMP","2");
                                                                                                    }
                                                                                                } else {
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("STORE","3");
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("SUB","3");
                                                                                                    $$.instructions.emplace_back("JPOS",std::to_string($$.instructions.size()+2));
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()+2));
                                                                                                }
                                                                                                }
                | value GEQ value                                                               {
                                                                                                $$.used_variables = $1.used_variables + $3.used_variables;
                                                                                                $$.initialized_variables = $1.initialized_variables + $2.initialized_variables;
                                                                                                $$.local_variables = sync_local_vars($1,$3);
                                                                                                if ($1.literal && $2.literal) {
                                                                                                    $$.literal = true;
                                                                                                    $$.intval = $1.intval >= $2.intval;
                                                                                                    if ($$.intval) {
                                                                                                        $$.instructions.emplace_back("JUMP","2");
                                                                                                    }
                                                                                                } else {
                                                                                                    $$.instructions = $3.instructions;
                                                                                                    $$.instructions.emplace_back("STORE","3");
                                                                                                    $$.instructions += $1.instructions;
                                                                                                    $$.instructions.emplace_back("SUB","3");
                                                                                                    $$.instructions.emplace_back("JNEG",std::to_string($$.instructions.size()+2));
                                                                                                    $$.instructions.emplace_back("JUMP",std::to_string($$.instructions.size()+2));
                                                                                                }
                                                                                                }
;
value:            num                                                                           {
                                                                                                $$.lineno = $1.lineno;
                                                                                                $$.literal = true;
                                                                                                $$.intval = $1.intval;
                                                                                                $$.instructions = ll_to_instructions($$.intval);
                                                                                                }
                | identifier                                                                    {
                                                                                                $$.lineno = $1.lineno;
                                                                                                $$.used_variables = $1.used_variables;
                                                                                                if ($1.str.compare("") != 0) {
                                                                                                    $$.initialized_variables[$1.str] = false;
                                                                                                }
                                                                                                if ($1.double_identifier) {
                                                                                                    if ($1.local_var) {
                                                                                                        $$.instructions = ll_to_instructions($1.intval);
                                                                                                        $$.instructions.emplace_back("ADD",$1.str);
                                                                                                        $$.instructions.emplace_back("LOADI","0");
                                                                                                    } else {
                                                                                                        $$.instructions = ll_to_instructions($1.intval);
                                                                                                        $$.instructions.emplace_back("ADD",std::to_string($1.second_identifier));
                                                                                                        $$.instructions.emplace_back("LOADI","0");
                                                                                                    }
                                                                                                } else {
                                                                                                    if ($1.local_var) {
                                                                                                        $$.local_variables.emplace($1.str,false);
                                                                                                        $$.instructions.emplace_back("LOAD",$1.str);
                                                                                                    } else {
                                                                                                        $$.instructions.emplace_back("LOAD",std::to_string($1.intval));
                                                                                                    }
                                                                                                }
                                                                                                }
;
identifier:       pidentifier                                                                   {
                                                                                                $$.lineno = $1.lineno;
                                                                                                $$.str = $1.str;
                                                                                                $$.used_variables[$$.str] = $$.lineno;
                                                                                                if (global_variables.count($1.str)) {
                                                                                                    struct global_variable var = global_variables[$1.str];
                                                                                                    if (!var.arr) {
                                                                                                        $$.intval = global_variables[$1.str].loc;
                                                                                                    } else {
                                                                                                        print_error($1.lineno,"variable '" + var.name + "' is an array");
                                                                                                    }
                                                                                                } else {
                                                                                                    $$.local_var = true;
                                                                                                }
                                                                                                }
                | pidentifier LPAR pidentifier RPAR                                             {
                                                                                                $$.lineno = $1.lineno;
                                                                                                $$.str = $3.str;
                                                                                                $$.used_variables[$$.str] = $3.lineno;
                                                                                                if (global_variables.count($1.str) && global_variables.count($3.str)) {
                                                                                                    struct global_variable var1 = global_variables[$1.str];
                                                                                                    struct global_variable var2 = global_variables[$3.str];
                                                                                                    if (!var1.arr) {
                                                                                                        print_error($1.lineno,"variable '" + var1.name + "' not an array");
                                                                                                    } else if (var2.arr) {
                                                                                                        print_error($3.lineno,"variable '" + var2.name + "' is an array");
                                                                                                    } else {
                                                                                                        $$.double_identifier = true;
                                                                                                        $$.intval = var1.loc;
                                                                                                        $$.second_identifier = var2.loc;
                                                                                                    }
                                                                                                } else if (global_variables.count($1.str) && !global_variables.count($3.str)) {
                                                                                                    $$.double_identifier = true;
                                                                                                    $$.intval = global_variables[$1.str].loc;
                                                                                                    $$.local_var = true;
                                                                                                } else {
                                                                                                    print_error($1.lineno,"undeclared array '" + $1.str + "'");
                                                                                                }
                                                                                                }
                | pidentifier LPAR num RPAR                                                     {
                                                                                                $$.lineno = $1.lineno;
                                                                                                if (global_variables.count($1.str)) {
                                                                                                    struct global_variable var = global_variables[$1.str];
                                                                                                    if (var.arr) {
                                                                                                        if ($3.intval >= var.begin && $3.intval <= var.end) {
                                                                                                            $$.intval = var.loc + $3.intval;
                                                                                                        } else {
                                                                                                            print_error($3.lineno,"array index out of bounds '" + $1.str + "(" + std::to_string($3.intval) + ")'");
                                                                                                        }
                                                                                                    } else {
                                                                                                        print_error($1.lineno,"variable '" + $1.str + "' not an array");
                                                                                                    }
                                                                                                } else {
                                                                                                    print_error($1.lineno,"undeclared array variable '" + $1.str + "'");
                                                                                                }
                                                                                                }
;
%%

int yyerror(const char* s){
    error = true;
    if (s == nullptr){
        fprintf(stderr,"Error\n");
    } else {
        fprintf(stderr,"%s\n",s);
    }
}

int main(int argc,char** argv){
    if (argc < 2){
        yyin = stdin;
    } else {
        yyin = fopen(argv[1], "r");
    }
    if (argc < 3){
        yyout = stdout;
    } else {
        yyout = fopen(argv[2], "w");
    }
    yyparse();
    fclose(yyin);
    fclose(yyout);
    return 0;
}