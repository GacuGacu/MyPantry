import Foundation
import FirebaseAuth
import FirebaseFirestore

// PantryIngredient Model
struct PantryIngredient: Codable {
    var id: String
    var name: String
    var category: String
    var frozen: Bool
    var qty: Int
}
//Recipe model
struct Recipe: Identifiable {
    let id: String
    let name: String
    let ingredients: [String]
}


// MARK: - Firebase Authentication Functions

// Sign Up function
public func signUpUser(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
    Auth.auth().createUser(withEmail: email, password: password) { result, error in
        if let error = error {
            completion(.failure(error))
        } else if let user = result?.user {
            let db = Firestore.firestore()
            
            // Store the user data in Firestore with an empty pantry
            db.collection("users").document(user.uid).setData([
                "email": email,
                "uid": user.uid,
                "pantry": [], // Start with an empty pantry
                "recipes": []
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(user))
                }
            }
        }
    }
}

// Login function
func loginUser(email: String, password: String, completion: @escaping (Result<(User, [PantryIngredient]), Error>) -> Void) {
    Auth.auth().signIn(withEmail: email, password: password) { result, error in
        if let error = error {
            completion(.failure(error))
        } else if let user = result?.user {
            fetchUserPantry(uid: user.uid) { pantryResult in
                switch pantryResult {
                case .success(let pantry):
                    completion(.success((user, pantry)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}


// Sign Out function
public func signOutUser(completion: @escaping (Result<Void, Error>) -> Void) {
    do {
        try Auth.auth().signOut()
        completion(.success(()))
    } catch let error {
        completion(.failure(error))
    }
}

// Fetch User Pantry
func fetchUserPantry(uid: String, completion: @escaping (Result<[PantryIngredient], Error>) -> Void) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(uid)
    
    userRef.getDocument { document, error in
        if let error = error {
            completion(.failure(error))
        } else if let document = document, document.exists {
            if let pantryArray = document.data()?["pantry"] as? [[String: Any]] {
                // Parse the pantry array into `PantryIngredient` objects
                let pantry = pantryArray.compactMap { dictionary -> PantryIngredient? in
                    guard
                        let id = dictionary["id"] as? String,
                        let name = dictionary["name"] as? String,
                        let category = dictionary["category"] as? String,
                        let frozen = dictionary["frozen"] as? Bool,
                        let qty = dictionary["qty"] as? Int
                    else {
                        return nil
                    }
                    return PantryIngredient(id: id, name: name, category: category, frozen: frozen, qty: qty)
                }
                completion(.success(pantry))
            } else {
                completion(.success([]))
            }
        } else {
            completion(.failure(NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: "User document does not exist."])))
        }
    }
}

// Add Ingredient to Pantry
func addIngredientToPantry(name: String, category: String, frozen: Bool, userId: String, pantryList: [PantryIngredient], completion: @escaping (Result<Void, Error>, [PantryIngredient]) -> Void) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(userId)
    
    // Generate UUID for the ingredient
    let ingredientId = UUID().uuidString
    
    // Create a dictionary for the new ingredient with the generated UUID
    let newIngredient: [String: Any] = [
        "id": ingredientId,    // Use the generated UUID here
        "name": name,
        "category": category,
        "frozen": frozen,
        "qty": 1
    ]
    userRef.updateData([
        "pantry": FieldValue.arrayUnion([newIngredient])
    ]) { error in
        if let error = error {
            completion(.failure(error), pantryList)
        } else {
            let addedIngredient = PantryIngredient(id: ingredientId, name: name, category: category, frozen: frozen, qty: 1)
            var updatedPantryList = pantryList
            updatedPantryList.append(addedIngredient)
            completion(.success(()), updatedPantryList)
        }
    }
}



// Delete Ingredient from Pantry
func deleteIngredientFromFirebase(ingredient: PantryIngredient, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(userId)
    
    let ingredientToDelete: [String: Any] = [
        "id": ingredient.id,
        "name": ingredient.name,
        "category": ingredient.category,
        "frozen": ingredient.frozen,
        "qty": ingredient.qty
    ]
    print(ingredientToDelete)
    print(userRef)
    userRef.updateData([
        "pantry": FieldValue.arrayRemove([ingredientToDelete])
    ]) { error in
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(()))
        }
    }
}

import FirebaseFirestore

func updateFrozenState(ingredientId: String, isFrozen: Bool, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(userId)
    userRef.getDocument { document, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        guard let document = document, var pantry = document.data()?["pantry"] as? [[String: Any]] else {
            completion(.failure(NSError(domain: "Firestore", code: -1, userInfo: [NSLocalizedDescriptionKey: "Pantry data not found."])))
            return
        }
        print(ingredientId)
        for i in 0..<pantry.count {
            if pantry[i]["id"] as? String == ingredientId {
                pantry[i]["frozen"] = isFrozen
                userRef.updateData(["pantry": pantry]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
                return
            }
        }
        completion(.failure(NSError(domain: "Firestore", code: -2, userInfo: [NSLocalizedDescriptionKey: "Ingredient with specified ID not found."])))
    }
}

func addRecipeToFirebase(name: String, ingredients: [String], userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(userId)
    let newRecipe: [String: Any] = [
        "id": UUID().uuidString,
        "name": name,
        "ingredients": ingredients
    ]
    userRef.updateData([
        "recipes": FieldValue.arrayUnion([newRecipe])
    ]) { error in
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(()))
        }
    }
}

func fetchAllRecipesFromFirebase(userId: String, completion: @escaping (Result<[Recipe], Error>) -> Void) {
    let db = Firestore.firestore()
    // Fetch the user document
    db.collection("users").document(userId).getDocument { document, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let document = document, document.exists else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User document not found."])))
            return
        }
        
        // Fetch the recipes from the "recipes" field
        if let recipesData = document.data()?["recipes"] as? [[String: Any]] {
            var recipes: [Recipe] = []
            // Convert each recipe dictionary into a Recipe object
            for recipeData in recipesData {
                if let name = recipeData["name"] as? String,
                   let ingredients = recipeData["ingredients"] as? [String] {
                    let recipe = Recipe(id: UUID().uuidString, name: name, ingredients: ingredients)
                    recipes.append(recipe)
                }
            }
            // Return the recipes array
            completion(.success(recipes))
        } else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Recipes not found."])))
        }
    }
}


