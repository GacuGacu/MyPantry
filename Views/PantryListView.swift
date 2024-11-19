import SwiftUI

struct PantryListView: View {
    @Binding var pantryList: [PantryIngredient]
    @Binding var userId: String
    @State private var showErrorAlert = false

    private var sortedIndices: [Int] {
            pantryList.indices.sorted { pantryList[$0].frozen == false && pantryList[$1].frozen == true }
        }

    var body: some View {
            List {
                ForEach(sortedIndices, id: \.self) { index in
                    ProductCellView(ingredient: $pantryList[index], userId: $userId)
                }
                .onDelete(perform: deleteIngredient)
            }
        .listStyle(PlainListStyle())
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Error deleting ingredient"),
                message: Text("There was an error deleting this ingredient. Please try again."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func deleteIngredient(at offsets: IndexSet) {
        for index in offsets {
            let ingredient = pantryList[index]
            
            // Remove the ingredient locally from the list
            pantryList.remove(at: index)
            
            // Call the function to delete from Firebase
            deleteIngredientFromFirebase(ingredient: ingredient, userId: userId) { result in
                switch result {
                case .success:
                    print("Ingredient successfully deleted from Firebase.")
                case .failure(let error):
                    print("Error deleting ingredient from Firebase: \(error.localizedDescription)")
                    showErrorAlert = true
                }
            }
        }
    }
}

#Preview {
    PantryListView(pantryList: .constant([]), userId: .constant("?"))
}
