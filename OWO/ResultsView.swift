//
//  ResultsView.swift
//  OWO
//
//  Created by Katherine Palevich on 2/16/26.
//

import SwiftUI
import FoundationModels

struct ResultsView: View {
    @Binding var text: String
    let kaomojis : [Kaomoji]
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                // Header
                Group {
                    Text("Icon").bold()
                    Text("Description").bold()
                    Text("Insert").bold()
                }
                
                // Data Rows
                ForEach(kaomojis.indices, id: \.self) { index in
                    Text(kaomojis[index].text)
                    Text(kaomojis[index].description)
                    Button(action: {
                        Task {
                            await enhanceText(kaomoji: kaomojis[index].text, because: kaomojis[index].description)
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    

    func enhanceText(kaomoji: String, because description: String) async {
        do {
            let session = LanguageModelSession {
                "Your job is to insert the kaomoji string \(kaomoji) one time into the text based on the \(description) reasoning. Include proper spacing around the kaomoji and text"
            }
            
            let result = try await session.respond(generating: EnhancedText.self) {
                "Insert the kaomoji given this text: \(text)"
            }
            text = result.content.resultText
            
        } catch {
            // Get more detailed error info
            print("Full error: \(error)")
            print("Error type: \(type(of: error))")
            
            // Check if it's a specific generation error
            if let genError = error as? LanguageModelSession.GenerationError {
                print("Generation error details: \(genError)")
            }
        }
    }
}

#Preview {
    @Previewable @State var textPreview : String = "Hello world"
    let kaomojisPreview : [Kaomoji] = [
        Kaomoji(text: "(๑♡⌓♡๑)", description: "Heart-eyes/Infatuation"),
        Kaomoji(text: "(っ˘ڡ˘ς)", description: "Delicious/Eating"),
        Kaomoji(text: "٩(◕‿◕)۶", description: "Pure joy"),
        Kaomoji(text: "(ಥ﹏ಥ)", description: "Crying/Despair"),
        Kaomoji(text: "(´。＿。｀)", description: "Dejected/Pouting")
    ]
    ResultsView(text: $textPreview, kaomojis: kaomojisPreview)
}
