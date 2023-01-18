*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

    MOVE.B      #9,D1
    *This line of code is moving the number 9 to Data Register 1 
    MOVE.B      D1,D2
    *This line of code is moving the information in Data Register 1 to Data Register 2 but it will still exist in both
    MOVE.B      D2, 1100
    *This line of code is moving the data in data register two to the hex address for 1100
    MOVE.B      1100,D2
    *This line of code is moving the hex value of 1100 into Data register 2
    MOVE.B      1100,100
    *This line of code is moving the hex value of 1100 into 100
  
      

    SIMHALT             ; halt simulator


    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
