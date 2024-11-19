import SwiftUI

struct ProductCellView: View {
    @Binding var ingredient: PantryIngredient
    @Binding var userId: String
    
    var body: some View {
        HStack {
            // Product name (leftmost)
            Text(ingredient.name)
                .font(.headline)
                .padding(.leading, 10)
            
            // Category (a bit after the product name)
            Text(ingredient.category)
                .padding(.leading, 10)
                .font(.subheadline)
            
            Spacer()
            Button(action: {
                ingredient.frozen.toggle() // Toggle frozen state
                updateFrozenState(ingredientId: ingredient.id, isFrozen: ingredient.frozen, userId: userId) { result in
                    switch result {
                    case .success:
                        print("Successfully updated frozen state for ingredient \(ingredient.name).")
                    case .failure(let error):
                        print("Failed to update frozen state: \(error.localizedDescription)")
                    }
                }

            }) {
                Text(ingredient.frozen ? "❄️" : "🔥")
                    .font(.title)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
        }
        .padding()
        .background(ingredient.frozen ? Color.blue.opacity(0.3) : Color.white) // Icy blue background when frozen
        .cornerRadius(10)
    }
}

#Preview {
    ProductCellView(ingredient: .constant(PantryIngredient(
        id: "ABC",
        name: "Tomato",
        category: "Fruit 🍎",
        frozen: false,
        qty: 1
    )), userId: .constant("1122"))
}

