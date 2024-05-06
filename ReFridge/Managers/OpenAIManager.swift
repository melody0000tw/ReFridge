//
//  OpenAIManager.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/4.
//

import Foundation
import OpenAI

enum TextScanError: String, Error {
    case noText = "no texts in the image"
    case decodeJsonFailed = "the open ai replay can not be decoded from json"
}

struct AIFoodReplay: Codable {
    let food: [String]
    let notFood: [String]
}

class OpenAIManager {
    static let shared = OpenAIManager()
    private init() {}
    
    func filterArrays(inputArray: [String], completion: @escaping (Result<AIFoodReplay, Error>) -> Void) {
        let token = Secrets.shared.openaiApiToken
        let openAI = OpenAI(apiToken: token)
        let prompt = inputArray.joined(separator: "\n")
        
        // swiftlint:disable line_length
        // system role
        let systemRole = "You are a helpful assistant tasked with categorizing text within an array. Your goal is to discern whether each item in the array is food-related or not. Once categorized, you will organize the items into two separate arrays accordingly. Your final output should be returned as JSON format, providing clear distinctions between food-related and non-food-related items"
        // swiftlint:enable line_length
        
        // reply example
        let exampleInput = ["芒果", "衛生紙", "牛奶", "洗碗精", "垃圾袋", "烤肉醬", "香草口味的牙膏", "香菇", "Oreo"]
        let exampleOutput = AIFoodReplay(
            food: ["芒果", "牛奶", "烤肉醬", "香菇", "蝦味先", "Oreo"],
            notFood: ["衛生紙", "洗碗精", "垃圾袋", "香草口味的牙膏"]
        )
        
        // convert example ouput to json and to json string
        guard let outputJson = try? JSONEncoder().encode(exampleOutput), let outputJsonString = String(data: outputJson, encoding: .utf8) else {
            print("open ai example cannot convert to JSON")
            return
        }
        let query = ChatQuery(messages: [
            .init(role: .system, content: systemRole)!,
            .init(role: .user, content: String(describing: exampleInput))!,
            .init(role: .assistant, content: outputJsonString)!,
            .init(role: .user, content: prompt)!],
                              model: .gpt3_5Turbo_0125
        )
        
        openAI.chats(query: query) { result in
            print("open AI result ========\(result)")
            switch result {
            case .success(let completionResult):
                if let jsonString = completionResult.choices.first?.message.content?.string,
                   let jsonData = jsonString.data(using: .utf8),
                   let jsonObject = try? JSONSerialization.jsonObject(with: jsonData),
                   let jsonDict = jsonObject as? [String: [String]] {
                    
                       let foodAry = jsonDict["food"]
                       let notFoodAry = jsonDict["notFood"]
                    let foodReply = AIFoodReplay(food: foodAry ?? [""], notFood: notFoodAry ?? [""])
                    print("成功decode成 AIFoodReplay : \(foodReply)")
                    completion(.success(foodReply))
                } else {
                    print("Failed to parse JSON")
                    completion(.failure(TextScanError.decodeJsonFailed))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
