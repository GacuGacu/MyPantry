//
//  sortRecipe.swift
//  MyPantry
//
//  Created by  on 18/11/2024.
//

import Foundation

// Sort recipes to ensure full recipes come first.
func sortRecipesByPantryMatch(recipes: [Recipe], pantryList: [PantryIngredient]) -> [Recipe] {
    return recipes.sorted { recipe1, recipe2 in
        let recipe1MissingIngredients = recipe1.ingredients.filter { ingredient in
            !pantryList.contains { pantryItem in
                pantryItem.name.lowercased() == ingredient.lowercased()
            }
        }
        let recipe2MissingIngredients = recipe2.ingredients.filter { ingredient in
            !pantryList.contains { pantryItem in
                pantryItem.name.lowercased() == ingredient.lowercased()
            }
        }
        return recipe1MissingIngredients.isEmpty && !recipe2MissingIngredients.isEmpty
    }
}
