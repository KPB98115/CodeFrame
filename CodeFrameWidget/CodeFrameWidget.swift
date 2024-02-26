//
//  CodeFrameWidget.swift
//  CodeFrameWidget
//
//  Created by 施家浩 on 2024/2/9.
//

import WidgetKit
import SwiftUI

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let item = getData(isFilterFavItems: false)
        return SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), item: item.first, themeColor: WidgetTheme(id: "", primary: .white, secondary: .gray, highlight: .black))
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let item = getData(isFilterFavItems: configuration.showFavoritesOnly)
        return SimpleEntry(date: Date(), configuration: configuration, item: item.first, themeColor: configuration.themeColor)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let item = getData(isFilterFavItems: configuration.showFavoritesOnly)
        var entry: SimpleEntry
        if !item.isEmpty {
            let defaults = UserDefaults.standard
            let index = defaults.integer(forKey: "widgetStateIndex")
            entry = SimpleEntry(date: Date(), configuration: configuration, item: item[index], themeColor: configuration.themeColor)
        } else {
            entry = SimpleEntry(date: Date(), configuration: configuration, item: nil, themeColor: configuration.themeColor)
        }

        return Timeline(entries: [entry], policy: .never)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let item: Item?
    let themeColor: WidgetTheme
}

struct CodeFrameWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    @AppStorage("widgetStateIndex") var index = 0
    @AppStorage("isLargetWidgetExpandableCollapse") var isCollapse = false

    var body: some View {
        VStack {
            switch widgetFamily {
                case .systemSmall:
                    SmallWidgetView(entry: entry)
                        .containerBackground(.white, for: .widget)
                    //Text("small widget, \(entry.configuration.favoriteEmoji)")
                case .systemMedium:
                    MediumWidgetView(entry: entry)
                        .containerBackground(entry.themeColor.primary, for: .widget)
                    //Text("medium widget, \(entry.configuration.favoriteEmoji)")
                case .systemLarge:
                    LargeWidgetView(entry: entry)
                        .containerBackground(entry.themeColor.primary, for: .widget)
                    //Text("large widget, \(entry.configuration.favoriteEmoji)")
                default:
                    fatalError("Unsupport widget family")
            }
        }
    }
    
    struct SmallWidgetView: View {
        var entry: Provider.Entry
        
        var body: some View {
            if entry.item == nil {
                Text("There is no item info yet...")
            } else {
                Button(intent: SwitchItem(), label: {
                    ZStack(alignment: .center) {
                        Image(uiImage: qrcodeGenerator(from: entry.item!.textCode!)!)
                            .interpolation(.none)
                            .resizable()
                            .padding(.all, 5)
                            .background(
                                WidgetRectangle(cornerRadius: 15, text: entry.item!.title!, borderColor: entry.themeColor.highlight, shadowColor: entry.themeColor.primary)
//                                RoundedRectangle(cornerRadius: 15)
//                                    .scale(x: 1.1, y: 1.1)
//                                    .stroke(entry.themeColor.highlight, lineWidth: 7)
//                                    .fill(.white)
//                                    .shadow(color: entry.themeColor.secondary, radius: 5, x: 3, y: 3)
                            )
//                        HStack(alignment: .top) {
//                            Text(" \(entry.item!.title!) ")
//                                .lineLimit(1)
//                                .truncationMode(.tail)
//                                .foregroundStyle(entry.themeColor.highlight)
//                                .background(entry.themeColor.primary)
//                                .font(.title3)
//                        }
//                        .offset(x: 0, y: -70)
                    }
                }).buttonStyle(.plain)
            }
        }
    }
    
    struct MediumWidgetView: View {
        var entry: Provider.Entry
        
        var body: some View {
            if entry.item == nil {
                Text("There is no item info yet...")
            } else {
                Button(intent: SwitchItem(), label: {
                    if entry.item!.showAsQRcode || entry.configuration.isDisplayQRcode {
                        ZStack {
                            HStack {
                                VStack(alignment:.leading) {
                                    Text(entry.item!.title!)
                                        .font(.title)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .foregroundStyle(entry.themeColor.highlight)
                                    Text(entry.item!.textCode!)
                                        .font(.subheadline)
                                        .foregroundStyle(entry.themeColor.secondary)
                                }
                                Spacer()
                                ZStack(alignment: .center) {
                                    Image(uiImage: qrcodeGenerator(from: entry.item!.textCode!)!)
                                        .interpolation(.none)
                                        .resizable()
                                        .padding(.all, 3)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15, style:.continuous)
                                                .scale(x: 1.1, y: 1.1)
                                                .stroke(entry.themeColor.highlight, lineWidth: 7)
                                                .fill(.white)
                                                .shadow(color: entry.themeColor.secondary, radius: 5, x: 3, y: 3)
                                        )
                                }.frame(width: 125, height: 125).padding(.trailing, 5)
                            }
                        }
                    } else {
                        ZStack(alignment:.center) {
                            Image(uiImage: barcodeGenerator(from: entry.item!.textCode!)!)
                                .interpolation(.none)
                                .resizable()
                                .padding(.all, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                        .stroke(entry.themeColor.secondary, lineWidth: 7)
                                        .fill(.white)
                                        .shadow(color: entry.themeColor.highlight, radius: 5, x: 3, y: 3)
                                )
                            Text(entry.item!.title!)
                                .offset(y: -50)
                                .font(.headline)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .foregroundStyle(entry.themeColor.secondary)
                            Text(entry.item!.textCode!)
                                .offset(y: 50)
                                .font(.subheadline)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .foregroundStyle(entry.themeColor.secondary)
                        }
                    }
                }).buttonStyle(.plain)
            }
        }
    }
    
    struct LargeWidgetView: View {
        var entry: Provider.Entry
        let items = getData(isFilterFavItems: false)
        
        var body: some View {
            if entry.item == nil {
                Text("There is no item info yet...")
            } else {
                GeometryReader { geo in
                    VStack(spacing: -1) {
                        ZStack {
                            Image(uiImage: barcodeGenerator(from: entry.item!.textCode!)!)
                                .interpolation(.none)
                                .resizable()
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(lineWidth: 3)
                                .scale(x: 1, y: 1.03)
                                .fill()
                        }.padding(.all, 11)
                        HStack(spacing: -1) {
                            VStack {
                                ZStack(alignment: .center) {
                                    Image(uiImage: qrcodeGenerator(from: entry.item!.textCode!)!)
                                        .interpolation(.none)
                                        .resizable()
                                        .padding(.all, 5)
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(lineWidth: 3)
                                        .scale(x: 1.1, y: 1.1)
                                        .fill()
                                }.padding()
                            }.frame(minWidth: geo.size.width * 1/2).border(.green)
                            VStack {
                                Text(entry.item!.title!)
                                    .font(.title)
                                Button(intent: SwitchItem(), label: {
                                    Label("Next", systemImage: "arrow.right")
                                        .environment(\.layoutDirection, .rightToLeft)
                                })
                            }.frame(maxWidth: geo.size.width * 1/2).border(.green)
                        }.frame(maxHeight: geo.size.height * 1/2).border(.green)
                    }
                }.border(.red)
            }
        }
    }

}

struct CodeFrameWidget: Widget {
    let kind: String = "CodeFrameWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: Provider()
        ) { entry in
            CodeFrameWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("CodeFrame widget")
        .description("Supported small and medium widget size.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

private func getData(isFilterFavItems: Bool) -> [Item] {
    do {
        let context = PersistenceController.shared.container.viewContext
        let request = Item.fetchRequest()
        if isFilterFavItems {
            request.predicate = NSPredicate(format: "favorite == %@", true as NSNumber)
        }
        let result = try context.fetch(request)
        if result.isEmpty {
            return []
        }
        return result
    } catch {
        let nsError = error as NSError
        fatalError("Failed to fetch item data: \(nsError.userInfo)")
    }
}

private func getPreviewData() -> [Item] {
    let context = PersistenceController.preview.container.viewContext
    do {
        let result =  try context.fetch(Item.fetchRequest())
        return result
    } catch {
        let nsError = error as NSError
        fatalError("Failed to fetch preview data: \(nsError.userInfo)")
    }
}

#Preview(as: .systemMedium) {
    CodeFrameWidget()
} timeline: {
    let dummy = getPreviewData()
    SimpleEntry(date: .now, configuration: ConfigurationAppIntent(), item: dummy.first, themeColor: WidgetTheme(id: "Preview theme", primary: .Ocean.skyBlue, secondary: .Ocean.grayBlue, highlight: .Ocean.marineBlue))
}
