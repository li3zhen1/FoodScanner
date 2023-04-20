import SwiftUI

struct RecipeView: View {
    
    @ObservedObject var model: RecipeViewModel
    
    
    let gridItems: [GridItem] = Array(repeating: .init(.adaptive(minimum: 180), spacing: 16.0), count: 2)
    
    var body: some View {
        
        
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                
                LazyVGrid(columns: gridItems, alignment: .center, spacing: 16.0, pinnedViews: []) {
                    ForEach(model.recipe) { recipeGroup in
                        RecipeGroupItemView(
                            recipeGroup: recipeGroup, 
                            isSelected: model.config[recipeGroup.id],
                            checkAction: {
                                let _ = model.toggleRecipe(id: recipeGroup.id)
                            }, detailAction: {
                                model.setSelectedReciptID(sel: recipeGroup.id)
                            })
                    }
                    
                }
                .padding()
                
//                Button {
//                    
//                } label: {
//                    Text("Custom")
//                        .frame(
//                            maxWidth: .infinity,
//                            minHeight: 144.0,
//                            maxHeight: 144.0
//                        )
//                        .background(
//                            RoundedRectangle(cornerSize: CGSize(width: 24.0, height: 24.0), style: .continuous)
//                                .fill(.black)
//                        )
//                }
//                .padding(.horizontal)
//                .padding(.top, 8)
                
                
                Text("Configured to detect \(model.checkedCategoryCount) categories.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                
            }
            .navigationBarTitle("Recipes", displayMode: .automatic)
            .background(Color(.systemGroupedBackground))
            //            .toolbar {
            //                
            //                ToolbarItem(placement: .primaryAction) {
            //                    Button {
            //                        
            //                    } label: {
            //                        Image(systemName: "clock")
            //                    }
            //                    
            //                }
            //                
            //                ToolbarItem(placement: .primaryAction) {
            //                    
            //                    Button {
            //                        
            //                    } label: {
            //                        Image(systemName: "plus")
            //                    }
            //                    
            //                }
            //                
            //            }
            .sheet(isPresented: $model.hasRecipeSelected, onDismiss: {
                model.setSelectedReciptID(sel: nil)
            }, content: {
                if let r = model.selectedRecipe {
                    RecipeDetailView(
                        r, 
                        defaultSelection: model.getSelectionFor(key: r.id) ?? [], 
                        onDismiss: { 
                            model.setSelectedReciptID(sel: nil)
                        }, 
                        onChangeSelection: { sel in
                            model.setSelectionFor(key: r.id, sel: sel)
                        }
                    )
                }
            })
            
        }
        
    }
}
