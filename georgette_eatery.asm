; ================================================
; GEORGETTE EATERY
; Food Ordering System
; NASM 32-bit Assembly Language (Linux)
; With MACROS, PROCEDURES and receipt.txt
; ================================================
BITS 32
GLOBAL _start
%define SYS_EXIT 1
%define SYS_READ 3
%define SYS_WRITE 4
%define SYS_OPEN 5
%define SYS_CLOSE 6
; ================ MACROS =========================
%macro PRINT 2
   mov eax, SYS_WRITE
   mov ebx, 1
   mov ecx, %1
   mov edx, %2
   int 0x80
%endmacro
%macro INPUT 2
   mov eax, SYS_READ
   mov ebx, 0
   mov ecx, %1
   mov edx, %2
   int 0x80
%endmacro
%macro SAVE_RECEIPT 2
   mov eax, SYS_WRITE
   mov ebx, ebp
   mov ecx, %1
   mov edx, %2
   int 0x80
%endmacro
SECTION .data
title db 10,'========== Georgette EATERY ==========',10
title_len equ $-title
menu db 'A. Rice : Plain Rice       Php 5.00',10
    db 'B. Rice : Java Rice        Php 10.00',10
    db 'C. Ulam 1: Fish            Php 35.00',10
    db 'D. Ulam 2: Pork            Php 50.00',10
    db 'E. Ulam 3: Vegetables      Php 20.00',10
    db 'F. Dessert: Saging con yelo Php 60.00',10
    db '======================================',10
menu_len equ $-menu
ask db 'Enter your order (A-F): '
ask_len equ $-ask
again db 'Do you want to order again? [Y/N]: '
again_len equ $-again
invalid db 'Invalid choice! Please try again.',10
invalid_len equ $-invalid
invalid_yn db 'Please enter Y or N.',10
invalid_yn_len equ $-invalid_yn
ordered db 'You ordered: '
ordered_len equ $-ordered
thanks db 10,'Thank you! Please come again!',10
thanks_len equ $-thanks
receipt_title db '========== GEORGETTE EATERY RECEIPT ==========',10
receipt_title_len equ $-receipt_title
receipt_end db '==============================================',10
receipt_end_len equ $-receipt_end
receipt_file db 'receipt.txt',0
receipt_msg db 10,'----- RECEIPT CONTENTS -----',10
receipt_msg_len equ $-receipt_msg
itemA db 'Plain Rice - Php 5.00',10
lenA equ $-itemA
itemB db 'Java Rice - Php 10.00',10
lenB equ $-itemB
itemC db 'Fish - Php 35.00',10
lenC equ $-itemC
itemD db 'Pork - Php 50.00',10
lenD equ $-itemD
itemE db 'Vegetables - Php 20.00',10
lenE equ $-itemE
itemF db 'Saging con yelo - Php 60.00',10
lenF equ $-itemF
SECTION .bss
choice resb 4
answer resb 4
buffer resb 2048
SECTION .text
_start:
   call create_file
   cmp eax, 0
   jl exit_program
   mov ebp, eax
   PRINT receipt_title, receipt_title_len
   SAVE_RECEIPT receipt_title, receipt_title_len
order_loop:
   call display_menu
   PRINT ask, ask_len
   INPUT choice, 4
   cmp eax, 0
   jle finish
   mov al, [choice]
   ; Convert lowercase to uppercase
   cmp al, 'a'
   jb check
   cmp al, 'f'
   ja check
   sub al, 32
check:
   cmp al, 'A'
   je orderA
   cmp al, 'B'
   je orderB
   cmp al, 'C'
   je orderC
   cmp al, 'D'
   je orderD
   cmp al, 'E'
   je orderE
   cmp al, 'F'
   je orderF
   PRINT invalid, invalid_len
   jmp order_loop
orderA:
   mov esi, itemA
   mov edi, lenA
   jmp show_order
orderB:
   mov esi, itemB
   mov edi, lenB
   jmp show_order
orderC:
   mov esi, itemC
   mov edi, lenC
   jmp show_order
orderD:
   mov esi, itemD
   mov edi, lenD
   jmp show_order
orderE:
   mov esi, itemE
   mov edi, lenE
   jmp show_order
orderF:
   mov esi, itemF
   mov edi, lenF
show_order:
   PRINT ordered, ordered_len
   mov eax, SYS_WRITE
   mov ebx, 1
   mov ecx, esi
   mov edx, edi
   int 0x80
   SAVE_RECEIPT esi, edi
ask_again:
   PRINT again, again_len
   INPUT answer, 4
   cmp eax, 0
   jle finish
   mov al, [answer]
   cmp al, 'Y'
   je order_loop
   cmp al, 'y'
   je order_loop
   cmp al, 'N'
   je finish
   cmp al, 'n'
   je finish
   PRINT invalid_yn, invalid_yn_len
   jmp ask_again
finish:
   ; Close receipt file
   mov eax, SYS_CLOSE
   mov ebx, ebp
   int 0x80
   call thank_customer
   call show_receipt
exit_program:
   mov eax, SYS_EXIT
   xor ebx, ebx
   int 0x80
; ================ PROCEDURES =====================
display_menu:
   PRINT title, title_len
   PRINT menu, menu_len
   ret
create_file:
   mov eax, SYS_OPEN
   mov ebx, receipt_file
   mov ecx, 577
   mov edx, 420
   int 0x80
   ret
thank_customer:
   PRINT thanks, thanks_len
   ret
show_receipt:
   PRINT receipt_msg, receipt_msg_len
   ; Open receipt.txt for reading
   mov eax, SYS_OPEN
   mov ebx, receipt_file
   mov ecx, 0
   mov edx, 0
   int 0x80
   cmp eax, 0
   jl receipt_done
   mov esi, eax
read_receipt:
   mov eax, SYS_READ
   mov ebx, esi
   mov ecx, buffer
   mov edx, 2048
   int 0x80
   cmp eax, 0
   jle close_receipt
   mov edx, eax
   mov eax, SYS_WRITE
   mov ebx, 1
   mov ecx, buffer
   int 0x80
   jmp read_receipt
close_receipt:
   mov eax, SYS_CLOSE
   mov ebx, esi
   int 0x80
receipt_done:
   PRINT receipt_end, receipt_end_len
   ret
has context menu
