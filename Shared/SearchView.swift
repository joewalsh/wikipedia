import SwiftUI

struct SearchView: View {
    
    @ObservedObject var model: SearchViewModel
    
    var body: some View {
        VStack {
            switch model.state {
            case .empty:
                Spacer()
                Text("No results")
                Spacer()
            case .failure(let error):
                Spacer()
                Text(error.localizedDescription)
                Spacer()
            default:
                Spacer()
            }
            PagingatedListView(items: pages,
                               navigationLinkBuilder: model.listItem,
                               searchTextBinding: $model.term,
                               onPaginate: model.onPaginate)
        }.padding()
    }
    
    
    var pages: [Page] {
        switch model.state {
        case .searching(let pages):
            fallthrough
        case .results(let pages, _):
            return pages
        default:
            return []
        }
    }
}

struct WikipediaView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(model: SearchViewModel())
    }
}
