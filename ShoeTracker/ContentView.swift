//
//  ContentView.swift
//  ShoeTracker
//
//  Created by Matthew Johanson on 10/03/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \TryOn.date, order: .reverse) var tryOns: [TryOn]
    @State private var showingAddShoeSheet = false
    @State private var showingSettingsSheet = false
    @State private var searchText = ""
    @State private var showingFilterSheet = false
    @State private var filterPurchased: FilterOption = .all
    @State private var filterRating: Double? = nil
    @State private var showingDeleteAlert = false
    @State private var shoeToDelete: TryOn?
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    private var accentColor: Color { Color.blue }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.systemGroupedBackground)
    }
    
    // Filtered tryOns based on search text and filters
    private var filteredTryOns: [TryOn] {
        tryOns.filter { tryOn in
            let matchesSearch = searchText.isEmpty ||
                tryOn.name.localizedCaseInsensitiveContains(searchText) ||
                tryOn.details.localizedCaseInsensitiveContains(searchText) ||
                tryOn.color.localizedCaseInsensitiveContains(searchText) ||
                tryOn.location.localizedCaseInsensitiveContains(searchText)
            
            let matchesPurchased: Bool
            switch filterPurchased {
            case .all:
                matchesPurchased = true
            case .purchased:
                matchesPurchased = tryOn.purchased
            case .notPurchased:
                matchesPurchased = !tryOn.purchased
            }
            
            let matchesRating: Bool
            if let minRating = filterRating {
                matchesRating = tryOn.rating >= minRating
            } else {
                matchesRating = true
            }
            
            return matchesSearch && matchesPurchased && matchesRating
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 8) {
                        // Search and filter bar
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                
                                TextField("Search shoes", text: $searchText)
                                    .submitLabel(.search)
                                
                                if !searchText.isEmpty {
                                    Button(action: {
                                        searchText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                            )
                            
                            Button(action: {
                                showingFilterSheet = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                        .font(.system(size: 16))
                                    
                                    if filterPurchased != .all || filterRating != nil {
                                        Text("\(isFiltering ? "•" : "")")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(accentColor)
                                    }
                                }
                                .frame(width: 44, height: 44)
                                .foregroundColor(isFiltering ? accentColor : .primary)
                            }
                        }
                        .padding(.horizontal)
                        
                        if isFiltering {
                            FilterChipsView(
                                filterPurchased: $filterPurchased,
                                filterRating: $filterRating
                            )
                            .padding(.horizontal)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        if filteredTryOns.isEmpty {
                            // Content unavailable view when no shoes match
                            VStack(spacing: 16) {
                                Spacer()
                                
                                if tryOns.isEmpty {
                                    // No shoes at all
                                    VStack(spacing: 16) {
                                        Image(systemName: "shoe")
                                            .font(.system(size: 60))
                                            .foregroundColor(.secondary)
                                            .symbolEffect(.pulse)
                                        
                                        Text("No shoes")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        
                                        Text("You don't have any saved shoes yet.")
                                            .foregroundColor(.secondary)
                                        
                                        Button(action: {
                                            showingAddShoeSheet.toggle()
                                        }) {
                                            HStack {
                                                Image(systemName: "plus.circle.fill")
                                                Text("Create Shoe")
                                            }
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(accentColor)
                                            )
                                            .foregroundColor(.white)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                } else {
                                    // No matches for the search/filter
                                    VStack(spacing: 16) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 60))
                                            .foregroundColor(.secondary)
                                        
                                        Text("No matches")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        
                                        Text("Try adjusting your search or filters")
                                            .foregroundColor(.secondary)
                                        
                                        Button(action: {
                                            // Clear all search and filters
                                            searchText = ""
                                            filterPurchased = .all
                                            filterRating = nil
                                        }) {
                                            HStack {
                                                Image(systemName: "arrow.clockwise")
                                                Text("Reset Filters")
                                            }
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color(UIColor.tertiarySystemGroupedBackground))
                                            )
                                            .foregroundColor(.primary)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                
                                Spacer()
                            }
                            .frame(minHeight: 400)
                            .frame(maxWidth: .infinity)
                        } else {
                            // Grid of shoes
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                                ForEach(filteredTryOns) { tryOn in
                                    ShoeCardView(
                                        tryOn: tryOn,
                                        onDelete: {
                                            shoeToDelete = tryOn
                                            showingDeleteAlert = true
                                        }
                                    )
                                    .contextMenu {
                                        // Context menu for additional options
                                        NavigationLink(destination: ShoeDetailsView(tryOn: tryOn)) {
                                            Label("View Details", systemImage: "eye")
                                        }
                                        
                                        NavigationLink(destination: EditShoeView(tryOn: tryOn)) {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        
                                        Button(role: .destructive) {
                                            shoeToDelete = tryOn
                                            showingDeleteAlert = true
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .transition(.opacity)
                                    .animation(.easeInOut, value: filteredTryOns)
                                }
                            }
                            .padding()
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("ShoeTracker")
            .navigationDestination(for: TryOn.self) { tryOn in
                ShoeDetailsView(tryOn: tryOn)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddShoeSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .symbolEffect(.scale)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettingsSheet.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .symbolEffect(.rotate.byLayer, options: .nonRepeating)
                    }
                }
            }
            .alert("Delete Shoe", isPresented: $showingDeleteAlert, presenting: shoeToDelete) { shoe in
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    withAnimation {
                        deleteItem(shoe)
                    }
                }
            } message: { shoe in
                Text("Are you sure you want to delete \"\(shoe.name)\"? This action cannot be undone.")
            }
        }
        .sheet(isPresented: $showingAddShoeSheet) {
            CreateNewShoe()
        }
        .sheet(isPresented: $showingSettingsSheet) {
            Settings()
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterSheetView(
                filterPurchased: $filterPurchased,
                filterRating: $filterRating
            )
            .presentationDetents([.medium])
        }
    }
    
    private var isFiltering: Bool {
        filterPurchased != .all || filterRating != nil
    }
    
    private func deleteItem(_ item: TryOn) {
        // Perform the deletion on the next run loop to avoid UI update issues
        DispatchQueue.main.async {
            withAnimation {
                modelContext.delete(item)
                try? modelContext.save()
            }
        }
    }
}

// Shoe card view for the grid
struct ShoeCardView: View {
    let tryOn: TryOn
    var onDelete: () -> Void = {}
    
    @State private var isShowingDeleteOverlay = false
    @GestureState private var dragOffset: CGSize = .zero
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Card 
            NavigationLink(value: tryOn) {
                VStack {
                    VStack(spacing: 12) {
                        ZStack(alignment: .topTrailing) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "shoe")
                                    .font(.system(size: 36))
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top)
                            
                            // Badge for purchased status
                            if tryOn.purchased {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .background(Circle().fill(Color.white).frame(width: 16, height: 16))
                                    .padding(8)
                            }
                        }
                        
                        // Shoe name
                        Text(tryOn.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        
                        // Rating
                        HStack {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.yellow)
                            
                            Text(String(format: "%.1f", tryOn.rating))
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        // Date and size
                        HStack {
                            Text(tryOn.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("Size \(tryOn.size)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.blue.opacity(0.1))
                                )
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 5)
                    )
                }
                .buttonStyle(.plain)
                .offset(x: offset + dragOffset.width)
            }
        }
    }
}

// Filter options
enum FilterOption: Int, CaseIterable, Identifiable {
    case all
    case purchased
    case notPurchased
    
    var id: Int { self.rawValue }
    
    var title: String {
        switch self {
        case .all: return "All"
        case .purchased: return "Purchased"
        case .notPurchased: return "Try-on Only"
        }
    }
}

// Filter chips view
struct FilterChipsView: View {
    @Binding var filterPurchased: FilterOption
    @Binding var filterRating: Double?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                // Purchase status filters
                ForEach(FilterOption.allCases) { option in
                    Button {
                        filterPurchased = option
                    } label: {
                        Text(option.title)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .stroke(filterPurchased == option ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1.5)
                                    .background(
                                        Capsule()
                                            .fill(filterPurchased == option ? Color.blue.opacity(0.1) : Color.clear)
                                    )
                            )
                            .foregroundColor(filterPurchased == option ? .blue : .primary)
                    }
                }
                
                // Rating filters
                ForEach([7.0, 8.0, 9.0], id: \.self) { rating in
                    Button {
                        filterRating = filterRating == rating ? nil : rating
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                            Text("≥ \(Int(rating))")
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .stroke(filterRating == rating ? Color.yellow : Color.gray.opacity(0.3), lineWidth: 1.5)
                                .background(
                                    Capsule()
                                        .fill(filterRating == rating ? Color.yellow.opacity(0.1) : Color.clear)
                                )
                        )
                        .foregroundColor(filterRating == rating ? .primary : .primary)
                    }
                }
                
                // Reset button
                if filterPurchased != .all || filterRating != nil {
                    Button {
                        filterPurchased = .all
                        filterRating = nil
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12))
                            Text("Reset")
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                        )
                        .foregroundColor(.primary)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// Filter sheet view
struct FilterSheetView: View {
    @Binding var filterPurchased: FilterOption
    @Binding var filterRating: Double?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    // Purchase status section
                    Section(header: Text("Purchase Status")) {
                        ForEach(FilterOption.allCases) { option in
                            Button {
                                filterPurchased = option
                            } label: {
                                HStack {
                                    Text(option.title)
                                    Spacer()
                                    if filterPurchased == option {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // Rating section
                    Section(header: Text("Minimum Rating")) {
                        Toggle(isOn: Binding(
                            get: { filterRating != nil },
                            set: { if !$0 { filterRating = nil } else if filterRating == nil { filterRating = 8.0 } }
                        )) {
                            Text("Filter by rating")
                        }
                        
                        if filterRating != nil {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("\(String(format: "%.1f", filterRating ?? 0)) or higher")
                                        .font(.headline)
                                    Spacer()
                                    
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                        Text("\(String(format: "%.1f", filterRating ?? 0))")
                                            .fontWeight(.medium)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.yellow.opacity(0.1))
                                    )
                                }
                                
                                Slider(
                                    value: Binding(
                                        get: { filterRating ?? 8.0 },
                                        set: { filterRating = $0 }
                                    ),
                                    in: 0...10,
                                    step: 0.5
                                )
                            }
                        }
                    }
                }
                
                // Apply/Reset buttons
                HStack {
                    Button {
                        // Reset all filters
                        filterPurchased = .all
                        filterRating = nil
                        dismiss()
                    } label: {
                        Text("Reset")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        // Apply the filters
                        dismiss()
                    } label: {
                        Text("Apply")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue)
                            )
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .navigationTitle("Filter Shoes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Preview provider
#Preview {
    ContentView()
}
