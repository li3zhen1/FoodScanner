import SwiftUI

let recipeFileName = "recipe.json"
let configFileName = "config.json"
let recipeSelectionFileName = "selection.json"

let defaultConfigContent = [
    "Gluten Free": true,
    "Lactose Free": true,
]

enum RecipeError: Error {
    case recipeLoadingError
    case configLoadingError
    case recipeSavingError
    case configSavingError
}


final class RecipeViewModel: ObservableObject, ScannableRecipe {
    
    private let fileManager = FileManager.default
    
    private let defaults = UserDefaults.standard
    
    @Published var recipe: [RecipeGroup] = []
    
    @Published var config: Dictionary<String, Bool> = [:]
    
    var recipeSelection: Dictionary<String, [String]> = [:]
    
    @Published var checkedCategoryCount: Int = 0
    
    @Published var recipeError: RecipeError?
    
    @Published var isConfigInitForFirstTime: Bool? = nil
    
    init() {
        //        try? fileManager.removeItem(atPath: configFileName)
        //        try? fileManager.removeItem(atPath: recipeFileName)
        //        try? fileManager.removeItem(atPath: recipeSelectionFileName)
        
        loadRecipeFromStorage()
        loadConfigFromStorage()
        loadRecipeSelection()
        
        $config.receive(on: RunLoop.main)
            .map { cfg in
                return cfg.filter {
                    $0.value == true
                }.count
            }
            .assign(to: &$checkedCategoryCount)
        
        $selectedRecipeID.receive(on: RunLoop.main)
            .map { sel in
                if sel == nil {
                    return nil
                }
                else {
                    guard let targetRecipe = self.recipe.first(where: { rg in
                        rg.id == sel
                    }) else {
                        return nil
                    }
                    return targetRecipe
                }
            }
            .assign(to: &$selectedRecipe)
        
        $selectedRecipe.receive(on: RunLoop.main)
            .map { sel in
                return sel != nil
            }
            .assign(to: &$hasRecipeSelected)
        
        
    }
    
    func loadRecipeSelection() {
        //        if fileManager.isReadableFile(atPath: recipeSelectionFileName) {
        //
        //            if let data = fileManager.contents(atPath: recipeSelectionFileName) {
        //                do {
        //                    let decoder = JSONDecoder()
        //                    recipeSelection = try decoder.decode(Dictionary<String, [String]>.self, from: data)
        //                }
        //                catch {
        //                    recipeError = .configLoadingError
        //                }
        //            }
        //        }
        //        else {
        //            recipeSelection = Dictionary(uniqueKeysWithValues: recipe.map({ rg in
        //                (rg.id, rg.items)
        //            }))
        //            saveRecipeSelectionToStorage()
        //        }
        
        if let decoded = defaults.object(forKey: recipeSelectionFileName) as? Dictionary<String, [String]> {
            recipeSelection = decoded
        }
        else {
            recipeSelection = Dictionary(uniqueKeysWithValues: recipe.map({ rg in
                (rg.id, rg.items)
            }))
            saveRecipeSelectionToStorage()
        }
    }
    
    func saveRecipeSelectionToStorage() {
        defaults.set(recipeSelection, forKey: recipeSelectionFileName)
//        do {
//            let encoder = JSONEncoder()
//            let encoded = try encoder.encode(recipeSelection)
//            fileManager.createFile(atPath: recipeSelectionFileName, contents: encoded, attributes: [:])
//        }
//        catch {
//            recipeError = .configSavingError
//        }
    }
    
    func loadConfigFromStorage() {
        
        if let decoded = defaults.object(forKey: configFileName) as? Dictionary<String, Bool> {
            config = decoded
        }
        else {
            isConfigInitForFirstTime = true
            config = defaultConfigContent
            saveConfigToStorage()
        }
        
        //        if fileManager.isReadableFile(atPath: configFileName) {
        //
        //            if let data = fileManager.contents(atPath: configFileName) {
        //                do {
        //                    isConfigInitForFirstTime = false
        //                    let decoder = JSONDecoder()
        //                    config = try decoder.decode(Dictionary<String, Bool>.self, from: data)
        //                }
        //                catch {
        //                    recipeError = .configLoadingError
        //                }
        //            }
        //        }
        //        else {
        //            isConfigInitForFirstTime = true
        //            config = defaultConfigContent
        //            saveConfigToStorage()
        //        }
    }
    
    func loadRecipeFromStorage()  {
                if fileManager.isReadableFile(atPath: recipeFileName) {
                    if let data = fileManager.contents(atPath: recipeFileName) {
                        do {
                            let decoder = JSONDecoder()
                            recipe = try decoder.decode([RecipeGroup].self, from: data)
                        }
                        catch {
                            recipeError = .recipeLoadingError
                        }
                    }
                }
                else {
                    recipe = defaultRecipeContent
                    saveRecipeToStorage()
                }
        
//        if let decoded = defaults.object(forKey: recipeFileName) as? [RecipeGroup] {
//            recipe = decoded
//        }
//        else {
//
//            recipe = defaultRecipeContent
//            saveRecipeToStorage()
//        }
    }
    
    func saveRecipeToStorage()  {
//        defaults.set(self.recipe, forKey: recipeFileName)
                do {
                    let encoder = JSONEncoder()
                    let encoded = try encoder.encode(recipe)
                    fileManager.createFile(atPath: recipeFileName, contents: encoded, attributes: [:])
                }
                catch {
                    recipeError = .recipeSavingError
                }
    }
    
    func saveConfigToStorage()  {
        defaults.set(self.config, forKey: configFileName)
        //        do {
        //            let encoder = JSONEncoder()
        //            let encoded = try encoder.encode(config)
        //            fileManager.createFile(atPath: configFileName, contents: encoded, attributes: [:])
        //
        //            let d = String(data: fileManager.contents(atPath: configFileName), encoding: .utf8)
        //        }
        //        catch {
        //            recipeError = .configSavingError
        //        }
    }
    
    public func toggleRecipe(id: String) -> Bool {
        if config[id] == true {
            config[id] = false
            saveConfigToStorage()
            return false
        }
        else {
            config[id] = true
            saveConfigToStorage()
            return true
        }
    }
    
    
    @Published var selectedRecipeID: String? = nil
    @Published var selectedRecipe: RecipeGroup? = nil
    @Published var hasRecipeSelected: Bool = false
    
    func setSelectedReciptID(sel: String?) {
        selectedRecipeID = sel
    }
    
    func getSelectionFor(key: String) -> [String]? {
        //        print(recipeSelection[key])
        return recipeSelection[key]
    }
    
    func setSelectionFor(key: String, sel: Set<String>) {
        recipeSelection[key] = sel.sorted()
        saveRecipeSelectionToStorage()
    }
}
