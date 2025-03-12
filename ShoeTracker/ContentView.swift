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
    @Environment(\.modelContext) private var modelContext
    @State private var lastSavedId: UUID? = nil

    
    var body: some View {
        NavigationStack {
            ZStack {
                if tryOns.isEmpty {
                    // Show ContentUnavailableView when no shoes exist
                    ContentUnavailableView {
                        Label {
                            Text("No shoes")
                        } icon: {
                            Image(systemName: "shoe")
                        }
                    } description: {
                        Text("You don't have any saved shoes yet.")
                    } actions: {
                        Button("Create Shoe") {
                            showingAddShoeSheet.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    // Show list of try-ons when they exist
                    List {
                        ForEach(tryOns) { tryOn in
                            NavigationLink(value: tryOn) {
                                VStack(alignment: .leading) {
                                    Text(tryOn.name)
                                        .font(.headline)
                                    Text(tryOn.date.formatted(date: .abbreviated, time: .omitted))
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteItem(tryOn)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("ShoeTracker")
            .navigationDestination(for: TryOn.self) { tryOn in
                ShoeDetailsView(tryOn: tryOn)
            }
             // Apply toolbar to the NavigationStack content instead
            .toolbar {
                    ToolbarItem {
                        Button {
                            showingAddShoeSheet.toggle()
                        } label: {
                            Image(systemName: "plus")
                                .symbolEffect(.scale)
                        }
                    }
                    ToolbarItem {
                        Button {
                            showingSettingsSheet.toggle()
                        } label: {
                            Image(systemName: "gear")
                            .symbolEffect(.rotate.byLayer, options: .nonRepeating)
                        }
                    }
            }
        }
        .sheet(isPresented: $showingAddShoeSheet) {
            CreateNewShoe()
        }
        .sheet(isPresented: $showingSettingsSheet) {
            Settings()
        }
        
    }
    
    
    private func deleteItem(_ item: TryOn) {
        modelContext.delete(item)
        try? modelContext.save()
    }
}

#Preview {
    ContentView()
}
