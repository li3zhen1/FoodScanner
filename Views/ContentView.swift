import SwiftUI

struct ContentView: View {
    
    @StateObject var recipeModel = RecipeViewModel()
    
    @State private var selectedTabTag = 0
    
    @Environment(\.colorScheme) var scheme: ColorScheme
    
    var body: some View {
        TabView(selection: $selectedTabTag) {
            ScannerView(recipeModel: recipeModel)
                .environment(\.colorScheme, scheme)
                .tabItem {
                    Image(systemName: "camera.fill")
                        .tint(.white)
                    Text("Scanner")
                        .tint(.white)
                }
                .tag(0)
            
            RecipeView(model: recipeModel)
                .tabItem {
                    Image(systemName: "backpack.fill")
                    Text("Recipes")
                }
                .tag(1)
            
        }
        .tint(selectedTabTag == 0 ? .white : .blue)
        .environment(\.colorScheme, selectedTabTag == 0 ? .dark : scheme)
    }
}

