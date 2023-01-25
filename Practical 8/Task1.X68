*-----------------------------------------------------------
* Title      : Task 1
* Written by : Aaron Doyle
* Date       : 25/1/23
* Description: 
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

    LEA points, A1
    move.b #14, D0
    trap #15
    
    move.b #4, D0
    trap #15
    
    LEA userpoints, A1
    move.b #14, d0
    trap #15
    
    move.b #3, d0
    trap #15
    
      
    
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here
points dc.b 'Please Enter Gamer Points: ',0
userpoints dc.b 'Your points total is: ' ,0
    END    START        ; last line of source
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
