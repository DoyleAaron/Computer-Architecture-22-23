*-----------------------------------------------------------
* Title      : Part 3 
* Written by : Aaron Doyle
* Date       : 18/01/2023
* Description:
*-----------------------------------------------------------
    ORG $1000
START:
 LEA text, A1 
 *This line of code is moving the address that text is stored in and stores it in address line 1
 MOVE #4,D0
 * This line of code is moving the number 4 into data register 0
 TRAP #15
 * This line is an interrupt in the code
 MOVE #14,D0
 * This line of code is moving the number 14 into data register 0
 TRAP #15
 * This line is an interrupt in the code
 MOVE #3,D0
 *This line of code is moving the number 3 into data register 0
 TRAP #15
 * This line is an interrupt in the code
 
 SIMHALT
text dc.b 'Data Register: ',0
*This line of code is assigning the text "Data Register: " to the text title 'text'
 END START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
