//
//  ContentView.swift
//  OWO
//
//  Created by Katherine Palevich on 2/6/26.
//

import SwiftUI
import FoundationModels

struct ContentView: View {
    var body: some View {
        TabView {
            GenerativeView()
                .tabItem {
                    Label("Kaomoji", systemImage: "face.smiling")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct IntelligentUIView: View {
    @State private var status: String = "Ready"
    @State private var userText: String = ""
    @State var kaomojiList: KaomojiList?
    @State private var history: [String] = []
    @State private var isGenerating: Bool = false
    @FocusState private var isTextEditorFocused: Bool
    let placeholder = "Enter text here..."
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack(alignment: .topLeading) {
                if userText.isEmpty {
                    Text(placeholder)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                }
                TextEditor(text: $userText)
                    .textFieldStyle(.roundedBorder)
                    .focused($isTextEditorFocused)
                    .opacity(userText.isEmpty ? 0.5 : 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }
            
            if isTextEditorFocused {
                HStack {
                    Spacer()
                    Button("Done Editing") {
                        saveSnapshot()
                        isTextEditorFocused = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            Button("Use Demo") {
                userText = "I'm so incredibly happy that our picnic is finally happening under this beautiful sun! However, I'm actually quite angry and frustrated that you completely ignored my request for eclairs! It's so inconsiderate! And I'm incredibly jealous of the neighbor's perfect golden picnic set; I'm so envious that they always have the best gear. It makes me a little blue to think about how much effort I put into the sandwiches that no one is eating. Wait, why is there a troupe of squirrels wearing tiny capes and dancing around the fruit salad? Oh no, those squirrels are looking at me with such menace that I'm actually terrified they're going to swarm me! I'm genuinely scared!"
            }
            
            if let generatedKaomojisList = kaomojiList {
                ResultsView(text: $userText, kaomojis: generatedKaomojisList.kaomojis, onBeforeUpdate: {
                    saveSnapshot()
                })
            }
            
            HStack(spacing: 20) {
                Button(action: undo) {
                    Image(systemName: "arrow.uturn.backward")
                        .padding()
                }
                .disabled(history.isEmpty)
                
                Button(action: {
                    saveSnapshot()
                    Task {
                        await generate(with: userText)
                    }
                }) {
                    if isGenerating {
                        ProgressView()
                            .padding(.horizontal, 10)
                    } else {
                        Text("Generate Kaomojis")
                    }
                }
                .disabled(userText.isEmpty || isGenerating)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
    
    func generate(with text: String) async {
        isGenerating = true
        status = "Generating..."
        defer { isGenerating = false }
        
        do {
            let session = LanguageModelSession(tools: [SentimentTool()]) {
                "Your job is to generate five different Kaomojis for the user based on some input text. Kaomojis look like (๑>◡<๑), (◕‿◕✿), ~(˘▾˘~), :), or :D. Do not use emojis but instead give examples of regular text that when combined in various ways resembles other objects. Avoid using the example kaomojis. When creating the description for each generated kaomoji, reference a relevant part of the user text that influenced the resulting kaomoji. Avoid duplicate characters to create a diverse result. The text will always be non empty. Before generating, you should use the get_sentiment_score tool to verify the emotional tone of the user's text to ensure your kaomojis are perfectly matched. For each kaomoji, assign one of the following sentiments: anger, joy, jealousy, sadness, confusion, fear."
            }
            
            let result = try await session.respond(generating: KaomojiList.self) {
                "Generate five relevant Kaomojis given the context of \(text)"
            }
            status = "Success! Here are your results:"
            kaomojiList = result.content
            
        } catch {
            // Get more detailed error info
            status = "Error: \(error)"
            print("Full error: \(error)")
            print("Error type: \(type(of: error))")
            
            // Check if it's a specific generation error
            if let genError = error as? LanguageModelSession.GenerationError {
                print("Generation error details: \(genError)")
            }
        }
    }
    
    func saveSnapshot() {
        if history.last != userText {
            history.append(userText)
        }
    }
    
    func undo() {
        guard !history.isEmpty else { return }
        userText = history.removeLast()
    }
    
}



struct DumbUIView: View {
    let reason : String
    var body: some View {
        Text(reason)
    }
}

struct GenerativeView: View {
    // Create a reference to the system language model.
    private var model = SystemLanguageModel.default


    var body: some View {
        switch model.availability {
        case .available:
            // Show your intelligence UI.
            IntelligentUIView()
        case .unavailable(.deviceNotEligible):
            // Show an alternative UI.
            DumbUIView(reason: ".unavailable(.deviceNotEligible)")
        case .unavailable(.appleIntelligenceNotEnabled):
            // Ask the person to turn on Apple Intelligence.
            DumbUIView(reason: "Ask the person to turn on Apple Intelligence")
        case .unavailable(.modelNotReady):
            // The model isn't ready because it's downloading or because of other system reasons.
            DumbUIView(reason: "The model isn't ready because it's downloading or because of other system reasons.")
        case .unavailable(_):
            // The model is unavailable for an unknown reason.
            DumbUIView(reason: "The model is unavailable for an unknown reason.")
        }
    }
}

#Preview {
    ContentView()
}
