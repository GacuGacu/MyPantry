import SwiftUI

struct RecipeTileView: View {
    let recipe: Recipe
    let pantryList: [PantryIngredient]

    var body: some View {
        VStack(alignment: .leading) {
            let missingIngredients = recipe.ingredients.filter { ingredient in
                !pantryList.contains { pantryItem in
                    pantryItem.name.lowercased() == ingredient.lowercased()
                }
            }
            
            let availableButFrozen = recipe.ingredients.filter { ingredient in
                pantryList.contains { pantryItem in
                    pantryItem.name.lowercased() == ingredient.lowercased() && pantryItem.frozen
                    
                }
                
            }

            let allIngredientsInPantry = missingIngredients.isEmpty

            // Recipe title
            Text(recipe.name)
                .font(.headline)
                .fontWeight(.bold)
                .padding(8)
                .background(allIngredientsInPantry ? Color.green.opacity(0.3) : Color.clear)
                .cornerRadius(8)
                .foregroundColor(.primary)

            if allIngredientsInPantry {
                Text("You have all the ingredients!")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding(.top, 8)
                if(!availableButFrozen.isEmpty){
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: [GridItem(.flexible())], spacing: 8) {
                            ForEach(availableButFrozen, id: \.self) { ingredient in
                                Text(ingredient)
                                    .font(.body)
                                    .padding(8)
                                    .background(Color.blue.opacity(0.3))
                                    .cornerRadius(8)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
            } else {
                Text("Missing Ingredients:")
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .padding(.top, 8)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: [GridItem(.flexible())], spacing: 8) {
                        ForEach(missingIngredients, id: \.self) { ingredient in
                            let pantryItem = pantryList.first { $0.name.lowercased() == ingredient.lowercased() }
                            let isFrozen = pantryItem?.frozen ?? false

                            Text(ingredient)
                                .font(.body)
                                .padding(8)
                                .background(
                                    isFrozen
                                        ? Color.blue.opacity(0.3)
                                        : Color.red.opacity(0.3)
                                )
                                .cornerRadius(8)
                                .foregroundColor(.black)
                        }
                    }
                }
            }
        }
        .padding()
    }
}
