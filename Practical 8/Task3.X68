*-----------------------------------------------------------
* Title      : Part 3
* Written by : Aaron Doyle
* Date       : 25/1/23
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    
    *Trap 2
    LEA trap2text, A1
    MOVE.B  #14, D0
    TRAP #15
    
    MOVE.B #2, D0
    TRAP #15

  
    *Trap 5
    LEA trap5text, A1
    MOVE.B  #5, D0
    TRAP #15
    
    
    *Trap 8
    MOVE.B  #8, D0
    TRAP #15
    
    
    
    
    
    *INCOMPLETE
    
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here
trap2text dc.b 'Enter a string: ' , 0
trap5text dc.b 'Enter a character: ' , 0
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
