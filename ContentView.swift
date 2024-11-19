
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    @State var isLoggedIn = false
    @State var pantryList: [PantryIngredient] = []
    @State var recipes: [Recipe] = []
    @State var userId = ""
    
    @State var ingredientName = ""
    @State var ingredientCategory = "Fruit 🍎"
    @State var ingredientFrozen = false
    @State var showAddIngredientForm = false
    @State private var showErrorAlert = false
    @State var showRecipeModal = false
    @State var isCheckingSession = true
    
    // Categories for filtering
    let categories = [
        "Fruit 🍎", "Vegetable 🥦", "Meat 🍖","Fish 🍣", "Condiment 🥫", "Spices 🍶", "Dairy 🧀", "Grains 🌾", "Nuts 🌰"
    ]
    
    var body: some View {
        if(isCheckingSession){
            ProgressView("Logging in...")
                .onAppear{
                    checkUserSession()
                }
        } else if isLoggedIn {
            NavigationStack {
                ZStack {
                    VStack {
                        PantryListView(pantryList: $pantryList, userId: $userId)
                    }
                    
                    VStack {
                        Spacer()
                        HStack {
                            Button(action: {
                                searchForRecipes()
                                print("Search for recipe")
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            .padding()
                            .sheet(isPresented: $showRecipeModal) {
                                NavigationStack {
                                    RecipeModalView(pantryList: $pantryList, recipes: $recipes)
                                }
                            }
                            Button(action: {
                                showAddIngredientForm.toggle()
                            }) {
                                Text("+")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.green)
                                    .clipShape(Circle())
                            }
                            .padding()
                        }
                    }
                    
                    if showAddIngredientForm {
                        AddIngredientsFormView(
                            showAddIngredientForm: $showAddIngredientForm,
                            ingredientName: $ingredientName,
                            ingredientCategory: $ingredientCategory,
                            ingredientFrozen: $ingredientFrozen,
                            pantryList: $pantryList,
                            userId: userId
                        )
                    }
                }
                .navigationTitle("My Pantry")
                .navigationBarTitleDisplayMode(.large)
                .navigationBarItems(trailing: Button(action: {
                    signOutUser { result in
                        switch result {
                        case .success(_):
                            isLoggedIn = false
                            print("Signed out")
                        case .failure(_):
                            print("Error")
                            showErrorAlert = true
                        }
                    }
                }, label: {
                    Image(systemName: "door.left.hand.open")
                }))
                .alert(isPresented: $showErrorAlert) {
                    Alert(
                        title: Text("Error logging you out"),
                        message: Text("Please try again later"),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        } else {
            Login_SignupView(isLoggedIn: $isLoggedIn, pantryList: $pantryList, userId: $userId)
        }
        
    }
    
    private func searchForRecipes() {
        // Fetch all recipes for the user from Firebase
        fetchAllRecipesFromFirebase(userId: userId) { result in
            switch result {
            case .success(let fetchedRecipes):
                // Save the fetched recipes to the state
                recipes = fetchedRecipes
                showRecipeModal = true
            case .failure(let error):
                print("Error fetching recipes: \(error.localizedDescription)")
            }
        }
    }
    private func checkUserSession() {
            if let user = Auth.auth().currentUser {
                // User is logged in, fetch their pantry data
                userId = user.uid
                fetchUserPantry(uid: user.uid) { result in
                    switch result {
                    case .success(let pantry):
                        pantryList = pantry
                        isLoggedIn = true
                    case .failure(let error):
                        print("Failed to fetch pantry: \(error.localizedDescription)")
                        isLoggedIn = false
                    }
                    isCheckingSession = false
                }
            } else {
                // No user logged in
                isLoggedIn = false
                isCheckingSession = false
            }
        }
}
#Preview {
    ContentView()
}
