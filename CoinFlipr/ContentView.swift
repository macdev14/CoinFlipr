//
//  ContentView.swift
//  FlipMaster
//
//  Created by Lauro Pimentel on 03/03/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            CoinFlipperView()
                .tabItem {
                    Label("Flip", systemImage: "arrow.triangle.2.circlepath")
                }
            
            FlipHistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }
        }
    }
}

struct CoinFlipperView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentSide: String = "Heads"
    @State private var isFlipping: Bool = false
    
    var body: some View {
        VStack {
            Button(action: {
                            flipCoin()
            }) {
                // Display the coin based on currentSide
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
            }.disabled(isFlipping)
            
            Button("Flip Coin") {
                flipCoin()
            }
            .padding().foregroundStyle(Color.primary)
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
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]
    
    var body: some View {
        List {
            ForEach(items) { item in
                Text("\(item.result) at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
            }
            .onDelete(perform: deleteItems)
        }
        .toolbar {
            EditButton()
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

// SVG-like Heads Coin Representation
struct HeadsCoinView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.yellow.opacity(0.8))
                .overlay(Circle().stroke(Color.gray, lineWidth: 4))
            VStack{
                Text("H")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.black)
                Text("Heads")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.primary)
            }
        }
    }
}

// SVG-like Tails Coin Representation
struct TailsCoinView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.yellow.opacity(0.8))
                .overlay(Circle().stroke(Color.gray, lineWidth: 4))
            VStack{
                Text("T")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(Color.primary)
                Text("Tails")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.primary)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
