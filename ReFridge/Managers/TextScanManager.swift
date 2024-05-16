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
    
    lazy var openAIManager = OpenAIManager.shared
    
    private init() {}
    
    func detectText(in image: UIImage, completion: @escaping (ScanResult?) -> Void) {
        guard let cgImage = image.cgImage else { completion(nil); return }
        let request = VNRecognizeTextRequest { [self] request, error in
            handleTextRecognitionResults(request: request, error: error, completion: completion)
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
    
    private func handleTextRecognitionResults(request: VNRequest, error: Error?, completion: @escaping (ScanResult?) -> Void) {
        if let error = error {
            print("Text detection error: \(error)")
            completion(nil)
            return
        }
        guard let observations = request.results as? [VNRecognizedTextObservation], !observations.isEmpty else {
            completion(nil)
            return
        }

        let detectedText = observations.compactMap { $0.topCandidates(1).first?.string }
        processDetectedText(detectedText, completion: completion)
    }
    
    private func processDetectedText(_ detectedText: [String], completion: @escaping (ScanResult?) -> Void) {
        openAIManager.filterArrays(inputArray: detectedText) { result in
            switch result {
            case .success(let foodReply) where foodReply.food.isEmpty:
                print("Food array is empty, retrying...")
                self.retryFiltering(detectedText, completion: completion)
            case .success(let foodReply):
                let scanResult = self.createScanResult(foodReply: foodReply)
                completion(scanResult)
            case .failure(let error):
                print(error.localizedDescription)
                print("error")
                let foodReply = AIFoodReplay(food: [], notFood: detectedText)
                let scanResult = self.createScanResult(foodReply: foodReply)
            }
        }
    }
    
    private func retryFiltering(_ detectedText: [String], completion: @escaping (ScanResult?) -> Void) {
        openAIManager.filterArrays(inputArray: detectedText) { secondResult in
            switch secondResult {
            case .success(let foodReply):
                let scanResult = self.createScanResult(foodReply: foodReply)
                completion(scanResult)
            case .failure(let error):
                print("Retry failed: \(error.localizedDescription)")
                let foodReply = AIFoodReplay(food: [], notFood: detectedText)
                let scanResult = self.createScanResult(foodReply: foodReply)
                completion(scanResult)
            }
        }
    }
    
    func createScanResult(foodReply: AIFoodReplay) -> ScanResult {
        var recogResult = [FoodCard]()
        for text in foodReply.food {
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
        
        var notRecogResult = [String]()
        for text in foodReply.notFood {
            notRecogResult.append(text)
        }
        let result = ScanResult(recongItems: recogResult, notRecongItems: notRecogResult)
        return result
    }
}
