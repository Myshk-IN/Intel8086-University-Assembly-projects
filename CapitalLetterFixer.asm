.model small
.stack 100h
.data
	src db 255 dup(0)
	dst db "res.txt",0h
	src1 db "hello.txt",0h
	in_fh dw 0000h ;file handle is a WORD
	out_fh dw 0000h
	buff db 256 dup(?) ;because there would be 256 bytes saved in the buffer
	temp dw 0
.code
start:

	mov dx,@data
    mov ds,dx

	xor cx,cx
    mov cl,es:[80h] ;read the first parameter - how many symbols were entered (argc)
	dec cl
	mov si,0082h ;0081h - first character (a space), 0082h - first entered character
    xor bx,bx
	l:
    mov al,es:[si + bx]
    mov ds:[src + bx], al ;saving parametrs into src
    inc bx
	cmp al, 20h
	jz open_file
    loop l
	open_file:
	
	mov ah, 3dh ;open disk file with handle
	mov al, 0h
    lea dx, src ;DS:DX - address(or name, then path is set by default)
    int 21h
    mov in_fh, ax 
	
	mov ah, 3ch ;create a file with handle
    xor cx, cx ;attributes(listed in dos txt) for file (cx=0)
    lea dx, dst ;DS:DX - address(or name, then path is set by default)
    int 21h
    mov out_fh, ax
    
    lea dx, buff ;<=> mov dx, offset buff ;according to int 21h ax, 3f00h - DS:DX = address of buffer
	xor si, si
	ll:
    mov ax, 3f00h ;read from file with handle
    mov bx, in_fh 
    mov cx, 256 ;number of bytes o read (256 in this case)
    int 21h ;if CF set on error, AX = error code, otherwise - AX = number of bytes read
	
	mov temp, ax
	mov cx, temp
	xor bx, bx
	xor ax, ax
	cmp si, 1
	jz change
	lll:
	mov al, ds:[buff+bx] ;i al irasome simbolius (nuo pirm iki paskutinio)
	cmp al, 'A'
	jb skip ;praleidziame simboli, jei simbolio ASCII kodas zemesnis negu A
	cmp al, 'Z'
	ja skip ;praleidziame simboli, jei simbolio ASCII kodas zemesnis negu A
	
	jmp change
	
	skip:
	inc bx
	loop lll
	continue:
	
	mov ax, temp
	;DX - buffer to be written into the file
    mov cx, ax ;writing number of bytes read into CX (according to ax, 4000h: CX = number of bytes to write)
    mov ax, 4000h ;write to file with handle
    mov bx, out_fh ;BX = file handle
    int 21h
	;if CX is zero, no data is written, and the file is truncated or extended to the current position; If CX = 0, the loop ends
    cmp ax, 0 ;AX - error code (CF set on error) or number of bytes written (CF clear) ;checking whether bytes were written
    jnz ll
	
	;close files
	mov ah,3eh ;close a file with handle
    mov bx, out_fh ;BX = file handle
    int 21h
	
	mov ah,3eh ;close a file with handle
    mov bx, in_fh ;BX = file handle
    int 21h
	
    mov ah, 4ch
    mov al, 0
    int 21h
	
	change:
	mov ah, '*'
	mov ds:[buff+bx], ah
	inc bx
	dec cx
	mov al, ds:[buff+bx]
	cmp cx, 0
	mov si, 1
	jz continue
	cmp al, ' '
	jz lll
	cmp al, 13
	jz lll
	jmp change
	
	
end start
