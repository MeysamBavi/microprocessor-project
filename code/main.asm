    .MODEL SMALL
    .STACK 64
    .DATA
        SCREEN_DELAY DB 0004h
        BALL_CENTER_X DW 00A0h
        BALL_CENTER_Y DW 0064h    
        BALL_RADIUS DW 07h
        BALL_SPEED_X DW 02h
        BALL_SPEED_Y DW -03h
        ;BALL DRAWING VARIABLES
        D_X DW ?
        D_Y DW 0
        ERR DW 0
        ;BORDER VALUES
        BORDER_MIN_X DW ?
        BORDER_MIN_Y DW ?
        BORDER_MAX_X DW ?
        BORDER_MAX_Y DW ?
        BORDER_COLOR DB 09h
        ;PAD VALUES
        PAD_MOVE_SPEED DW 00h
        PAD_MOVE_SPEED_AMP EQU 0003h
        PAD_CORNER_X DW 00A0h
        PAD_CORNER_Y DW 00BEh
        PAD_WIDTH DW 50
        PAD_HEIGHT DW 10
        PAD_COLOR DB ?
        ;SCORE VALUE
        SCORE DB 0
        ;STRINGS
        SCORE_TEXT_STRING DB 'S','C','O','R','E','$'
        SCORE_NUM_STRING DB '0','0','$'
        ;FILE VARIABLES
        PORTNAME DB "COM3"
        HANDLE DW ?
        RECEIVE_BUFFER DB 1 DUP(0)
        PORT_CHECK_COUNTER DW 0
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

    MOV D_Y,0

    MOV ERR,0
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

DRAW_PAD PROC
    MOV DX, PAD_CORNER_Y
    MOV CX, PAD_CORNER_X
    
    MOV BX, DX
    ADD BX, PAD_HEIGHT
    MOV AX, CX
    ADD AX, PAD_WIDTH
    ;NESTED FOR LOOP TO DRAW THE PAD RECTANGLE
    PAD_DRAW_LOOP1:
        CMP DX,BX
        JE DRAW_LOOP1END
        MOV CX, PAD_CORNER_X
        PAD_DRAW_LOOP2:
            CMP CX, AX
            JE DRAW_LOOP2END
            PUSH AX
            PUSH BX
            MOV AL, PAD_COLOR
            CALL DRAW_PIXEL_INIT
            POP BX
            POP AX
            INC CX
            JMP PAD_DRAW_LOOP2
        DRAW_LOOP2END:
        INC DX
        JMP PAD_DRAW_LOOP1
    DRAW_LOOP1END:
    
    RET
    DRAW_PAD ENDP
DRAW_BORDER PROC NEAR
    
    MOV CX, BORDER_MIN_X
    MOV DX, BORDER_MIN_Y
    SUB CX, BALL_RADIUS
    SUB DX, BALL_RADIUS
    MOV AX, BORDER_MAX_X
    ADD AX, BALL_RADIUS

    BORDER_DRAW_LOOP_VERTIACL:
        CMP CX, AX
        JE BORDER_DRAW_LOOP_VERTICAL_END
        PUSH AX
        MOV AL, BORDER_COLOR
        CALL DRAW_PIXEL_INIT
        POP AX
        INC CX
        JMP BORDER_DRAW_LOOP_VERTIACL
    BORDER_DRAW_LOOP_VERTICAL_END:

    MOV CX,BORDER_MIN_X
    MOV DX,BORDER_MIN_Y
    SUB CX, BALL_RADIUS
    SUB DX, BALL_RADIUS
    BORDER_DRAW_LOOP_HORIZONTAL1:
        CMP DX, BORDER_MAX_Y
            JE BORDER_DRAW_LOOP_HORIZONTAL_END1
        MOV AL, BORDER_COLOR
        CALL DRAW_PIXEL_INIT
        INC DX
        JMP BORDER_DRAW_LOOP_HORIZONTAL1
    BORDER_DRAW_LOOP_HORIZONTAL_END1:

    MOV CX,BORDER_MAX_X
    MOV DX,BORDER_MIN_Y
    ADD CX, BALL_RADIUS
    SUB DX, BALL_RADIUS
    BORDER_DRAW_LOOP_HORIZONTAL2:
        CMP DX, BORDER_MAX_Y
            JE BORDER_DRAW_LOOP_HORIZONTAL_END2
        MOV AL, BORDER_COLOR
        CALL DRAW_PIXEL_INIT
        INC DX
        JMP BORDER_DRAW_LOOP_HORIZONTAL2
    BORDER_DRAW_LOOP_HORIZONTAL_END2:
    
    RET
    DRAW_BORDER ENDP
;FOR CHECKING COLLISION AND DEFLECTING THE BALL
CHECKBORDER PROC NEAR
    ;FOR CHECKING IF WE HAVE COLLISION TO SIDE BORDERS 
    MOV BX, BALL_CENTER_X
    CMP BX, BORDER_MIN_X   
    JLE X_BORDER_IF
    CMP BX, BORDER_MAX_X
    JGE X_BORDER_IF
    ;CHECK IF WE HAVE COLLISION WITH THE TOP AND BOTTOM BORDERS
    MOV BX, BALL_CENTER_Y
    CMP BX, BORDER_MIN_Y
    JLE Y_BORDER_IF
    CMP BX, BORDER_MAX_Y
    JGE Y_BORDER_IF_LOSE
    ;CHECK IF THE BALL IS COLLIDING WITH THE PAD
    MOV CX, PAD_CORNER_Y
    SUB CX, BALL_RADIUS
    CMP BX, CX
    JGE PAD_IF
    JMP ENDLABEL
    ;REVERSE THE SPEED IN Y DIRECTION
    Y_BORDER_IF:
        MOV BX, 0
        SUB BX, BALL_SPEED_Y
        MOV BALL_SPEED_Y,BX
        JMP ENDLABEL
    ;YOU HAVE HIT THE BOTTOM BORDER AND SO YOU HAVE LOST
    Y_BORDER_IF_LOSE:    
        MOV AX, 0
        JMP ENDLABEL
    ;REVERSE THE SPEED IN X DIRECTION
    X_BORDER_IF:
        MOV BX,0
        SUB BX, BALL_SPEED_X
        MOV BALL_SPEED_X, BX
        JMP ENDLABEL

    ;IF YOUR X IS IN THE PAD AREA THEN REVERSE Y AND INCREASE SCORE
    PAD_IF:
        MOV BX, PAD_CORNER_X
        CMP BX, BALL_CENTER_X
        JG ENDLABEL
        ADD BX, PAD_WIDTH
        CMP BX, BALL_CENTER_X
        JL ENDLABEL
        INC SCORE
        JMP Y_BORDER_IF

    ENDLABEL:
    
    RET
    CHECKBORDER ENDP
SHOW_SCORE PROC NEAR
    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 01h
    MOV DL, 11h
    INT 10h
    
    MOV AH,09h
    LEA DX,SCORE_TEXT_STRING
    INT 21h

    MOV AH, 02h
    MOV BH, 00h
    MOV DH, 03h
    MOV DL, 12h
    INT 10h
    
    MOV AH,09h
    LEA DX,SCORE_NUM_STRING
    INT 21h


    RET
    SHOW_SCORE ENDP

UPDATE_SCORE PROC NEAR
    MOV AX, 0
    MOV AL, SCORE
    MOV BL,10
    DIV BL
    ADD AH, 30h
    ADD AL, 30h
    MOV [SCORE_NUM_STRING],AL
    MOV [SCORE_NUM_STRING +1],AH
    RET
    UPDATE_SCORE ENDP

UPDATE_PAD_SPEED PROC FAR
    CMP PORT_CHECK_COUNTER, 0
    JNE UPDATE_PAD_SPEED_END
    MOV PORT_CHECK_COUNTER, 5

    ; READ ONE BYTE FROM CONTROLLER
    MOV DX, OFFSET RECEIVE_BUFFER
    MOV CX, 1
    MOV BX, HANDLE
    MOV AH, 3Fh
    INT 21h

    MOV DH, [RECEIVE_BUFFER]
    CMP DH, 'R'
    JE RIGHT_DIR
    CMP DH, 'L'
    JE LEFT_DIR
    JMP STOP_DIR

    RIGHT_DIR:
    MOV PAD_MOVE_SPEED, PAD_MOVE_SPEED_AMP
    JMP UPDATE_PAD_SPEED_END

    LEFT_DIR:
    MOV PAD_MOVE_SPEED, -PAD_MOVE_SPEED_AMP
    JMP UPDATE_PAD_SPEED_END

    STOP_DIR:
    MOV PAD_MOVE_SPEED, 0
    JMP UPDATE_PAD_SPEED_END

    UPDATE_PAD_SPEED_END:
    DEC PORT_CHECK_COUNTER
    RET

    UPDATE_PAD_SPEED ENDP

UPDATE_PAD_SPEED_KEYBOARD PROC NEAR
    CHECK_BUFF:
        MOV AH, 01h
        INT 16h
        JZ SKIP_KEY

        MOV AH, 00h
        INT 16h
        JMP CHECK_BUFF

    SKIP_KEY:
        CMP AL, 44h
        JE RIGHT_PRESSED
        CMP AL, 64h
        JE RIGHT_PRESSED

        CMP AL, 41h
        JE LEFT_PRESSED
        CMP AL, 61h
        JE LEFT_PRESSED

        CMP AL, 53h
        JE STOP_PRESSED
        CMP AL, 73h
        JE STOP_PRESSED

        RET

        RIGHT_PRESSED:
        MOV PAD_MOVE_SPEED, PAD_MOVE_SPEED_AMP
        RET

        LEFT_PRESSED:
        MOV PAD_MOVE_SPEED, -PAD_MOVE_SPEED_AMP
        RET

        STOP_PRESSED:
        MOV PAD_MOVE_SPEED, 0
        RET

UPDATE_PAD_SPEED_KEYBOARD ENDP

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

        ;OPEN COM PORT FILE
        MOV AL, 02H
        MOV DX, OFFSET PORTNAME
        MOV AH, 3DH
        INT 21H
        MOV HANDLE, AX
        
        ;GRAPHIC INIT START        
        MOV AX,  0013h
        INT 10h
        
        MOV AH, 0Bh
        MOV BX, 0000h 
        INT 10h
        ;GRAPHIC INIT END
       
        ;BORDER INIT
        MOV BX,0
        ADD BX, BALL_RADIUS
        ADD BX, 20
        MOV BORDER_MIN_X, BX
        SUB BX, 20
        ADD BX, 40
        MOV BORDER_MIN_Y, BX
        MOV BX, 140h
        SUB BX, 20
        SUB BX, BALL_RADIUS
        MOV BORDER_MAX_X, BX
        MOV BX, 0C8h
        SUB BX, BALL_RADIUS
        MOV BORDER_MAX_Y, BX
        ;BORDER INIT END
        ;MAIN GAME LOOP
        GAME_LOOP:
            CALL UPDATE_SCORE
            CALL DRAW_BORDER
            ;DRAW THE BALL IN WHITE (AL INDICATES COLOR)
            MOV AL,0Fh 
            CALL DRAW_BALL
            ;DRAW THE PAD IN ORANGE
            MOV PAD_COLOR, 0Ch
            CALL DRAW_PAD

            MOV AL,SCREEN_DELAY
            CALL DELAY

            ; READ FROM CONTROLLER TO UPDATE PAD_SPEED
            CALL UPDATE_PAD_SPEED_KEYBOARD

            ;REDRAW THE BALL IN BLACK    
            MOV AL,00h
            CALL DRAW_BALL
            ;REDRAW THE PAD IN BLACK
            MOV PAD_COLOR, 00h
            CALL DRAW_PAD


            ;MOVE THE PAD WITH PAD_SPEED
            MOV BX, PAD_CORNER_X
            ADD BX, PAD_MOVE_SPEED
            MOV PAD_CORNER_X, BX
            ;MOVE THE BALL_X WITH BALL_SPEED_X
            MOV BX, BALL_CENTER_X
            ADD BX, BALL_SPEED_X
            MOV BALL_CENTER_X, BX
            ;MOVE THE BALL_Y WITH BALL_SPEED_Y
            MOV BX, BALL_CENTER_Y
            ADD BX, BALL_SPEED_Y
            MOV BALL_CENTER_Y, BX
            ;
            CALL SHOW_SCORE
            
            ;CHECK FOR COLLISION WITH THE BORDERS OR THE PAD
            CALL CHECKBORDER

            ;IF WE HAVE COLLISION WITH THE BOTTOM BORDER WE HAVE LOST
            CMP AX, 00h
            JE DONE
            ;IF THE SCORE IS 30 WE HAVE WON
            MOV AH, SCORE
            CMP AH, 30
            JE DONE
            
            JMP GAME_LOOP
        
        DONE:
        ;END MAIN GAME LOOP
        MOV AH, 00h        
        INT 16h
        
        MOV AH, 4CH
        INT 21H
MAIN    ENDP
        END MAIN