//
//  Recipe.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/13.
//

import Foundation

struct Recipe: Codable {
    let recipeId: String
    let title: String
    let cookingTime: Int
    let calories: Int
    let servings: Int
    let description: String
    let ingredients: [Ingredient]
    let steps: [String]
    let images: [String]
}

struct Ingredient: Codable {
    let typeId: String
    let qty: Int
    let mesureWord: String
}

struct RecipeData: Codable {
    static let share = RecipeData()
    var data: [Recipe] = [
        Recipe(recipeId: "", title: "番茄炒雞肉", cookingTime: 15, calories: 200, servings: 1,
               description: "酸甜的玉女小番茄加上低脂雞胸肉，加入糖、蠔油和米酒，增添美味的醬汁，蒜碎和白胡椒粉增添了香味。簡單易做，酸甜可口，非常適合快速的家庭料理。",
               ingredients: [
                Ingredient(typeId: "305", qty: 1, mesureWord: "片"),
                Ingredient(typeId: "107", qty: 1, mesureWord: "碗")
               ],
               steps: ["熱油鍋，放入雞肉煎至兩面上色", "加入少許蒜碎炒出香氣", "加入切對半的小番茄至鍋中，加入蠔油、米酒、糖、鹽巴、白胡椒粉拌炒均勻至番茄熟透即可"],
               images: ["https://static01.nyt.com/images/2015/08/14/dining/14CHICKENBREASTS/14CHICKENBREASTS-superJumbo.jpg", "https://cafedelites.com/wp-content/uploads/2017/08/Garlic-Tomato-Basil-Chicken-IMAGES-4.jpg"
               ]),
        Recipe(recipeId: "", title: "涼拌菠菜蛋絲", cookingTime: 10, calories: 100, servings: 1,
               description: "天氣漸漸回溫，吃膩了一般料理？快把這道涼拌菜學起來，不僅營養健康，賣像也很好喔！",
               ingredients: [
                Ingredient(typeId: "106", qty: 300, mesureWord: "克"),
                Ingredient(typeId: "304", qty: 2, mesureWord: "顆")
               ],
               steps: ["首先將雞蛋打成蛋液，並下鍋煎成蛋皮再切絲備用；將醬汁的食材均勻混合備用", "接著將菠菜下鍋汆燙熟後，馬上起鍋泡冰水備用", "將菠菜的水份擠乾，切成適合的長度", "將菠菜與醬汁、蛋皮、花生均勻混合", "盛盤後在依照喜好撒上白芝麻就完成了"
                      ],
               images: ["https://tokyo-kitchen.icook.network/uploads/recipe/cover/326705/0d5e9d4630c14fe3.jpg", "https://pic.pimg.tw/colin7287/1583924638-2327962192_wn.jpg", "https://img.cook1cook.com/upload/step/202003/79/43118-1583925108.jpg"
               ]),
        Recipe(recipeId: "", title: "酪梨蛋吐司", cookingTime: 10, calories: 150, servings: 2,
               description: "酪梨特有的絲滑水潤口感搭配煎蛋和培根，簡單的組合，不需要再額外添加醬料就超級美味了！",
               ingredients: [
                Ingredient(typeId: "204", qty: 1, mesureWord: "顆"),
                Ingredient(typeId: "304", qty: 1, mesureWord: "顆"),
                Ingredient(typeId: "405", qty: 2, mesureWord: "片"),
                Ingredient(typeId: "103", qty: 1, mesureWord: "顆")
               ],
               steps: ["吐司跟送進烤箱", "酪梨切片、洋蔥切絲", "起油鍋煎荷包蛋，撒上黑胡椒及少許玫瑰鹽，單邊稍微成形後倒入少許水蓋鍋蓋悶１分鐘", "將酪梨、洋蔥、蛋放在吐司上", "對切後就完成了"
                      ],
               images: ["https://tokyo-kitchen.icook.network/uploads/recipe/cover/397672/14ca3be63ecf8dab.jpg", "https://imageproxy.icook.network/resize?background=255%2C255%2C255&height=1200&nocrop=false&stripmeta=true&type=auto&url=http%3A%2F%2Ftokyo-kitchen.icook.tw.s3.amazonaws.com%2Fuploads%2Frecipe%2Fcover%2F116840%2F16aa5cea792545db.jpg&width=1200"
               ])
    ]
}
