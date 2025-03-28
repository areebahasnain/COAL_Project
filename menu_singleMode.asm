TITLE Hangman Game                (Hangman.asm)

INCLUDE Irvine32.inc

.data
    welcome     BYTE "Welcome to Hangman!", 0
    newLine     BYTE 13, 10, 0
    
    menuText BYTE "HANGMAN MENU", 13, 10,
              "1. Single Player", 13, 10,
              "2. Multiplayer", 13, 10,
              "3. Instructions", 13, 10,
              "4. Exit", 13, 10, 0
    
    singlePlayerMsg BYTE "Starting Single Player Mode...", 13, 10, 0
    multiplayerMsg  BYTE "Starting Multiplayer Mode...", 13, 10, 0
    instructions    BYTE "Instructions: Guess the word before the hangman is fully drawn.", 13, 10, 0
    exitMsg        BYTE "Exiting the game. Goodbye!", 13, 10, 0
    
    wordPrompt  BYTE "The word to guess: ", 0
    guessPrompt BYTE "Enter a letter: ", 0
    correctMsg  BYTE "Correct guess!", 0
    wrongMsg    BYTE "Wrong guess!", 0
    winMsg      BYTE "Congratulations! You won!", 0
    loseMsg     BYTE "Game Over! You lost. The word was: ", 0
    
    secretWord  BYTE "ASSEMBLY", 0    ; The word to guess
    wordLength  DWORD 8               ; Length of the secret word
    displayWord BYTE "________", 0    ; Initially shows underscores
    
    guessedLetter BYTE ?             ; User's current guess
    wrongGuesses  DWORD 0            ; Counter for wrong guesses
    foundMatch    DWORD 0            ; Flag to check if match found in current guess
    
    ; Array of pointers to hangman states
    hangmanStates DWORD OFFSET hangman0, OFFSET hangman1, OFFSET hangman2, OFFSET hangman3, OFFSET hangman4, OFFSET hangman5, OFFSET hangman6
    
    ; Hangman drawing states
    hangman0    BYTE "  +---+", 13, 10, "  |   |", 13, 10, "      |", 13, 10, "      |", 13, 10, "      |", 13, 10, "      |", 13, 10, "=========", 0
    hangman1    BYTE "  +---+", 13, 10, "  |   |", 13, 10, "  O   |", 13, 10, "      |", 13, 10, "      |", 13, 10, "      |", 13, 10, "=========", 0
    hangman2    BYTE "  +---+", 13, 10, "  |   |", 13, 10, "  O   |", 13, 10, "  |   |", 13, 10, "      |", 13, 10, "      |", 13, 10, "=========", 0
    hangman3    BYTE "  +---+", 13, 10, "  |   |", 13, 10, "  O   |", 13, 10, " /|   |", 13, 10, "      |", 13, 10, "      |", 13, 10, "=========", 0
    hangman4    BYTE "  +---+", 13, 10, "  |   |", 13, 10, "  O   |", 13, 10, " /|\  |", 13, 10, "      |", 13, 10, "      |", 13, 10, "=========", 0
    hangman5    BYTE "  +---+", 13, 10, "  |   |", 13, 10, "  O   |", 13, 10, " /|\  |", 13, 10, " /    |", 13, 10, "      |", 13, 10, "=========", 0
    hangman6    BYTE "  +---+", 13, 10, "  |   |", 13, 10, "  O   |", 13, 10, " /|\  |", 13, 10, " / \  |", 13, 10, "      |", 13, 10, "=========", 0

.code
ShowMenu PROC
    mov edx, OFFSET newLine
    call WriteString
    mov edx, OFFSET newLine
    call WriteString
    
    mov edx, OFFSET menuText
    call WriteString
    
    call ReadChar   ; Read user's choice
    call WriteChar  ; Echo the choice
    call Crlf
    
    cmp al, '1'
    je StartSinglePlayer
    cmp al, '2'
    je StartMultiplayer
    cmp al, '3'
    je ShowInstructions
    cmp al, '4'
    je ExitGame
    
    jmp ShowMenu
    
StartSinglePlayer:
    call Crlf
    mov edx, OFFSET singlePlayerMsg
    call WriteString
    call StartGame
    jmp ShowMenu
    
StartMultiplayer:
    call Crlf
    mov edx, OFFSET multiplayerMsg
    call WriteString
    call StartMultiplayerGame
    jmp ShowMenu
    
ShowInstructions:
    call Crlf
    mov edx, OFFSET instructions
    call WriteString
    call Crlf
    jmp ShowMenu
    
ExitGame:
    call Crlf
    mov edx, OFFSET exitMsg
    call WriteString
    call Crlf
    exit
ShowMenu ENDP

StartGame PROC
    mov wrongGuesses, 0
GameLoop:
    ; Display current hangman state
    mov esi, wrongGuesses
    mov edx, hangmanStates[esi * TYPE DWORD]
    call WriteString
    call Crlf
    
    ; Display current word state
    mov edx, OFFSET wordPrompt
    call WriteString
    mov edx, OFFSET displayWord
    call WriteString
    call Crlf
    
    ; Prompt for guess
    mov edx, OFFSET guessPrompt
    call WriteString
    call ReadChar
    call WriteChar
    call Crlf
    
    mov guessedLetter, al
    
    ; Check if guessed letter is in the word
    mov foundMatch, 0
    mov esi, 0
CheckLetter:
    movzx eax, secretWord[esi]
    cmp al, 0
    je EndCheckLetter
    cmp al, guessedLetter
    jne NotMatch
    mov displayWord[esi], al
    mov foundMatch, 1
NotMatch:
    inc esi
    jmp CheckLetter

EndCheckLetter:
    cmp foundMatch, 1
    je CorrectGuess
    inc wrongGuesses
CorrectGuess:
    jmp GameLoop
StartGame ENDP

StartMultiplayerGame PROC
    ret
StartMultiplayerGame ENDP

main PROC
    call ShowMenu
    exit
main ENDP
END main
