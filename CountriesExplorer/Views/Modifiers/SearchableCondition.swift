//
//  SearchableCondition.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/6/24.
//

import SwiftUI

struct SearchableCondition: ViewModifier {
    let condition: Bool
    let text: Binding<String>
    let placement: SearchFieldPlacement

    func body(content: Content) -> some View {
        content.background {
            if condition {
                EmptyView().searchable(text: text, placement: placement)
            }
        }
    }
}

extension View {
    func searchable(condition: @autoclosure () -> Bool, text: Binding<String>, placement: SearchFieldPlacement) -> some View {
        modifier(SearchableCondition(condition: condition(), text: text, placement: placement))
    }
}
