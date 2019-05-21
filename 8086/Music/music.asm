;|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
;|Przygotowałem 4 pliki muzyczne: mario.txt,spider.txt,nutka.txt,spect.txt|
;|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|


;Układ 8253 może być wykorzystany do generowania dźwięku z głośnika systemowego. Aby wygenerować dźwięk o danej częstotliwości potrzebne jest 
;zaprogramowanie dzielnika. Aby ustawić wartość dzielnika należy je wysłać poprzez port 42h w kolejności najpierw mniej znaczący bajt, 
;a później bardziej znaczący bajt. 
;Układ 8255 - układ we/wy

;Podzielniki czestotliwosci
noteC equ 36156    ;1193180Hz/33Hz
noteD equ 32248    ;1193180Hz/37Hz
noteE equ 29102    ;1193180Hz/41Hz
noteF equ 27118    ;1193180Hz/44Hz
noteG equ 24350    ;1193180Hz/49Hz
noteA equ 21694    ;1193180Hz/55Hz
noteH equ 19245    ;1193180Hz/62Hz
notePause equ 1    ;pauza

Progr           segment
                assume  cs:Progr, ds:data, ss:stackSeg

                jmp start

closeFile:      mov ah, 3EH             ;Funkcja do zamykania pliku, wymaga w bx "fileID", czyli id pliku
                mov bx, fileID
                int 21H
                ret
              
noFileParam:    lea dx, noFileParamMsg  ;wyświetlanie błędu o braku wprowadzonej nazwy plpiku
                mov ah, 09H
                int 21H
                jmp progrEnd

noFile:         lea dx, noFileMsg       ;wyświetlanie błędu o nieistniejącym pliku
                mov ah, 09H
                int 21H
                jmp progrEnd

progrEnd:       call closeFile          ;koniec programu, który najpierw zamyka plik a potem
                mov ah, 4cH             ;wywołuje przerwanie 21H z argumentem 4cH - zakończ program
                xor al, al
                int 21H

regReset:       xor ax, ax               ;zerowanie rejestrów
                xor bx, bx
                xor cx, cx
                xor dx, dx
                ret

start:          mov ax,data
                mov ds,ax
                mov ax,stackSeg
                mov ss,ax
                mov sp,offset szczyt

                call regReset
                
getLen:         mov ah, 62H             ;Zwraca do bx adres segmentu PSP - Program Segment Prefix
                int 21H                 ;w PSP znajduje sie nazwa pliku ktorą wprowadzilismy
                mov es, bx              ;oraz długość (pod adresem 0080H), reszta znajduje sie
                mov al, es:[0080H]      ;za adresem 0081H
                cmp al, 0               ;sprawdzamy, czy nazwa pliku została podana
                je noFileParam                ;jeśli nie, to błąd

                mov cl, al              ;przenosimy len do cl, uzyjemy tego, jako iterator
                dec cl                  ;-1 iteracja - ostatni znak to 0D
                xor si, si               ;zerujemy si
getFileName:    mov al, es:[0081H+si+1] ;przenosimy do al pojedyncza litere nazwy pliku
                xor ah, ah              ;zerujemy ax
                lea bx, fileName        ;do bx offset do zmiennej fileName
                mov ds:[bx+si], al      ;do zmiennej fileName dodajemy literkę z nazwy pliku
                inc si
                loop getFileName        ;odczytuj po kolei każdy znak

                xor ax, ax
openFile:       mov ah, 3dH             ;otwarcie pliku
                mov al, 0               ;tryb pracy - 0 tylko do odczytu
                mov dx, offset fileName ;3dH wymaga w dx nazwy pliku
                int 21H                 ;wywołanie przerwania
                jc  noFile              ;Jeśli plik nie istnieje to carry
                mov fileID, ax          ;jeśli plik istnieje to w ax dostaniemy 16bitową wartość fileName

readFile:       mov ah, 3FH             ;Funkcja do odczytu pliku, wymaga: bx - fileID, cx - liczba bajtów do odczytu, dx - gdzie zapisujemy
                xor al, al              ;zerujemy al
                mov bx, fileID
                mov cx, 3               ;3 bajty do przeczytania, na nute, nr. oktawy i długość
                lea dx, signs           ;w zmiennej signs przechowywane będzie 3 bajty z pliku
                int 21H
                
                mov ah,1h	              ;oczekiwanie na nacisniecie klawisza, jesli nacisnieto to zakończ program
                int 16h								
                jnz progrEnd	

getNote:        lea bx, signs           ;do bx wpisujemy adres pobranych 3 bajtów
                mov dl, ds:[bx]         ;bierzemy nutę z pierwszej pozycji zmiennej signs
                cmp dl, 'Q'             ;Jeśli natrafi na literę Q, to koniec programu
                je progrEnd             ;Jeśli nie, to porównuje na jaką nutę trafił - setNote

setNote:        cmp dl, 'C'             ;Porównujemy pierwszy znak z pobrany z pliku, robimy i wykonujemy skoki do etykiet
                je NoC                  
                cmp dl, 'D'
                je NoD
                cmp dl, 'E'
                je NoE
                cmp dl, 'F'
                je NoF
                cmp dl, 'G'
                je NoG
                cmp dl, 'A'
                je NoA
                cmp dl, 'H'
                je NoH                            
                cmp dl, 'P'
                je pa

NoC:            mov octave, noteC       ;przypisujemy odpowiednie wartości do zmiennej octave
                call printSign          ;wyświetlamy znak na ekran
                jmp setOctave           ;i robimy skok do etykiety setOctave
NoD:            mov octave, noteD
                call printSign
                jmp setOctave
NoE:            mov octave, noteE
                call printSign
                jmp setOctave
NoF:            mov octave, noteF
                call printSign
                jmp setOctave
NoG:            mov octave, noteG
                call printSign
                jmp setOctave
NoA:            mov octave, noteA
                call printSign
                jmp setOctave
NoH:            mov octave, noteH
                call printSign
                jmp setOctave
pa:             mov octave, notePause
                call printSign
                jmp waitFitTime

printSign:      mov ah, 02H
                mov al, 0H
                int 21H
                ret

setOctave:      lea bx, signs       ;do bx wczytujemy adres zmiennej signs (w której trzymamy 3 bajty z pliku)
                mov cl, ds:[bx+1]   ;pobranie numeru oktawy
                sub cl, 30H         ;Przesunięcie zakresu ze znaku HEX na znak w DEC
                shr octave, cl      ;przesuwa wszystkie bity octave w prawo o ilość bitów zdefiniowaną przez cl (do zmiany oktawy) *2(cl)

setTime:        lea bx, signs
                mov cl, ds:[bx+2]   ;Pobranie czasu danej nuty
                sub cl, 30H         ;Przesusnięcie zakresu ze znaku HEX na znak w DEC
                xor ch, ch          ;zerowanie ch
                mov len, cx

playMusic:      mov ax, octave
                mov dx, 42h         ;Adres układu 8253
                out dx, al          ;wysyłamy do układu oktawę
                mov al, ah
                out dx, al

speakerOn:      mov dx, 61h         ;61H to adres układu 8255, tu włączymy dźwięk
                in al, dx           ;pobranie wartości portu do AL
                or al, 00000011B    ;2 najmłodsze bity muszą być 1
                out dx, al          ;wysłanie tego co ustawiliśmy

waitFitTime:    jmp fitTime         ;dopasowanie czasu do nuty, półnuty, ćwierc nuty i ósemki
                                    ;====int 15h fun:86 - WAIT params:cx,dx====
waitNoFit:      xor dx, dx          ;microseconds (1/1000000) to wait
                mov ah, 86h
                int 15h             

speakerOff:     mov dx, 61H         ;61H - układ 8255
                in al, dx           ;pobieramy to co jest w tym układzie
                and al, 11111100B   ;2 najmłodsze bity muszą być 0
                out dx, al          ;wysyłamy spowrotem zmodyfikowaną już zawartość
                jmp readFile        ;wracamy do pobrania kolejnych 3 bajtów z pliku

fitTime:        cmp len, 1
                je fullNote         ; 1-pełna nuta,2-półnuta,4-ćwierćnuta,8-ósemka
                cmp len, 2
                je halfNote
                cmp len, 4
                je quarterNote
                cmp len, 8
                je quaverNote

fullNote:       mov cx, 8
                jmp waitNoFit

halfNote:       mov cx, 4
                jmp waitNoFit

quarterNote:    mov cx, 2
                jmp waitNoFit

quaverNote:     mov cx, 1
                jmp waitNoFit

Progr           ends

data            segment
noFileParamMsg  DB 'No file name entered', '$'
noFileMsg       DB 'File does not exist', '$'
fileName        db 13 dup(0)
signs           db 3 dup(0)
octave          dw 0
len             dw 0
fileID          dw 0
data            ends

stackSeg        segment
szczyt          Label word
stackSeg        ends

end start