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
            VStack(spacing: 16) {
                SentimentBreakdownHeader(kaomojis: kaomojis)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                LazyVGrid(columns: columns, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section(header: headerView) {
                        ForEach(kaomojis.indices, id: \.self) { index in
                            let rowColor = index % 2 == 0 ? Color.clear : Color.secondary.opacity(0.05)
                            Text(attributedKaomoji(kaomojis[index]))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.vertical, 12)
                                .shadow(color: color(for: kaomojis[index].sentiment).opacity(0.5), radius: 8)
                                .background(rowColor)
                            
                            SentimentBadge(kaomoji: kaomojis[index])
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
    }

    var headerView: some View {
        return HStack {
            Text("Icon").bold().frame(maxWidth: .infinity)
            Text("Sentiment").bold().frame(maxWidth: .infinity)
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

    func attributedKaomoji(_ kaomoji: Kaomoji) -> AttributedString {
        var attributed = AttributedString(kaomoji.text)
        attributed.foregroundColor = color(for: kaomoji.sentiment)
        return attributed
    }

    func color(for sentiment: Sentiment) -> Color {
        switch sentiment {
        case .anger: return .red
        case .joy: return .yellow
        case .jealousy: return .green
        case .sadness: return .blue
        case .confusion, .fear: return .purple
        }
    }
}

struct SentimentBadge: View {
    let kaomoji: Kaomoji
    @State private var showDetail = false

    var body: some View {
        Button(action: { showDetail.toggle() }) {
            Text(kaomoji.sentiment.rawValue.capitalized)
                .font(.caption2)
                .bold()
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(color(for: kaomoji.sentiment).opacity(0.2))
                )
                .foregroundColor(color(for: kaomoji.sentiment))
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showDetail) {
            VStack(alignment: .leading, spacing: 8) {
                Text(kaomoji.sentiment.rawValue.capitalized)
                    .font(.headline)
                    .foregroundColor(color(for: kaomoji.sentiment))
                Text(kaomoji.description)
                    .font(.subheadline)
            }
            .padding()
            .presentationCompactAdaptation(.popover)
        }
    }

    func color(for sentiment: Sentiment) -> Color {
        switch sentiment {
        case .anger: return .red
        case .joy: return .yellow
        case .jealousy: return .green
        case .sadness: return .blue
        case .confusion, .fear: return .purple
        }
    }
}

struct SentimentBreakdownHeader: View {
    let kaomojis: [Kaomoji]

    var sentimentCounts: [Sentiment: Int] {
        var counts: [Sentiment: Int] = [:]
        for k in kaomojis {
            counts[k.sentiment, default: 0] += 1
        }
        return counts
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sentiment Profile")
                .font(.caption)
                .bold()
                .foregroundColor(.secondary)
            
            HStack(spacing: 2) {
                ForEach(Sentiment.allCases, id: \.self) { sentiment in
                    if let count = sentimentCounts[sentiment], count > 0 {
                        Rectangle()
                            .fill(color(for: sentiment))
                            .frame(maxWidth: .infinity)
                            .frame(height: 8)
                            .cornerRadius(4)
                    }
                }
            }
            .clipShape(Capsule())
            
            HStack {
                ForEach(Sentiment.allCases, id: \.self) { sentiment in
                    if let count = sentimentCounts[sentiment], count > 0 {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(color(for: sentiment))
                                .frame(width: 6, height: 6)
                            Text("\(sentiment.rawValue.capitalized)")
                                .font(.system(size: 10))
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }

    func color(for sentiment: Sentiment) -> Color {
        switch sentiment {
        case .anger: return .red
        case .joy: return .yellow
        case .jealousy: return .green
        case .sadness: return .blue
        case .confusion, .fear: return .purple
        }
    }
}

#Preview {
    @Previewable @State var textPreview : String = "Hello world"
    let kaomojisPreview : [Kaomoji] = [
        Kaomoji(text: "(๑♡⌓♡๑)", description: "Heart-eyes/Infatuation", sentiment: .joy),
        Kaomoji(text: "(っ˘ڡ˘ς)", description: "Delicious/Eating", sentiment: .joy),
        Kaomoji(text: "٩(◕‿◕)۶", description: "Pure joy", sentiment: .joy),
        Kaomoji(text: "(ಥ﹏ಥ)", description: "Crying/Despair", sentiment: .sadness),
        Kaomoji(text: "(´。＿。｀)", description: "Dejected/Pouting", sentiment: .sadness)
    ]
    ResultsView(text: $textPreview, kaomojis: kaomojisPreview)
}
