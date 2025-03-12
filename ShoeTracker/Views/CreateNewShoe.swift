//
//  CreateNewShoe.swift
//  ShoeTracker
//
//  Created by Matthew Johanson on 10/03/2025.
//

import SwiftUI
import SwiftData

struct CreateNewShoe: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @State private var shoeName = ""
    @State private var shoeWidth = ""
    @State private var shoeDetails = ""
    @State private var shoeRating: Double = 5.0
    @State private var shoeTryOnDate = Date()
    @State private var shoePurchased = false
    @State private var shoeColor = ""
    @State private var shoeSize = ""
    @State private var storeLocation = ""
    
    // Color scheme based on system theme
    private var accentColor: Color {
        Color.blue
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.systemGroupedBackground)
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header with save button
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .foregroundColor(accentColor)
                        }
                        
                        Spacer()
                        
                        Text("New Shoe")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button {
                            saveTryOn()
                        } label: {
                            Text("Save")
                                .fontWeight(.bold)
                                .foregroundColor(accentColor)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Basic Info Card
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Basic Info")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        CustomTextField(title: "Shoe Name", text: $shoeName, icon: "shippingbox")
                        
                        HStack(spacing: 12) {
                            CustomTextField(title: "Size", text: $shoeSize, icon: "ruler", keyboard: .decimalPad)
                                .frame(maxWidth: .infinity)
                            
                            CustomTextField(title: "Width", text: $shoeWidth, icon: "arrow.left.and.right", keyboard: .default)
                                .frame(maxWidth: .infinity)
                        }
                        
                        CustomTextField(title: "Color", text: $shoeColor, icon: "paintpalette")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 5)
                    )
                    .padding(.horizontal)
                    
                    // Try-on Details Card
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Try-on Details")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        // Rating View
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Overall Fit Rating")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text("\(Int(shoeRating))")
                                    .font(.system(size: 36, weight: .bold))
                                
                                Text("/10")
                                    .font(.system(size: 20))
                                    .foregroundColor(.secondary)
                                    .padding(.top, 8)
                                
                                Spacer()
                                
                                // Star representation
                                HStack(spacing: 2) {
                                    ForEach(1...5, id: \.self) { index in
                                        Image(systemName: index <= Int(shoeRating) / 2 ? "star.fill" : "star")
                                            .foregroundColor(.yellow)
                                    }
                                }
                            }
                            
                            Slider(value: $shoeRating, in: 1...10, step: 1)
                                .accentColor(accentColor)
                        }
                        
                        Divider()
                        
                        // Date picker & purchase indicator
                        HStack(alignment: .center, spacing: 50) { // Adjust spacing as needed
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Try-on Date")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                DatePicker("", selection: $shoeTryOnDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                            }

                            VStack(alignment: .leading, spacing: 10) { // Align text and toggle properly
                                Text(shoePurchased ? "Purchased" : "Purchased?")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Toggle("", isOn: $shoePurchased)
                                    .labelsHidden()
                            }
                        }
                        .padding(.horizontal)

                        
                        Divider()
                        
                        // Store location
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Store Location")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.secondary)
                                
                                TextField("Add store location", text: $storeLocation)
                            }
                        }
                        
                        Divider()
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Notes")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextEditor(text: $shoeDetails)
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(Color(UIColor.tertiarySystemGroupedBackground))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 5)
                    )
                    .padding(.horizontal)
                    
                    // Save button
                    Button {
                        saveTryOn()
                    } label: {
                        Text("Save Shoe")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(accentColor)
                            )
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .padding(.vertical, 20)
            }
        }
        .navigationBarHidden(true)
    }
    
    func saveTryOn() {
        let newTryOn = TryOn(
            id: UUID(),
            name: shoeName,
            details: shoeDetails,
            rating: shoeRating,
            purchased: shoePurchased,
            size: shoeSize,
            date: shoeTryOnDate,
            color: shoeColor,
            width: shoeWidth,
            location: storeLocation
        )
        modelContext.insert(newTryOn)
        try? modelContext.save()
        dismiss()
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    var keyboard: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                
                TextField(title, text: $text)
                    .keyboardType(keyboard)
            }
            .padding(.vertical, 8)
            
            Divider()
        }
    }
}


#Preview {
    CreateNewShoe()
}
