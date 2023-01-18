*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

    LEA points, A1
    MOVE.B  #14, D0
    trap #15
    
    
* Put program code here

    SIMHALT             ; halt simulator
points dc.b 'Please Enter Gamer Points: ',0
userpoints dc.b 'Your points total is: ' ,0
* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
