//
//  FloatingCard.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/4/24.
//

import SwiftUI

struct FloatingCard: ViewModifier {
    var cornerSize: CGSize
    var shadowRadius: CGFloat
    var shadowColor: Color
    var shadowOffset: CGPoint
    var backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerSize: cornerSize))
            .shadow(color: shadowColor, radius: shadowRadius, x: shadowOffset.x, y: shadowOffset.y)
    }
}

extension View {
    func floatingCardStyle(
        cornerSize: CGSize = CGSize(width: 10, height: 10),
        shadowRadius: CGFloat = 2,
        shadowColor: Color = .gray.opacity(0.25),
        shadowOffset: CGPoint = CGPoint(x: 0, y: 1.5),
        backgroundColor: Color = Color(UIColor.systemBackground)
    ) -> some View {
        modifier(FloatingCard(
            cornerSize: cornerSize,
            shadowRadius: shadowRadius,
            shadowColor: shadowColor,
            shadowOffset: shadowOffset,
            backgroundColor: backgroundColor
        ))
    }
}
