import SwiftUI
import Vision



protocol ScannableRecipe {
    var recipe: [RecipeGroup] { get }
    var config: Dictionary<String, Bool> { get }
    var recipeSelection: Dictionary<String, [String]> { get }
}

extension ScannableRecipe {
    
    func getRecipeGroupById(id: String) -> RecipeGroup? {
        return recipe.first { it in
            it.id == id
        }
    }
    
    func detectRecipes(on observations: [VNRecognizedTextObservation]?) -> ScanResult {
        
        guard let observations else { return ScanResult.noTextResult }
        
        guard !observations.isEmpty else { return ScanResult.noTextResult }
        
        let joinedText = observations.compactMap { it in
            return it.topCandidates(1).first?.string
        }.joined(separator: " ").lowercased()
        
        
        
        let detectedThreats: [ScanResultItem] = recipe.filter { r in
            config[r.id] == true
        }.compactMap { recipe in
            guard let groupItems = recipeSelection[recipe.id] else { return nil }
//            guard let recipe = getRecipeGroupById(id: k) else { return nil }
            
            let itemsDetected = groupItems.filter { it in
//                do {
                    return joinedText.range(of: it) != nil
//                }
//                catch {
//                    return false
//                }
            }
            
            if itemsDetected.isEmpty { return nil }
            
            return ScanResultItem(id: recipe.id, icon: recipe.iconName, items: itemsDetected)
        }
        
        if detectedThreats.isEmpty {
            return ScanResult.safeResult
        }
        else {
            return ScanResult(textDetected: true, safe: false, potentialThreats: detectedThreats)
        }
        
    }
}
