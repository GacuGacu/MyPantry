//
//  CategoryPicker.swift
//  MyPantry
//
//  Created by Kacper Domagała on 17/11/2024.
//

import SwiftUI

struct CategoryPicker: View {
    @Binding var selectedCategory: String
    let categories: [String]
    
    var body: some View {
        VStack {
            Text("Choose a Category:")
                .font(.headline)
            
            // Horizontal Scroll View for category selection
            ScrollView(.horizontal) {
                HStack {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            Text(category)
                                .padding()
                                .background(selectedCategory == category ? Color.blue : Color.white)
                                .foregroundColor(selectedCategory == category ? .white : .blue)
                                .cornerRadius(10)
                                .shadow(color: selectedCategory == category ? Color.clear : Color.gray.opacity(0.5), radius: 5, x: 0, y: 2)
                        }
                        .padding(4)
                    }
                }
            }
        }
    }
}

#Preview {
    CategoryPicker(
        selectedCategory: .constant("Fruit 🍎"),
        categories: ["Fruit 🍎", "Vegetable 🥦", "Meat 🍖","Fish 🍣", "Condiment 🥫", "Spices 🍶", "Dairy 🧀", "Grains 🌾", "Nuts 🌰"]
    )
}
