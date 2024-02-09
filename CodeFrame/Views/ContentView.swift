//
//  ContentView.swift
//  CodeFrame
//
//  Created by 施家浩 on 2024/2/9.
//

import SwiftUI
import CoreData
import WidgetKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.lastModify, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State private var showAddView = false
    var body: some View {
        VStack {
            NavigationStack {
                List {
                    if items.isEmpty {
                        Text("The list is empty...")
                    }
                    ForEach(items) { item in
                        NavigationLink(destination: EditItemView(barcode: item)) {
                            VStack(alignment: .leading, spacing: 1) {
                                HStack {
                                    Text(item.title!)
                                        .font(.headline)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                    Spacer()
                                    Text(item.textCode!)
                                        .font(.callout)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .foregroundStyle(.gray)
                                }.padding(.leading)
                                let barcodeImage = barcodeGenerator(from: item.textCode!)
                                if barcodeImage != nil {
                                    Image(uiImage: barcodeImage!)
                                        .resizable()
                                        .interpolation(.none)
                                        .frame(height: 100)
                                } else {
                                    Text("Failed to generate image...")
                                }
                                HStack {
                                    Text("Last modify: \(dateFormatter(date: item.lastModify!))")
                                        .foregroundStyle(.gray)
                                        .italic()
                                    Spacer()
                                    if item.favorite {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(.yellow)
                                    }
                                }.padding(.leading)
                            }.frame(width: 350)//.border(.blue)
                        }
                    }.onDelete(perform: deleteItems)
                }
                .listStyle(.plain)
                .navigationTitle("Inventory")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { showAddView.toggle() }, label: {
                            Label("Add Barcode", systemImage: "plus.circle")
                        })
                    }
                    if !items.isEmpty {
                        ToolbarItem(placement: .topBarLeading) {
                            EditButton()
                        }
                    }
                }.sheet(isPresented: $showAddView) {
                    AddItemView()
                }
            }
        }
    }
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
                WidgetCenter.shared.reloadTimelines(ofKind: "BarcodeDisplayWidget")
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Failed to delete context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
