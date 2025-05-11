# 🪓 Hangman Game (COAL Project)

A classic Hangman game written in **x86 Assembly Language** using **MASM** and the **Irvine32** library. This project was developed as part of a Computer Organization and Assembly Language (COAL) course.

---

## 🎯 Objective

To implement the Hangman game in low-level x86 assembly to gain a deeper understanding of:

- Memory management
- String operations
- Conditional logic
- I/O operations
- Procedural programming in Assembly

---

## 🛠️ Tools & Environment

| Tool           | Description                                 |
|----------------|---------------------------------------------|
| **Assembler**  | MASM (Microsoft Macro Assembler)            |
| **Library**    | Irvine32.inc                                |
| **OS**         | Windows                                     |
| **Editor**     | Visual Studio / Notepad++ / MASM32 IDE      |

---

## 🕹️ Game Modes

### 🔹 Single Player
- Choose a difficulty level (Easy / Medium / Hard)
- Get a random word with a hint
- 6 incorrect guesses before the game ends

### 🔸 Multiplayer
- Player 1 inputs a secret word (hidden input)
- Player 1 also inputs a hint (visible)
- Player 2 tries to guess the word using the hint

---

## 🎮 Features

- Word selection based on difficulty
- Dynamic hangman ASCII art display
- Letter-by-letter guessing with input validation
- Tracks and shows used letters in different colors
- Hint display system
- Game restart option after win/loss
- Clear and colored UI using console text attributes

---

## 🧠 Key Assembly Concepts Used

- `PROC`/`ENDP` structured procedures
- Loops & conditionals: `cmp`, `je`, `jne`, `loop`, `jmp`
- String manipulation: copying, comparing, masking input
- Random number generation (`RandomRange`)
- Input/output routines: `ReadChar`, `WriteString`, `ClrScr`
- ASCII art drawing using memory offsets

---

## 📦 Data Structures

- `BYTE` arrays for:
  - Words and hints
  - Hidden word display (`_`)
  - Used letters (A-Z)
- `DWORD` arrays for Hangman stage pointers
- Game state variables:
  - `triesRemaining`, `wordLength`, `difficultyLevel`, `gameMode`

---

## ⚠️ Challenges Faced

- Secure hidden input in multiplayer mode
- Manual string manipulation and uppercasing
- Buffer limit handling
- Real-time screen updates in text UI
- Validation of alphabetic input and repeats

---

## 🖼️ Screenshots (Optional)

You can add screenshots here using:

```markdown
![Main Menu](screenshots/menu.png)
![Game Progress](screenshots/game.png)
![Win Screen](screenshots/win.png)

