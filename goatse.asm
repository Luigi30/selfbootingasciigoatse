include emu8086.inc                                  
                                  
; directive to create BOOT file:
#make_boot#

; Boot record is loaded at 0000:7C00,
; so inform compiler to make required
; corrections:
ORG 7C00h

PUSH    CS   ; make sure DS=CS
POP     DS

lea SI, plsWait
mov ah, 0eh

mov al, 0x36
out 0x43, al    ;tell the PIT which channel we're setting
 
mov AL, 2Eh 	;0x2E9B, 100Hz system timer
out 0x40, AL    ;send low byte
mov AL, 9Bh
out 0x40, AL    ;send high byte

writing:
    MOV AL, [SI] ;load
    CMP AL, 0
    JZ sectors
    INT 10h
    INC SI
    JMP writing

sectors:       
; load some floppy sectors into memory to make it look like we're doing something
    mov ah, 02h
    mov AL, 10
    mov ch, 0
    mov cl, 1
    mov dx, 0
    mov bx, 1000h
    mov es, bx
    mov bx, 0000h
    int 13h

; load message address into SI register:
LEA SI, msg
MOV AH, 0Eh

yospos: 
    MOV AL, [SI] ;load
    CMP AL, 0
    JZ done
    INT 10h
    INC SI
    JMP yospos

; wait for 'any key':
done:   
    MOV AH, 0
    INT 16h
           
    MOV AH, 0Eh
    INT 10h
        
    cmp AL,'y'
    je penusNewLine

reboot:  
    MOV     AX, 0040h
    MOV     DS, AX
    MOV     w.[0072h], 0000h
    
    JMP	0FFFFh:0000h 
            
penusNewLine:
    mov al,new_line
    mov ah,0eh
    int 10h            
            
penusStart:
    ;load sectors 2-5 into working memory
    ;lea si, asciiGoatse
    ;mov ah,0eh
    mov     ah, 02h ; read function.
    mov     al, 10  ; sectors to read.
    mov     ch, 0   ; cylinder.
    mov     cl, 2   ; sector.
    mov     dh, 0   ; head.
    ; dl not changed! - drive number.
    
    ; es:bx points to receiving
    ;  data buffer:
    mov     bx, 0800h   
    mov     es, bx
    mov     bx, 0

    ; read!
    int     13h
    
    ;Read from 0800:0000 to find the ASCII goatse.
    ;DS = 0800 (data source is 0800)
    ;SI = 0000 (offset of string is 0000)
    
    mov bx, 0800h
    mov ds, bx
    mov bx, 0
    mov si, 0000h
    mov ah, 0eh 
       
penusLoop:
    mov al,[si]
    cmp al,0
    jz endOfLine ;have we reached the null terminator of the ASCII goatse?
    int 10h
    inc si
    jmp penusLoop
    
endOfLine:
    print 'END OF LINE.'
    hlt    

new_line EQU 13, 10

msg DB  'GOATSE Y/N?',
    db  new_line,'>',0

plsWait db 'Loading GOATSE OS...',
        db new_line,0