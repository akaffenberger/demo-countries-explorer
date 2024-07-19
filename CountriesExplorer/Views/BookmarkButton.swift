//
//  BookmarkButton.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/6/24.
//

import SwiftUI
import CoreData

struct BookmarkButton<B: Bookmark>: View where B: NSManagedObject {
    let id: String
    let repository: any Repository<B>
    var tapDisabled: Bool
    
    @FetchRequest private var bookmarks: FetchedResults<B>
    @State private var bookmarksEmpty: Bool = true
    
    init(
        id: String,
        repository: any Repository<B>,
        tapDisabled: Bool = false
    ) {
        self.id = id
        self.repository = repository
        self.tapDisabled = tapDisabled
        self._bookmarks = FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "id == %@", id))
    }
    
    var body: some View {
        Button(action: onTap) {
            if tapDisabled && bookmarksEmpty {
                EmptyView()
            } else {
                Image(systemName: bookmarksEmpty ? "bookmark" : "bookmark.fill")
            }
        }
        .foregroundStyle(Color.blue)
        .onReceive(bookmarks.publisher.collect()) { values in
            self.bookmarksEmpty = values.isEmpty
        }
    }
    
    func onTap() {
        if tapDisabled { return }
        Task {
            bookmarks.isEmpty ?
                try await repository.add(id) :
                try await repository.remove(id)
        }
    }
}

#Preview {
    BookmarkButton(
        id: "Ireland",
        repository: MockBookmarkRepository()
    )
    .environment(\.managedObjectContext, CoreDataPersistenceService.preview.container.viewContext)
}
