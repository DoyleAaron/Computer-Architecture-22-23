*-----------------------------------------------------------
* Title      : Box Adventure
* Written by : Aaron Doyle
* Date       : 03/03/23
* Description: A simple endless runner made in assembly code
* Known Bugs: Sometimes the first enemy doesnt take a life
*-----------------------------------------------------------
    ORG    $1000
START:                                  ; first instruction of program

*-----------------------------------------------------------
* Section       : Trap Codes
* Description   : Trap Codes used throughout StarterKit
*-----------------------------------------------------------
* Trap CODES
TC_SCREEN   EQU         33              ; Screen size information trap code
TC_S_SIZE   EQU         00              ; Places 0 in D1.L to retrieve Screen width and height in D1.L
TC_KEYCODE  EQU         19              ; Check for pressed keys
TC_DBL_BUF  EQU         92              ; Double Buffer Screen Trap Code
TC_CURSR_P  EQU         11              ; Trap code cursor position

TC_EXIT     EQU         09              ; Exit Trapcode

*-----------------------------------------------------------
* Section       : Character Setup
* Description   : Size of Player and Enemy and properties
* of these characters e.g Starting Positions and Sizes
*-----------------------------------------------------------
PLYR_W_INIT EQU         08              ; Players initial Width
PLYR_H_INIT EQU         08              ; Players initial Height

PLYR_DFLT_V EQU         00              ; Default Player Velocity
PLYR_JUMP_V EQU        -10              ; Player Jump Velocity
PLYR_DFLT_G EQU         01              ; Player Default Gravity

GND_TRUE    EQU         01              ; Player on Ground True
GND_FALSE   EQU         00              ; Player on Ground False
  
JMP_INDEX   EQU         01              ; Player Jump Sound Index  
DEATH_INDEX  EQU        02              ; Player Death Sound Index



ENMY_W_INIT EQU         08              ; Enemy initial Width
ENMY_H_INIT EQU         08              ; Enemy initial Height

*-----------------------------------------------------------
* Section       : Game Stats
* Description   : Points
*-----------------------------------------------------------
POINTS      EQU         00              ; Points added

*-----------------------------------------------------------
* Section       : Keyboard Keys
* Description   : Spacebar and Escape or two functioning keys
* Spacebar to JUMP and Escape to Exit Game
*-----------------------------------------------------------
SPACEBAR    EQU         $20             ; Spacebar ASCII Keycode
ESCAPE      EQU         $1B             ; Escape ASCII Keycode

*-----------------------------------------------------------
* Subroutine    : Initialise
* Description   : Initialise game data into memory such as 
* sounds and screen size
*-----------------------------------------------------------
INITIALISE:
    ; Initialise Sounds
    BSR     JUMP_LOAD                   ; Load Jump Sound into Memory
    BSR     DEATH_LOAD                  ; Load Death Sound into Memory
    
    ; Screen Size
    MOVE.B  #TC_SCREEN, D0              ; access screen information
    MOVE.L  #TC_S_SIZE, D1              ; placing 0 in D1 triggers loading screen size information
    TRAP    #15                         ; interpret D0 and D1 for screen size
    MOVE.W  D1,         SCREEN_H        ; place screen height in memory location
    SWAP    D1                          ; Swap top and bottom word to retrive screen size
    MOVE.W  D1,         SCREEN_W        ; place screen width in memory location

    ; Place the Player at the center of the screen
    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1              ; Place Screen width in D1
    DIVU    #02,        D1              ; divide by 2 for center on X Axis
    MOVE.L  D1,         PLAYER_X        ; Players X Position

    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1              ; Place Screen width in D1
    DIVU    #02,        D1              ; divide by 2 for center on Y Axis
    MOVE.L  D1,         PLAYER_Y        ; Players Y Position

    ; Initialise Player Score
    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    MOVE.L  #00,        D1              ; Init Score
    MOVE.L  D1,         PLAYER_SCORE
    
    ;Initialise Player Lives
    CLR.L   D1                          ; Clear contents of D1
    MOVE.L  #5,        D1               ; Moving the number five into D1
    MOVE.L  D1,         PLAYER_LIVES    ; Assigning the 5 lives into Player Lives

    ; Initialise Player Velocity
    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    MOVE.B  #PLYR_DFLT_V,D1             ; Init Player Velocity
    MOVE.L  D1,         PLYR_VELOCITY

    ; Initialise Player Gravity
    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    MOVE.L  #PLYR_DFLT_G,D1             ; Init Player Gravity
    MOVE.L  D1,         PLYR_GRAVITY

    ; Initialize Player on Ground
    MOVE.L  #GND_TRUE,  PLYR_ON_GND     ; Init Player on Ground

    ; Initial Position for Enemy
    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1              ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X         ; Enemy X Position

    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1              ; Place Screen width in D1
    DIVU    #02,        D1              ; divide by 2 for center on Y Axis
    MOVE.L  D1,         ENEMY_Y         ; Enemy Y Position

    ; Enable the screen back buffer(see easy 68k help)
	MOVE.B  #TC_DBL_BUF,D0              ; 92 Enables Double Buffer
    MOVE.B  #17,        D1              ; Combine Tasks
	TRAP	#15                         ; Trap (Perform action)

    ; Clear the screen (see easy 68k help)
    MOVE.B  #TC_CURSR_P,D0              ; Set Cursor Position
	MOVE.W  #$FF00,     D1              ; Fill Screen Clear
	TRAP	#15                         ; Trap (Perform action)

*-----------------------------------------------------------
* Subroutine    : Gameloop
* Description   : This is the main GameLoop. GameLoop is like
* a while loop in that it runs forever until interupted
* (Input, Update, Draw). The Enemies Run at Player Jump to Avoid
*-----------------------------------------------------------

GAMELOOP:
    ; Main Gameloop
    BSR     INPUT                   ; Check Keyboard Input
    BSR     UPDATE                  ; Update positions and points
    BSR     IS_PLAYER_ON_GND        ; Check if player is on ground
    BSR     CHECK_COLLISIONS        ; Check for Collisions
    BSR     PLAYER_LIVES_CHECK      ; Checking if the players lives are 0
    BSR     DRAW                    ; Draw the Scene
    BSR     FLOOR_DRAW              ; Draw the floor
    BSR     POINTS_LOOP             ; Increments the points
    BSR     DELAY                   ; Slows the speed of the game down
    BRA     GAMELOOP                ; Loop back to GameLoop

*-----------------------------------------------------------
* Subroutine    : Input
* Description   : Process Keyboard Input
*-----------------------------------------------------------
INPUT:
    ; Process Input
    CLR.L   D1                      ; Clear Data Register
    MOVE.B  #TC_KEYCODE,D0          ; Listen for Keys
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  D1,         D2          ; Move last key D1 to D2
    CMP.B   #00,        D2          ; Key is pressed
    BEQ     PROCESS_INPUT           ; Process Key
    TRAP    #15                     ; Trap for Last Key
    ; Check if key still pressed
    CMP.B   #$FF,       D1          ; Is it still pressed
    BEQ     PROCESS_INPUT           ; Process Last Key
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Process Input
* Description   : Branch based on keys pressed
*-----------------------------------------------------------
PROCESS_INPUT:
    MOVE.L  D2,         CURRENT_KEY ; Put Current Key in Memory
    CMP.L   #ESCAPE,    CURRENT_KEY ; Is Current Key Escape
    BEQ     EXIT                    ; Exit if Escape
    CMP.L   #SPACEBAR,  CURRENT_KEY ; Is Current Key Spacebar
    BEQ     JUMP                    ; Jump
    BRA     IDLE                    ; Or Idle
    RTS                             ; Return to subroutine
    
*-----------------------------------------------------------
* Subroutine    : Points Loop
* Description   : A loop that increments the points by one each time
*-----------------------------------------------------------
POINTS_LOOP:
    MOVE.L      #0, D3              ; Setting the data register 3 to 0
    ADD.L       #1, D3              ; Adding one to this data register which will be the constant increment
    ADD.L       PLAYER_SCORE, D3    ; Assigning this number to the current player score
    MOVE.L      D3, PLAYER_SCORE    ; Updating the player score so its ready for the next increment
   
    

*-----------------------------------------------------------
* Subroutine    : Update
* Description   : Main update loop update Player and Enemies
*-----------------------------------------------------------
UPDATE:
    ; Update the Players Positon based on Velocity and Gravity
    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    MOVE.L  PLYR_VELOCITY, D1           ; Fetch Player Velocity
    MOVE.L  PLYR_GRAVITY, D2            ; Fetch Player Gravity
    ADD.L   D2,         D1              ; Add Gravity to Velocity
    MOVE.L  D1,         PLYR_VELOCITY   ; Update Player Velocity
    ADD.L   PLAYER_Y,   D1              ; Add Velocity to Player
    MOVE.L  D1,         PLAYER_Y        ; Update Players Y Position 

    ; Move the Enemy
    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    CLR.L   D1                          ; Clear the contents of D0
    MOVE.L  ENEMY_X,    D1              ; Move the Enemy X Position to D0
    CMP.L   #00,        D1
    BLE     RESET_ENEMY_POSITION        ; Reset Enemy if off Screen
    BRA     MOVE_ENEMY                  ; Move the Enemy

    RTS                                 ; Return to subroutine  

*-----------------------------------------------------------
* Subroutine    : Move Enemy
* Description   : Move Enemy Right to Left
*-----------------------------------------------------------
MOVE_ENEMY:
    SUB.L   #4,        ENEMY_X          ; Move enemy by X Value which is 7 
    RTS

*-----------------------------------------------------------    
* Subroutine    : Reset Enemy
* Description   : Reset Enemy if to passes 0 to Right of Screen
*-----------------------------------------------------------
RESET_ENEMY_POSITION:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X     ; Enemy X Position
    RTS

*-----------------------------------------------------------
* Subroutine    : Draw
* Description   : Draw Screen
*-----------------------------------------------------------
DRAW: 
    ; Enable back buffer
    MOVE.B  #94,        D0
    TRAP    #15

    ; Clear the screen
    MOVE.B	#TC_CURSR_P,D0          ; Set Cursor Position
	MOVE.W	#$FF00,     D1          ; Clear contents
	TRAP    #15                     ; Trap (Perform action)

    BSR     DRAW_PLYR_DATA          ; Draw Draw Score, HUD, Player X and Y
    BSR     DRAW_PLAYER             ; Draw Player
    BSR     DRAW_ENEMY              ; Draw Enemy
    RTS                             ; Return to subroutine
    
    
*-----------------------------------------------------------
* Subroutine    : DRAW FLOOR
* Description   : Draws the floor line for the player to jump on
*-----------------------------------------------------------
FLOOR_DRAW:

    CLR.L   D1
    MOVE.B  #80, D0              
    MOVE.L  #$00A020F0, D1      ; Setting the colour of the line to purple using hex codes
    TRAP    #15
    
    CLR.L   D1                  ; Clear D1
    MOVE.B  #84, D0             ; Trap code to draw a line
    MOVE.W  #10, D1             ; Setting the start X value
    MOVE.W  #250, D2            ; Setting the end X value
    MOVE.W  #SCREEN_W, D3       ; Setting the length of the line
    MOVE.W  #250, D4            ; Setting the Y value of the line
    TRAP    #15
    
    
    
    
*-----------------------------------------------------------
* Subroutine    : Draw Player Data
* Description   : Draw Player X, Y, Velocity, Gravity and OnGround
*-----------------------------------------------------------
DRAW_PLYR_DATA:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    
    ; Escape Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0201,     D1          ; Col 02, Row 02
    TRAP    #15                     ; Trap (Perform action)
    LEA     CTRL_MSG, A1            ; Escape to exit Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Control Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0202,     D1          ; Col 02, Row 02
    TRAP    #15                     ; Trap (Perform action)
    LEA     ESC_MSG, A1             ; Escape to exit Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Player Score Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0203,     D1          ; Col 02, Row 01
    TRAP    #15                     ; Trap (Perform action)
    LEA     SCORE_MSG,  A1          ; Score Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Player Score Value
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0A03,     D1          ; Col 10, Row 01
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_SCORE,D1         ; Move Score to D1.L
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Lives Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0204,     D1          ; Col 02, Row 02
    TRAP    #15                     ; Trap (Perform action)
    LEA     LIVES_MSG, A1           ; Lives Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Lives
    MOVE.B  #TC_CURSR_P, D0         ; Set Cursor Position
    MOVE.W  #$0A04,     D1          ; Col 10, Row 02
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_LIVES,   D1      ; Move X to D1.L
    TRAP    #15                     ; Trap (Perform action)
    
  
*-----------------------------------------------------------
* Subroutine    : Player is on Ground
* Description   : Check if the Player is on or off Ground
*-----------------------------------------------------------
IS_PLAYER_ON_GND:
    ; Check if Player is on Ground
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    CLR.L   D2                      ; Clear contents of D2 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  PLAYER_Y,   D2          ; Player Y Position
    CMP     D1,         D2          ; Compare middle of Screen with Players Y Position 
    BGE     SET_ON_GROUND           ; The Player is on the Ground Plane
    BLT     SET_OFF_GROUND          ; The Player is off the Ground
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : On Ground
* Description   : Set the Player On Ground
*-----------------------------------------------------------
SET_ON_GROUND:
    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1              ; Place Screen width in D1
    DIVU    #02,        D1              ; divide by 2 for center on Y Axis
    MOVE.L  D1,         PLAYER_Y        ; Reset the Player Y Position
    CLR.L   D1                          ; Clear contents of D1 (XOR is faster)
    MOVE.L  #00,        D1              ; Player Velocity
    MOVE.L  D1,         PLYR_VELOCITY   ; Set Player Velocity
    MOVE.L  #GND_TRUE,  PLYR_ON_GND     ; Player is on Ground
    RTS

*-----------------------------------------------------------
* Subroutine    : Off Ground
* Description   : Set the Player Off Ground
*-----------------------------------------------------------
SET_OFF_GROUND:
    MOVE.L  #GND_FALSE, PLYR_ON_GND ; Player if off Ground
    RTS                             ; Return to subroutine
*-----------------------------------------------------------
* Subroutine    : Jump
* Description   : Perform a Jump
*-----------------------------------------------------------
JUMP:
    CMP.L   #GND_TRUE,PLYR_ON_GND       ; Player is on the Ground ?
    BEQ     PERFORM_JUMP                ; Do Jump
    BRA     JUMP_DONE                   ; Branch to Jump Done
PERFORM_JUMP:
    BSR     PLAY_JUMP                   ; Play jump sound
    MOVE.L  #PLYR_JUMP_V,PLYR_VELOCITY  ; Set the players velocity to true
    RTS                                 ; Return to subroutine
JUMP_DONE:
    RTS                                 ; Return to subroutine
    
*-----------------------------------------------------------
* Subroutine    : Player Lives Check
* Description   : Checking to see if the player has died
*-----------------------------------------------------------    
PLAYER_LIVES_CHECK:
    CLR         D1                  ; Clear d1
    MOVE.L      PLAYER_LIVES, D1    ; Moves player Lives into d1
    CMP.L       #0, D1              ; Checks if player lives is equal to 0
    BLE         EXIT                ; If it is go to exit routine, if not
    RTS                             ; Return to subroutine
    
    
*-----------------------------------------------------------
* Subroutine    : Delay
* Description   : Used to slow down the in game speed by using trap codes
*-----------------------------------------------------------
DELAY:
    MOVE.L      #1, D1
    MOVEQ       #23, D0             ;This trap code creates a delay in the code 
    TRAP        #15


*-----------------------------------------------------------
* Subroutine    : Idle
* Description   : Perform a Idle
*----------------------------------------------------------- 
IDLE:

    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutines   : Sound Load and Play
* Description   : Initialise game sounds into memory 
* Current Sounds are JUMP & DEATH 
*-----------------------------------------------------------
JUMP_LOAD:
    LEA     JUMP_WAV,   A1          ; Load Wav File into A1
    MOVE    #JMP_INDEX, D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_JUMP:
    MOVE    #JMP_INDEX, D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

DEATH_LOAD:
    LEA     DEATH_WAV,   A1         ; Load Wav File into A1
    MOVE    #DEATH_INDEX, D1        ; Assign it INDEX
    MOVE    #71,         D0         ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_DEATH:
    MOVE    #DEATH_INDEX,D1         ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine
    
*-----------------------------------------------------------
* Subroutine    : Draw Player
* Description   : Draw Player Square
*-----------------------------------------------------------
DRAW_PLAYER:
    ; Set Pixel Colors
    MOVE.L  #WHITE,     D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  PLAYER_X,   D1          ; X
    MOVE.L  PLAYER_Y,   D2          ; Y
    MOVE.L  PLAYER_X,   D3
    ADD.L   #PLYR_W_INIT,   D3      ; Width
    MOVE.L  PLAYER_Y,   D4 
    ADD.L   #PLYR_H_INIT,   D4      ; Height
    
    ; Draw Player
    MOVE.B  #87,        D0          ; Draw Player
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Draw Enemy
* Description   : Draw Enemy Square
*-----------------------------------------------------------
DRAW_ENEMY:
    ; Set Pixel Colors
    MOVE.L  #RED,       D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  ENEMY_X,    D1          ; X
    MOVE.L  ENEMY_Y,    D2          ; Y
    MOVE.L  ENEMY_X,    D3
    ADD.L   #ENMY_W_INIT,   D3      ; Width
    MOVE.L  ENEMY_Y,    D4 
    ADD.L   #ENMY_H_INIT,   D4      ; Height
    
    ; Draw Enemy    
    MOVE.B  #87,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Collision Check
* Description   : Axis-Aligned Bounding Box Collision Detection
* Algorithm checks for overlap on the 4 sides of the Player and 
* Enemy rectangles
* PLAYER_X <= ENEMY_X + ENEMY_W &&
* PLAYER_X + PLAYER_W >= ENEMY_X &&
* PLAYER_Y <= ENEMY_Y + ENEMY_H &&
* PLAYER_H + PLAYER_Y >= ENEMY_Y
*-----------------------------------------------------------
CHECK_COLLISIONS:
    CLR.L   D1                              ; Clear D1
    CLR.L   D2                              ; Clear D2
PLAYER_X_LTE_TO_ENEMY_X_PLUS_W:
    MOVE.L  PLAYER_X,   D1                  ; Move Player X to D1
    MOVE.L  ENEMY_X,    D2                  ; Move Enemy X to D2
    ADD.L   ENMY_W_INIT,D2                  ; Set Enemy width X + Width
    CMP.L   D1,         D2                  ; Do the Overlap ?
    BLE     PLAYER_X_PLUS_W_LTE_TO_ENEMY_X  ; Less than or Equal ?
    RTS
PLAYER_X_PLUS_W_LTE_TO_ENEMY_X:             ; Check player is not  
    ADD.L   PLYR_W_INIT,D1                  ; Move Player Width to D1
    MOVE.L  ENEMY_X,    D2                  ; Move Enemy X to D2
    CMP.L   D1,         D2                  ; Do they OverLap ?
    BGE     PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H  ; Less than or Equal
    RTS   
PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H:     
    MOVE.L  PLAYER_Y,   D1                  ; Move Player Y to D1
    MOVE.L  ENEMY_Y,    D2                  ; Move Enemy Y to D2
    ADD.L   ENMY_H_INIT,D2                  ; Set Enemy Height to D2
    CMP.L   D1,         D2                  ; Do they Overlap ?
    BLE     PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y  ; Less than or Equal
    RTS 
PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y:             ; Less than or Equal ?
    ADD.L   PLYR_H_INIT,D1                  ; Add Player Height to D1
    MOVE.L  ENEMY_Y,    D2                  ; Move Enemy Height to D2  
    CMP.L   D1,         D2                  ; Do they OverLap ?
    BGE     COLLISION                       ; Collision !
    RTS

COLLISION:
    MOVE.L      #1, D3                      ; Setting the data register 3 to 1
    SUB.L       D3, PLAYER_LIVES            ; Assigning this number to the current player score
    BGE         RESET_ENEMY_POSITION        ; Moves the enemy postion so that user doesnt get stuck inside
    RTS                                     ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : EXIT
* Description   : Exit message and End Game
*-----------------------------------------------------------
EXIT:
    ; Show if Exiting is Running
    BSR     PLAY_DEATH
    MOVE.B  #TC_CURSR_P,D0                  ; Set Cursor Position
    MOVE.W  #$4004,     D1                  ; Col 40, Row 1
    TRAP    #15                             ; Trap (Perform action)
    LEA     EXIT_MSG,   A1                  ; Exit
    MOVE    #13,        D0                  ; No Line feed
    TRAP    #15                             ; Trap (Perform action)
    MOVE.B  #94,        D0                  ; Trap code for double buffer to update screen
    TRAP    #15                             ; Trap
    MOVE.B  #TC_EXIT,   D0                  ; Exit Code
    TRAP    #15                             ; Trap (Perform action)
   

    SIMHALT

*-----------------------------------------------------------
* Section       : Messages
* Description   : Messages to Print on Console 
*-----------------------------------------------------------
SCORE_MSG       DC.B    'Score : ', 0                       ; Score Message

LIVES_MSG       DC.B    'Lives:', 0                         ; Lives Position Message

EXIT_MSG        DC.B    'GAME OVER!', 0                     ; Exit Message

ESC_MSG         DC.B    'Press ESC to exit!',0              ; ESC to exit message

CTRL_MSG        DC.B    'Press the SPACE key to jump!',0    ; Controls for user message



*-----------------------------------------------------------
* Section       : Graphic Colors
* Description   : Screen Pixel Color
*-----------------------------------------------------------
WHITE           EQU     $00FFFFFF       ; Hex colour for white
RED             EQU     $000000FF       ; Hex colour for red

*-----------------------------------------------------------
* Section       : Screen Size
* Description   : Screen Width and Height
*-----------------------------------------------------------
SCREEN_W        DS.W    01  ; Reserve Space for Screen Width
SCREEN_H        DS.W    01  ; Reserve Space for Screen Height

*-----------------------------------------------------------
* Section       : Keyboard Input
* Description   : Used for storing Keypresses
*-----------------------------------------------------------
CURRENT_KEY     DS.L    01  ; Reserve Space for Current Key Pressed

*-----------------------------------------------------------
* Section       : Character Positions
* Description   : Player and Enemy Position Memory Locations
*-----------------------------------------------------------
PLAYER_X        DS.L    01  ; Reserve Space for Player X Position
PLAYER_Y        DS.L    01  ; Reserve Space for Player Y Position
PLAYER_SCORE    DS.L    01  ; Reserve Space for Player Score
PLAYER_LIVES    DS.L    01  ; Reserve space for Player Lives

PLYR_VELOCITY   DS.L    01  ; Reserve Space for Player Velocity
PLYR_GRAVITY    DS.L    01  ; Reserve Space for Player Gravity
PLYR_ON_GND     DS.L    01  ; Reserve Space for Player on Ground

ENEMY_X         DS.L    01  ; Reserve Space for Enemy X Position
ENEMY_Y         DS.L    01  ; Reserve Space for Enemy Y Position

*-----------------------------------------------------------
* Section       : Sounds
* Description   : Sound files, which are then loaded and given
* an address in memory, they take a longtime to process and play
* so keep the files small. Used https://voicemaker.in/ to 
* generate and Audacity to convert MP3 to WAV
*-----------------------------------------------------------
JUMP_WAV        DC.B    'jump.wav',0            ; Jump Sound
DEATH_WAV       DC.B   'death.wav',0            ; Death Sound
    END    START                                ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
