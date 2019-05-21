ORG 800H
    RST 7

ORG B00H
    ASK_FOR_NUMBER
        CALL DESC
        CALL READ_NUMBER
        CALL ENTER
        CALL SHOW_BIN
        CALL ENTER
        CALL SHOW_HEX
        CALL ENTER
        CALL ENTER
        JMP ASK_FOR_NUMBER

ENTER
    PUSH PSW
    MVI A,0AH
    RST 1
    MVI A,0DH
    RST 1
    POP PSW
    RET


DESC_PRO_TEKST
    DB 'wpisz liczbe z zakresu 0-255 do zamiany na bix i hex'
    DB 0AH
    DB 0DH
    DB '@'

DESC
    LXI H,DESC_PRO_TEKST
    RST 3
    RET

WRONG_CHAR_MSG
    DB 0AH
    DB 0DH
    DB 'Wpisz cyfre 0-9'
    DB 0AH
    DB 0DH
    DB '@'

WRONG_CHAR
    LXI H,WRONG_CHAR_MSG
    RST 3
    JMP READ_NUMBER

TOO_MUCH_TXT
    DB 0AH
    DB 0DH
    DB 'Liczba poza zakresem'
    DB 0AH
    DB 0DH
    DB '@'

TOO_MUCH
    LXI H,TOO_MUCH_TXT
    RST 3
    JMP READ_NUMBER
; It returns char in A or flag CY if enter
LOAD_ONE_CHAR
    RST 2
    ; Test if enter
    CPI 0DH
    JNZ NOT_ENTER
    MVI A,254
    RET

    NOT_ENTER
        ; Test if greater than '0'
        CPI '0'
        JM WRONG_CHAR_RET
        ; Test if smaller than ':' (is after '9')
        CPI ':'
        JP WRONG_CHAR_RET
        ; good sign
        SUI '0'
        RET

    WRONG_CHAR_RET
        MVI A,255
        RET

MULTIPLY_10
    MOV B,A
    RLC
    JC MULTIPLY_10_END
    RLC
    JC MULTIPLY_10_END
    ADD B
    JC MULTIPLY_10_END
    RLC
    JC MULTIPLY_10_END

    MULTIPLY_10_END
        RET

READ_NUMBER

    CALL LOAD_ONE_CHAR

    MOV C,A
    ; Test if enter so wrong character
    CPI 254
    JZ WRONG_CHAR
    MOV A,C
    ; Test if returns code wrong character
    CPI 255
    JZ WRONG_CHAR
    MOV A,C

    READ_ONE_CHAR
        CALL LOAD_ONE_CHAR
        MOV D,A

        ; Test if enter
        CPI 254
        JZ READED

        MOV A,D
        ; Test czy zwrocono kod zlego znaku
        CPI 255
        JZ WRONG_CHAR
        MOV A,D
        ; Dodaj do liczby poprzedniej z obsluga przepelnienia
        MOV A,C
        CALL MULTIPLY_10
        JC TOO_MUCH
        ADD D
        JC TOO_MUCH
        MOV C,A
        JMP READ_ONE_CHAR

    READED
        MOV A,C
        RET

SHIFT_LEFT_4
    RLC
    RLC
    RLC
    RLC
    ANI 11110000B
    RET

SHOW_BIN
    PUSH PSW
    ; remember original
    MOV B,A

    ; handling 0
    CPI 0
    JNZ NOT_0_BIN
    MVI A,'0'
    RST 1
    POP PSW
    RET

    NOT_0_BIN
        MVI C,8

    DELETE_ZERO_BIN
        ; Check if first bit is equal to 0
        ANI 10000000B
        CPI 0
        ; If not i'm starting display.
        JNZ SHOW_REST_BIN
        DCR C
        ; Delete first bit and remember in B
        MOV A,B
        ; Offset to the left
        RLC
        ANI 11111110B
        MOV B,A
        JMP DELETE_ZERO_BIN

    SHOW_REST_BIN
        MOV A,B
        ; Take the oldest bit after deleting 0 and show
        ANI 10000000B
        RLC
        ADI '0'
        RST 1
        ; Offset to the left
        MOV A,B
        RLC
        ANI 11111110B
        MOV B,A
        ; Check is zero left but in front
        ; because we want initial zero.
        DCR C
        MOV A,C
        CPI 0
        JNZ SHOW_REST_BIN
        POP PSW
        RET

TABLICA_HEX 	 DB '0123456789ABCDEF'
SHOW_HEX
    PUSH PSW
    ; Remember original
    MOV B,A

    ; handle 0
    CPI 0
    JNZ NOT_0_HEX
    MVI A,'0'
    RST 1
    POP PSW
    RET

    NOT_0_HEX
        MVI C,2

    DELETE_ZERO_HEX
        ; Check if first four bits are 0
        ANI 11110000B
        CPI 0
        ; If not let's start show the rest
        JNZ SHOW_REST_HEX
        ; Delete first 4 bits and remember in B
        DCR C
        MOV A,B
        CALL SHIFT_LEFT_4
        MOV B,A
        JMP DELETE_ZERO_HEX

    SHOW_REST_HEX
        MOV A,B
        ; Take 4 the oldest bitst after removing 0 and read from the table
        ANI 11110000B
        RLC
        RLC
        RLC
        RLC
        ; Table + value char 0-F
        LXI H,TABLICA_HEX
        MVI D,0
        MOV E,A
        DAD D
        MOV A,M
        RST 1
        ; Left 4
        MOV A,B
        CALL SHIFT_LEFT_4
        MOV B,A
        ; Check if left zero in front
        ; because we want initial zero
        DCR C
        MOV A,C
        CPI 0
        JNZ SHOW_REST_HEX
        POP PSW
        RET
