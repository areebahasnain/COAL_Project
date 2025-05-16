

TITLE Hangman Game (hangman.asm) ; Sets the title of the program

INCLUDE Irvine32.inc            ; Includes the Irvine32 library with useful macros and procedures

.data
; ---------------------- Game Constants ----------------------
WORD_SIZE = 20            ; Maximum number of characters in a word
MAX_TRIES = 6             ; Maximum incorrect guesses allowed before losing
EASY_MAX_WORDS = 5        ; Number of words in the easy difficulty level
MED_MAX_WORDS = 5         ; Number of words in the medium difficulty level
HARD_MAX_WORDS = 5        ; Number of words in the hard difficulty level

; ---------------------- Game Messages ----------------------
titleMsg        BYTE "===== HANGMAN GAME =====", 0  ; Game title message
mainMenuMsg     BYTE "1. Single Player", 0dh, 0ah    ; Main menu options (1)
                BYTE "2. Multiplayer", 0dh, 0ah       ; Main menu options (2)
                BYTE "3. Game Instructions", 0dh, 0ah ; Main menu options (3)
                BYTE "4. Exit", 0dh, 0ah              ; Main menu options (4)
                BYTE "Enter your choice (1-4): ", 0   ; Prompt to choose menu option
difficultyMsg   BYTE "Select difficulty:", 0dh, 0ah  ; Prompt to select difficulty
                BYTE "1. Easy", 0dh, 0ah
                BYTE "2. Medium", 0dh, 0ah
                BYTE "3. Hard", 0dh, 0ah
                BYTE "Enter your choice (1-4): ", 0
instructionMsg  BYTE "===== HANGMAN GAME RULES =====", 0dh, 0ah, 0dh, 0ah ; Game instructions text
                BYTE "SINGLE PLAYER MODE:", 0dh, 0ah
                BYTE "- Select a difficulty level (Easy, Medium, Hard)", 0dh, 0ah
                BYTE "- A random word will be chosen for you to guess", 0dh, 0ah
                BYTE "- You have 6 incorrect guesses before the hangman is complete", 0dh, 0ah
                BYTE "- Try to guess the word one letter at a time", 0dh, 0ah, 0dh, 0ah
                BYTE "MULTIPLAYER MODE:", 0dh, 0ah
                BYTE "- One player enters a word for the other to guess", 0dh, 0ah
                BYTE "- The word is hidden while being entered", 0dh, 0ah
                BYTE "- The player also enters a genre/category as a hint", 0dh, 0ah
                BYTE "- The second player has 6 incorrect guesses to solve the word", 0dh, 0ah, 0dh, 0ah
                BYTE "Press any key to return to the main menu", 0
wordPrompt      BYTE "Player 1, enter a word: ", 0       ; Prompt for player 1 to enter the word
hintPrompt      BYTE "Enter Hint: ", 0                   ; Prompt for player 1 to enter a hint
enterGuessMsg   BYTE "Enter a letter: ", 0               ; Prompt for letter guess
usedLetterMsg   BYTE "You already guessed that letter!", 0 ; Message for repeated letter
correctGuessMsg BYTE "Good guess!", 0                    ; Message when guess is correct
wrongGuessMsg   BYTE "Wrong guess!", 0                   ; Message when guess is wrong
winMsg          BYTE "Congratulations! You won!", 0      ; Win message
loseMsg         BYTE "Game over! You lost!", 0           ; Lose message
wordWasMsg      BYTE "The word was: ", 0                 ; Message before revealing word
hintIsMsg       BYTE "Hint: ", 0                         ; Hint label
triesLeftMsg    BYTE "Tries left: ", 0                   ; Message showing remaining tries
playAgainMsg    BYTE "Play again? (y/n): ", 0            ; Prompt to play again
invalidInputMsg BYTE "Invalid input! Try again.", 0      ; Message for invalid input

; ---------------------- Word Lists with Hints ----------------------
; Each word is followed by a null terminator and then its hint
; Format: "WORD", 0, "HINT", 0

; Easy difficulty words and hints
easyWords       BYTE "APPLE", 0, "FOOD", 0
                BYTE "MARIO", 0, "GAME", 0
                BYTE "PIZZA", 0, "FOOD", 0
                BYTE "TIGER", 0, "ANIMAL", 0
                BYTE "CHAIR", 0, "FURNITURE", 0

; Medium difficulty words and hints
mediumWords     BYTE "COMPUTER", 0, "TECHNOLOGY", 0
                BYTE "ELEPHANT", 0, "ANIMAL", 0
                BYTE "SANDWICH", 0, "FOOD", 0
                BYTE "MOUNTAIN", 0, "GEOGRAPHY", 0
                BYTE "BASEBALL", 0, "SPORT", 0

; Hard difficulty words and hints
hardWords       BYTE "ALGORITHM", 0, "COMPUTING", 0
                BYTE "PSYCHOLOGY", 0, "SCIENCE", 0
                BYTE "HELICOPTER", 0, "VEHICLE", 0
                BYTE "MISSISSIPPI", 0, "GEOGRAPHY", 0
                BYTE "PNEUMONIA", 0, "DISEASE", 0

; ---------------------- Game State Variables ----------------------
currentWord     BYTE WORD_SIZE DUP(0)      ; Stores the current word being guessed
wordHint        BYTE WORD_SIZE DUP(0)      ; Stores the hint for the current word
hiddenWord      BYTE WORD_SIZE DUP(0)      ; Word with underscores for hidden letters
usedLetters     BYTE 26 DUP(0)             ; Tracks guessed letters A-Z (1 = used)
triesRemaining  BYTE ?                     ; Holds number of remaining incorrect guesses
wordLength      DWORD ?                    ; Holds length of the current word
gameMode        BYTE ?                     ; 1 = Single player, 2 = Multiplayer
difficultyLevel BYTE ?                     ; Difficulty selected (1 = Easy, 2 = Medium, 3 = Hard)

; ---------------------- Buffer Variables ----------------------
inputBuffer     BYTE WORD_SIZE DUP(0)      ; Temporary buffer for user input
tempBuffer      BYTE WORD_SIZE DUP(0)      ; Another temporary string buffer

; ---------------------- Hangman ASCII Art Stages ----------------------
; Each stage of the hangman drawing as ASCII art, each line ends with 0dh (carriage return) and 0ah (newline)
; Ending with 0 to terminate the string

; (The actual art will be described in the next section)
```

; Continuing with detailed comments for the .code section starting at main PROC

.code
main PROC
    call Randomize               ; Initializes the random number generator for word selection

MainGameLoop:
    call ClearScreen             ; Clears the screen
    call DisplayTitle            ; Shows the game title
    call DisplayMainMenu         ; Shows the main menu options
    call GetMenuChoice           ; Waits for user input (1-4) and stores it in AL

    ; Process the selected menu choice
    cmp al, 1
    je SinglePlayerMode          ; If choice is 1, jump to SinglePlayerMode
    cmp al, 2
    je MultiplayerMode           ; If choice is 2, jump to MultiplayerMode
    cmp al, 3
    je ShowInstructions          ; If choice is 3, jump to ShowInstructions
    cmp al, 4
    je ExitGame                  ; If choice is 4, jump to ExitGame

    ; If input is invalid, show error and loop again
    mov edx, OFFSET invalidInputMsg ; Point EDX to the invalid input message
    call WriteString             ; Print the message
    call Crlf                    ; New line
    call WaitForKey              ; Wait for user to press a key
    jmp MainGameLoop             ; Jump back to the main game loop

SinglePlayerMode:
    mov gameMode, 1              ; Set game mode to 1 (Single Player)
    call SinglePlayerGame        ; Start single player game logic
    jmp CheckPlayAgain           ; After the game ends, ask to play again

MultiplayerMode:
    mov gameMode, 2              ; Set game mode to 2 (Multiplayer)
    call MultiplayerGame         ; Start multiplayer game logic
    jmp CheckPlayAgain           ; After the game ends, ask to play again

CheckPlayAgain:
    call Crlf                    ; New line for spacing
    mov edx, OFFSET playAgainMsg ; Display "Play again? (y/n):"
    call WriteString
    call ReadChar                ; Read the user's response character
    call WriteChar               ; Echo the character on screen
    call Crlf                    ; New line

ShowInstructions:
    call DisplayHelpScreen       ; Show game instructions screen
    jmp MainGameLoop             ; Return to main menu

    ; Check if user wants to play again
    cmp al, 'y'
    je MainGameLoop              ; If 'y', restart the game
    cmp al, 'Y'
    je MainGameLoop              ; If 'Y', restart the game

ExitGame:
    exit                         ; Exit the program
main ENDP
; Continuing with detailed comments for the .code section starting at main PROC

.code
main PROC
    call Randomize               ; Initializes the random number generator for word selection

MainGameLoop:
    call ClearScreen             ; Clears the screen
    call DisplayTitle            ; Shows the game title
    call DisplayMainMenu         ; Shows the main menu options
    call GetMenuChoice           ; Waits for user input (1-4) and stores it in AL

    ; Process the selected menu choice
    cmp al, 1
    je SinglePlayerMode          ; If choice is 1, jump to SinglePlayerMode
    cmp al, 2
    je MultiplayerMode           ; If choice is 2, jump to MultiplayerMode
    cmp al, 3
    je ShowInstructions          ; If choice is 3, jump to ShowInstructions
    cmp al, 4
    je ExitGame                  ; If choice is 4, jump to ExitGame

    ; If input is invalid, show error and loop again
    mov edx, OFFSET invalidInputMsg ; Point EDX to the invalid input message
    call WriteString             ; Print the message
    call Crlf                    ; New line
    call WaitForKey              ; Wait for user to press a key
    jmp MainGameLoop             ; Jump back to the main game loop

SinglePlayerMode:
    mov gameMode, 1              ; Set game mode to 1 (Single Player)
    call SinglePlayerGame        ; Start single player game logic
    jmp CheckPlayAgain           ; After the game ends, ask to play again

MultiplayerMode:
    mov gameMode, 2              ; Set game mode to 2 (Multiplayer)
    call MultiplayerGame         ; Start multiplayer game logic
    jmp CheckPlayAgain           ; After the game ends, ask to play again

CheckPlayAgain:
    call Crlf                    ; New line for spacing
    mov edx, OFFSET playAgainMsg ; Display "Play again? (y/n):"
    call WriteString
    call ReadChar                ; Read the user's response character
    call WriteChar               ; Echo the character on screen
    call Crlf                    ; New line

ShowInstructions:
    call DisplayHelpScreen       ; Show game instructions screen
    jmp MainGameLoop             ; Return to main menu

    ; Check if user wants to play again
    cmp al, 'y'
    je MainGameLoop              ; If 'y', restart the game
    cmp al, 'Y'
    je MainGameLoop              ; If 'Y', restart the game

ExitGame:
    exit                         ; Exit the program
main ENDP

; ---------------------------------------------------------
; DisplayTitle - Displays the game title
; ---------------------------------------------------------
DisplayTitle PROC
    mov eax, title_color         ; Set text color to title color (bright magenta)
    call SetTextColor            ; Apply text color
    call Crlf                    ; New line for spacing
    mov edx, OFFSET titleMsg     ; Point EDX to the title message string
    call WriteString             ; Display the title message
    call Crlf                    ; New line
    call Crlf                    ; Another line for spacing

    mov eax, white_color         ; Reset text color to normal white
    call SetTextColor
    ret                          ; Return from procedure
DisplayTitle ENDP

; ---------------------------------------------------------
; DisplayMainMenu - Displays the main menu options
; ---------------------------------------------------------
DisplayMainMenu PROC
    mov eax, menu_color          ; Set menu color (light grey)
    call SetTextColor            ; Apply the color

    mov edx, OFFSET mainMenuMsg  ; Load the address of the menu message
    call WriteString             ; Display the main menu

    mov eax, white_color         ; Reset text color to white
    call SetTextColor
    ret                          ; Return from procedure
DisplayMainMenu ENDP

; ---------------------------------------------------------
; GetMenuChoice - Gets menu choice from the user (1-4)
; Returns: AL = menu choice
; ---------------------------------------------------------
GetMenuChoice PROC
    call ReadDec                 ; Read a decimal number from user input
    ret                          ; Return with result in AL
GetMenuChoice ENDP

; ---------------------------------------------------------
; SinglePlayerGame - Handles single player game logic
; ---------------------------------------------------------
SinglePlayerGame PROC
    call ClearScreen             ; Clear the console screen
    call DisplayTitle            ; Show the game title

    call GetDifficultyLevel      ; Ask user to choose difficulty (1-3)
    call InitializeGameState     ; Reset tries, used letters, etc.
    call SelectRandomWord        ; Choose a random word based on difficulty

    call GameLoop                ; Start the main guessing loop
    ret                          ; Return when game ends
SinglePlayerGame ENDP
; Continuing with detailed comments for the .code section starting at main PROC

.code
main PROC
    call Randomize               ; Initializes the random number generator for word selection

MainGameLoop:
    call ClearScreen             ; Clears the screen
    call DisplayTitle            ; Shows the game title
    call DisplayMainMenu         ; Shows the main menu options
    call GetMenuChoice           ; Waits for user input (1-4) and stores it in AL

    ; Process the selected menu choice
    cmp al, 1
    je SinglePlayerMode          ; If choice is 1, jump to SinglePlayerMode
    cmp al, 2
    je MultiplayerMode           ; If choice is 2, jump to MultiplayerMode
    cmp al, 3
    je ShowInstructions          ; If choice is 3, jump to ShowInstructions
    cmp al, 4
    je ExitGame                  ; If choice is 4, jump to ExitGame

    ; If input is invalid, show error and loop again
    mov edx, OFFSET invalidInputMsg ; Point EDX to the invalid input message
    call WriteString             ; Print the message
    call Crlf                    ; New line
    call WaitForKey              ; Wait for user to press a key
    jmp MainGameLoop             ; Jump back to the main game loop

SinglePlayerMode:
    mov gameMode, 1              ; Set game mode to 1 (Single Player)
    call SinglePlayerGame        ; Start single player game logic
    jmp CheckPlayAgain           ; After the game ends, ask to play again

MultiplayerMode:
    mov gameMode, 2              ; Set game mode to 2 (Multiplayer)
    call MultiplayerGame         ; Start multiplayer game logic
    jmp CheckPlayAgain           ; After the game ends, ask to play again

CheckPlayAgain:
    call Crlf                    ; New line for spacing
    mov edx, OFFSET playAgainMsg ; Display "Play again? (y/n):"
    call WriteString
    call ReadChar                ; Read the user's response character
    call WriteChar               ; Echo the character on screen
    call Crlf                    ; New line

ShowInstructions:
    call DisplayHelpScreen       ; Show game instructions screen
    jmp MainGameLoop             ; Return to main menu

    ; Check if user wants to play again
    cmp al, 'y'
    je MainGameLoop              ; If 'y', restart the game
    cmp al, 'Y'
    je MainGameLoop              ; If 'Y', restart the game

ExitGame:
    exit                         ; Exit the program
main ENDP

; ---------------------------------------------------------
; DisplayTitle - Displays the game title
; ---------------------------------------------------------
DisplayTitle PROC
    mov eax, title_color         ; Set text color to title color (bright magenta)
    call SetTextColor            ; Apply text color
    call Crlf                    ; New line for spacing
    mov edx, OFFSET titleMsg     ; Point EDX to the title message string
    call WriteString             ; Display the title message
    call Crlf                    ; New line
    call Crlf                    ; Another line for spacing

    mov eax, white_color         ; Reset text color to normal white
    call SetTextColor
    ret                          ; Return from procedure
DisplayTitle ENDP

; ---------------------------------------------------------
; DisplayMainMenu - Displays the main menu options
; ---------------------------------------------------------
DisplayMainMenu PROC
    mov eax, menu_color          ; Set menu color (light grey)
    call SetTextColor            ; Apply the color

    mov edx, OFFSET mainMenuMsg  ; Load the address of the menu message
    call WriteString             ; Display the main menu

    mov eax, white_color         ; Reset text color to white
    call SetTextColor
    ret                          ; Return from procedure
DisplayMainMenu ENDP

; ---------------------------------------------------------
; GetMenuChoice - Gets menu choice from the user (1-4)
; Returns: AL = menu choice
; ---------------------------------------------------------
GetMenuChoice PROC
    call ReadDec                 ; Read a decimal number from user input
    ret                          ; Return with result in AL
GetMenuChoice ENDP

; ---------------------------------------------------------
; SinglePlayerGame - Handles single player game logic
; ---------------------------------------------------------
SinglePlayerGame PROC
    call ClearScreen             ; Clear the console screen
    call DisplayTitle            ; Show the game title

    call GetDifficultyLevel      ; Ask user to choose difficulty (1-3)
    call InitializeGameState     ; Reset tries, used letters, etc.
    call SelectRandomWord        ; Choose a random word based on difficulty

    call GameLoop                ; Start the main guessing loop
    ret                          ; Return when game ends
SinglePlayerGame ENDP

; ---------------------------------------------------------
; MultiplayerGame - Handles multiplayer game logic
; ---------------------------------------------------------
MultiplayerGame PROC
    call ClearScreen             ; Clear the screen for Player 1
    call DisplayTitle            ; Display game title

    call GetPlayerInput          ; Get word and hint from Player 1 (word hidden)
    call InitializeMultiplayerGame ; Initialize game state and hidden word

    call ClearScreen             ; Clear screen before Player 2 begins guessing
    call DisplayTitle            ; Display title again for Player 2

    call GameLoop                ; Start the guessing loop for multiplayer
    ret                          ; Return when game ends
MultiplayerGame ENDP

; ---------------------------------------------------------
; GameLoop - Main game loop for both single and multiplayer
; ---------------------------------------------------------
GameLoop PROC
GameMainLoop:
    call ClearScreen             ; Clear screen before updating game state
    call DisplayTitle            ; Show the game title

    call DisplayHiddenWord       ; Show current progress of guessed word
    call DisplayHint             ; Show the hint for the word
    call Crlf                    ; New line
    call DisplayHangman          ; Show hangman ASCII art based on mistakes
    call Crlf                    ; New line
    call DisplayAlphabet         ; Show letters with used/unused coloring
    call Crlf                    ; New line

    mov edx, OFFSET triesLeftMsg ; Display "Tries left: "
    call WriteString
    movzx eax, triesRemaining    ; Load remaining tries into EAX
    call WriteDec                ; Display number of tries
    call Crlf                    ; New line

    mov eax, white_color         ; Reset text color to white
    call SetTextColor

    call CheckWinCondition       ; Check if player has guessed all letters
    jz WinGame                   ; If ZF=1, the player won

    cmp triesRemaining, 0        ; Check if player has no tries left
    je LoseGame                  ; If yes, jump to lose condition

    call GetUserGuess            ; Get a letter guess from the player
    call ProcessGuess            ; Check if it's correct and update state

    jmp GameMainLoop             ; Loop back to update and continue game

WinGame:
    call Crlf                    ; New line
    mov edx, OFFSET winMsg       ; Display win message
    call WriteString
    call Crlf                    ; New line
    call RevealWord              ; Reveal the full word to the player
    ret                          ; Return from GameLoop

LoseGame:
    call Crlf                    ; New line
    mov edx, OFFSET loseMsg      ; Display lose message
    call WriteString
    call Crlf                    ; New line
    call RevealWord              ; Reveal the full word to the player
    ret                          ; Return from GameLoop
GameLoop ENDP
... (previous content remains unchanged) ...

; ---------------------------------------------------------
; GetDifficultyLevel - Gets difficulty from user (1-3)
; ---------------------------------------------------------
GetDifficultyLevel PROC
    mov edx, OFFSET difficultyMsg ; Load the message to prompt difficulty selection
    call WriteString              ; Print the message to the screen

GetDifficultyInput:
    call ReadDec                  ; Read a decimal input from the user into EAX

    ; Validate input range (should be 1, 2, or 3)
    cmp eax, 1
    jl InvalidDifficulty          ; If less than 1, invalid
    cmp eax, 3
    jg InvalidDifficulty          ; If greater than 3, invalid

    mov difficultyLevel, al       ; Store the valid difficulty choice in difficultyLevel
    ret                           ; Return from procedure

InvalidDifficulty:
    mov edx, OFFSET invalidInputMsg ; Load and print the invalid input message
    call WriteString
    call Crlf                     ; New line
    jmp GetDifficultyInput        ; Loop again until valid input is entered
GetDifficultyLevel ENDP

; ---------------------------------------------------------
; InitializeGameState - Initializes game state for single player
; ---------------------------------------------------------
InitializeGameState PROC
    mov triesRemaining, MAX_TRIES ; Set allowed tries to the defined maximum (6)

    ; Clear the used letters array (26 letters total)
    mov ecx, 26                  ; Counter for 26 letters A-Z
    mov edi, OFFSET usedLetters ; Point EDI to start of usedLetters array
    mov al, 0                   ; Value to store (0 = not used)
    rep stosb                   ; Store AL into 26 bytes at usedLetters

    ret                          ; Return from procedure
InitializeGameState ENDP

; ---------------------------------------------------------
; InitializeMultiplayerGame - Initializes game state and builds hidden word
; ---------------------------------------------------------
InitializeMultiplayerGame PROC
    mov triesRemaining, MAX_TRIES ; Reset tries for multiplayer mode

    ; Clear the used letters array
    mov ecx, 26
    mov edi, OFFSET usedLetters
    mov al, 0
    rep stosb

    ; Create hiddenWord version (underscores replacing letters)
    mov esi, OFFSET currentWord  ; Source: original word
    mov edi, OFFSET hiddenWord   ; Destination: hidden word with underscores
    mov ecx, 0                   ; Index counter

HiddenWordLoop:
    mov al, [esi + ecx]          ; Read current character from original word
    cmp al, 0
    je HiddenWordDone            ; If null terminator reached, end loop

    mov BYTE PTR [edi + ecx], '_' ; Replace with underscore
    inc ecx                      ; Move to next character
    jmp HiddenWordLoop

HiddenWordDone:
    mov BYTE PTR [edi + ecx], 0  ; Null-terminate the hidden word string
    mov wordLength, ecx          ; Store length of the word

    ret
InitializeMultiplayerGame ENDP
... (previous content remains unchanged) ...

; ---------------------------------------------------------
; SelectRandomWord - Selects random word based on difficulty
; ---------------------------------------------------------
SelectRandomWord PROC
    LOCAL wordListPtr:DWORD, wordCount:DWORD, randomIndex:DWORD

    ; Determine which word list to use based on difficulty
    movzx eax, difficultyLevel   ; Load difficulty level into EAX (zero-extended)
    cmp al, 1
    je SelectEasy                ; Jump if Easy
    cmp al, 2
    je SelectMedium              ; Jump if Medium
    jmp SelectHard               ; Otherwise, assume Hard

SelectEasy:
    mov wordListPtr, OFFSET easyWords ; Point to easyWords list
    mov wordCount, EASY_MAX_WORDS     ; Set number of words to 5
    jmp GenerateRandomIndex

SelectMedium:
    mov wordListPtr, OFFSET mediumWords ; Point to mediumWords list
    mov wordCount, MED_MAX_WORDS        ; Set number of words to 5
    jmp GenerateRandomIndex

SelectHard:
    mov wordListPtr, OFFSET hardWords ; Point to hardWords list
    mov wordCount, HARD_MAX_WORDS     ; Set number of words to 5

GenerateRandomIndex:
    mov eax, wordCount             ; Set upper limit for random range
    call RandomRange               ; Generate random index in EAX
    mov randomIndex, eax           ; Store random index

    ; Traverse the word list to the randomly selected entry
    mov esi, wordListPtr           ; ESI points to start of the word list
    mov ecx, 0                     ; Word counter

FindWord:
    cmp ecx, randomIndex
    je WordFound                  ; Jump when random index matches

    ; Skip current word (up to null terminator)
SkipWord:
    cmp BYTE PTR [esi], 0
    je FoundWordEnd               ; End of word
    inc esi
    jmp SkipWord

FoundWordEnd:
    inc esi                       ; Move past null terminator

    ; Skip the hint for this word
SkipHint:
    cmp BYTE PTR [esi], 0
    je FoundHintEnd
    inc esi
    jmp SkipHint

FoundHintEnd:
    inc esi                       ; Move past null terminator of hint
    inc ecx                       ; Increment word count index
    jmp FindWord

WordFound:
    ; ESI now points to the selected word
    mov edi, OFFSET currentWord   ; Destination buffer for the word
    call CopyString               ; Copy word to currentWord buffer

    push esi                      ; Save position in word list
    mov esi, OFFSET currentWord   ; Point to copied word
    call String_Length            ; Get length of the word
    mov wordLength, eax           ; Store length in wordLength
    pop esi                       ; Restore ESI to point after word

    ; Skip to the hint (after null terminator)
FindHintStart:
    cmp BYTE PTR [esi], 0
    je HintFound
    inc esi
    jmp FindHintStart

HintFound:
    inc esi                       ; Move to hint string
    mov edi, OFFSET wordHint      ; Destination buffer for hint
    call CopyString               ; Copy hint to wordHint

    call InitializeHiddenWord     ; Generate hidden word (underscores)
    ret
SelectRandomWord ENDP

; ---------------------------------------------------------
; InitializeHiddenWord - Creates the hidden version of word
; ---------------------------------------------------------
InitializeHiddenWord PROC
    mov esi, OFFSET currentWord   ; Source: original word
    mov edi, OFFSET hiddenWord    ; Destination: hidden word with underscores
    mov ecx, 0                    ; Index counter

HiddenWordLoop:
    mov al, [esi + ecx]           ; Get character from current word
    cmp al, 0
    je HiddenWordDone             ; Stop if end of string

    mov BYTE PTR [edi + ecx], '_' ; Replace letter with underscore
    inc ecx                       ; Move to next letter
    jmp HiddenWordLoop

HiddenWordDone:
    mov BYTE PTR [edi + ecx], 0   ; Null-terminate the hidden word string
    ret
InitializeHiddenWord ENDP
... (previous content remains unchanged) ...

; ---------------------------------------------------------
; CopyString - Copies string from ESI to EDI (null-terminated)
; ---------------------------------------------------------
CopyString PROC
    mov ecx, 0                   ; Initialize counter

CopyLoop:
    mov al, [esi + ecx]          ; Load character from source string
    mov [edi + ecx], al          ; Copy character to destination
    cmp al, 0                    ; Check if end of string (null terminator)
    je CopyDone                  ; If yes, stop copying
    inc ecx                      ; Move to next character
    jmp CopyLoop                 ; Repeat for next character

CopyDone:
    ret                          ; Return when copying is done
CopyString ENDP

; ---------------------------------------------------------
; GetPlayerInput - Gets word and hint from Player 1
; ---------------------------------------------------------
GetPlayerInput PROC
    mov edx, OFFSET wordPrompt   ; Message: "Player 1, enter a word:"
    call WriteString             ; Display prompt

    call HideWordInput           ; Read input without displaying actual letters (masked)

    ; Copy the input (hidden word) into currentWord buffer
    mov esi, OFFSET inputBuffer  ; Source: inputBuffer
    mov edi, OFFSET currentWord  ; Destination: currentWord
    call CopyString

    call String_Length           ; Calculate and store word length
    mov wordLength, eax          ; Save word length for later use

    call Crlf                    ; Print new line

    mov edx, OFFSET hintPrompt   ; Message: "Enter Hint:"
    call WriteString             ; Prompt for hint input

    mov edx, OFFSET inputBuffer  ; Use inputBuffer for reading hint
    mov ecx, WORD_SIZE           ; Set buffer size limit
    call ReadString              ; Read hint from user input

    ; Convert hint to uppercase (loop through each character)
    mov ecx, eax                 ; EAX has the number of characters read
    mov esi, OFFSET inputBuffer  ; Point to hint string in inputBuffer

ConvertHintLoop:
    mov al, [esi]                ; Load current character
    cmp al, 'a'
    jl SkipHintChar              ; Skip if less than 'a'
    cmp al, 'z'
    jg SkipHintChar              ; Skip if greater than 'z'
    sub al, 32                   ; Convert lowercase to uppercase
    mov [esi], al                ; Store uppercase back

SkipHintChar:
    inc esi                      ; Move to next character
    loop ConvertHintLoop         ; Repeat for all characters

    ; Copy hint to wordHint buffer
    mov esi, OFFSET inputBuffer  ; Source: converted hint
    mov edi, OFFSET wordHint     ; Destination: wordHint
    call CopyString              ; Copy it over

    ret                          ; Return to caller
GetPlayerInput ENDP
... (previous content remains unchanged) ...

; ---------------------------------------------------------
; HideWordInput - Gets input without displaying characters
; ---------------------------------------------------------
HideWordInput PROC
    ; Clear the input buffer
    mov edi, OFFSET inputBuffer  ; Destination buffer
    mov ecx, WORD_SIZE           ; Maximum word size
    mov al, 0                    ; Clear value
    rep stosb                    ; Fill buffer with zeros

    ; Begin reading characters one by one
    mov edi, OFFSET inputBuffer  ; Reset EDI to inputBuffer
    mov ecx, 0                   ; Index counter

InputLoop:
    call ReadChar                ; Read a character into AL

    cmp al, 13                   ; Check for Enter key
    je EndInput                  ; If Enter is pressed, end input

    cmp al, 8                    ; Check for Backspace key
    je HandleBackspace           ; Handle backspace if needed

    cmp ecx, WORD_SIZE - 1       ; Ensure buffer isn't full
    jae InputLoop                ; Skip if buffer is full

    mov [edi + ecx], al          ; Store the character in buffer

    ; Convert lowercase to uppercase
    cmp al, 'a'
    jl SkipConvert
    cmp al, 'z'
    jg SkipConvert
    sub BYTE PTR [edi + ecx], 32 ; Convert to uppercase

SkipConvert:
    push eax
    mov al, '*'                 ; Display asterisk instead of actual letter
    call WriteChar
    pop eax

    inc ecx                     ; Move to next position in buffer
    jmp InputLoop               ; Repeat for next character

HandleBackspace:
    cmp ecx, 0
    je InputLoop                ; Do nothing if buffer is empty

    dec ecx                     ; Move back one character
    mov BYTE PTR [edi + ecx], 0 ; Clear the character

    ; Remove asterisk from screen (simulate backspace)
    push eax
    mov al, 8                   ; Backspace
    call WriteChar
    mov al, ' '                 ; Space to overwrite
    call WriteChar
    mov al, 8                   ; Backspace again to position cursor
    call WriteChar
    pop eax

    jmp InputLoop               ; Continue reading

EndInput:
    mov BYTE PTR [edi + ecx], 0 ; Null-terminate the string
    call Crlf                   ; Move to next line
    ret
HideWordInput ENDP

; ---------------------------------------------------------
; DisplayHiddenWord - Displays hidden word with spaces
; ---------------------------------------------------------
DisplayHiddenWord PROC
    mov ecx, wordLength         ; Load number of letters in the word
    mov esi, OFFSET hiddenWord  ; Point to hiddenWord string

DisplayWordLoop:
    mov al, [esi]               ; Load a character (underscore or guessed letter)
    call WriteChar              ; Display the character
    mov al, ' '                 ; Add a space between letters
    call WriteChar
    inc esi                     ; Move to next letter
    loop DisplayWordLoop        ; Repeat for all letters

    call Crlf                   ; Move to new line
    ret
DisplayHiddenWord ENDP
... (previous content remains unchanged) ...

; ---------------------------------------------------------
; DisplayHint - Shows hint as hint
; ---------------------------------------------------------
DisplayHint PROC
    mov eax, hint_color         ; Set text color to hint color (dark cyan)
    call SetTextColor           ; Apply the color

    mov edx, OFFSET hintIsMsg   ; Load "Hint: " label
    call WriteString            ; Display label

    mov edx, OFFSET wordHint    ; Load the actual hint string
    call WriteString            ; Display the hint

    call Crlf                   ; New line for spacing
    call Crlf                   ; Another line for better readability

    mov eax, white_color        ; Reset text color to white
    call SetTextColor
    ret
DisplayHint ENDP

; ---------------------------------------------------------
; DisplayAlphabet - Displays alphabet with colored letters
; ---------------------------------------------------------
DisplayAlphabet PROC
    mov ecx, 26                 ; We will display 26 letters (A-Z)
    mov ebx, 0                  ; Index to track letters

AlphabetLoop:
    movzx eax, usedLetters[ebx] ; Get usage status of letter at index
    cmp eax, 1
    je LetterUsed               ; If used, go display in gray

    mov eax, white_color        ; If not used, set white color
    call SetTextColor
    jmp DisplayLetter

LetterUsed:
    mov eax, gray_color         ; Set gray color if letter has been used
    call SetTextColor

DisplayLetter:
    mov al, 'A'
    add al, bl                  ; Convert index to corresponding ASCII letter
    call WriteChar              ; Print the letter
    mov al, ' '                 ; Print space after letter
    call WriteChar

    inc ebx                     ; Move to next letter
    loop AlphabetLoop           ; Loop until all letters are printed

    mov eax, white_color        ; Reset text color
    call SetTextColor
    call Crlf                   ; New line after alphabet
    ret
DisplayAlphabet ENDP

; ---------------------------------------------------------
; DisplayHelpScreen - Displays game rules
; ---------------------------------------------------------
DisplayHelpScreen PROC
    call ClearScreen            ; Clear the screen first
    call DisplayTitle           ; Display the game title

    mov eax, menu_color         ; Set color for the instructions text
    call SetTextColor

    mov edx, OFFSET instructionMsg ; Load and display the instruction text
    call WriteString

    mov eax, white_color        ; Reset text color to white
    call SetTextColor

    call ReadChar               ; Wait for any key press to continue
    ret
DisplayHelpScreen ENDP
... (previous content remains unchanged) ...

; ---------------------------------------------------------
; DisplayHangman - Displays the hangman ASCII art
; ---------------------------------------------------------
DisplayHangman PROC
    mov eax, MAX_TRIES          ; Load the maximum number of tries (6)
    movzx ebx, triesRemaining   ; Load current remaining tries into EBX (zero-extended)
    sub eax, ebx                ; Calculate which stage to display (incorrect guesses)

    ; Ensure the value is within bounds (0-6)
    cmp eax, 0
    jl UseFirstFigure           ; If less than 0, use first stage
    cmp eax, 6
    jg UseLastFigure            ; If more than 6, use last stage
    jmp DisplayFigure

UseFirstFigure:
    mov eax, 0                  ; Force to use first figure
    jmp DisplayFigure

UseLastFigure:
    mov eax, 6                  ; Force to use last figure

DisplayFigure:
    mov edx, hangmanStages[eax*4] ; Multiply index by 4 to get pointer to figure
    call WriteString            ; Display selected ASCII art figure
    call Crlf                   ; New line after figure
    ret
DisplayHangman ENDP

; ---------------------------------------------------------
; GetUserGuess - Gets a letter guess from the user
; ---------------------------------------------------------
GetUserGuess PROC
    mov eax, prompt_color       ; Set text color to prompt color (white)
    call SetTextColor

    mov edx, OFFSET enterGuessMsg ; Load prompt message: "Enter a letter:"
    call WriteString

    mov eax, white_color        ; Reset text color to normal white
    call SetTextColor

GetGuessInput:
    call ReadChar               ; Read character input into AL
    call WriteChar              ; Echo the character to screen
    call Crlf                   ; New line

    ; Convert lowercase input to uppercase
    cmp al, 'a'
    jl CheckValidLetter         ; Skip conversion if below 'a'
    cmp al, 'z'
    jg GetGuessInput            ; Reject if above 'z'
    sub al, 32                  ; Convert to uppercase (A-Z)

CheckValidLetter:
    cmp al, 'A'
    jl GetGuessInput            ; Reject if not a letter
    cmp al, 'Z'
    jg GetGuessInput            ; Reject if not a letter

    mov inputBuffer, al         ; Store valid guess into input buffer
    ret
GetUserGuess ENDP
... (previous content remains unchanged) ...

; ---------------------------------------------------------
; ProcessGuess - Processes user's letter guess
; ---------------------------------------------------------
ProcessGuess PROC
    mov al, inputBuffer         ; Get the guessed letter

    movzx ebx, al               ; Convert character to integer value
    sub ebx, 'A'                ; Compute index into usedLetters array (0-25)

    cmp usedLetters[ebx], 1     ; Check if letter was already used
    je AlreadyGuessed           ; If yes, notify user

    mov usedLetters[ebx], 1     ; Mark letter as used

    call CheckLetterInWord      ; Check if letter exists in currentWord
    jnz LetterNotFound          ; If not found, jump to wrong guess logic

    ; Letter found
    mov edx, OFFSET correctGuessMsg ; Message: "Good guess!"
    call WriteString
    call Crlf                   ; New line
    call WaitForKey             ; Pause until user presses a key
    ret                         ; Return from procedure

AlreadyGuessed:
    mov edx, OFFSET usedLetterMsg ; Message: "You already guessed that letter!"
    call WriteString
    call Crlf                   ; New line
    call WaitForKey             ; Wait for user input
    ret                         ; Return

LetterNotFound:
    dec triesRemaining          ; Decrease number of tries left

    mov edx, OFFSET wrongGuessMsg ; Message: "Wrong guess!"
    call WriteString
    call Crlf                   ; New line
    call WaitForKey             ; Pause
    ret
ProcessGuess ENDP

; ---------------------------------------------------------
; CheckLetterInWord - Checks if letter is in the word
; Updates hiddenWord if found
; Returns ZF=1 if found, ZF=0 if not found
; ---------------------------------------------------------
CheckLetterInWord PROC
    LOCAL letterFound:BYTE

    mov letterFound, 0          ; Assume letter not found initially
    mov al, inputBuffer         ; Letter to search for

    mov ecx, wordLength         ; Loop through all characters in currentWord
    mov esi, OFFSET currentWord ; Pointer to original word
    mov edi, OFFSET hiddenWord  ; Pointer to the display version (with underscores)

CheckLoop:
    cmp [esi], al               ; Compare input letter to current character
    jne NextChar                ; If not equal, move to next character

    mov [edi], al               ; If match, update underscore with letter
    mov letterFound, 1          ; Flag that letter was found

NextChar:
    inc esi                     ; Move to next character in currentWord
    inc edi                     ; Move to next position in hiddenWord
    loop CheckLoop              ; Continue until all letters checked

    cmp letterFound, 1          ; Set flags based on whether letter was found
    ret
CheckLetterInWord ENDP
... (previous content remains unchanged) ...

; ---------------------------------------------------------
; CheckWinCondition - Checks if all letters are guessed
; Returns ZF=1 if won, ZF=0 if not won
; ---------------------------------------------------------
CheckWinCondition PROC
    mov ecx, wordLength         ; Load the length of the word
    mov esi, OFFSET hiddenWord  ; Point to the hiddenWord array

CheckLoop:
    cmp BYTE PTR [esi], '_'     ; Check if any letter is still hidden
    je NotWon                   ; If any underscore remains, not won
    inc esi                     ; Move to next character
    loop CheckLoop              ; Repeat for each character

    ; If no underscores found, player has won
    mov al, 0                   ; Dummy operation to set ZF = 1
    cmp al, 0                   ; ZF will be set
    ret

NotWon:
    mov al, 0                   ; Dummy operation to clear ZF
    cmp al, 1                   ; ZF will be cleared (not won)
    ret
CheckWinCondition ENDP

; ---------------------------------------------------------
; RevealWord - Shows the complete word
; ---------------------------------------------------------
RevealWord PROC
    mov edx, OFFSET wordWasMsg  ; Message: "The word was:"
    call WriteString
    mov edx, OFFSET currentWord ; Load the actual word
    call WriteString
    call Crlf                   ; New line
    ret
RevealWord ENDP

; ---------------------------------------------------------
; WaitForKey - Waits for any key press
; ---------------------------------------------------------
WaitForKey PROC
    call ReadChar               ; Waits for any key to be pressed
    ret
WaitForKey ENDP

; ---------------------------------------------------------
; ClearScreen - Clears the console screen
; ---------------------------------------------------------
ClearScreen PROC
    mov eax, 0                  ; Load color code 0 (black)
    call ClrScr                 ; Clear screen using Irvine32 library
    ret
ClearScreen ENDP

; ---------------------------------------------------------
; String_Length - Calculates string length
; Input: ESI = string pointer
; Output: EAX = length
; ---------------------------------------------------------
String_Length PROC
    push esi                    ; Save ESI to restore later
    mov eax, 0                  ; Clear EAX to count length

LengthLoop:
    cmp BYTE PTR [esi], 0       ; Check for null terminator
    je LengthDone               ; If found, end loop
    inc esi                     ; Move to next character
    inc eax                     ; Increment length counter
    jmp LengthLoop              ; Repeat

LengthDone:
    pop esi                     ; Restore original ESI
    ret
String_Length ENDP


