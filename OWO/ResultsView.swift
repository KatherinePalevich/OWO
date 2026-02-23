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
    var onBeforeUpdate: (() -> Void)? = nil
    @State private var insertingIndex: Int? = nil
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
                        Group {
                            if insertingIndex == index {
                                ProgressView()
                            } else {
                                Button(action: {
                                    Task {
                                        await enhanceText(index: index, kaomoji: kaomojis[index].text, because: kaomojis[index].description)
                                    }
                                }) {
                                    Image(systemName: "plus")
                                }
                                .disabled(insertingIndex != nil)
                            }
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

    func enhanceText(index: Int, kaomoji: String, because description: String) async {
        insertingIndex = index
        defer { insertingIndex = nil }
        
        do {
            let session = LanguageModelSession {
                """
                Your job is to insert the kaomoji string \(kaomoji) into the provided text.
                
                CRITICAL RULES:
                1. You MUST NOT delete, modify, or replace ANY characters from the input text.
                2. The input text may already contain other kaomojis or symbols; you MUST preserve them exactly as they are.
                3. The kaomoji to add \(kaomoji) MUST be inserted EXACTLY as provided. Do not alter, simplify, modify, or replace any characters within the kaomoji itself. It is a literal string.
                4. Your output MUST contain the exact same characters as the input, in the exact same order, with only the NEW kaomoji added at the most appropriate location.
                5. Add appropriate spacing around the new kaomoji.
                """
            }
            
            let result = try await session.respond(generating: EnhancedText.self) {
                """
                Original text: \(text)
                Kaomoji to add: \(kaomoji)
                Reasoning for placement: \(description)
                
                Task: Generate the resultText by adding the kaomoji to the original text while strictly following the preservation rules.
                """
            }
            onBeforeUpdate?()
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
