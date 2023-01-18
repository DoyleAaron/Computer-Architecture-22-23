
*-----------------------------------------------------------
* Title      : Part 2
* Written by : Aaron Doyle
* Date       : 18/01/2023
* Description:
*-----------------------------------------------------------
    
            START:  $1000

            
            MOVE.B #9,D1    *This line moves the number nine to Data Register 1
            LEA text, A1    *This line moves the address of the text into address register 1
            MOVE #14,D0     *This line moves the number 14 to Data Register 0
            TRAP #15        *This line is creating an interrupt in the code
            MOVE #3,D0      *This line moves the number 3 to Data Register 0
            TRAP #15        *This line is creating an interrupt in the code

        SIMHALT
text dc.b 'Data Register: ',0
END START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
