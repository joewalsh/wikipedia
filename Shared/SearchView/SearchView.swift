import SwiftUI

struct SearchView: View {
    @ObservedObject var model: SearchViewModel
    
    var body: some View {
        PagingatedListView(items: model.pages,
                           navigationLinkBuilder: model.listItem,
                           searchTextBinding: $model.term,
                           statusMessage: model.statusMessage,
                           onPaginate: model.onPaginate)
    }
}

struct WikipediaView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(model: SearchViewModel())
    }
}
