//
//  CustomViews.swift
//  CodeFrame
//
//  Created by 施家浩 on 2024/2/9.
//

import Foundation
import SwiftUI

struct ItemPropertyEditSheet<Content: View>: View {
    @State var title: String
    @State var description: String
    @State var content: () -> Content
    
    @State private var isShowSheet = false
    
    var body: some View {
        VStack {
            HStack {
                Text(self.title)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .onTapGesture {
                self.isShowSheet.toggle()
            }
            .sheet(isPresented: $isShowSheet) {
                Form {
                    Section(content: {
                        HStack {
                            Text("Enter new value:")
                            Spacer()
                            self.content().multilineTextAlignment(.trailing)
                        }
                    }, footer: {
                        Text(self.description)
                    })
                }
            }
        }
    }
}

struct Collapsible<Content: View>: View {
    @State var label: () -> Text
    @State var content: () -> Content
    
    @State private var collapsed: Bool = false
    
    var body: some View {
        VStack {
            Button(
                action: { self.collapsed.toggle() },
                label: {
                    HStack {
                        self.label()
                        Spacer()
                        Image(systemName: self.collapsed ? "chevron.down" : "chevron.up")
                    }
                    .padding(.bottom, 1)
                    .background(Color.white.opacity(0.01))
                }
            )
            .buttonStyle(PlainButtonStyle())
            VStack {
                self.content()
            }
            .frame(height: collapsed ? .none : 0)
            .clipped()
            .animation(.linear, value: collapsed)
            //VStack {
            //    self.content()
            //}
            //.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: collapsed ? 0 : .none)
            //.clipped()
            //.animation(.spring, value: collapsed)
            //.transition(.slide)
        }//.animation(.easeInOut, value: collapsed)
    }
}

struct WidgetRectangle: View {
    var cornerRadius: CGFloat
    var text: String
    var borderColor: Color
    var shadowColor: Color
    
    @State private var textWidth: CGFloat = .zero
    @State private var widthLimit: CGFloat = 96.0
    
    var body: some View {
        ZStack(alignment: .center) {
            CustomRroundedRectangle(cornerRadius: cornerRadius, spaceBetween: textWidth)
                .scale(x: 1.1, y: 1.1)
                .stroke(borderColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .scale(x: 1.1, y: 1.1)
                        .fill(.white)
                        .shadow(color: shadowColor, radius: 5, x: 3, y: 3)
                )
            ZStack {
                Text(text)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(borderColor)
                    .background( // Put GeometryReader in view background to measure the size
                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 15, style: .continuous) // must have a container to call onAppear()
                                .fill(.white)
                                .onAppear() {
                                    if geo.size.width > widthLimit {
                                        self.textWidth = widthLimit
                                    } else {
                                        self.textWidth = geo.size.width
                                    }
                                }
                        }
                    )
            }.offset(y: -70).frame(maxWidth: widthLimit)
            GeometryReader { geo in
                Color.clear.onAppear() {
                    self.widthLimit = geo.size.width - cornerRadius * 2
                }
            }
        }
    }
}

struct CustomRroundedRectangle: Shape {
    var cornerRadius: CGFloat
    var spaceBetween: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let minX = rect.minX
        let minY = rect.minY
        let maxX = rect.maxX
        let maxY = rect.maxY
        let xAxis = rect.width
        
        // Move to the starting point
        //path.move(to: CGPoint(x: maxX, y: minY + cornerRadius))
        path.move(to: CGPoint(x: xAxis/2 + spaceBetween/2, y: minY))
        path.addLine(to: CGPoint(x: maxX - cornerRadius, y: minY))
        
        // Top-right corner
        path.addArc(center: CGPoint(x: maxX - cornerRadius, y: minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(0),
                    clockwise: false)

        //Bottom-right corner
        path.addArc(center: CGPoint(x: maxX - cornerRadius, y: maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)

        // Bottom-left corner
        path.addArc(center: CGPoint(x: minX + cornerRadius, y: maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)

        // Top-left corner
        path.addArc(center: CGPoint(x: minX + cornerRadius, y: minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(180),
                    endAngle: .degrees(270),
                    clockwise: false)
        
        // Top-left-side
        path.addLine(to: CGPoint(x: xAxis/2 - spaceBetween/2, y: minY))

        return path
    }
}
