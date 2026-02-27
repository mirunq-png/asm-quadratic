.model small
.stack 200h
.data
    intro db "Introduceti coeficientii intregi pentru ecuatia de gradul 2, ax^2+bx+c$"
    mesaj_a db "a=$"
    mesaj_b db "b=$"
    mesaj_c db "c=$"
    mesaj_solunica db "Solutia unica este x=$"
    mesaj_sol1 db "Solutiile sunt x1=$"
    mesaj_sol2 db " si x2=$"
    mesaj_solinf db "Exista o infinitate de solutii$"
    mesaj_solvida db "Nu exista solutii$"
    mesaj_dneg db "Solutiile sunt numere complexe$"

    a dw 0 ; coef lui x^2
    b dw 0 ; coef lui x
    c dw 0 ; coef liber
    aux dw 0 ; auxiliar pentru calcule, debugging etc.

    semn_a dw 0
    semn_b dw 0
    semn_c dw 0
    semn dw 0 ; semn auxiliar

    delta dw 0 ; delta
    sqrt dw 0 ; radical din delta
    bb dw 0 ; b^2
    ac dw 0 ; 4ac
    
    x dw 0 ; variabila1 folosita pentru a calcula sqrt
    y dw 0 ; variabila2 -------------,,--------------

    cst1 dw 0 ; b din formula (-b+-sqrt(delta) ) / 2a, aka cand se determina solutiile x1 si x2
    cst2 dw 0 ; a din formula ---------------------------,,------------------------------------
    semn_cst1 dw 0
    semn_cst2 dw 0

    virgula dw 0 ; tinem cont daca un numar contine virgula sau nu

.code
    ;;;;;;;;;;;;;;macros,proceduri;;;;;;;;;;;;;;
    newLine MACRO ; self explanatory
        mov ah, 02h
	    mov dl, 10
	    int 21h
	    mov dl, 13
	    int 21h
    ENDM

    afisMesaj MACRO mesaj ; self explanatory
	    mov dx, offset mesaj
	    mov ah, 09h
	    int 21h
    ENDM

     afisCifra MACRO cx ; afisare numar, fara a lua in calcul existenta unui minus
	    afiseazaCifra:
	        pop dx
	        add dl, '0'
	        mov ah, 02h
	        int 21h
	        loop afiseazaCifra
    ENDM

    scrieVirgula MACRO cx ; self explanatory
	    cmp cx, 1
	        jne skipZero
		mov dx, '0'
		mov ah, 02h
		int 21h ; scrie 0 => 0
		mov dx, ','
		mov ah, 02h
		int 21h ; scrie virgula => 0,
		pop dx
		add dl, '0'
		mov ah, 02h
		int 21h ; scrie cifra => 0,ceva
		jmp exitVirgula
	    skipZero:
	        sub cx, 1
	        afisCifra cx
	        pop cx
	        mov ax, cx
	        cmp ax, 0
		        je exitVirgula
		    mov dx, ',' 
		    mov ah, 02h
		    int 21h
		    mov dx, cx
		    add dx, '0'
		    mov ah, 02h
		    int 21h
	    exitVirgula:
    ENDM

    citireNumar PROC
	    xor dx, dx
	    mov cx, 10
	    buclaCitire:
		    mov ah, 01h
		    int 21h
		    cmp al, 13 ; verific daca este enter
		        je done
		    cmp al, '-' ; verific daca este minus
		        je negativ
		    sub al, '0' ; schimb codul ascii in cifra
		    mov bl, al
		    mov ax, dx
		    mul cx
		    add ax, bx
		    mov dx, ax
	        jmp buclaCitire
        negativ:
            mov semn, 1
            jmp buclaCitire
	    done: ; am format numarul in dx
            ret
    citireNumar ENDP
	
    afisareNumar PROC
        cmp semn, 1
            jne skipMinus
        ; se ajunge aici cand nr este negativ
        mov ah, 02h 
        mov dl, '-'
        int 21h
        skipMinus:
        ; se ajunge aici indiferent
        mov dx, aux
        mov ax, dx
        mov bx, 10
        xor cx, cx
        descompunere:
            xor dx, dx
            div bx
            push dx
            inc cx ; nr de cifre
            cmp ax, 0
                je descompus
            jmp descompunere
        descompus:
            mov ax, virgula
            cmp ax, 1 ; daca virgula=1 inseamna ca nr contine virgula si se afiseaza
                je areVirgula
        afisare:
            pop dx
            add dl, '0' ; convertim numarul in cod ascii pentru afisare
		    mov ah, 02h
		    int 21h
            loop afisare
        jmp bravo ; am terminat de afisat
        areVirgula:
            scrieVirgula cx
        bravo:
            ret
    afisareNumar ENDP

    impartire PROC
        xor ax, ax
        xor dx, dx
	    add ax, semn_cst1
	    add ax, semn_cst2
        ; stabilim semnul rezultat dupa impartirea b/a
        cmp ax, 0 ; poz/poz=poz
            je semnImpartirePoz
        cmp ax, 1 ; neg/poz=neg || poz/neg=neg
            je semnImpartireNeg
        cmp ax, 2 ; neg/neg=poz
            je semnImpartirePoz
        semnImpartirePoz:
            mov semn, 0
            jmp contImpartire
        semnImpartireNeg:
            mov semn, 1
        contImpartire:
	        xor dx, dx
	        mov ax, cst1
	        mov bx, cst2
	        div bx ; cst1/cst2 <=> b/a
	        xor dx, dx
	        mov bx, 2
	        div bx ; (b/a)/2 <=> b/2a
	        mov aux, ax
        ret
    impartire ENDP
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    main:
        mov ax, @data
	    mov ds, ax
        ;;;;;;;;;;;;;;afis mesaje, citire a,b,c;;;;;;;;;;;;;;
        newLine
        afisMesaj intro
        newLine
        newLine
        afisMesaj mesaj_a
        ; a
        call citireNumar
        mov aux, dx
        mov a, dx
        push semn
        pop dx
        mov semn_a, dx
        newLine
        afisMesaj mesaj_b
        ; b
        mov semn, 0
        call citireNumar
        mov aux, dx
        mov b, dx
        push semn
        pop dx
        mov semn_b, dx
        newLine
        afisMesaj mesaj_c
        ; c
        mov semn, 0
        call citireNumar
        mov aux, dx
        mov c, dx
        push semn
        pop dx
        mov semn_c, dx
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        newLine
        mov ax, a 
        cmp ax, 0 ; a=0?
            je cont
        jmp ecGr2 ; a!=0
        cont: ; a=0
            mov ax, b
            cmp ax, 0 ; b=0?
                je doarC
            mov ax, c
            cmp ax, 0 ; c=0?
                jne cont2
            ; ecuatie de forma bx=0
            mov aux, 0
            mov semn, 0
            afisMesaj mesaj_solunica
            call afisareNumar
            jmp finish
        cont2:
            ; ecuatie de forma bx+c=0
            mov ax, c
            mov bx, 10
            mul bx
            mov c, ax
            mov virgula, 1
            ; stabilim semnul lui -c/b
            mov ax, 1
            add ax, semn_c
            add ax, semn_b
            cmp ax, 1 ; c si b poz => neg
                je cbNeg
            cmp ax, 2 ; c sau b neg => poz
                je cbPoz
            cmp ax, 3 ; c si b neg => neg
                je cbNeg
            cbPoz:
                mov semn, 0
                jmp contCB
            cbNeg:
                mov semn, 1
            contCB:
			xor dx, dx
			mov ax, c
			mov bx, b
			div bx ; realizam c/b
			mov aux, ax
			afisMesaj mesaj_solunica
			call afisareNumar
			jmp finish
        doarC: ; ecuatia de forma c=0
            mov ax, c
            cmp ax, 0 ; c=0?
                jne nuSuntSol
            ; a=b=c=0
            afisMesaj mesaj_solinf
            jmp finish
        nuSuntSol: ; a=b=0 si c!=0
            afisMesaj mesaj_solvida
            jmp finish
        ecGr2: ; a!=0 deci ecuatie de gradul 2
            xor ax, ax
            xor dx, dx
            ; calculam b^2
            mov ax, b
            mul ax
            mov bb, ax
            mov semn, 0 ; b^2 mereu va fi pozitiv
            xor ax, ax
            xor bx, bx
            xor dx, dx
            mov ax, a
            mov bx, 4
            mul bx ;4a
            mov bx, c
            mul bx ;4ac
            mov ac, ax  ; am calculat 4ac, fara a tine cont de semn
            ; calculam semnul lui '-4ac'
            xor ax, ax
            mov ax, 1
            add ax, semn_a
            add ax, semn_c
            cmp ax, 1 ; neg*poz*poz=neg
                je semn4acNeg
            cmp ax, 2 ; neg*neg*poz=poz
                je semn4acPoz
            cmp ax, 3 ; neg*neg*neg=neg
                je semn4acNeg
            semn4acPoz:
                mov semn, 0
                jmp cont4AC
            semn4acNeg:
                mov semn, 1
            cont4AC:
            mov ax, bb
            mov cx, ac
            xor dx, dx
            cmp semn, 1 ; daca semnul lui -4ac este 0, 4ac se va aduna la b^2
                jne adunare
            cmp ax, cx 
                jge scadere ; daca b^2 > 4ac
            afisMesaj mesaj_dneg ; daca b^2 < 4ac
            jmp finish
            scadere:
                sub ax, ac
                jmp finB4AC
            adunare:
                add ax, ac
            finB4AC:
                ; incepem pregatirile pentru radical din delta
                mov delta, ax ; mutam b^2-4ac in delta
                mov semn, 0 ; delta este pozitiv
                mov ax, delta
                mov sqrt, ax
                cmp delta, 0 ; delta=0?
                    je skipSqrt
                xor ax, ax
	            mov bx, 2
	            mov cx, delta
	            xor dx, dx
	            mov x, cx ; x=delta
	            mov y, 1 ; y=1
	        squareRoot: ; METODA BABILONIANA
		        mov ax, x
		        add ax, y
		        mov x, ax ; x+y
		        xor dx, dx
		        mov bx, 2
		        div bx
		        mov x, ax ; (x+y)/2
		        xor dx, dx
		        mov ax, cx
		        mov bx, x
		        div bx
		        mov y, ax ; n/x
		        mov ax, y
		        inc ax
		        mov bx, x
		        cmp bx, ax ; am ajuns la precizia dorita
	                jg squareRoot
	            mov ax, x
	            mov sqrt, ax
	            mov semn, 0
            skipSqrt:
                mov ax, sqrt
                mov bx, 10
                mul bx
                mov sqrt, ax ; sqrt*10
                mov ax, b
	            mov bx, 10
	            mul bx
	            mov b, ax ; b*10
                mov virgula, 1
                mov ax, sqrt
                cmp ax, 0
                    jne douaSol
                ; delta=0
                mov ax, b
                mov cst1, ax
                mov ax, semn_b
                mov semn_cst1, ax
                inc semn_cst1
                mov ax, a
                mov cst2, ax
                mov ax, semn_a
                mov semn_cst2, ax
                call impartire ; realizam -b/2a
                afisMesaj mesaj_solunica
                call afisareNumar
                jmp finish
            douaSol: ; delta!=0
	            ; ne propunem sa stabilim semnele pentru b, radical si b+radical
                ;;;;;;;;;;;;;;;;;solutia 1;;;;;;;;;;;;;;;;;
	            mov ax, semn_b
	            cmp ax, 1
	                jne fl1 ; b<0
	            ; b>0
	            mov ax, b
	            mov bx, sqrt
	            add ax, bx ; b+radical
	            mov cst1, ax ; cst1 devine b+radical
	            mov semn_cst1, 0 ; b+radical este pozitiv
	            jmp fl3
	            fl1: ; b<0
	                mov ax, sqrt
	                mov bx, b
	                cmp ax, bx
	                    jl fl2 ; sqrt < bx, dar bx < 0 <=> sqrt<0
		            ; sqrt>0
		            sub ax, bx ; sqrt-b
		            mov cst1, ax
		            mov semn_cst1, 0 ; sqrt>0
		            jmp fl3
	            fl2: ; b<0 si sqrt<0
		            sub bx, ax ; b-sqrt
		            mov cst1, bx
		            mov semn_cst1, 1 ; 
		            jmp fl3
	            fl3: ; se muta in cst2 (respectiv semn_cst2) valoarea (si semnul) lui a, pentru a putea apela impartirea corect
		        ; se ajunge aici indiferent de semnul lui b
		        mov ax, a
		        mov cst2, ax
		        mov ax, semn_a
		        mov semn_cst2, ax
		        call impartire ; realizam (-b+-sqrt(delta))/2a
		        afisMesaj mesaj_sol1
		        call afisareNumar
	            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                ;;;;;;;;;;;;;;;;;solutia 2;;;;;;;;;;;;;;;;;
                ; se procedeaza identic
	            mov ax, semn_b
	            cmp ax, 0
	                jne fl4
	            mov ax, b
	            mov bx, sqrt
	            add ax, bx
	            mov cst1, ax
	            mov semn_cst1, 1
	            jmp fl6
	            fl4:
	                mov ax, sqrt
	                mov bx, b
	                cmp ax, bx
	                    jg fl5
		            sub bx, ax
		            mov cst1, bx
		            mov semn_cst1, 0
		            jmp fl6
	            fl5:
		            sub ax, bx
		            mov cst1, ax
		            mov semn_cst1, 1
		            jmp fl6
	            fl6:
		        mov ax, a
		        mov cst2, ax
		        mov ax, semn_a
		        mov semn_cst2, ax
		        call impartire
		        afisMesaj mesaj_sol2
		        call afisareNumar
	            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     

        finish: ; am reusit!
            newLine
            mov ah, 4ch
            int 21h
        end main