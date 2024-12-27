
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

; This is a Rock, Paper, Scissors game written in assembly language.
;Date: 12/27/2024




; Import neccessary libraries to use built in functions
include emu8086.inc
ORG 100h
 

; Declare a label start game for starting the game
Start_Game:

   call CLEAR_SCREEN; clear the screen before starting the game
   
   ; Print the welcome message  
   mov dx, offset Welcome_message
   call Print_message
   
   ;Go to new line 
   call New_Line
   
   ;Start the game loop  
   Game_Loop:
   
     ; Print the instructions for the user
     mov dx, offset Instructions
     call Print_message 
         
     call New_Line
     
     ;Accept Input from the user   
     call Accept_Input
     
     ;Validate the input   
     call Validate_Input
         
     ; Move the input from al to variable because the value of al change constantly
     mov User_choice, al
     
     ; generate random number between 1 and 3
     call Random 
     
     mov Computer_choice, bl
     
     ;Print the computer choice
     mov dx, offset Computer_Choice_message
     call Print_message 
     call Display_Computer_choice
    
    ;Based on the user choice go to one of the functions defined to check who win the game     
    cmp User_choice, '1'
        JE Check_Rock
    
    cmp User_choice, '2'
        JE Check_Paper
    
    cmp User_choice, '3'
        JE Check_Scissor
    
    RET


; Function to accept input from the user and store it in al        
Accept_Input:
    
    mov ah, 1
    int 21h
    RET
    
;Validate the input based on conditions
Validate_Input:
    cmp al, '1' ;if the ascii is less than 1 it's an invalid input
        JL Invalid_Input
    cmp al, '3' ;same way if it's greater than 3 it's an invalid input
        JG Invalid_Input
    RET

; Function to print a message in the shell        
Print_message:
    mov ah, 9
    int 21h
    RET

; When the user Input is invalid this will handle the case
Invalid_Input:

    call New_Line
    
    ;Notify the user that he has entered the wrong input
    mov dx, offset Invalid_user_input
    call Print_message
    
    ;Start the game again by telling the user the instructions
    call Game_loop
    RET

; Function to go to a new line   
New_Line:
    MOV AH, 02h
    MOV DL, 0Dh
    INT 21h
    MOV DL, 0Ah
    INT 21h
    RET

; Function to generate a random number from 1 to 3 and store it in bl
Random:
    ; Get system timer tick using BIOS interrupt 1Ah
    mov ah, 00h       ; BIOS function to read timer
    int 1Ah           ; Call BIOS interrupt

    ; Timer tick is now in DX (high 16 bits of 24-bit timer count)
    mov ax, dx        ; Move DX to AX for arithmetic
    xor dx, dx        ; Clear DX for division

    ; Calculate modulo 3 (range: 0-2)
    mov cx, 3         ; Divisor
    div cx            ; AX / CX, remainder in DX

    ; Adjust range to 1-3
    inc dl            ; Add 1 to remainder to make range 1-3

    ; Store result in BL
    mov bl, dl        ; BL = Random number (1-3)
    RET
     
; Function to display what the computer has chosen    
Display_Computer_choice:
    add bl, '0'         ; Convert number to ASCII
    mov dl, bl          ; Move ASCII number to DL
    mov ah, 02h         ; Print single character
    int 21h
    RET

; Function to determine whether the user has won or not if he chooses rock
Check_Rock:
    cmp Computer_choice,3
        JE User_Win
    cmp Computer_choice, 2
        JE User_Lose
    
    
    call Draw
    RET

;Function to determine whether the user has won or not if he chooses paper   
Check_Paper:
    
    cmp Computer_choice, 1
        JE User_win
    cmp Computer_choice, 3
        JE User_lose
        
    call Draw
    RET

;Function to determine whether the user has won or not if he chooses scissors
Check_Scissor:

    cmp Computer_choice, 2
        JE User_win
    cmp Computer_choice, 1
        JE User_lose
    
    call Draw
    RET

;Instructions to do if the user win the game    
User_win:
    
    inc User_win_count
    call New_Line
    
    mov dx, offset User_win_round
    call Print_message
    
    call Current_Score
    
    mov dx, offset User_Input
    call Print_message
    
    call Accept_Input
    cmp al, 'y'
        JE Start_Game
    cmp al, 'Y'
        JE Start_Game
        
    call Compare_Result
    RET

;Instructions to do if the user loses the game    
User_Lose:

    
    inc Computer_win_count
    call New_Line
    
    mov dx, offset User_lose_round
    call Print_message
    
    call Current_Score
    
    mov dx, offset User_Input
    call Print_message
    
    call Accept_Input
    cmp al, 'y'
        JE Start_Game
    cmp al, 'Y'
        JE Start_Game
        
    call Compare_Result
    RET

; Continue the game if it's a draw
Draw:
    
    
    call New_Line
    
    
    mov dx, offset Draw_message
    call Print_message
    
    call Game_Loop

; Print the current score of the user    
Current_Score:

    mov dx, offset User_Score
    call Print_message
    
    mov bl, '0'
    add bl, User_win_count
    mov dl, bl          
    mov ah, 02h         
    int 21h
           
    mov dl, ':'
    mov ah, 02h
    int 21h
    
    
    mov bl, '0'
    add bl, Computer_win_count
    mov dl, bl          
    mov ah, 02h         
    int 21h
    
    mov dl, '.'
    mov ah, 02h
    int 21h
    RET

; Compare the result to decide who win the game
Compare_Result:

    mov al, User_win_count
    
    cmp al, Computer_win_count
        JG User_Win_Game
        JL User_lose_Game
        JE Tie
    RET
    
; If the user wins the game        
User_Win_Game:

    call New_Line
    
    mov dx, offset User_win_message
    call Print_message
    
    call Current_Score
    
    call End_Game
    RET

; If the user loses the game    
User_lose_Game:

    call New_Line
    
    mov dx, offset User_lose_message
    call Print_message
    
    call Current_Score
    
    
    call End_Game
    RET

; When nobody wins    
Tie:
    call New_Line
    
    mov dx, offset Tie_message
    call Print_message
    
    call Current_Score
    
    call End_Game
    RET

; Function to end the game if the user wants to quit  
End_Game:
    mov dx, offset Thank_you_message
    call Print_message    
    mov ah, 4ch
    int 21h

mov User_win_count, 0
mov Computer_win_count, 0   
call Start_Game
RET      

; Texts that need to be displayed when needed are declared here
Welcome_message db "Welcome to Rock, Paper, Scissors Game.$"
Instructions db "Enter your choice: 1 = Rock, 2 = Paper, 3 = Scissors$"
Invalid_user_input db "You have entered incorrect input please read the instructions carefully and enter the correct command.$"
User_win_message db "Congratulations you have won the game. $"
User_lose_message db "Oops You have lost the game!. $"
User_win_round db "Congratulations you have won this round. $"
User_lose_round db "You have lost this round. $"
Draw_message db "It is a Draw. Let's Play Again.$"
User_Input db "Do you want to continue playing the game(y/n)? $"
Computer_Choice_message DB ' Computer chose: $'
User_Score db "Your Score is $"
Tie_message db "It's a Tie. $" 
Thank_you_message db "Thank you for playing with us.$"

; variables to store the user and the computer choice are declared here
User_choice db ? 
Computer_choice db ?
User_win_count db 0
Computer_win_count db 0

Define_CLEAR_SCREEN

END

