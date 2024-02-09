//
//  EditItemView.swift
//  CodeFrame
//
//  Created by 施家浩 on 2024/2/9.
//

import Foundation
import SwiftUI
import WidgetKit

struct EditItemView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.dismiss) var dismiss
    
    var barcode: FetchedResults<Item>.Element
    
    @State private var title = ""
    @State private var textCode = ""
    @State private var isFavorite = false
    @State private var isShowAsQRcode = false
    
    @State private var isAlertShowing = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(content: {
                    HStack {
                        Text("Title:")
                        Spacer()
                        TextField(barcode.title!, text: $title)
                            .multilineTextAlignment(.trailing)
                            .onAppear {
                                self.title = barcode.title!
                            }
                    }
                    HStack {
                        Text("Text code:")
                        Spacer()
                        TextField(barcode.textCode!, text: $textCode)
                            .multilineTextAlignment(.trailing)
                            .onAppear {
                                self.textCode = barcode.textCode!
                            }
                    }
                    Toggle("Set as favorite barcode", isOn: $isFavorite)
                        .onChange(of: isFavorite) { _, newValue in
                            isFavorite = newValue // Can not use .toggle(), it cause all item value got toggled on single frame.
                        }
                        .onAppear() { // Assign item value after data processed and before view get render.
                            isFavorite = barcode.favorite
                        }
                    Toggle("Displayed as QRcode", isOn: $isShowAsQRcode)
                        .onChange(of: isShowAsQRcode) { _, newValue in
                            isShowAsQRcode = newValue
                        }
                        .onAppear() {
                            isShowAsQRcode = barcode.showAsQRcode
                        }
                }, header: {
                    Text("Information")
                })
            }
        }
        .navigationTitle("Configuration")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear() {
            do {
                barcode.title = title
                barcode.textCode = textCode
                barcode.favorite = isFavorite
                barcode.showAsQRcode = isShowAsQRcode
                try viewContext.save()
                WidgetCenter.shared.reloadTimelines(ofKind: "BarcodeDisplayWidget")
            } catch {
                let nsError = error as NSError
                fatalError("Failed to save context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
