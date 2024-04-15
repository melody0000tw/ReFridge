//
//  TextScanManager.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/15.
//

import Foundation
import UIKit
import Vision

class TextScanManager {
    static let shared = TextScanManager()
    
    private init() {}
    
    func detectText(in image: UIImage, completion: @escaping (ScanResult?) -> Void) {
        guard let cgImage = image.cgImage else { return }
        var scanResult: ScanResult?
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                print("Text detection error: \(error)")
                completion(nil)
                return
            }
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }

            let detectedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            print(detectedText)
            scanResult = self.filterFoodTypeText(from: detectedText)
            completion(scanResult)
        }
        
        request.recognitionLanguages = ["zh-Hant"]
        request.usesLanguageCorrection = true
    
        let requests = [request]
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform(requests)
        } catch {
            print("Failed to perform request:", error)
            completion(nil)
        }
    }
    
    func filterFoodTypeText(from texts: [String]) -> ScanResult {
        let foodKeywords = ["金針菇", "咖啡豆", "火腿"] // Example keywords
        var recongTexts = [String]()
        var notRecongTexts = [String]()
        for text in texts {
            if foodKeywords.contains(where: { keyword in text.localizedCaseInsensitiveContains(keyword)}) {
                recongTexts.append(text)
            } else {
                notRecongTexts.append(text)
            }
        }
        
        var recogResult = [ScanTextItem]()
        for text in recongTexts {
            let result = ScanTextItem(text: text)
            recogResult.append(result)
        }
        
        var notRecogResult = [ScanTextItem]()
        for text in notRecongTexts {
            let result = ScanTextItem(text: text)
            notRecogResult.append(result)
        }
        
        let result = ScanResult(recongItems: recogResult, notRecongItems: notRecogResult)
        return result
    }
}
