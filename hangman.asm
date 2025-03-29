TITLE Hangman Game (hangman.asm)

INCLUDE Irvine32.inc

.data
; ---------------------- Game Constants ----------------------
WORD_SIZE = 20            ; Maximum word length
MAX_TRIES = 6             ; Maximum incorrect guesses allowed
EASY_MAX_WORDS = 5        ; Number of words in easy category
MED_MAX_WORDS = 5         ; Number of words in medium category
HARD_MAX_WORDS = 5        ; Number of words in hard category

; ---------------------- Game Messages ----------------------
titleMsg        BYTE "===== HANGMAN GAME =====", 0
mainMenuMsg     BYTE "1. Single Player", 0dh, 0ah
                BYTE "2. Multiplayer", 0dh, 0ah
                BYTE "3. Game Instructions", 0dh, 0ah
                BYTE "4. Exit", 0dh, 0ah
                BYTE "Enter your choice (1-4): ", 0
difficultyMsg   BYTE "Select difficulty:", 0dh, 0ah
                BYTE "1. Easy", 0dh, 0ah
                BYTE "2. Medium", 0dh, 0ah
                BYTE "3. Hard", 0dh, 0ah
                BYTE "Enter your choice (1-4): ", 0
instructionMsg  BYTE "===== HANGMAN GAME RULES =====", 0dh, 0ah, 0dh, 0ah
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
wordPrompt      BYTE "Player 1, enter a word: ", 0
hintPrompt     BYTE "Enter Hint: ", 0
enterGuessMsg   BYTE "Enter a letter: ", 0
usedLetterMsg   BYTE "You already guessed that letter!", 0
correctGuessMsg BYTE "Good guess!", 0
wrongGuessMsg   BYTE "Wrong guess!", 0
winMsg          BYTE "Congratulations! You won!", 0
loseMsg         BYTE "Game over! You lost!", 0
wordWasMsg      BYTE "The word was: ", 0
hintIsMsg       BYTE "Hint: ", 0
triesLeftMsg    BYTE "Tries left: ", 0
playAgainMsg    BYTE "Play again? (y/n): ", 0
invalidInputMsg BYTE "Invalid input! Try again.", 0

; ---------------------- Word Lists with Hints ----------------------
; Format: word, 0, hint, 0
easyWords       BYTE "APPLE", 0, "FOOD", 0
                BYTE "MARIO", 0, "GAME", 0
                BYTE "PIZZA", 0, "FOOD", 0
                BYTE "TIGER", 0, "ANIMAL", 0
                BYTE "CHAIR", 0, "FURNITURE", 0

mediumWords     BYTE "COMPUTER", 0, "TECHNOLOGY", 0
                BYTE "ELEPHANT", 0, "ANIMAL", 0
                BYTE "SANDWICH", 0, "FOOD", 0
                BYTE "MOUNTAIN", 0, "GEOGRAPHY", 0
                BYTE "BASEBALL", 0, "SPORT", 0

hardWords       BYTE "ALGORITHM", 0, "COMPUTING", 0
                BYTE "PSYCHOLOGY", 0, "SCIENCE", 0
                BYTE "HELICOPTER", 0, "VEHICLE", 0
                BYTE "MISSISSIPPI", 0, "GEOGRAPHY", 0
                BYTE "PNEUMONIA", 0, "DISEASE", 0

; ---------------------- Game State Variables ----------------------
currentWord     BYTE WORD_SIZE DUP(0)      ; Current word to guess
wordHint       BYTE WORD_SIZE DUP(0)      ; Hint for the current word
hiddenWord      BYTE WORD_SIZE DUP(0)      ; Word with _ for hidden letters
usedLetters     BYTE 26 DUP(0)             ; Track guessed letters (0=unused, 1=used)
triesRemaining  BYTE ?                     ; Number of tries left
wordLength      DWORD ?                    ; Length of current word
gameMode        BYTE ?                     ; 1=Single player, 2=Multiplayer
difficultyLevel BYTE ?                     ; 1=Easy, 2=Medium, 3=Hard (Single player only)

; ---------------------- Buffer Variables ----------------------
inputBuffer     BYTE WORD_SIZE DUP(0)      ; Buffer for user input
tempBuffer      BYTE WORD_SIZE DUP(0)      ; Temporary buffer

; ---------------------- Hangman ASCII Art Stages ----------------------
hangman0 BYTE "  +---+", 0dh, 0ah
         BYTE "  |   |", 0dh, 0ah
         BYTE "      |", 0dh, 0ah
         BYTE "      |", 0dh, 0ah
         BYTE "      |", 0dh, 0ah
         BYTE "      |", 0dh, 0ah
         BYTE "=========", 0

hangman1 BYTE "  +---+", 0dh, 0ah
         BYTE "  |   |", 0dh, 0ah
         BYTE "  O   |", 0dh, 0ah
         BYTE "      |", 0dh, 0ah
         BYTE "      |", 0dh, 0ah
         BYTE "      |", 0dh, 0ah
         BYTE "=========", 0

hangman2 BYTE "  +---+", 0dh, 0ah
         BYTE "  |   |", 0dh, 0ah
         BYTE "  O   |", 0dh, 0ah
         BYTE "  |   |", 0dh, 0ah
         BYTE "      |", 0dh, 0ah
         BYTE "      |", 0dh, 0ah
         BYTE "=========", 0

hangman3 BYTE "  +---+", 0dh, 0ah
         BYTE "  |   |", 0dh, 0ah
         BYTE "  O   |", 0dh, 0ah
         BYTE " /|   |", 0dh, 0ah
         BYTE "      |", 0dh, 0ah
         BYTE "      |", 0dh, 0ah
         BYTE "=========", 0

hangman4 BYTE "  +---+", 0dh, 0ah
         BYTE "  |   |", 0dh, 0ah
         BYTE "  O   |", 0dh, 0ah
         BYTE " /|\  |", 0dh, 0ah
         BYTE "      |", 0dh, 0ah
         BYTE "      |", 0dh, 0ah
         BYTE "=========", 0

hangman5 BYTE "  +---+", 0dh, 0ah
         BYTE "  |   |", 0dh, 0ah
         BYTE "  O   |", 0dh, 0ah
         BYTE " /|\  |", 0dh, 0ah
         BYTE " /    |", 0dh, 0ah
         BYTE "      |", 0dh, 0ah
         BYTE "=========", 0

hangman6 BYTE "  +---+", 0dh, 0ah
         BYTE "  |   |", 0dh, 0ah
         BYTE "  O   |", 0dh, 0ah
         BYTE " /|\  |", 0dh, 0ah
         BYTE " / \  |", 0dh, 0ah
         BYTE "      |", 0dh, 0ah
         BYTE "=========", 0

; Table of pointers to hangman stages
hangmanStages DWORD hangman0, hangman1, hangman2, hangman3, hangman4, hangman5, hangman6

; ---------------------- Color Constants ----------------------
white_color = white + (black * 16)
gray_color = gray + (black * 16)
title_color = 0Dh      ; Bright Magenta
menu_color = 07h       ; Light Grey
hint_color = 03h       ; Dark Cyan
prompt_color = 0Fh     ; White

.code
main PROC
    call Randomize               ; Initialize random number generator
    
MainGameLoop:
    call ClearScreen
    call DisplayTitle
    call DisplayMainMenu
    call GetMenuChoice
    
    ; Process menu choice
    cmp al, 1
    je SinglePlayerMode
    cmp al, 2
    je MultiplayerMode
    cmp al, 3
    je ShowInstructions
    cmp al, 4
    je ExitGame
    
    ; Invalid choice
    mov edx, OFFSET invalidInputMsg
    call WriteString
    call Crlf
    call WaitForKey
    jmp MainGameLoop
    
SinglePlayerMode:
    mov gameMode, 1
    call SinglePlayerGame
    jmp CheckPlayAgain
    
MultiplayerMode:
    mov gameMode, 2
    call MultiplayerGame
    jmp CheckPlayAgain
    
CheckPlayAgain:
    call Crlf
    mov edx, OFFSET playAgainMsg
    call WriteString
    call ReadChar
    call WriteChar                ; Echo character
    call Crlf

ShowInstructions:
    call DisplayHelpScreen
    jmp MainGameLoop
    
    ; Check if user wants to play again
    cmp al, 'y'
    je MainGameLoop
    cmp al, 'Y'
    je MainGameLoop
    
ExitGame:
    exit
main ENDP

; ---------------------------------------------------------
; DisplayTitle - Displays the game title
; ---------------------------------------------------------
DisplayTitle PROC
    mov eax, title_color
    call SetTextColor
    call Crlf
    mov edx, OFFSET titleMsg
    call WriteString
    call Crlf
    call Crlf
    
    ; Reset color
    mov eax, white_color
    call SetTextColor
    ret
DisplayTitle ENDP

; ---------------------------------------------------------
; DisplayMainMenu - Displays the main menu options
; ---------------------------------------------------------
DisplayMainMenu PROC
    ; Set menu color
    mov eax, menu_color
    call SetTextColor
    
    ; Display original menu items
    mov edx, OFFSET mainMenuMsg
    call WriteString

    ; Reset color
    mov eax, white_color
    call SetTextColor
    ret
DisplayMainMenu ENDP

; ---------------------------------------------------------
; GetMenuChoice - Gets menu choice from the user (1-4)
; Returns: AL = menu choice
; ---------------------------------------------------------
GetMenuChoice PROC
    call ReadDec
    ret
GetMenuChoice ENDP

; ---------------------------------------------------------
; SinglePlayerGame - Handles single player game logic
; ---------------------------------------------------------
SinglePlayerGame PROC
    call ClearScreen
    call DisplayTitle
    
    ; Get difficulty level
    call GetDifficultyLevel
    
    ; Initialize game based on difficulty
    call InitializeGameState
    call SelectRandomWord
    
    ; Main game loop
    call GameLoop
    
    ret
SinglePlayerGame ENDP

; ---------------------------------------------------------
; MultiplayerGame - Handles multiplayer game logic
; ---------------------------------------------------------
MultiplayerGame PROC
    call ClearScreen
    call DisplayTitle
    
    ; Get word and hint from Player 1
    call GetPlayerInput
    
    ; Initialize game state
    call InitializeMultiplayerGame
    
    ; Clear screen for Player 2
    call ClearScreen
    call DisplayTitle
    
    ; Main game loop
    call GameLoop
    
    ret
MultiplayerGame ENDP

; ---------------------------------------------------------
; GameLoop - Main game loop for both single and multiplayer
; ---------------------------------------------------------
GameLoop PROC
GameMainLoop:
    call ClearScreen
    call DisplayTitle
    
    ; Display current game state
    call DisplayHiddenWord
    call DisplayHint
    call Crlf
    call DisplayHangman
    call Crlf
    call DisplayAlphabet
    call Crlf
    
    ; Display tries remaining
    mov edx, OFFSET triesLeftMsg
    call WriteString
    movzx eax, triesRemaining
    call WriteDec
    call Crlf

    ; Reset color
    mov eax, white_color
    call SetTextColor
    
    ; Check win condition
    call CheckWinCondition
    jz WinGame
    
    ; Check lose condition
    cmp triesRemaining, 0
    je LoseGame
    
    ; Get user guess
    call GetUserGuess
    
    ; Process guess
    call ProcessGuess
    
    jmp GameMainLoop
    
WinGame:
    call Crlf
    mov edx, OFFSET winMsg
    call WriteString
    call Crlf
    call RevealWord
    ret
    
LoseGame:
    call Crlf
    mov edx, OFFSET loseMsg
    call WriteString
    call Crlf
    call RevealWord
    ret
GameLoop ENDP

; ---------------------------------------------------------
; GetDifficultyLevel - Gets difficulty from user (1-3)
; ---------------------------------------------------------
GetDifficultyLevel PROC
    mov edx, OFFSET difficultyMsg
    call WriteString
    
GetDifficultyInput:
    call ReadDec
    
    ; Validate input
    cmp eax, 1
    jl InvalidDifficulty
    cmp eax, 3
    jg InvalidDifficulty
    
    ; Store difficulty level
    mov difficultyLevel, al
    ret
    
InvalidDifficulty:
    mov edx, OFFSET invalidInputMsg
    call WriteString
    call Crlf
    jmp GetDifficultyInput
GetDifficultyLevel ENDP

; ---------------------------------------------------------
; InitializeGameState - Initializes game state for single player
; ---------------------------------------------------------
InitializeGameState PROC
    ; Set tries based on difficulty
    mov triesRemaining, MAX_TRIES
    
    ; Initialize used letters array
    mov ecx, 26
    mov edi, OFFSET usedLetters
    mov al, 0
    rep stosb
    
    ret
InitializeGameState ENDP

; ---------------------------------------------------------
; InitializeMultiplayerGame - Initializes game for multiplayer
; ---------------------------------------------------------
InitializeMultiplayerGame PROC
    ; Set tries
    mov triesRemaining, MAX_TRIES
    
    ; Initialize used letters array
    mov ecx, 26
    mov edi, OFFSET usedLetters
    mov al, 0
    rep stosb
    
    ; Initialize hidden word
    mov esi, OFFSET currentWord
    mov edi, OFFSET hiddenWord
    mov ecx, 0
    
HiddenWordLoop:
    mov al, [esi + ecx]
    cmp al, 0
    je HiddenWordDone
    
    ; Replace letter with underscore
    mov BYTE PTR [edi + ecx], '_'
    inc ecx
    jmp HiddenWordLoop
    
HiddenWordDone:
    mov BYTE PTR [edi + ecx], 0
    mov wordLength, ecx
    
    ret
InitializeMultiplayerGame ENDP

; ---------------------------------------------------------
; SelectRandomWord - Selects random word based on difficulty
; ---------------------------------------------------------
SelectRandomWord PROC
    LOCAL wordListPtr:DWORD, wordCount:DWORD, randomIndex:DWORD
    
    ; Determine word list based on difficulty
    movzx eax, difficultyLevel
    cmp al, 1
    je SelectEasy
    cmp al, 2
    je SelectMedium
    jmp SelectHard
    
SelectEasy:
    mov wordListPtr, OFFSET easyWords
    mov wordCount, EASY_MAX_WORDS
    jmp GenerateRandomIndex
    
SelectMedium:
    mov wordListPtr, OFFSET mediumWords
    mov wordCount, MED_MAX_WORDS
    jmp GenerateRandomIndex
    
SelectHard:
    mov wordListPtr, OFFSET hardWords
    mov wordCount, HARD_MAX_WORDS
    
GenerateRandomIndex:
    ; Generate random index
    mov eax, wordCount
    call RandomRange     ; EAX = random number between 0 and (wordCount-1)
    mov randomIndex, eax
    
    ; Navigate through the list to find the selected word
    mov esi, wordListPtr
    mov ecx, 0          ; Current word counter
    
FindWord:
    cmp ecx, randomIndex
    je WordFound        ; Found our target word index
    
    ; Skip current word (find null terminator)
SkipWord:
    cmp BYTE PTR [esi], 0
    je FoundWordEnd
    inc esi
    jmp SkipWord
    
FoundWordEnd:
    inc esi             ; Move past null terminator
    
    ; Skip hint (find null terminator)
SkipHint:
    cmp BYTE PTR [esi], 0
    je FoundHintEnd
    inc esi
    jmp SkipHint
    
FoundHintEnd:
    inc esi             ; Move past null terminator
    inc ecx             ; Increment word counter
    jmp FindWord
    
WordFound:
    ; ESI now points to the selected word
    ; Copy word to currentWord
    mov edi, OFFSET currentWord
    call CopyString
    
    ; Calculate word length
    push esi            ; Save ESI
    mov esi, OFFSET currentWord
    call String_Length
    mov wordLength, eax
    pop esi             ; Restore ESI
    
    ; Find hint (skip to null terminator)
    push esi            ; Save word pointer
FindHintStart:
    cmp BYTE PTR [esi], 0
    je HintFound
    inc esi
    jmp FindHintStart
    
HintFound:
    inc esi             ; Move past null terminator to hint
    
    ; Copy hint to wordHint
    mov edi, OFFSET wordHint
    call CopyString
    
    ; Initialize hidden word
    call InitializeHiddenWord
    
    ret
SelectRandomWord ENDP

; ---------------------------------------------------------
; InitializeHiddenWord - Creates the hidden version of word
; ---------------------------------------------------------
InitializeHiddenWord PROC
    mov esi, OFFSET currentWord
    mov edi, OFFSET hiddenWord
    mov ecx, 0
    
HiddenWordLoop:
    mov al, [esi + ecx]
    cmp al, 0
    je HiddenWordDone
    
    ; Replace letter with underscore
    mov BYTE PTR [edi + ecx], '_'
    inc ecx
    jmp HiddenWordLoop
    
HiddenWordDone:
    mov BYTE PTR [edi + ecx], 0
    
    ret
InitializeHiddenWord ENDP


; ---------------------------------------------------------
; CopyString - Copies string from ESI to EDI (null-terminated)
; ---------------------------------------------------------
CopyString PROC
    mov ecx, 0
    
CopyLoop:
    mov al, [esi + ecx]
    mov [edi + ecx], al
    cmp al, 0
    je CopyDone
    inc ecx
    jmp CopyLoop
    
CopyDone:
    ret
CopyString ENDP

; ---------------------------------------------------------
; GetPlayerInput - Gets word and hint from Player 1
; ---------------------------------------------------------
GetPlayerInput PROC
    ; Get word from Player 1
    mov edx, OFFSET wordPrompt
    call WriteString
    
    ; Read word (hiding input)
    call HideWordInput
    
    ; Copy input to currentWord
    mov esi, OFFSET inputBuffer
    mov edi, OFFSET currentWord
    call CopyString
    
    ; Calculate word length
    call String_Length
    mov wordLength, eax
    
    call Crlf
    
    ; Get hint from Player 1
    mov edx, OFFSET hintPrompt
    call WriteString
    
    ; Read hint (visible input)
    mov edx, OFFSET inputBuffer
    mov ecx, WORD_SIZE
    call ReadString
    
    ; Convert to uppercase
    mov ecx, eax
    mov esi, OFFSET inputBuffer
ConvertHintLoop:
    mov al, [esi]
    cmp al, 'a'
    jl SkipHintChar
    cmp al, 'z'
    jg SkipHintChar
    sub al, 32    ; Convert to uppercase
    mov [esi], al
SkipHintChar:
    inc esi
    loop ConvertHintLoop
    
    ; Copy input to wordHint
    mov esi, OFFSET inputBuffer
    mov edi, OFFSET wordHint
    call CopyString
    
    ret
GetPlayerInput ENDP

; ---------------------------------------------------------
; HideWordInput - Gets input without displaying characters
; ---------------------------------------------------------
HideWordInput PROC
    ; Reset buffer
    mov edi, OFFSET inputBuffer
    mov ecx, WORD_SIZE
    mov al, 0
    rep stosb
    
    ; Read characters one by one
    mov edi, OFFSET inputBuffer
    mov ecx, 0
    
InputLoop:
    call ReadChar    ; Get character into AL
    
    ; Check for Enter key
    cmp al, 13       ; Carriage return
    je EndInput
    
    ; Check for backspace
    cmp al, 8        ; Backspace
    je HandleBackspace
    
    ; Check buffer limit
    cmp ecx, WORD_SIZE - 1
    jae InputLoop
    
    ; Store character and display asterisk
    mov [edi + ecx], al
    
    ; Convert to uppercase
    cmp al, 'a'
    jl SkipConvert
    cmp al, 'z'
    jg SkipConvert
    sub BYTE PTR [edi + ecx], 32  ; Convert to uppercase
SkipConvert:
    
    ; Display asterisk
    push eax
    mov al, '*'
    call WriteChar
    pop eax
    
    inc ecx
    jmp InputLoop
    
HandleBackspace:
    ; Only handle backspace if buffer not empty
    cmp ecx, 0
    je InputLoop
    
    ; Delete last character
    dec ecx
    mov BYTE PTR [edi + ecx], 0
    
    ; Erase asterisk on screen
    push eax
    mov al, 8        ; Backspace
    call WriteChar
    mov al, ' '      ; Space to overwrite
    call WriteChar
    mov al, 8        ; Backspace again
    call WriteChar
    pop eax
    
    jmp InputLoop
    
EndInput:
    ; Null terminate the string
    mov BYTE PTR [edi + ecx], 0
    call Crlf
    
    ret
HideWordInput ENDP

; ---------------------------------------------------------
; DisplayHiddenWord - Displays hidden word with spaces
; ---------------------------------------------------------
DisplayHiddenWord PROC
    ; Display current state of word
    mov ecx, wordLength
    mov esi, OFFSET hiddenWord
    
DisplayWordLoop:
    mov al, [esi]
    call WriteChar
    mov al, ' '      ; Space between characters
    call WriteChar
    inc esi
    loop DisplayWordLoop
    
    call Crlf
    ret
DisplayHiddenWord ENDP

; ---------------------------------------------------------
; DisplayHint - Shows hint as hint
; ---------------------------------------------------------
DisplayHint PROC
    mov eax, hint_color
    call SetTextColor
    
    mov edx, OFFSET hintIsMsg
    call WriteString
    mov edx, OFFSET wordHint
    call WriteString
    call Crlf
    call Crlf  ; Add extra line space
    
    ; Reset color
    mov eax, white_color
    call SetTextColor
    ret
DisplayHint ENDP

; ---------------------------------------------------------
; DisplayAlphabet - Displays alphabet with colored letters 
; ---------------------------------------------------------
DisplayAlphabet PROC
    mov ecx, 26      ; 26 letters
    mov ebx, 0       ; Index for usedLetters array
    
AlphabetLoop:
    ; Check if letter was used
    movzx eax, usedLetters[ebx]
    cmp eax, 1
    je LetterUsed
    
    ; Letter not used - display in white
    mov eax, white_color
    call SetTextColor
    jmp DisplayLetter
    
LetterUsed:
    ; Letter used - display in gray
    mov eax, gray_color
    call SetTextColor
    
DisplayLetter:
    ; Calculate and display the letter
    mov al, 'A'
    add al, bl       ; Convert index to ASCII letter
    call WriteChar
    mov al, ' '
    call WriteChar
    
    inc ebx          ; Move to next letter
    loop AlphabetLoop
    
    ; Reset text color
    mov eax, white_color
    call SetTextColor
    call Crlf
    ret
DisplayAlphabet ENDP

; ---------------------------------------------------------
; DisplayHelpScreen - Displays game rules
; ---------------------------------------------------------
DisplayHelpScreen PROC
    call ClearScreen
    call DisplayTitle
    
    ; Display help content
    mov eax, menu_color
    call SetTextColor
    mov edx, OFFSET instructionMsg
    call WriteString
    
    ; Reset color
    mov eax, white_color
    call SetTextColor
    
    ; Wait for key press
    call ReadChar
    ret
DisplayHelpScreen ENDP

; ---------------------------------------------------------
; DisplayHangman - Displays the hangman ASCII art
; ---------------------------------------------------------
DisplayHangman PROC
    ; Calculate which hangman figure to display
    mov eax, MAX_TRIES
    movzx ebx, triesRemaining
    sub eax, ebx
    
    ; Bounds check
    cmp eax, 0
    jl UseFirstFigure
    cmp eax, 6
    jg UseLastFigure
    jmp DisplayFigure
    
UseFirstFigure:
    mov eax, 0
    jmp DisplayFigure
    
UseLastFigure:
    mov eax, 6
    
DisplayFigure:
    ; Get pointer to the appropriate hangman stage
    mov edx, hangmanStages[eax*4]
    call WriteString
    call Crlf
    
    ret
DisplayHangman ENDP

; ---------------------------------------------------------
; GetUserGuess - Gets a letter guess from the user
; ---------------------------------------------------------
GetUserGuess PROC
    mov eax, prompt_color
    call SetTextColor
    mov edx, OFFSET enterGuessMsg
    call WriteString
    
    ; Reset color
    mov eax, white_color
    call SetTextColor
    
GetGuessInput:
    call ReadChar
    call WriteChar   ; Echo the character
    call Crlf
    
    ; Convert to uppercase if lowercase
    cmp al, 'a'
    jl CheckValidLetter
    cmp al, 'z'
    jg GetGuessInput
    sub al, 32       ; Convert to uppercase
    
CheckValidLetter:
    ; Check if it's a letter A-Z
    cmp al, 'A'
    jl GetGuessInput
    cmp al, 'Z'
    jg GetGuessInput
    
    ; Store in input buffer
    mov inputBuffer, al
    
    ret
GetUserGuess ENDP

; ---------------------------------------------------------
; ProcessGuess - Processes user's letter guess
; ---------------------------------------------------------
ProcessGuess PROC
    ; Get the letter
    mov al, inputBuffer
    
    ; Calculate index in usedLetters
    movzx ebx, al
    sub ebx, 'A'
    
    ; Check if letter was already used
    cmp usedLetters[ebx], 1
    je AlreadyGuessed
    
    ; Mark letter as used
    mov usedLetters[ebx], 1
    
    ; Check if letter is in the word
    call CheckLetterInWord
    jnz LetterNotFound
    
    ; Letter found
    mov edx, OFFSET correctGuessMsg
    call WriteString
    call Crlf
    call WaitForKey
    ret
    
AlreadyGuessed:
    mov edx, OFFSET usedLetterMsg
    call WriteString
    call Crlf
    call WaitForKey
    ret
    
LetterNotFound:
    ; Decrement tries
    dec triesRemaining
    
    mov edx, OFFSET wrongGuessMsg
    call WriteString
    call Crlf
    call WaitForKey
    ret
ProcessGuess ENDP

; ---------------------------------------------------------
; CheckLetterInWord - Checks if letter is in the word
; Updates hiddenWord if found
; Returns ZF=1 if found, ZF=0 if not found
; ---------------------------------------------------------
CheckLetterInWord PROC
    LOCAL letterFound:BYTE
    
    ; Initialize found flag
    mov letterFound, 0
    
    ; Get letter to check
    mov al, inputBuffer
    
    ; Check each character in word
    mov ecx, wordLength
    mov esi, OFFSET currentWord
    mov edi, OFFSET hiddenWord
    
CheckLoop:
    ; Compare letter with current character
    cmp [esi], al
    jne NextChar
    
    ; Letter found, update hiddenWord
    mov [edi], al
    mov letterFound, 1
    
NextChar:
    inc esi
    inc edi
    loop CheckLoop
    
    ; Set ZF based on found flag
    cmp letterFound, 1
    
    ret
CheckLetterInWord ENDP

; ---------------------------------------------------------
; CheckWinCondition - Checks if all letters are guessed
; Returns ZF=1 if won, ZF=0 if not won
; ---------------------------------------------------------
CheckWinCondition PROC
    ; Check if hiddenWord still has any underscores
    mov ecx, wordLength
    mov esi, OFFSET hiddenWord
    
CheckLoop:
    cmp BYTE PTR [esi], '_'
    je NotWon         ; Found underscore, not won yet
    inc esi
    loop CheckLoop
    
    ; No underscores found, game is won
    mov al, 0
    cmp al, 0         ; Set ZF=1
    ret
    
NotWon:
    mov al, 0
    cmp al, 1         ; Set ZF=0
    ret
CheckWinCondition ENDP

; ---------------------------------------------------------
; RevealWord - Shows the complete word
; ---------------------------------------------------------
RevealWord PROC
    mov edx, OFFSET wordWasMsg
    call WriteString
    mov edx, OFFSET currentWord
    call WriteString
    call Crlf
    ret
RevealWord ENDP

; ---------------------------------------------------------
; WaitForKey - Waits for any key press
; ---------------------------------------------------------
WaitForKey PROC
    call ReadChar
    ret
WaitForKey ENDP

; ---------------------------------------------------------
; ClearScreen - Clears the console screen
; ---------------------------------------------------------
ClearScreen PROC
    mov eax, 0
    call ClrScr
    ret
ClearScreen ENDP

; ---------------------------------------------------------
; String_Length - Calculates string length
; Input: ESI = string pointer
; Output: EAX = length
; ---------------------------------------------------------
String_Length PROC
    push esi
    mov eax, 0
    
LengthLoop:
    cmp BYTE PTR [esi], 0
    je LengthDone
    inc esi
    inc eax
    jmp LengthLoop
    
LengthDone:
    pop esi
    ret
String_Length ENDP

END main
