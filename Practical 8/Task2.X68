*-----------------------------------------------------------
* Title      : Task 2
* Written by : Aaron Doyle
* Date       : 25/1/23
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    
    LEA health, A1
    Move.l    A1, A2
    Move.b    #10, D1
    move.b    D1, D2
    move.b    #5, D3
    add.b     D3, D2
    move.b    #5, D5
    sub.b     D5, D2
    move.b    #2, D4
    mulu      D4, D2
    move.b    #2, D5
    divu      D5, D2
    
   
    
    
    





* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

health dc.b 'Your Health is: ',0


    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
