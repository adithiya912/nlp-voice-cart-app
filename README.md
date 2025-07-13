# Voice-Controlled Mobile App Point of Sale System

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)

The Voice Cart App is an innovative mobile shopping cart application that revolutionizes traditional shopping by integrating advanced voice recognition technology with intuitive UI design.

## Features

- 🎙️ **Voice Command Processing**
  - Add/remove/view items with natural language commands
  - Supports multiple commands in single utterance (e.g., "add 3 pens and remove 2 notebooks")
  - Continuous listening mode for extended sessions

- 🛒 **Smart Cart Management**
  - Real-time cart updates with inventory tracking
  - Persistent cart storage across sessions
  - Automatic total calculation

- 📄 **Automated Invoice Generation**
  - Professional PDF invoices
  - Export to device storage or share via other apps
  - Unique invoice numbering

- 🔍 **Fuzzy Product Matching**
  - Handles variations in product names
  - Case-insensitive search
  - Similarity matching for misspelled items

- 📱 **Cross-Platform Compatibility**
  - Works on both Android and iOS
  - Responsive UI for all screen sizes
  - Offline-first architecture

## Supported Commands

### Add Items
- "add 3 pens"
- "include 2 notebooks"
- "put 5 erasers in cart"
- "insert three rulers"

### Remove Items
- "remove 1 pen"
- "delete 2 notebooks"
- "take out 3 erasers"
- "clear all pens"

### View Cart
- "show cart"
- "display my items"
- "what's in my cart?"
- "list cart contents"

### Combined Commands
- "add 3 pens and remove 2 notebooks"
- "add 5 erasers then show cart"
- "remove 1 pen plus add 4 notebooks also display cart"

## Technology Stack

- **Framework**: Flutter (Dart)
- **Voice Recognition**: Google ML Kit Speech-to-Text
- **Database**: SQLite
- **PDF Generation**: pdf library
- **State Management**: Provider
- **Permissions**: permission_handler

## System Requirements

### Hardware
- Processor: ARM64 or x86_64
- RAM: 2GB minimum (4GB recommended)
- Storage: 100MB available space
- Microphone: Built-in or external

### Software
- Android: 5.0 (API 21+) or iOS 12.0+
- Flutter SDK: 3.8.1+
- Dart SDK: 3.8.1+

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/voice-cart-app.git
