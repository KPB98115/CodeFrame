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
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.lastModify, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State private var isExpend = false
    
    @State private var showAddView = false
    var body: some View {
        ZStack(alignment:.bottomTrailing) {
            NavigationStack {
                List {
                    if items.isEmpty {
                        Text("The list is empty...")
                    }
                    ForEach(items) { item in
                        NavigationLink(destination: EditItemView(item: item)) {
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
                                        .frame(height: 70)
                                        .padding()
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
                            }
                            .frame(width: 350)
                        }
                    }.onDelete(perform: deleteItems)
                }
                .listStyle(.plain)
                .navigationTitle("Inventory")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { showAddView.toggle() }, label: {
                            Label("Add item", systemImage: "plus.circle")
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
            Button(action: {
                withAnimation {
                    isExpend.toggle()
                }
            }, label: {
                VStack {
                    if isExpend {
                        Button(action: {
                            items.sortDescriptors = [SortDescriptor(\Item.favorite, order: .reverse)]
                            withAnimation {
                                isExpend.toggle()
                            }
                        }, label: {
                            Image(systemName: "star")
                                .padding()
                                .foregroundColor(.blue)
                                .fontWeight(.bold)
                                .background(
                                    Circle().stroke(.blue, lineWidth: 3).fill(.white))
                        })
                        Button(action: {
                            items.sortDescriptors = [SortDescriptor(\Item.lastModify, order: .reverse)]
                            withAnimation {
                                isExpend.toggle()
                            }
                        }, label: {
                            Image(systemName: "timer")
                                .padding()
                                .foregroundColor(.blue)
                                .fontWeight(.bold)
                                .background(
                                    Circle().stroke(.blue, lineWidth: 3).fill(.white)
                                )
                        })
                        Button(action: {
                            items.sortDescriptors = [SortDescriptor(\Item.title, order: .reverse)]
                            withAnimation {
                                isExpend.toggle()
                            }
                        }, label: {
                            Image(systemName: "textformat.abc.dottedunderline")
                                .padding()
                                .foregroundColor(.blue)
                                .fontWeight(.bold)
                                .background(
                                    Circle().stroke(.blue, lineWidth: 3).fill(.white)
                                )
                        })
                    }
                    Image(systemName: "line.horizontal.3.decrease")
                        .padding()
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .background(
                            Circle().fill(.blue)
                        )
                }.frame(width: 55)
            }).padding(.trailing, 30)
        }
    }
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
                WidgetCenter.shared.reloadTimelines(ofKind: "CodeFrameWidget")
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
