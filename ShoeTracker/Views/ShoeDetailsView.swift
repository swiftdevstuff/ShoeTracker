//
//  ShoeDetailsView.swift
//  ShoeTracker
//
//  Created by Matthew Johanson on 11/03/2025.
//

//
//  ShoeDetailsView.swift
//  ShoeTracker
//
//  Created by Matthew Johanson on 11/03/2025.
//

import SwiftUI
import SwiftData

struct ShoeDetailsView: View {
    let tryOn: TryOn
    @Environment(\.colorScheme) var colorScheme
    @State private var showShareSheet = false
    
    private var accentColor: Color { Color.blue }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.systemGroupedBackground)
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Hero section with name and purchase status
                    VStack(spacing: 16) {
                        // Shoe name
                        Text(tryOn.name)
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        // Purchase status badge
                        if tryOn.purchased {
                            Text("PURCHASED")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.green.opacity(0.2))
                                )
                                .foregroundColor(.green)
                        } else {
                            Text("TRY-ON ONLY")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.orange.opacity(0.2))
                                )
                                .foregroundColor(.orange)
                        }
                        
                        // Rating display
                        VStack(spacing: 8) {
                            Text("Fit Rating")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(String(format: "%.1f", tryOn.rating))
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(accentColor)
                            
                            // Stars
                            HStack(spacing: 4) {
                                ForEach(1...5, id: \.self) { index in
                                    if Double(index) <= tryOn.rating / 2 {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                    } else if Double(index) - 0.5 <= tryOn.rating / 2 {
                                        Image(systemName: "star.leadinghalf.filled")
                                            .foregroundColor(.yellow)
                                    } else {
                                        Image(systemName: "star")
                                            .foregroundColor(.yellow)
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 5)
                    )
                    .padding(.horizontal)
                    
                    // Specifications card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "shoeprints.fill")
                                .foregroundColor(accentColor)
                            
                            Text("Specifications")
                                .font(.headline)
                                .fontWeight(.bold)
                                
                            Spacer()
                        }
                        
                        Divider()
                        
                        // Size, Width, Color in grid layout
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            specItem(label: "Size", value: tryOn.size, icon: "ruler")
                            specItem(label: "Width", value: tryOn.width, icon: "arrow.left.and.right")
                            specItem(label: "Color", value: tryOn.color, icon: "paintpalette")
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 5)
                    )
                    .padding(.horizontal)
                    
                    // Try-on details card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "shoe.circle")
                                .foregroundColor(accentColor)
                            
                            Text("Try-on Details")
                                .font(.headline)
                                .fontWeight(.bold)
                                
                            Spacer()
                        }
                        
                        Divider()
                        
                        // Date with icon
                        HStack(spacing: 12) {
                            Image(systemName: "calendar")
                                .foregroundColor(.secondary)
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading) {
                                Text("Try-on Date")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(tryOn.date.formatted(date: .long, time: .omitted))
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                        }
                        
                        // Location with icon
                        if !tryOn.location.isEmpty {
                            HStack(spacing: 12) {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.secondary)
                                    .frame(width: 24, height: 24)
                                
                                VStack(alignment: .leading) {
                                    Text("Store Location")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text(tryOn.location)
                                        .font(.body)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 5)
                    )
                    .padding(.horizontal)
                    
                    // Notes card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "note.text")
                                .foregroundColor(accentColor)
                            
                            Text("Notes")
                                .font(.headline)
                                .fontWeight(.bold)
                                
                            Spacer()
                        }
                        
                        Divider()
                        
                        if tryOn.details.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 24))
                                        .foregroundColor(.secondary)
                                    
                                    Text("No notes available")
                                        .foregroundColor(.secondary)
                                        .italic()
                                }
                                Spacer()
                            }
                            .padding(.vertical, 16)
                        } else {
                            Text(tryOn.details)
                                .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 5)
                    )
                    .padding(.horizontal)
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        Button {
                            // Share functionality
                            showShareSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(UIColor.tertiarySystemGroupedBackground))
                            )
                        }
                        .foregroundColor(.primary)
                        
                        NavigationLink(destination: EditShoeView(tryOn: tryOn)) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(accentColor)
                            )
                            .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                }
                .padding(.vertical, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        // Add to favorites action
                    }) {
                        Label("Add to Favorites", systemImage: "heart")
                    }
                    
                    Button(action: {
                        // Share action
                        showShareSheet = true
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive, action: {
                        // Delete action
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            let text = "Check out this shoe I tried: \(tryOn.name) - Rating: \(tryOn.rating)/10"
            ActivityView(activityItems: [text])
        }
    }
    
    // Helper view for specs display
    private func specItem(label: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(accentColor)
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value.isEmpty ? "—" : value)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// Activity view for sharing
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Placeholder for EditShoeView
struct EditShoeView: View {
    let tryOn: TryOn
    
    var body: some View {
        Text("Edit Shoe View")
            .navigationTitle("Edit Shoe")
    }
}

// Preview provider
struct ShoeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ShoeDetailsView(tryOn: TryOn(
                id: UUID(),
                name: "Nike Air Max",
                details: "Very comfortable with good arch support. The toe box is a bit narrow.",
                rating: 8.5,
                purchased: true,
                size: "10.5",
                date: Date(),
                color: "Black/Red",
                width: "Medium",
                location: "Nike Store"
            ))
        }
    }
}
