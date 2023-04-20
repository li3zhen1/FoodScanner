import SwiftUI

struct RecipeDetailView: View {
    
    @State private var multiSelection: Set<String>
    
    let recipe: RecipeGroup
    let onDismiss: ()->Void
    let onChangeSelection: (Set<String>)->Void
    
    init(
        _ recipe: RecipeGroup, 
        defaultSelection: [String],
        onDismiss: @escaping ()->Void,
        onChangeSelection: @escaping (Set<String>)->Void
    ) {
        self.recipe = recipe
        self.onDismiss = onDismiss
        self.onChangeSelection = onChangeSelection
        self.multiSelection = Set(defaultSelection)
    }
    
    var body: some View {
        NavigationStack {
            
            List { 
                Section{ 
                    
                    ForEach(recipe.items.sorted(using: .localizedStandard), id: \.self) { it in
                        Button {
                            if (multiSelection.contains(it)) {
                                multiSelection.remove(it)
                            }
                            else {
                                multiSelection.insert(it)
                            }
                            onChangeSelection(multiSelection)
                        } label: {
                            HStack(alignment: .center, spacing: 16.0, content: {
                                Image(systemName: "checkmark")
                                    .fontWeight(.semibold)
                                    .opacity(multiSelection.contains(it) ? 1.0 : 0.0)
                                Text(it)
                                    .foregroundColor(.primary)
                            })
                        }
                    }
                } header: {
                    Text("Ingredients to avoid")
                        .textCase(.none)
                } footer: {
                    VStack(alignment: .leading) {
                        Text("Food Scanner will warn you if any of the selected \(multiSelection.count) ingredients is recognized.")
                            .padding(.bottom, 4.0)
                        Text("Please note that the data is collected from multiple sources on the Internet, and might be incorrect.")
                    }
                }
                
               
            }
            
            .navigationBarTitle(recipe.id)
            
            .toolbar {
                ToolbarItem(placement: .primaryAction) { 
                    DismissButton(onDismiss: onDismiss)
                }
            }
        }
    }
}
