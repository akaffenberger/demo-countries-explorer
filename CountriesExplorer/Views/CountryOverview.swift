//
//  CountryOverview.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/6/24.
//

import SwiftUI

struct CountryOverview<C: Country>: View {
    
    let country: C
    var detailAction: () -> Void
    @State private var gridFirstCardHeight: CGFloat = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                FlagImage(flag: country.flags?.png)
                
                DetailsGrid(country: country, offset: $gridFirstCardHeight, detailAction: detailAction)
                    .padding(.horizontal)
                    .offset(CGSize(width: 0, height: -(gridFirstCardHeight / 2.0)))
                    .background()
            }
        }
    }
}

fileprivate struct FlagImage: View {
    let flag: URL?
    
    @State private var scale: CGFloat = 1
    @State private var offset: CGFloat = 0
    
    var body: some View {
        AsyncImage(url: flag) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaleEffect(x: scale, y: scale, anchor: .top)
                .offset(CGSize(width: 0, height: offset))
                .background(GeometryReader(content: { geometry in
                    Color.clear
                        .onChange(of: geometry.frame(in: .scrollView(axis: .vertical))) {
                            let offset = geometry.frame(in: .scrollView(axis: .vertical)).minY
                            let scale = 1.0 - (min(geometry.size.height, -offset) / geometry.size.height)
                            self.scale = max(1 * scale, 1)
                            self.offset = offset < 0 ? -offset : -offset
                        }
                }))
        } placeholder: {
            EmptyView()
        }
    }
}

fileprivate struct DetailsGrid: View {
    
    let country: any Country
    
    @Binding var offset: CGFloat
    var detailAction: () -> Void
    
    var body: some View {
        Grid(horizontalSpacing: 20, verticalSpacing: 20) {
            GridRow {
                Card(opacity: 0.95, padding: 3) {
                    Button(action: detailAction) {
                        VStack(spacing: 0) {
                            Text(country.commonName ?? "")
                                .font(.system(size: 23, weight: .heavy))
                            Text(country.officialName ?? "")
                                .font(.system(size: 14))
                                .offset(y: -2)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .background(GeometryReader { geometry in
                    Color.clear
                        .onAppear { self.offset = geometry.size.height }
                        .onChange(of: geometry.size) { self.offset = geometry.size.height }
                })
            }
            .gridCellColumns(2)

            GridRow {
                Card {
                    TitledSection(text: "Region", padding: 5, lineLimit: 1, bottomSpacerEnabled: false) {
                        Text(country.region ?? "")
                            .padding(.horizontal, 10)
                    }
                    Divider().frame(width: 1)
                    TitledSection(text: "Subregion", padding: 5, lineLimit: 1, bottomSpacerEnabled: false) {
                        Text(country.subregion ?? "")
                            .padding(.horizontal, 10)
                    }
                    Divider().frame(width: 1)
                    TitledSection(text: "Capital", padding: 5, lineLimit: 1, bottomSpacerEnabled: false) {
                        Text(country.capital?.joined(separator: ", ") ?? "")
                            .padding(.horizontal, 10)
                    }
                }
                .gridCellColumns(2)
            }
            
            GridRow {
                Card(title: "Timezone(s)") {
                    TextList(values: country.timezones)
                }
                
                Card(title: "Population") {
                    Text("\(country.population)")
                }
            }
            
            GridRow {
                Card(title: "Languages") {
                    TextList(values: country.languages?.values.sorted() ?? [])
                }
                
                Card(title: "Currencies") {
                    TextList(values: country.currencies?.map { currency in
                        "\(currency.abbreviation ?? "") (\(currency.symbol ?? "") \(currency.name ?? ""))"
                    })
                }
            }
            
            GridRow {
                Card(title: "Car Driver Side") {
                    HStack(spacing: 4) {
                        Text("LEFT")
                            .font(.system(size: 12))
                            .fontWeight(.medium)
                            .opacity(country.car?.side == "left" ? 1 : 0.1)
                        Image(systemName: "car.circle")
                            .font(.system(size: 20))
                        Text("RIGHT")
                            .font(.system(size: 12))
                            .fontWeight(.medium)
                            .opacity(country.car?.side == "right" ? 1 : 0.1)
                    }
                }
                
                Card(title: "Coat of Arms") {
                    AsyncImage(
                        url: country.coatOfArms?.png,
                        transaction: Transaction(animation: .default)
                    ) { phase in
                        switch phase {
                        case .empty: EmptyView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .transition(.opacity)
                        case .failure: EmptyView()
                        @unknown default: EmptyView()
                        }
                    }
                    .frame(minWidth: 40)
                    .frame(height: 50)
                }
            }
        }
    }
}

fileprivate struct TitledSection<V: View>: View {
    let text: String
    var size: CGFloat = 15
    var padding: CGFloat = 15
    var lineLimit: Int? = nil
    var bottomSpacerEnabled: Bool = true
    let content: () -> V

    var body: some View {
        VStack(spacing: 0) {
            Text(text)
                .font(.system(size: size))
                .fontWeight(.bold)
                .padding(.bottom, padding)
                .unredacted()
            content()
                .font(.system(size: size - 1))
                .fontWeight(.regular)
                .lineLimit(lineLimit)
                .minimumScaleFactor(lineLimit == nil ? 1 : 0.33)
            if bottomSpacerEnabled {
                Spacer()
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

fileprivate struct Card<V: View>: View {
    var title: String? = nil
    var opacity: CGFloat = 1
    var padding: CGFloat = 8
    @ViewBuilder let content: () -> V

    var body: some View {
        if let title = title {
            TitledSection(text: title, content: content)
                .padding(EdgeInsets(top: padding, leading: padding, bottom: 0, trailing: padding))
                .floatingCardStyle(backgroundColor: Color(UIColor.systemBackground).opacity(opacity))
        } else {
            HStack(spacing: 0) {
                content()
            }
            .padding(.vertical, padding)
            .floatingCardStyle(backgroundColor: Color(UIColor.systemBackground).opacity(opacity))
        }
    }
}

fileprivate struct TextList: View {
    let values: [String]?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(values ?? [], id: \.self) { text in
                HStack(spacing: 0) {
                    if (values?.count ?? 0) > 1 {
                        Text("• ")
                            .font(.system(size: 22))
                            .frame(height: 14, alignment: .centerLastTextBaseline)
                            .unredacted()
                    }
                    Text(text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                }
            }
        }
    }
}

#Preview {
    CountryOverview(country: MockCountryRepository.mockIreland, detailAction: {})
}
