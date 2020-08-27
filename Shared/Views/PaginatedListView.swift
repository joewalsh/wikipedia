import SwiftUI

struct PagingatedListView<T: Identifiable, L: View, D: View>: View {
    let items: [T]
    let navigationLinkBuilder: (_ item: T) -> NavigationLink<L, D>
    let searchTextBinding: Binding<String>?
    var statusMessage: String?
    var paginationTriggerCount: Int = 10
    let onPaginate: () -> Void
    
    var body: some View {
        List {
            if let searchTextBinding = searchTextBinding {
                TextField("Search", text: searchTextBinding)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding([.top, .bottom])
            }
            if let statusMessage = statusMessage {
                Text(statusMessage)
                    .padding([.top, .bottom])
            }
            ForEach(items) { item in
                navigationLinkBuilder(item).onAppear(perform: {
                    guard paginationTrigger == item.id else {
                        return
                    }
                    onPaginate()
                })
            }
        }
        .listStyle(PlainListStyle())
    }
    
    var paginationTrigger: T.ID? {
        guard items.count > paginationTriggerCount else {
            return nil
        }
        return items[items.endIndex.advanced(by: 0 - paginationTriggerCount)].id
    }
}
