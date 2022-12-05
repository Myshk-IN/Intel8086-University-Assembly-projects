.model small
.stack 100h

.data
	msg db "Iveskite eilute: $"
	buff db 255, ?, 255 dup(?)
	res db 0dh, 0ah, "Atsakymas: $"
	counter db 0
	buff_rez db 3 dup(?), "$"
	
.code
start:
	mov	ax, @data		
	mov	ds, ax	
	
	;Atspausdiname msg
	mov ah, 9
	mov dx, offset msg
	int 21h
	;irasome eilute i buff
	mov ah, 0ah
	mov dx, offset buff
	int 21h
	
	xor cx, cx ;cx = 0
	mov cl, [buff+1] ;irasome i cl kiek buvo ivesta simboliu
	xor bx, bx ;bx = 0
	jcxz pabaiga ;jeigu nieko neivesta - i pabaiga  
	
	l:
	mov al, ds:[buff+2+bx] ;i al irasome simbolius (nuo pirm iki paskutinio)
	cmp al, 'A'
	jb skip ;praleidziame simboli, jei simbolio ASCII kodas zemesnis negu A
	cmp al, 'Z'
	ja skip ;praleidziame simboli, jei simbolio ASCII kodas zemesnis negu A
	
	inc counter ;issaugome did.raidziu kieki
   
	skip:
	inc bx ;imame sekanti simboli
	
	loop l
	
	xor cx, cx
	xor bx, bx
	mov cl, counter;ne ch, nes tokiu atveju paskui bus daloma is 0!
	cmp cl, 10 ;tikriname, ar counter (ch) > ar < uz 10
	jc carry10
	cmp cl, 100 ;tikriname, ar counter (ch) > ar < uz 100
	jc carry100
	cmp cl, 255 ;tikriname, ar counter (ch) > ar < uz 256
	jc carry255
	
	carry10: ;jeigu skaicius yra nuo 0 iki 9
	add cl, 30h ;+30h, nes ASCII lenteleje skaiciai prasideda nuo 30h
	mov ds:[buff_rez], cl
	jmp result
	
	carry100: ;jeigu skaicius yra nuo 10 iki 99
	mov ax, cx
	mov bl, 10
	div bl ;ekvivalentu cx/10, dalybos rezultatas eina i al, liekana eina i ah 
	add al, 30h
	add ah, 30h;
	mov ds:[buff_rez], al
	mov ds:[buff_rez+1], ah
	jmp result
	
	carry255: ;jeigu skaicius yra nuo 100 iki 255
	mov ax, cx
	mov bl, 100
	div bl
	add al, 30h
	mov ds:[buff_rez], al
	mov al, ah
	xor ah, ah
	mov bl, 10
	div bl
	add al, 30h
	add ah, 30h;
	mov ds:[buff_rez+1], al
	mov ds:[buff_rez+2], ah	
	jmp result
	
	;rezultatu atspausdinimas
	result:
	mov ah, 9
	mov dx, offset res
	int 21h
	mov ah, 9
	mov dx, offset buff_rez
	int 21h
	
	pabaiga:
	mov ax, 4c00h
	int 21h
	
end start
