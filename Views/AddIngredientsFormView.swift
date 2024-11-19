import SwiftUI

struct AddIngredientsFormView: View {
    @Binding var showAddIngredientForm: Bool
    @Binding var ingredientName: String
    @Binding var ingredientCategory: String
    @Binding var ingredientFrozen: Bool
    @Binding var pantryList: [PantryIngredient]
    @State private var isAddingRecipe = false
    @State private var recipeName = ""
    @State private var recipeIngredients: [String] = []
    @State private var newIngredient = ""
    let userId: String
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    resetForm()
                    showAddIngredientForm = false
                }
            
            VStack(spacing: 12) {
                // Switcher between Add Ingredient and Add Recipe
                Picker(selection: $isAddingRecipe, label: Text("")) {
                    Text("Add Ingredient").tag(false)
                    Text("Add Recipe").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if isAddingRecipe {
                    // Add Recipe UI
                    VStack(spacing: 12) {
                        Text("Add Recipe")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.bottom, 8)
                        
                        // Recipe Name
                        TextField("Recipe Name", text: $recipeName)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                        
                        // Ingredients List
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ingredients:")
                                .font(.headline)
                            
                            ForEach(recipeIngredients, id: \.self) { ingredient in
                                HStack {
                                    Text(ingredient)
                                    Spacer()
                                    Button(action: {
                                        recipeIngredients.removeAll { $0 == ingredient }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            
                            HStack {
                                TextField("Add Ingredient", text: $newIngredient)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(15)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                                
                                Button(action: {
                                    if !newIngredient.isEmpty {
                                        recipeIngredients.append(newIngredient)
                                        newIngredient = ""
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .padding(.vertical)
                        
                        // Action Buttons
                        HStack {
                            Button(action: {
                                resetForm()
                                showAddIngredientForm = false
                            }) {
                                Text("Cancel")
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            
                            Spacer()
                            
                            Button(action: {
                                if !recipeName.isEmpty && !recipeIngredients.isEmpty {
                                    addRecipeToFirebase(name: recipeName, ingredients: recipeIngredients, userId: userId) { result in
                                        switch result {
                                        case .success:
                                            print("Recipe added successfully.")
                                            resetForm()
                                            showAddIngredientForm = false
                                        case .failure(let error):
                                            print("Error adding recipe: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }) {
                                Text("Add Recipe")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                        }
                    }
                } else {
                    // Add Ingredient UI
                    VStack(spacing: 12) {
                        Text("Add Ingredient")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.bottom, 8)
                        
                        // Ingredient Name
                        TextField("Ingredient Name", text: $ingredientName)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                        
                        // Category Picker
                        CategoryPicker(
                            selectedCategory: $ingredientCategory,
                            categories: [
                                "Fruit 🍎", "Vegetable 🥦", "Meat 🍖","Fish 🍣", "Condiment 🥫", "Spices 🍶", "Dairy 🧀", "Grains 🌾", "Nuts 🌰"
                            ]
                        )
                        
                        // Frozen Toggle
                        Toggle(isOn: $ingredientFrozen) {
                            Text("Frozen")
                                .font(.headline)
                        }
                        .padding(.horizontal)
                        
                        // Action Buttons
                        HStack {
                            Button(action: {
                                resetForm()
                                showAddIngredientForm = false
                            }) {
                                Text("Cancel")
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            
                            Spacer()
                            
                            Button(action: {
                                if !ingredientName.isEmpty && !ingredientCategory.isEmpty {
                                    addIngredientToPantry(
                                        name: ingredientName,
                                        category: ingredientCategory,
                                        frozen: ingredientFrozen,
                                        userId: userId,
                                        pantryList: pantryList
                                    ) { result, updatedPantryList in
                                        switch result {
                                        case .success:
                                            pantryList = updatedPantryList
                                            resetForm()
                                            showAddIngredientForm = false
                                            print("Success appending ingredient.")
                                        case .failure(let error):
                                            print("Failed to add ingredient: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }) {
                                Text("Add Ingredient")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .gray.opacity(0.4), radius: 10, x: 0, y: 4)
            )
            .frame(maxWidth: 300)
        }
    }
    
    private func resetForm() {
        ingredientName = ""
        ingredientCategory = "Fruit 🍎"
        ingredientFrozen = false
        recipeName = ""
        recipeIngredients.removeAll()
        newIngredient = ""
    }
}

#Preview {
    AddIngredientsFormView(
        showAddIngredientForm: .constant(true),
        ingredientName: .constant(""),
        ingredientCategory: .constant(""),
        ingredientFrozen: .constant(false),
        pantryList: .constant([]),
        userId: "rM4OO8r1aQes72p9IxjJFwhVAiP2"
    )
}
