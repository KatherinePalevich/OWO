//
//  ResultsView.swift
//  OWO
//
//  Created by Katherine Palevich on 2/16/26.
//

import SwiftUI

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
                        insertKaomoj(kaomoji: kaomojis[index].text, at: kaomojis[index].placement)
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    func insertKaomoj(kaomoji: String, at index: Int) {
        let targetIndex = text.index(text.startIndex, offsetBy: index)
        text.insert(contentsOf: kaomoji, at: targetIndex)
    }
}

#Preview {
    @Previewable @State var textPreview : String = "Hello world"
    let kaomojisPreview : [Kaomoji] = [
        Kaomoji(text: "(๑♡⌓♡๑)", description: "Heart-eyes/Infatuation", placement: 12),
        Kaomoji(text: "(っ˘ڡ˘ς)", description: "Delicious/Eating", placement: 13),
        Kaomoji(text: "٩(◕‿◕)۶", description: "Pure joy", placement: 34),
        Kaomoji(text: "(ಥ﹏ಥ)", description: "Crying/Despair", placement: 48),
        Kaomoji(text: "(´。＿。｀)", description: "Dejected/Pouting", placement: 70)
    ]
    ResultsView(text: $textPreview, kaomojis: kaomojisPreview)
}
