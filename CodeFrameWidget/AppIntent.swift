//
//  AppIntent.swift
//  CodeFrameWidget
//
//  Created by 施家浩 on 2024/2/9.
//

import WidgetKit
import AppIntents
import SwiftUI

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("Configure your widget")
    
    //WidgetCenter.shared.getCurrentConfigurations() { result in
    //    guard let widget = try? result.get() else { return }
    //}
    @Parameter(title: "Displayed as QRcode", description: "This setting only affect medium widget since barcode can not display on small widget.", default: false)
    var isDisplayQRcode: Bool
    
    @Parameter(title: "Display favorite items only", description: "Display all item or favorite items only.", default: false)
    var showFavoritesOnly: Bool
    
    @Parameter(title: "Select widget theme")
    var themeColor: WidgetTheme
    
    init(themeColor: WidgetTheme) {
        self.themeColor = themeColor
    }
    
    init() {}
}

struct WidgetTheme: AppEntity {
    var id: String
    var primary: Color
    var secondary: Color
    var highlight: Color
    //var timeline: [SimpleEntry]
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "TEST"
    static var defaultQuery = WidgetThemeQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(id)")
    }
    
    static let themes: [WidgetTheme] = [
        WidgetTheme(id: "🖤🩶🤍", primary: .white, secondary: .gray, highlight: .black),
        WidgetTheme(id: "💙🩵🤍", primary: .indigo, secondary: .blue, highlight: .cyan),
        WidgetTheme(id: "🧡💛🤍", primary: .darkOrange, secondary: .orange, highlight: .yellow),
        WidgetTheme(id: "💜💚🧡", primary: .purple, secondary: .green, highlight: .orange),
    ]
}

struct WidgetThemeQuery: EntityQuery {
    func entities(for identifiers: [WidgetTheme.ID]) async throws -> [WidgetTheme] {
        WidgetTheme.themes.filter {
            identifiers.contains($0.id)
        }
    }
    
    func suggestedEntities() async throws -> [WidgetTheme] {
        WidgetTheme.themes
    }
    
    func defaultResult() async -> DefaultValue? {
        WidgetTheme.themes.first
    }
}

struct SwitchItem: AppIntent {
    static var title: LocalizedStringResource = "Tap to switch items"
    static var description: IntentDescription = "Tap to display the next item in the list"
    
    func increaseWidgetIndex() {
        func getItemAmount() -> Int {
            do {
                let context = PersistenceController.shared.container.viewContext
                let request = Item.fetchRequest()
                let result = try context.fetch(request)
                return result.count
            } catch {
                let nsError = error as NSError
                fatalError("Failed to fetch item data: \(nsError.userInfo)")
            }
        }
        
        let defaults = UserDefaults.standard
        let amount = getItemAmount()
        let currentIndex = defaults.integer(forKey: "widgetStateIndex")
        var newIndex: Int = 0
        if amount > 0 {
            newIndex = (currentIndex + 1) % amount
        }
        UserDefaults.standard.setValue(newIndex, forKey: "widgetStateIndex")
    }
    
    func perform() async throws -> some IntentResult {
        increaseWidgetIndex()
        return .result()
    }
}

struct LargeWidgetNextPage: AppIntent {
    static var title: LocalizedStringResource = "Tap to switch to next page"
    static var description: IntentDescription = "Tap to switch to next page"
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
