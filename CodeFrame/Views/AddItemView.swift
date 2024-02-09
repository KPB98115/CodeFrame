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
            Section {
                TextField("Enter title", text: $title)
                TextField("Enter text code", text: $textCode)
                Toggle("Favorite barcode", isOn: $isFavorite)
            }
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
                    let newBarcode = Item(context: viewContext)
                    newBarcode.title = title
                    newBarcode.textCode = textCode
                    newBarcode.favorite = isFavorite
                    newBarcode.showAsQRcode = isShowAsQRcode
                    do {
                        try viewContext.save()
                        WidgetCenter.shared.reloadTimelines(ofKind: "BarcodeDisplayWidget")
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
