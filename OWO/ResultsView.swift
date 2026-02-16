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
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 0, pinnedViews: [.sectionHeaders]) {
                Section(header: headerView) {
                    ForEach(kaomojis.indices, id: \.self) { index in
                        let rowColor = index % 2 == 0 ? Color.clear : Color.secondary.opacity(0.05)
                        Text(kaomojis[index].text)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.vertical, 12)
                            .background(rowColor)
                        Text(kaomojis[index].description)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.vertical, 12)
                            .background(rowColor)
                        Button(action: {
                            Task {
                                await enhanceText(kaomoji: kaomojis[index].text, because: kaomojis[index].description)
                            }
                        }) {
                            Image(systemName: "plus")
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.vertical, 12)
                        .background(rowColor)
                    }
                }
                
            }
        }
    }
    
    var headerView: some View {
        return HStack {
            Text("Icon").bold().frame(maxWidth: .infinity)
            Text("Description").bold().frame(maxWidth: .infinity)
            Text("Insert").bold().frame(maxWidth: .infinity)
        }
        
            .padding()
            .background(.ultraThinMaterial)
            .zIndex(1)
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
