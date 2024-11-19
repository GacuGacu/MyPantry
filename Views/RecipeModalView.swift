import SwiftUI

struct RecipeModalView: View {
    @Binding var pantryList: [PantryIngredient]
    @Binding var recipes: [Recipe]

    var body: some View {
        VStack {
            Text("Recipes")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            // Sort recipes
            let sortedRecipes = sortRecipesByPantryMatch(recipes: recipes, pantryList: pantryList)

            List(sortedRecipes) { recipe in
                RecipeTileView(recipe: recipe, pantryList: pantryList)
            }

            Spacer()
        }
    }
}

#Preview {
    RecipeModalView(pantryList: .constant([]), recipes: .constant([
        Recipe(id: "1", name: "Spaghetti", ingredients: ["Spaghetti", "Tomato", "Garlic", "Olive Oil"]),
        Recipe(id: "2", name: "Taco", ingredients: ["Taco Shell", "Lettuce", "Cheese", "Beef"]),
        Recipe(id: "3", name: "Salad", ingredients: ["Lettuce", "Tomato", "Cucumber"])
    ]))
}
