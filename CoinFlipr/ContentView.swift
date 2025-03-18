//
//  ContentView.swift
//  FlipMaster
//
//  Created by Lauro Pimentel on 03/03/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isDarkMode = false
    
    var body: some View {
        TabView {
            CoinFlipperView(isDarkMode: $isDarkMode)
                .tabItem {
                    Label("Flip", systemImage: "arrow.triangle.2.circlepath")
                }
            
            FlipHistoryView(isDarkMode: $isDarkMode)
                .tabItem {
                    Label("History", systemImage: "clock")
                }
        }
        .accentColor(isDarkMode ? .white : .blue)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .background(isDarkMode ? Color.black : Color(.systemBackground))
    }
}

struct CoinFlipperView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @State private var currentSide: String = "Heads"
    @State private var isFlipping: Bool = false
    @Binding var isDarkMode: Bool
    
    var body: some View {
        ZStack {
            VStack {
                Button(action: {
                    flipCoin()
                }) {
                    if currentSide == "Heads" {
                        HeadsCoinView()
                            .frame(width: 200, height: 200)
                            .rotation3DEffect(
                                .degrees(isFlipping ? 180 : 0),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .animation(.easeInOut(duration: 0.5), value: isFlipping)
                    } else {
                        TailsCoinView()
                            .frame(width: 200, height: 200)
                            .rotation3DEffect(
                                .degrees(isFlipping ? 180 : 0),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .animation(.easeInOut(duration: 0.5), value: isFlipping)
                    }
                }
                .disabled(isFlipping)
                
                Button("Flip Coin") {
                    flipCoin()
                }
                .padding()
                .foregroundStyle(Color.primary)
                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Toggle button with descriptive text in upper right corner
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isDarkMode.toggle()
                    }) {
                        VStack(spacing: 5) {
                            Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                                .font(.system(size: 30))
                                .foregroundColor(isDarkMode ? .yellow : .gray)
                            Text(isDarkMode ? "Light Mode" : "Dark Mode")
                                .font(.caption)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                        .frame(width: 80, height: 80)
                        .padding(10)
                        .background(colorScheme == .dark ? Color.black.opacity(0.7) : Color.white.opacity(0.7))
                        .cornerRadius(12)
                    }
                    .padding(.top, 15)
                    .padding(.trailing, 15)
                }
                Spacer()
            }
        }
    }
    
    private func flipCoin() {
        isFlipping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let result = Bool.random() ? "Heads" : "Tails"
            currentSide = result
            isFlipping = false
            addFlipToHistory(result: result)
        }
    }
    
    private func addFlipToHistory(result: String) {
        let newItem = Item(timestamp: Date(), result: result)
        modelContext.insert(newItem)
    }
}

struct FlipHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]
    @Binding var isDarkMode: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Toggle button with descriptive text in upper right corner
            HStack {
                Spacer()
                Button(action: {
                    isDarkMode.toggle()
                }) {
                    VStack(spacing: 5) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .font(.system(size: 30))
                            .foregroundColor(isDarkMode ? .yellow : .gray)
                        Text(isDarkMode ? "Light Mode" : "Dark Mode")
                            .font(.caption)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    .frame(width: 80, height: 80)
                    .padding(10)
                    .background(colorScheme == .dark ? Color.black.opacity(0.7) : Color.white.opacity(0.7))
                    .cornerRadius(12)
                }
                .padding(.top, 15)
                .padding(.trailing, 15)
            }
            
            // List below the button
            List {
                ForEach(items) { item in
                    HStack {
                        Text(item.result)
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        Text("at \(item.timestamp.formatted(.dateTime.month(.abbreviated).day().year()))")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(isDarkMode ? Color.clear : Color(.systemGray6))
                    .listRowSeparator(.hidden)
                    
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteItem(item)
                        } label: {
                            Text("Delete")
                                .padding(.horizontal, 12) // Custom padding to control width
                                .padding(.vertical, 8)   // Custom padding to control height
                                .frame(minWidth: 0)      // Ensures no extra width padding
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .scrollContentBackground(.hidden)
            .background(isDarkMode ? Color.black : Color(.systemBackground))
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                EditButton()
            }
        }
    }
    
    private func deleteItem(_ item: Item) {
        withAnimation {
            modelContext.delete(item)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

struct HeadsCoinView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Circle()
                .fill(colorScheme == .dark ?
                    Color.yellow.opacity(0.6) :
                    Color.yellow.opacity(0.8))
                .overlay(Circle().stroke(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray, lineWidth: 4))
            VStack {
                Text("H")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Text("Heads")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
        }
    }
}

struct TailsCoinView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Circle()
                .fill(colorScheme == .dark ?
                    Color.yellow.opacity(0.6) :
                    Color.yellow.opacity(0.8))
                .overlay(Circle().stroke(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray, lineWidth: 4))
            VStack {
                Text("T")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Text("Tails")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
