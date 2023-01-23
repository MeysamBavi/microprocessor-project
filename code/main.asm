    .MODEL SMALL
    .STACK 64
    .DATA
        SCREEN_DELAY DB 00001h
        BALL_CENTER_X DW 0000Fh
        BALL_CENTER_Y DW 00010h    
        BALL_RADIUS DW 07h
        BALL_SPEED_X DW 02h
        BALL_SPEED_Y DW 00h
        ; BALL DRAWING VARIABLES
        D_X DW ?
        D_Y DW 0
        ERR DW 0
    .CODE

;BEFORE CALLING THIS PROC MOVE COLOR TO AL
DRAW_PIXEL_INIT PROC NEAR
    MOV AH, 0Ch
    MOV BH, 00h
    INT 10h
    RET
    DRAW_PIXEL_INIT ENDP

;THIS PROC DRAWS THE 8 POINTS THAT SHOULD BE DRAWN AFTER FINDING THE BORDER POINT 
DRAW_POINTS PROC NEAR
     ;1
    MOV CX, BALL_CENTER_X
    MOV DX, BALL_CENTER_Y
    ADD CX, D_X
    ADD DX, D_Y
    CALL DRAW_PIXEL_INIT
        
    ;2
    MOV CX, BALL_CENTER_X
    MOV DX, BALL_CENTER_Y
    ADD CX, D_Y
    ADD DX, D_X
    CALL DRAW_PIXEL_INIT
        
    ;3
    MOV CX, BALL_CENTER_X
    MOV DX, BALL_CENTER_Y
    SUB CX, D_Y
    ADD DX, D_X
    CALL DRAW_PIXEL_INIT
        
    ;4
    MOV CX, BALL_CENTER_X
    MOV DX, BALL_CENTER_Y
    SUB CX, D_X
    ADD DX, D_Y
    CALL DRAW_PIXEL_INIT
        
    ;5
    MOV CX, BALL_CENTER_X
    MOV DX, BALL_CENTER_Y
    SUB CX, D_X
    SUB DX, D_Y
    CALL DRAW_PIXEL_INIT
        
    ;6
    MOV CX, BALL_CENTER_X
    MOV DX, BALL_CENTER_Y
    SUB CX, D_Y
    SUB DX, D_X
    CALL DRAW_PIXEL_INIT
        
    ;7
    MOV CX, BALL_CENTER_X
    MOV DX, BALL_CENTER_Y
    ADD CX, D_Y
    SUB DX, D_X
    CALL DRAW_PIXEL_INIT
        
    ;8
    MOV CX, BALL_CENTER_X
    MOV DX, BALL_CENTER_Y
    ADD CX, D_X
    SUB DX, D_Y
    CALL DRAW_PIXEL_INIT
    RET
    DRAW_POINTS ENDP

;THE MAIN CODE FOR DRAWING THE BALL
DRAW_BALL PROC NEAR
    MOV DX, BALL_RADIUS
    MOV D_X, DX

    MOV DX, D_Y
    MOV D_Y,0
    ;THIS LOOP FOLLOWS THE MIDPOINT CIRLCE DRAWING ALGHORITHM
    CIRCLE_LOOP:
        MOV BX, D_X
        CMP BX, D_Y
        JB END_LOOP
        
        CALL DRAW_POINTS

        INC D_Y

        MOV BX, ERR
        INC BX
        ADD BX, D_Y
        ADD BX, D_Y
        MOV ERR, BX

        MOV BX, ERR
        SUB BX, D_X
        ADD BX, BX
        INC BX
        CMP BX, 0
        JG CHECK
        JMP CIRCLE_LOOP

        CHECK:
            
            DEC D_X

            MOV BX, ERR
            INC BX
            SUB BX, D_X
            SUB BX, D_X
            MOV ERR, BX
            JMP CIRCLE_LOOP
        
        END_LOOP :
    RET
    DRAW_BALL ENDP

DELAY PROC NEAR
    
    MOV AH,2Ch
    INT 21h
    MOV BL, DL
    WAITLOOP:
        MOV AH,2Ch
        INT 21h
        MOV CL, DL
        SUB CL, BL
        CMP CL,AL
        JB WAITLOOP
    RET
    DELAY ENDP

MAIN    PROC FAR
        
        MOV AX,@DATA
        MOV DS, AX
        
        ;GRAPHIC INIT START        
        MOV AX,  0013h
        INT 10h
        
        MOV AH, 0Bh
        MOV BX, 0000h 
        INT 10h
        ;GRAPHIC INIT END
       
        GAME_LOOP:

            MOV AL,0Fh 
            CALL DRAW_BALL
            
            MOV AL,SCREEN_DELAY
            CALL DELAY
            
            MOV AL,00h
            CALL DRAW_BALL

            MOV BX, BALL_CENTER_X
            ADD BX, BALL_SPEED_x
            MOV BALL_CENTER_X, BX

            MOV BX, BALL_CENTER_Y
            ADD BX, BALL_SPEED_Y
            MOV BALL_CENTER_Y, BX
            
            MOV BX,BALL_CENTER_X
            CMP BX,00FFh
            JAE DONE
            
            JMP GAME_LOOP
        
        DONE:
        MOV AH, 00h        
        INT 16h
        
        MOV AH, 4CH
        INT 21H
MAIN    ENDP
        END MAIN