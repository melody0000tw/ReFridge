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
    
    let openAIManager = OpenAIManager.shared
    
    private init() {}
    
    func detectText(in image: UIImage, completion: @escaping (ScanResult?) -> Void) {
        guard let cgImage = image.cgImage else { return }
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
            
            if detectedText.count == 0 {
                print("沒有可偵測的！")
                completion(nil)
                return
            }
            
            print("detectedText===============\(detectedText)")
            self.openAIManager.filterArrays(inputArray: detectedText) { result in
                switch result {
                case .success(let foodReply):
                    let scanResult = self.createScanResult(food: foodReply.food, notFood: foodReply.notFood)
                    completion(scanResult)
                case .failure(let error):
                    print(error.localizedDescription)
                    let scanResult = self.createScanResult(food: nil, notFood: detectedText)
                    completion(scanResult)
                }
            }
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
    
    func createScanResult(food: [String]?, notFood: [String]) -> ScanResult {
        var recogResult = [FoodCard]()
        if let food = food {
            for text in food {
                let result = FoodCard(
                    cardId: UUID().uuidString,
                    name: text,
                    categoryId: 5,
                    typeId: "501",
                    iconName: "other",
                    qty: 1, createDate: Date(),
                    expireDate: Date().createExpiredDate(afterDays: 7) ?? Date(),
                    isRoutineItem: false,
                    barCode: "",
                    storageType: 0,
                    notes: "")
                recogResult.append(result)
            }
        }
        
        var notRecogResult = [String]()
        for text in notFood {
            notRecogResult.append(text)
        }
        let result = ScanResult(recongItems: recogResult, notRecongItems: notRecogResult)
        return result
        
    }
    
    
//    func filterFoodTypeText(from texts: [String]) -> ScanResult {
//        let foodKeywords = ["菇", "豆", "火腿", "菜", "肉", "萵苣", "大陸妹", "吐司", "蘿美"] // Example keywords
//        var recongTexts = [String]()
//        var notRecongTexts = [String]()
//        for text in texts {
//            if foodKeywords.contains(where: { keyword in text.localizedCaseInsensitiveContains(keyword)}) {
//                recongTexts.append(text)
//            } else {
//                notRecongTexts.append(text)
//            }
//        }
//        
//        var recogResult = [FoodCard]()
//        for text in recongTexts {
//            let result = FoodCard(
//                cardId: UUID().uuidString,
//                name: text,
//                categoryId: 5,
//                typeId: "501",
//                iconName: "other",
//                qty: 1, createDate: Date(),
//                expireDate: Date().createExpiredDate(afterDays: 7) ?? Date(),
//                isRoutineItem: false,
//                barCode: "",
//                storageType: 0,
//                notes: "")
//            recogResult.append(result)
//        }
//        
//        var notRecogResult = [String]()
//        for text in notRecongTexts {
//            notRecogResult.append(text)
//        }
//        
//        let result = ScanResult(recongItems: recogResult, notRecongItems: notRecogResult)
//        return result
//    }
}
