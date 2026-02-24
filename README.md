# OWO - The Intelligent Kaomoji Generator

OWO uses on-device Apple Intelligence to generate perfectly matched Kaomojis for your text. It analyzes the sentiment and context of your input to suggest expressive symbols like `(๑>◡<๑)` or `(ಥ﹏ಥ)` and helps you insert them seamlessly.

<img width="360" alt="OWO Demo" src="https://github.com/user-attachments/assets/592a57a4-a054-4891-a3d9-b20c38856935" />


## ✨ Features

- **Generative Kaomojis**: Uses a system language model to create five diverse Kaomojis tailored to your specific text context.
- **Real-time Sentiment Analysis**: Leverages Apple's `NaturalLanguage` framework to verify the emotional tone of your input.
- **Intelligent Placement**: Automatically inserts your chosen Kaomoji into the most appropriate spot in your text while strictly preserving all original content.
- **Sentiment Profile**: Visualize the emotional distribution of your suggested Kaomojis with a sleek breakdown header.
- **Interactive Sentiment Badges**: Tap on sentiment badges to understand the reasoning behind each suggestion.
- **Undo Support**: Easily revert changes with a built-in history stack.

## 📱 Requirements

OWO relies on the latest Apple Intelligence features, which require specific hardware and software:

### Operating System
- **iOS / iPadOS**: 18.2 or later.
- **macOS**: 15.2 or later.

### Hardware
- **iPhone**: iPhone 15 Pro, iPhone 15 Pro Max, or any iPhone 16 model and later.
- **iPad**: iPad Pro or iPad Air with M1 chip or later.
- **Mac**: Any Mac with M1 chip or later.

### Model Requirements
- **Apple Intelligence** must be enabled in your system settings.
- The system language model must be fully downloaded (the app will provide a status message if the model is still downloading).

## 🚀 Getting Started

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/KatherinePalevich/OWO.git
   cd OWO
   ```

2. **Open the project**:
   - Double-click `OWO.xcodeproj` to open it in Xcode.

3. **Select a Target**:
   - Choose a supported simulator (e.g., iPhone 16 Pro) or your own Apple Intelligence-capable device.

4. **Build and Run**:
   - Press `⌘R` or click the Play button in Xcode.

### Usage

1. Type or paste your text into the editor.
2. Click **Generate Kaomojis**.
3. Review the suggestions in the **Results** section.
4. Click the **+** (plus) button next to a Kaomoji to intelligently insert it into your text.
5. Use the **Undo** button if you want to revert an insertion.

## 🛠 Tech Stack


- **FoundationModels**: For `LanguageModelSession` integration.
- **NaturalLanguage**: For `NLTagger` sentiment analysis.
- **SwiftUI**: Modern, responsive user interface.

---

Developed with ❤️ by Katherine Palevich.
