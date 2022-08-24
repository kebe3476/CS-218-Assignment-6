;	Assignment #6
; 	Author: Keith Beauvais
; 	Section: 1001
; 	Date Last Modified: 10/18/2021
; 	Program Description: This program will explore the use of fuctions, floating points, command line arguments and intefrating C/C++ code
;   Tried using gcc to link and got error used g++ instead and everything worked


section .data

    SYSTEM_EXIT equ 60
	SUCCESS equ 0
	SYSTEM_READ equ 0 
	STANDARD_IN equ 0
	SYSTEM_WRITE equ 1
	STANDARD_OUT equ 1

    NULL equ 0
	LINEFEED equ 10

    pi dd 3.14159
    heliumLift dd 0.06689

    weightArg db "-W", NULL
    diameterArg db "-D", NULL

    argIs1Error db "Please include the following: -W weight -D diameter", LINEFEED, NULL
    wrongArgs db "Expecected 4 arguments: -W weight -D diameter",LINEFEED,NULL
    weightError db "Expected a -W argument",LINEFEED,NULL
    diameterError db "Expected a -D argument",LINEFEED,NULL
    invalidNumber db "Invalid Number",LINEFEED,NULL


section .bss

    weightVariable resq 1
    diameterVariable resq 1

    extern atof, ceil, printBalloonsRequired
    

section .text

;-----------------------------
; argc -> edi
; argv -> rsi
global processCommandLineArgs
processCommandLineArgs:
    ; Presevered Registers:
    push rbx
    push rdx
    push rcx

    ; checks for single argument
    cmp edi, 1
    jne keepChecking

    ; Return 0 for single argument: 
    mov rax, 0

    ; Restore Preserved Registers:
    pop rcx
    pop rdx
    pop rbx
   
ret

    
    keepChecking:
    
        push rdi
        push rsi
        ; more than 1 args but less than 5 
        cmp rdi, 5

        je continueChecking
        ; Returns -1 if (1 < args < 5)

        mov rax, -1

        pop rsi
        pop rdi
        pop rcx
        pop rdx
        pop rbx
    ret

    ; Checks if the second command line arg is -W

    continueChecking:

        mov rdi, qword[rsi+8]
        mov rsi, weightArg
        call compareStrings

        cmp rax, 0 
        je checkDiameter

        ; returns -2 if second arg is not -W
        mov rax, -2

        pop rsi
        pop rdi
        pop rcx
        pop rdx
        pop rbx
    ret
    
    ; Checks if the second command line arg is -D

    checkDiameter:
        ;Restores original rsi and rdi and saves them 
        pop rsi
        pop rdi
        push rdi
        push rsi

        mov rdi, qword[rsi+24]
        mov rsi, diameterArg
        call compareStrings

        cmp rax, 0 
        je checkDiameterNumber

        ; Returns -4 id fourth arg is not -D
        mov rax, -4

        pop rsi
        pop rdi 
        pop rcx
        pop rdx
        pop rbx
    ret

    ;Checks the value of the Diameter and converts
    checkDiameterNumber:
        ;Restores original rsi and rdi and saves them 
        pop rsi 
        pop rdi
        push rdi
        push rsi

        ;Aligning Stack
        mov rax, rsp
        mov rdx, 0
        mov rcx, 16
        div rcx
        sub rsp, rdx
        mov rbx, rdx
        
        ; atof function call
        mov rdi, qword[rsi + 32]
        call atof
        add rsp, rbx

        cvtsd2ss xmm7, xmm0
        movss xmm0, xmm7

        mov eax, 0
        cvtsi2ss xmm1, eax ; 0.0

        ;compares atof (xmm0) to 0.0 (xmm1)
        ucomiss xmm0, xmm1 
        ja checkWeightNumber

        ; if incorrect number enter i.e. < 0 then returns -3
        mov rax, -3
        
        pop rsi
        pop rdi
        pop rcx
        pop rdx
        pop rbx
    ret

    checkWeightNumber:

        movss dword[diameterVariable], xmm0 ; moves the previous xmm0 (returned value) into the diameter variable
        ;Restores original rsi and rdi and saves them 
        pop rsi 
        pop rdi
        push rdi
        push rsi

        ;Aligning Stack
        mov rax, rsp
        mov rdx, 0
        mov rcx, 16
        div rcx
        sub rsp, rdx
        mov rbx, rdx
        
        ; atof function call
        mov rdi, qword[rsi + 16]
        call atof

        add rsp, rbx

        cvtsd2ss xmm7, xmm0
        movss xmm0, xmm7

        mov eax, 0
        cvtsi2ss xmm1, eax ; 0.0

        ucomiss xmm0, xmm1 ;compares atof (xmm0) to 0.0 (xmm1)
        ja noErrors
        ; if incorrect number enter i.e. < 0 then returns -3
        mov rax, -3
        pop rsi
        pop rdi
        pop rcx
        pop rdx
        pop rbx
    ret

    noErrors:
        ; moves the previous xmm0 (returned value) into the weight variable
        movss dword[weightVariable], xmm0
        ; returns a 1 if there are no errors 
        mov rax, 1 
        
        pop rsi
        pop rdi
        pop rcx
        pop rdx
        pop rbx
    ret


;-----------------------------
global balloonCalc
balloonCalc:
    ; xmm0 -> diameter
    ; xmm1 -> weight
    movss xmm6, xmm1 ; moves weight to xmm6

    ; Balloon Volume:
    ; 4/3 x pi x (diameter/2)^3

    ; 4/3
    mov eax, 4
    cvtsi2ss xmm4, eax ; 4
    mov eax, 3
    cvtsi2ss xmm3, eax ;  3
    divss xmm4, xmm3 ; 4/3 in xmm4

    ; 4/3 * pi
    mulss xmm4, dword[pi] ; (4/3)* pi

    ; (diameter/2)^3
    mov eax, 2 
    cvtsi2ss xmm2, eax ; xmm2 = 2
    divss xmm0, xmm2 ; diameter/2
    ; ^3
    movss xmm5, xmm0;
    mulss xmm0, xmm0; ^2
    mulss xmm0, xmm5; ^3 (diameter/2)^3 -> xmm0

    ;(4/3*pi)*((diameter/2)^3)
    mulss xmm0, xmm4

    ; Ballon Volume x Helium Lift
    mulss xmm0, dword[heliumLift]

    ; Weight / (Ballon Volume x Helium Lift)
    divss xmm6, xmm0

    movss xmm1, xmm6
    
    mov rax, 0
    cvtsi2sd xmm0, rax
    cvtss2sd xmm0, xmm6

    mov rax, rsp
    mov rdx, 0
    mov rcx, 16
    div rcx
    sub rsp, rdx
    mov rbx, rdx

    call ceil

    add rsp, rbx

    cvtsd2ss xmm1, xmm0
    movss xmm0, xmm1

ret


;-----------------------------
; Argument 1: Address to a null terminated string
global stringLength
stringLength:

    push rbx
    push rdi

    mov rcx, 0
    stringLoop:

		mov bl, byte[rdi] 
		cmp bl, NULL 
		je endStringLoop 

		inc rcx 
		inc rdi 
		jmp stringLoop  

    endStringLoop:
        mov rax, rcx ; returns the length of the string

        pop rdi
        pop rbx

ret
;-----------------------------
global printString
printString:
    push rbx
    push r12

    mov r12, rdi

    call stringLength
    

    mov rdx, rax
    mov rax, SYSTEM_WRITE
    mov rdi, STANDARD_OUT
    mov rsi, r12

    syscall

    pop r12
    pop rbx
ret
;-----------------------------
global compareStrings
compareStrings:
    
    mov dl, byte[rdi]
    cmp dl, byte[rsi]
    je compareNULL ; same char see if NULL

    cmp dl, byte[rsi]
    jb charLess

    mov rax, 1
    ret 

    charLess:
        mov rax, -1 ; rdi is less than rsi 
        ret

    compareNULL:
        cmp dl, NULL
        jne increaseChar ; not NULL but equal char, move to next char if not equal to NULL
        mov rax, 0 ; char is a NULL and returns 0 
        ret

    increaseChar:
        inc rdi
        inc rsi
        jmp compareStrings
ret       
;-----------------------------   
global main
main:

    call processCommandLineArgs
    ; No errors
    cmp rax, 1
    je goodArgs
    ; only 1 argument
    cmp rax, 0 
    je ifArgcIs1
    ; if 1 < args < 5
    cmp rax, -1
    je lessThan5Args
    ; if there is an error with -W
    cmp rax, -2
    je secondArgError
    ; if the values for diamenter or weight are less than 0
    cmp rax, -3
    je lessThanZero
    ; if there is an error with -D
    cmp rax, -4
    je fourthArgError

    ifArgcIs1:
        mov rdi, argIs1Error
        call printString
        jmp endProgram

    fourthArgError:
        mov rdi, diameterError
        call printString
        jmp endProgram

    lessThanZero:
        mov rdi, invalidNumber
        call printString
        jmp endProgram

    secondArgError:
        mov rdi, weightError
        call printString
        jmp endProgram

    lessThan5Args:
        mov rdi, wrongArgs
        call printString
        jmp endProgram

    goodArgs:

    ; xmm0 -> diameter
    ; xmm1 -> weight

    movss xmm0, dword[diameterVariable]
    movss xmm1, dword[weightVariable]

    call balloonCalc
    
    movss xmm3, xmm0
    movss xmm4, dword[weightVariable]
    movss xmm5, dword[diameterVariable]

    cvtss2sd xmm0, xmm4 ; weight
    cvtss2sd xmm1, xmm5 ; diameter
    cvtss2sd xmm2, xmm3 ; weight
    
    ; Aligning stack 
    mov rax, rsp
    mov rdx, 0
    mov rcx, 16
    div rcx
    sub rsp, rdx
    mov rbx, rdx
    call printBalloonsRequired

    add rsp, rbx

endProgram:
    mov rax, SYSTEM_EXIT
    mov rdi, SUCCESS
    syscall