Progr           segment
                assume  cs:Progr, ds:dane, ss:stosik

start:          mov ax,dane
                mov ds,ax
                mov ax,stosik
                mov ss,ax
                mov sp,offset szczyt
napiszPustyZnak:
                mov ax, 0b800h ;Początek bloku na pamięć wideo
                mov es, ax
                mov di, 0 ;di czyli rejestr indeksowy. Może być wykorzystywany jako wstaźnik - adresacja pośrednia
                mov al, ' '
                mov ah, 07d ;Biała litera na czarnym tle - modyfikacja wyglądu znaku
				mov cx, 2000
czysc:		
				mov es:[di], ax   ;To jest tak jakby referencja, chcesz modyfikować wartość a nie wskaźnik
				inc di
				inc di
				loop czysc
				mov ax, 0b800h
				mov di, 0
powtarzajWPionie:
				mov cx, [ilePrzesun] ;Tak jakby referencja, WARTOŚĆ ilePrzesun a nie ilePrzesun
przesun:    
				inc di
				inc di
				loop przesun
				mov cx, [ileWypisac]
wypisz:
				mov al, [jakaLiterka]
				mov ah, 07d
				mov es:[di], ax
				inc di
				inc di
				loop wypisz
				add [ileWypisac], 2
				mov bx, [ileDoKonca]
				shl bx, 1
				add di, bx			
				sub [ilePrzesun], 1
				sub [ileDoKonca], 1
				sub [ileRazy], 1
				mov cx, [ileRazy]
				inc [jakaLiterka]
				loop powtarzajWPionie
				
				;Przerwanie kończące program
				mov  ah, 4ch
                mov  al, 0
                int  21h
Progr           ends

dane            segment
	 ilePrzesun dw 39
	 ileDoKonca dw 40
	 ileWypisac dw 1
	    ileRazy dw 25   ;dw jest 16 bitowe
	jakaLiterka db 'a' ;db jest 8 bitowe
dane            ends

stosik          segment
                dw    100h dup(0)
szczyt          Label word
stosik          ends

end start