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
        GenerativeView()
    }
    
}

struct IntelligentUIView: View {
    @State private var status: String = "Ready"
    @State private var userText: String = ""
    @State var kaomojiList: KaomojiList?
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
                    .opacity(userText.isEmpty ? 0.5 : 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }
            
            ScrollView {
                Text(status)
                    .padding()
                if let generatedKaomojisList = kaomojiList {
                    ResultsView(text: $userText, kaomojis: generatedKaomojisList.kaomojis)
                }
                
            }
            
            Button("Generate Kaomojis") {
                Task {
                    await generate(with: userText)
                }
            }.disabled(userText.isEmpty)
        }
        .padding()
    }
    
    func generate(with text: String) async {
        status = "Generating..."
        
        do {
            let session = LanguageModelSession {
                "Your job is to generate five different Kaomojis for the user based on some input text. Kaomojis look like (๑>◡<๑), (◕‿◕✿), ~(˘▾˘~), :), or :D. Do not use emojis but instead give examples of regular text that when combined in various ways resembles other objects. Avoid using the example kaomojis. When creating the description for each generated kaomoji, reference a relevant part of the user text that influenced the resulting kaomoji. The text will always be non empty"
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
