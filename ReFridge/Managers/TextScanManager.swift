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
    
    func detectText(in image: UIImage) {
            guard let cgImage = image.cgImage else { return }

            let request = VNRecognizeTextRequest { [weak self] (request, error) in
                guard let self = self else { return }
                guard error == nil else { return }
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

                let detectedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                print(detectedText)
//                self.filterFoodRelatedText(from: detectedText)
            }
            
            request.recognitionLanguages = ["zh-Hant"]
            request.usesLanguageCorrection = true
        
            let requests = [request]
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform(requests)
    }
}
