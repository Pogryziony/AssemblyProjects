Progr       segment
            assume  cs:Progr,ds:data,ss:stackSeg
Start:									
            mov ax,data							
            mov ds,ax	
            mov ax,stackSeg						
            mov ss,ax
            mov sp,offset szczyt	
;zerowanie ax i dx i pobranie czasu systemowego (brak powrotu do tej etykiety)            
zerow:            
            mov ax,0							
            mov dx,0																	 
            int 1Ah								
            mov sysTime,dl							
            mov ax,0							
            mov dx,0	
;losowanie linii  
loop1:
            mov ax,0							
            inc sysTime							
            mov al,sysTime							
            mov si,ax							
            mov dl,randNum(si) 					
            mov losik,dl		
            mov ax,0							
            mov dx,0							
            mov ah,0		   
            mov al,160							
            mul losik 						
            mov bx,ax 		
;-wyczysczenie flagi kierunku-            
            cld							;Zeruje znacznik kierunkowy	
;-----------------------------            
            push ds								
            push ds								
            pop es								
            mov di,0							
            mov ax,0b800h						
            mov ds,ax							
            mov si,bx							
            mov cx,80							
            rep movsw		;Powtarzanie kopiowania 16bitowych słów (Double Bytes) 							
            pop ds								
            mov ax,0b800h						
            mov es,ax			   				
            mov si,bx		
;wypelnienie wylosowanej linii spacjami (32) oraz kolorem czerwonym(01000000b)  
loop2:
            mov byte ptr es:[si],32   			
            mov byte ptr es:[si+1],01000000b 
            inc si								
            inc si								
            inc znaki						
            cmp znaki,80					 
            jnz loop2		
            
            mov znaki,1						
            mov cx,8							
            mov dx,0	
;---------int 15h fun86 : Wait---------            
            mov ah,86h							
            int 15h	
;--------------------------------            
            mov si,offset buffer					
            mov di,bx							
            mov cx,80							
            rep movsw  	
;czekaj na nacisniecie znaku - jesli nacisnieto - zakoncz program - jesli nie, skocz do loop1	
;--------------int 16h fun 01: Read input status --------------------------------------------            
            mov ah,1h	
            int 16h								
            jnz progrEnd							
            jmp loop1	
  
progrEnd: 
            mov ah,4Ch							
            mov al,0h							
            int 21h	
  
Progr ends

stackSeg segment
            dw 100h dup(0)
            szczyt label word
stackSeg ends

data segment
            buffer db 160 dup(?)		
            losik db 0
            znaki db 1
            sysTime db 0
            randNum db 4, 7, 11, 2, 11, 17, 24, 21, 0, 18, 8, 11, 0, 0, 14, 19, 13, 4, 6, 4, 8, 23, 20, 5, 23, 19, 24, 6, 4, 16, 10, 12, 7, 2, 20, 15, 18, 24, 18, 17, 15, 12, 23, 2, 1, 13, 10, 1, 4, 23, 2, 4, 17, 6, 13, 19, 16, 15, 16, 13, 14, 10, 6, 17, 9, 5, 20, 24, 8, 5, 17, 7, 23, 12, 18, 7, 10, 3, 16, 21, 22, 19, 20, 1, 23, 14, 18, 7, 19, 14, 21, 22, 9, 15, 6, 8, 5, 18, 20, 3, 6, 24, 11, 2, 5, 2, 24, 24, 24, 24, 22, 10, 9, 20, 13, 10, 10, 21, 14, 4, 15, 17, 22, 1, 18, 22, 13, 3, 24, 3, 14, 16, 3, 5, 12, 19, 16, 8, 11, 18, 0, 0, 10, 3, 20, 20, 12, 10, 5, 20, 24, 8, 19, 24, 1, 18, 13, 18, 12, 15, 3, 9, 13, 1, 22, 12, 20, 10, 5, 9, 18, 23, 9, 18, 5, 14, 7, 15, 24, 8, 21, 22, 13, 6, 24, 8, 3, 11, 2, 8, 5, 15, 24, 2, 11, 11, 5, 12, 1, 8, 20, 17, 18, 6, 14, 7, 2, 2, 19, 7, 7, 18, 17, 20, 5, 23, 0, 13, 12, 19, 23, 6, 9, 12, 18, 4, 18, 8, 1, 19, 10, 3, 16, 7, 8, 2, 23, 18, 19, 3, 5, 11, 6, 3, 9, 14, 2, 12, 0, 6, 8, 16, 19, 3, 22, 16
data ends	

end start