# 📘 Requirements Document — Mindful Moments App

---

## 1. **App Overview**

Mindful Moments is a simple meditation and mindfulness app made for people who want to feel calmer and less stressed. The app gives guided meditations, short mindful exercises, daily reminders, and a small journaling space. It is for anyone who wants a peaceful break during their day.

---

## 2. **Main Goals**

1. Help users choose a meditation or exercise they want to do.
2. Let users track their progress over time.
3. Give users daily reminders to stay mindful.
4. Provide a simple journal to write thoughts after meditating.

---

## 3. **User Stories**

- **US-001** — As a user, I want to pick a meditation theme so that I can focus on what I need (sleep, calm, focus, etc.).
- **US-002** — As a user, I want to choose how long my meditation lasts so that it fits into my day.
- **US-003** — As a user, I want to see my past sessions so that I can track my progress.
- **US-004** — As a user, I want daily reminders so that I don’t forget to meditate.
- **US-005** — As a user, I want to write short journal notes so that I can reflect on my day or session.
- **US-006** — As a user, I want the app to feel calm and easy so that it doesn’t stress me out.

---

## 4. **Features**

### **F-001 — Meditation List**

- **What it does:** Shows a list of meditation themes (calm, sleep, focus, etc.).
- **When it appears:** On the Home Screen (S-001).
- **If something goes wrong:** Show a simple message like “Could not load meditations.”

### **F-002 — Duration Picker**

- **What it does:** Lets users choose how long a session lasts (5, 10, 15 minutes).
- **When it appears:** When the user selects a meditation theme (S-002).
- **If something goes wrong:** Use a default time (5 minutes).

### **F-003 — Meditation Player**

- **What it does:** Plays audio for the guided meditation. Shows a timer.
- **When it appears:** After the user chooses a theme and time (S-003).
- **If something goes wrong:** Show “Audio unavailable” and return to S-002.

### **F-004 — Progress Tracking**

- **What it does:** Saves each completed session with date, theme, and duration.
- **When it appears:** On the Progress Screen (S-004).
- **If something goes wrong:** Show “No progress to show yet.”

### **F-005 — Daily Reminders**

- **What it does:** Sends a reminder at a time the user chooses.
- **When it appears:** From the Settings Screen (S-005).
- **If something goes wrong:** Tell the user reminders must be allowed in Settings.

### **F-006 — Journal**

- **What it does:** Lets users write simple notes after a session.
- **When it appears:** On the Journal Screen (S-006).
- **If something goes wrong:** Show “Could not save note.”

### **F-007 — Theme (Light/Dark Mode)**

- **What it does:** Makes the app look calm in light or dark.
- **When it appears:** The whole app.
- **If something goes wrong:** Use the phone’s default mode.

---

## 5. **Screens**

### **S-001 — Home Screen**

- Shows meditation themes (F-001).
- Button to see progress (S-004).
- Button to open journal (S-006).
- Tap a theme to go to S-002.

### **S-002 — Meditation Details Screen**

- Shows theme name.
- Duration picker (F-002).
- Start button to go to S-003.

### **S-003 — Meditation Player Screen**

- Timer.
- Play / Pause.
- End session button that saves progress (F-004) and offers to open journal (S-006).

### **S-004 — Progress Screen**

- List of past sessions (F-004).
- Back button to return to S-001.

### **S-005 — Settings Screen**

- Daily reminder time picker (F-005).
- Option to turn reminders on/off.
- Back button to S-001.

### **S-006 — Journal Screen**

- List of saved journal entries (F-006).
- Button to write a new entry.
- Back to S-001.

---

## 6. **Data**

### **D-001 — Meditation Themes List**

- Theme name
- Short description
- Audio file name

### **D-002 — User Session History**

- Date
- Duration
- Theme

### **D-003 — Journal Entries**

- Date
- Text written by the user

### **D-004 — Reminder Settings**

- Reminder time
- Reminder on/off

---

## 7. **Extra Details**

- Works fully offline except for downloading audio files (if needed).
- Saves all data on the device.
- Needs permission for notifications (for reminders).
- Dark mode should be supported.
- No camera, no location, no special permissions.

---

## 8. **Build Steps**

### **B-001**

Create S-001 (Home Screen) with the list of themes (F-001) using D-001.

### **B-002**

Build S-002 to show theme details and the duration picker (F-002).

### **B-003**

Build S-003 and add the meditation player (F-003).

### **B-004**

Add progress saving using D-002, then create S-004 (F-004).

### **B-005**

Add the journal feature using D-003 and build S-006 (F-006).

### **B-006**

Add daily reminders using D-004 and build S-005 (F-005).

### **B-007**

Add dark mode support (F-007).

### **B-008**

Test all screens together. Make sure navigation works (S-001 → S-002 → S-003, etc.).

### **B-009**

Polish the app: clean layout, soft colors, calm feel.

---
