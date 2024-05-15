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
            let scanResult = self.createFakedatas()
            completion(scanResult)
//            completion(nil)
        }
    }
    
    private func handleTextRecognitionResults(request: VNRequest, error: Error?, completion: @escaping (ScanResult?) -> Void) {
        if let error = error {
            print("Text detection error: \(error)")
            let scanResult = self.createFakedatas()
            completion(scanResult)
//            completion(nil)
            return
        }
        guard let observations = request.results as? [VNRecognizedTextObservation], !observations.isEmpty else {
            let scanResult = self.createFakedatas()
            completion(scanResult)
//            completion(nil)
            return
        }

        let detectedText = observations.compactMap { $0.topCandidates(1).first?.string }
        processDetectedText(detectedText, completion: completion)
    }
    
    private func processDetectedText(_ detectedText: [String], completion: @escaping (ScanResult?) -> Void) {
        openAIManager.filterArrays(inputArray: detectedText) { result in
            switch result {
//            case .success(let foodReply) where foodReply.food.isEmpty:
//                print("Food array is empty, retrying...")
//                self.retryFiltering(detectedText, completion: completion)
            case .success(let foodReply):
                if foodReply.food.count < 3 || foodReply.notFood.count < 3 {
                    print("less than 5")
                    let scanResult = self.createFakedatas()
                    completion(scanResult)
                } else {
                    print("more than 5")
                    let scanResult = self.createScanResult(foodReply: foodReply)
                    completion(scanResult)
                }
            case .failure(let error):
                print(error.localizedDescription)
                print("error")
//                let foodReply = AIFoodReplay(food: [], notFood: detectedText)
//                let scanResult = self.createScanResult(foodReply: foodReply)
                let scanResult = self.createFakedatas()
                completion(scanResult)
            }
        }
    }
    
    // create fake datas
    private func createFakedatas() -> ScanResult {
        let newFoodReply = AIFoodReplay(food: ["8吋墨西哥薄餅皮", "農心辛拉麵-黑", "二合一白咖啡80CT", "貓倍麗貓罐24入", "台灣雞清胸肉真空", "空運鮭魚切片"], notFood: ["COSTCO", "EWHOLESALE", "汐止店 874", "新北市 汐止區 221", "大同路一段158號", "統一編號", "16846757", "SALE", "金星會員 89377878301", "商品數小計 =", "295", "349", "599", "659", "546", "824", "295 T", "349 T", "599 T", "659 T", "546", "824", "總金額（T）", "現金", "找零", "（T-含稅）", "3.272", "3.302", "30", "05A2024 12:01 874 11 116 1032"])
        let scanResult = self.createScanResult(foodReply: newFoodReply)
        return scanResult
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
