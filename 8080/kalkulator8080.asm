        ORG 800H
LICZB1  RST 5
        MOV B,D
        MOV C,E
OPERAN  RST 2
        CPI '-'
        JZ ODEJMO
        JNZ OPERAN
ODEJMO  RST 5
        LXI H,WYNIKO
        RST 3
        LXI H,0  
PORSTA  MOV A,B
        CMP D
        JZ SPRCMI
        JC SPRMLD
        JNC PORMLO
PORMLO  MOV A,C
        CMP E
        JC OZPZSP
        JNC OBPZSP
SPRMLD  CMC
        MOV A,E
        CMP C
        JC OZPZSM
        JNC OBPZSM
SPRCMI  MOV A,C
        CMP E
        JC OZPZSM
        JNC OBPZSP
OZPZSP  MOV A,B
        SBB D
        RST 4
        MOV A,C
        SUB E
        RST 4
        JMP KONIEC
OBPZSP  MOV A,B
        SUB D
        RST 4
        MOV A,C
        SUB E
        RST 4
        JMP KONIEC
OBPZSM  MVI A,'-'
        RST 1
        MOV A,D
        SUB B
        RST 4
        MOV A,E
        SUB C
        RST 4
        JMP KONIEC
OZPZSM  MVI A,'-'
        RST 1
        MOV A,D
        SBB B
        RST 4
        MOV A,E
        SUB C
        RST 4
        JMP KONIEC
KONIEC  HLT
 
LICZ1      DB 10,13,'Wprowadz 1 liczbe:@',10,13
LICZ2      DB 10,13,'Wprowadz 2 liczbe:@',10,13
ZNAKI      DB 10,13,'Wprowadz znak(+,-,N):@',10,13
WYNIKD     DB 10,13,'Wynik dodawania to:@',10,13
WYNIKO     DB 10,13,'wynik odejmowania to:@',10,13
WYNIKN     DB 10,13,'wynik negacji to:@',10,13