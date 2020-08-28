;NICULA IULIAN-STEFAN 324CB
%include "io.inc"

%define MAX_INPUT_SIZE 4096

section .bss
    expr: resb MAX_INPUT_SIZE
    
section .data
    contor: db 0            ;o valoare diferita de 0 indica faptul ca numarul curent este, de fapt, negativ, si trebuie inmultit cu -1

section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    push ebp

    GET_STRING expr, MAX_INPUT_SIZE
    mov edi, expr
procesare_string:           ;bucla principala in care realizez citirea inputului
    cld                     ;setez directia de parcurgere a sirurilor ca fiind directa
    mov al, 0               ;compar caracter cu caracter pana intalnesc caracterul NULL(am terminat de citit inputul)
    scasb                  
    je final                ;daca am citit caracterul NULL, am terminat citirea si sar la eticheta final
    xor ebx, ebx            ;resetez registrul ebx, pentru formarea numarului curent(daca este cazul)
    mov bl, byte [edi - 1]  ;mov in registrul bl caracterul citit anterior
    cmp bl, ' '             ;il compar cu spatiu
    je procesare_string     ;daca este spatiu, citesc urmatorul caracter
    jmp e_operator          ;verific daca caracterul citit anterior este operator
    jmp procesare_string    ;reiau bucla de citire

e_operator:                 ;compar rand pe rand caracterul curent cu cele 4 operatii: inmultire, impartire, adunare si scadere
    cmp bl, '*'
    je inmultire            ;sar la instructiunea corespunzatoare, in functie de caracterul curent
    cmp bl, '/'
    je impartire
    cmp bl, '+'
    je adunare
    cmp bl, '-'             ;daca semnul curent este -, verific daca este izolat, si atunci e operator, altfel este numar
    je scadere_sau_numar
    jmp e_operand           ;daca nu am gasit niciun semn, inseamna ca am de citit un numar si sar la eticheta e_operand
    
scadere_sau_numar:          ;verific daca am numar sau doar -
    mov [contor], byte 0    ;resetez contorul(influenteaza diverse operatii ulterioare pe numere)
    mov bl, byte [edi]      ;mut in registrul bl caracterul ce urmeaza sa fie citit
    cmp bl, ' '             ;daca este spatiu, inseamna ca am doar semnul -, deci am de efectuat o scadere si sar la eticheta corespunzatoare
    je scadere
    cmp bl, 0               ;verific daca am terminat citirea(ultimul caracter este NULL)
    je scadere              ;si in acest caz, am de efectuat o scadere
    add [contor], byte 1    ;daca nu am de efectuat scadere, numarul curent este negativ
    scasb                   ;citesc urmatorul caracter(prima cifra din numar)
    jmp e_operand           ;construiesc numarul in memorie
    
inmultire:                  ;operatia de inmultire, implementata folosind imul(numere intregi)
    pop ecx
    pop eax
    imul ecx
    push eax
    jmp procesare_string
    
impartire:                  ;operatia de impartire, implementata folosind operatia idiv(numere intregi)
    pop ecx
    pop eax
    xor edx, edx
    cmp eax, 0              ;daca numarul din eax este negativ, efectuez impartirea altfel
    jl impartire_alternativa
    idiv ecx
    push eax                ;efectuez impartirea si introduc rezultatul pe stiva
    jmp procesare_string    ;trec la citirea urmatorului caracter
    
impartire_alternativa:      ;daca eax este negativ, schimb atat semnul lui eax(pentru a deveni pozitiv), cat si pe cel al lui ecx
;nu este influentat rezultatul impartirii, dar setand mereu edx la 0 valoare lui eax trebuie sa fie pozitiva
    mov ebx, -1
    mul ebx                 ;inmultesc eax cu -1
    push eax                ;introduc eax pe stiva
    mov eax, ecx
    mul ebx                 ;inmultesc ecx, care se alfa acum in eax, cu -1
    push eax                ;introduc pe stiva valoarea
    pop ecx                 ;mut in ecx valoarea initiala din ecx, cu semn schimbat
    pop eax                 ;mut in eax valoarea initiala din eax, cu semn schimbat    
    xor edx, edx            ;setez partea superioara a numarului de impartit cu 0
    idiv ecx                ;efectuez impartirea
    push eax                ;introduc rezultatul pe stiva
    jmp procesare_string    ;citesc urmatorul caracter

adunare:                    ;operatia de adunare
    pop eax
    pop ecx
    add eax, ecx
    push eax
    jmp procesare_string    ;citesc urmatorul caracter
    
scadere:                    ;operatia de scadere
    pop ecx
    pop eax
    sub eax, ecx
    push eax
    jmp procesare_string    ;citesc urmatorul caracter
    
e_operand:                  ;daca am de procesat un numar:
    xor eax, eax            ;in eax stochez numarul; initial este 0
    
urmatoarea_cifra:           ;ii calculez urmatoarea cifra si o adaug la numarul deja format
    mov bl, byte [edi - 1]  ;mut in bl caracterul citit ultima oara
    xor ecx, ecx            ;setez ecx  ca fiind 0
    mov ecx, ebx            ;mut in ecx caracterul curent(care este o cifra, reprezentata folosind codul ASCII)
    sub ecx, '0'            ;scazand din cifra curenta caracterul '0', aflu care este cifra
    add eax, ecx            ;adaug cifra la numarul deja format(a fost inmultit deja cu 10 daca era cazul)
    mov ecx, eax            ;salvez in ecx valoarea din eax
    cld                     ;setez directia de parcurgere a sirului ca fiind directa
    mov al, ' '             ;caracterul cu care voi compara ce am citit este spatiu
    scasb                   ;citesc urmatorul caracter
    je numar_format         ;daca este spatiu, am terminat de format numarul si sar la eticheta numar_format
    cmp byte [edi - 1], byte 0
    je numar_format         ;daca am citit NULL, am terminat de format numarul si sar la aceeasi eticheta, numar_format
    mov eax, ecx            ;mut inapoi in eax valoarea salvata in ecx
    mov ebx, 10             
    mul ebx                 ;inmultesc eax cu 10, pentru ca mai am de agaugat o cifra
    jmp urmatoarea_cifra    ;adaug urmatoarea cifra
    
numar_format:               ;daca am terminat de format numarul
    mov eax, ecx            ;in acest caz, numarul se afla salvat in ecx si il mut inapoi in eax(vezi urmatoarea_cifra)
    cmp [contor], byte 0    ;daca contor este 0, numarul este pozitiv
    je adaugare_pe_stiva    ;il adaug direct pe stiva
    mov ecx, -1             ;daca contor nu e 0, inseamna ca numarul este negativ de fapt si il inmultesc cu -1
    imul ecx
    
adaugare_pe_stiva:          ;adaug numarul format pe stiva
    mov [contor], byte 0    ;resetez contorul
    push eax
    jmp procesare_string    ;citesc urmatorul caracter
    
final:                      ;cand am terminat de efectuat citirea
    pop eax                 ;extrag rezultatul de pe stiva
    PRINT_DEC 4, eax        ;si il afisez
    xor eax, eax
    pop ebp
    ret
