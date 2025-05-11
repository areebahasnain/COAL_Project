; I'll begin commenting your Hangman game in Assembly.
; Since it's a very large file, I'll proceed in sections.
; Let's start with the `.data` section.

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

Let me know if you want me to continue commenting the `.code` section as well — it's large, so I can break it into manageable parts with clear explanations. Would you like me to continue?
