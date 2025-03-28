; need to add dual mode, create menu, fix ascii figure

TITLE Hangman Game                (Hangman.asm)

INCLUDE Irvine32.inc

.data
    welcome     BYTE "Welcome to Hangman!", 0
    wordPrompt  BYTE "The word to guess: ", 0
    guessPrompt BYTE "Enter a letter: ", 0
    correctMsg  BYTE "Correct guess!", 0
    wrongMsg    BYTE "Wrong guess!", 0
    winMsg      BYTE "Congratulations! You won!", 0
    loseMsg     BYTE "Game Over! You lost. The word was: ", 0
    newLine     BYTE 13, 10, 0
    
    ; Hangman secret word and current display
    secretWord  BYTE "ASSEMBLY", 0    ; The word to guess
    wordLength  DWORD 8               ; Length of the secret word
    displayWord BYTE "________", 0    ; Initially shows underscores
    
    ; Hangman drawing states
    hangman0    BYTE "  +---+", 13, 10
                BYTE "  |   |", 13, 10
                BYTE "      |", 13, 10
                BYTE "      |", 13, 10
                BYTE "      |", 13, 10
                BYTE "      |", 13, 10
                BYTE "=========", 0
                
    hangman1    BYTE "  +---+", 13, 10
                BYTE "  |   |", 13, 10
                BYTE "  O   |", 13, 10
                BYTE "      |", 13, 10
                BYTE "      |", 13, 10
                BYTE "      |", 13, 10
                BYTE "=========", 0
                
    hangman2    BYTE "  +---+", 13, 10
                BYTE "  |   |", 13, 10
                BYTE "  O   |", 13, 10
                BYTE "  |   |", 13, 10
                BYTE "      |", 13, 10
                BYTE "      |", 13, 10
                BYTE "=========", 0
                
    hangman3    BYTE "  +---+", 13, 10
                BYTE "  |   |", 13, 10
                BYTE "  O   |", 13, 10
                BYTE " /|   |", 13, 10
                BYTE "      |", 13, 10
                BYTE "      |", 13, 10
                BYTE "=========", 0
                
    hangman4    BYTE "  +---+", 13, 10
                BYTE "  |   |", 13, 10
                BYTE "  O   |", 13, 10
                BYTE " /|\\  |", 13, 10
                BYTE "      |", 13, 10
                BYTE "      |", 13, 10
                BYTE "=========", 0
                
    hangman5    BYTE "  +---+", 13, 10
                BYTE "  |   |", 13, 10
                BYTE "  O   |", 13, 10
                BYTE " /|\\  |", 13, 10
                BYTE " /    |", 13, 10
                BYTE "      |", 13, 10
                BYTE "=========", 0
                
    hangman6    BYTE "  +---+", 13, 10
                BYTE "  |   |", 13, 10
                BYTE "  O   |", 13, 10
                BYTE " /|\\  |", 13, 10
                BYTE " / \\  |", 13, 10
                BYTE "      |", 13, 10
                BYTE "=========", 0
                
    ; Array of pointers to hangman states
    hangmanStates DWORD hangman0, hangman1, hangman2, hangman3, hangman4, hangman5, hangman6
    
    ; Game variables
    guessedLetter BYTE ?             ; User's current guess
    wrongGuesses  DWORD 0            ; Counter for wrong guesses
    foundMatch    DWORD 0            ; Flag to check if match found in current guess
    
.code
main PROC
    ; Set text color
    mov eax, yellow + (blue * 16)
    call SetTextColor
    
    ; Display welcome message
    mov edx, OFFSET welcome
    call WriteString
    call Crlf
    call Crlf
    
    ; Game loop
    gameLoop:
        ; Display current hangman state
        mov esi, wrongGuesses
        mov ebx, hangmanStates[esi * TYPE DWORD]
        mov edx, ebx
        call WriteString
        call Crlf
        
        ; Display word prompt and current state of the word
        mov edx, OFFSET wordPrompt
        call WriteString
        mov edx, OFFSET displayWord
        call WriteString
        call Crlf
        
        ; Check if player won (no more underscores in displayWord)
        mov esi, 0
        checkWinLoop:
            cmp displayWord[esi], '_'
            je notWonYet
            inc esi
            cmp esi, wordLength
            jb checkWinLoop
            
        ; Player won
        call Crlf
        mov edx, OFFSET winMsg
        call WriteString
        call Crlf
        jmp endGame
        
        notWonYet:
        ; Check if player lost (wrongGuesses reached 6)
        cmp wrongGuesses, 6
        jne continueGame
        
        ; Player lost
        call Crlf
        mov edx, OFFSET loseMsg
        call WriteString
        mov edx, OFFSET secretWord
        call WriteString
        call Crlf
        jmp endGame
        
        continueGame:
        ; Prompt for guess
        mov edx, OFFSET guessPrompt
        call WriteString
        
        ; Get one character input (convert to uppercase for case insensitivity)
        call ReadChar
        call WriteChar
        call Crlf
        
        ; Convert to uppercase if lowercase
        cmp al, 'a'
        jb notLowercase
        cmp al, 'z'
        ja notLowercase
        sub al, 32          ; Convert to uppercase
        
        notLowercase:
        mov guessedLetter, al
        
        ; Check if the guessed letter is in the secret word
        mov foundMatch, 0
        mov esi, 0
        
        checkLetter:
            movzx eax, secretWord[esi]
            cmp al, 0                   ; Check for end of string
            je endCheckLetter
            
            cmp al, guessedLetter       ; Compare with guessed letter
            jne notMatch
            
            ; Found a match, update display word
            mov displayWord[esi], al
            mov foundMatch, 1
            
        notMatch:
            inc esi
            jmp checkLetter
            
        endCheckLetter:
        
        ; Check if a match was found
        cmp foundMatch, 1
        je correctGuess
        
        ; Wrong guess
        mov edx, OFFSET wrongMsg
        call WriteString
        call Crlf
        inc wrongGuesses
        jmp continueGameLoop
        
        correctGuess:
        mov edx, OFFSET correctMsg
        call WriteString
        call Crlf
        
        continueGameLoop:
        call Crlf
        jmp gameLoop
    
    endGame:
    call WaitMsg
    exit
main ENDP
END main
