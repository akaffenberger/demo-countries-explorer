//
//  CountryListItem.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/2/24.
//

import SwiftUI
import Observation

struct CountryListItem: View {
    
    let commonName: String?
    let officialName: String?
    let capital: [String]?
    let flag: URL?
    
    @State private var imageUrl: URL?
    
    var body: some View {
        HStack(spacing: 15) {
            AsyncImage(
                url: imageUrl,
                transaction: Transaction(animation: .default)
            ) { phase in
                switch phase {
                case .empty: Color.gray.opacity(0.5)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .transition(.opacity)
                case .failure(let error): Color.gray.opacity(0.5).task { retryImageIfCancelled(error: error) }
                @unknown default: EmptyView()
                }
            }
            .frame(width: 65)
            .padding(.vertical)
            .onAppear { imageUrl = flag }

            VStack(alignment: .leading, spacing: 2) {
                Text(commonName ?? "")
                    .fontWeight(.bold)
                    .font(.system(size: 14))
                Text(officialName ?? "")
                    .fontWeight(.medium)
                    .font(.system(size: 13))
                Text(capital?.joined(separator: ", ") ?? "")
                    .fontWeight(.medium)
                    .font(.system(size: 11))
                    .foregroundStyle(.gray)
            }
            
            Spacer()
        }
        .padding(.leading, 15)
        .frame(height: 90)
        .floatingCardStyle()
    }
    
    // Retry workaround for async images edge case: sometimes image loads are cancelled in a List
    // In a production setting I would not ship this. Likely be using cached images using a third party Kingfisher, etc.
    private func retryImageIfCancelled(error: Error) {
        if let error = error as? URLError, error.code == .cancelled {
            self.imageUrl = nil

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.imageUrl = flag
                print("Retrying image.. \(flag?.absoluteString ?? "")")
            }
        }
    }
}

#Preview {
    CountryListItem(
        commonName: "Ireland",
        officialName: "Republic of Ireland",
        capital: ["Dublin"],
        flag: URL(string: "https://flagcdn.com/w320/ie.png")
    )
}
