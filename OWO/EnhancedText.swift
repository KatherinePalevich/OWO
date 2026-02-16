//
//  EnhancedText.swift
//  OWO
//
//  Created by Katherine Palevich on 2/16/26.
//

import Foundation
import FoundationModels

@Generable
struct EnhancedText {
    @Guide(description: "The full text with kaomoji inserted at appropriate emotional point. Ensure exactly one space exists on both sides of the kaomoji")
    let resultText: String
}
