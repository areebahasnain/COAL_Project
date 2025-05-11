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

## 🖼️ Screenshots 



```markdown
![image](https://github.com/user-attachments/assets/18f7bb47-1521-4e91-97fe-e58f6a5b8680)

![image](https://github.com/user-attachments/assets/89d718cd-b5ee-406c-be97-fef1d66d7ede)
![image](https://github.com/user-attachments/assets/9cda85da-5b24-463f-a1c7-a49c6e37f623)

![image](https://github.com/user-attachments/assets/9228d26d-bad4-4987-990d-7d52a4ad466f)


