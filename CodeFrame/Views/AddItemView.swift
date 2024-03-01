//
//  AddItemView.swift
//  CodeFrame
//
//  Created by 施家浩 on 2024/2/9.
//

import Foundation
import SwiftUI
import WidgetKit

struct AddItemView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var textCode = ""
    @State private var isFavorite = false
    @State private var isShowAsQRcode = false
    
    var body: some View {
        Form {
            Section(content: {
                TextField("Enter title", text: $title)
                TextField("Enter text code", text: $textCode)
                Toggle("Favorite item", isOn: $isFavorite)
            }, footer: {
                Text("To generate a barcode or QRcode, copy and paste your membership id or any code.")
            })
            Section(content: {
                VStack(alignment:.leading) {
                    Toggle("Displayed as QRcode", isOn: $isShowAsQRcode)
                }
            }, header: {
                Text("Widget Configurations")
            }, footer: {
                Text("QRcode can neither displayed on small widget or medium widget. \nBarcode can only displayed on medium widget.")
            })
            HStack {
                Spacer()
                Button("Add item") {
                    defer {
                        dismiss()
                    }
                    let newItem = Item(context: viewContext)
                    newItem.title = title
                    newItem.textCode = textCode
                    newItem.favorite = isFavorite
                    newItem.showAsQRcode = isShowAsQRcode
                    do {
                        try viewContext.save()
                        WidgetCenter.shared.reloadTimelines(ofKind: "CodeFrameWidget")
                    } catch {
                        let nsError = error as NSError
                        fatalError("Failed to add context: \(nsError), \(nsError.userInfo)")
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    AddItemView()
}
