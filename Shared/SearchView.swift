import SwiftUI

struct SearchView: View {
    
    @ObservedObject var model: SearchViewModel
    
    var body: some View {
        VStack {
            TextField("", text: $model.term)
                .textFieldStyle(RoundedBorderTextFieldStyle())
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
                List {
                    ForEach(pages) { page in
                        Text(page.id.title).onAppear(perform: {
                            guard paginationTrigger == page.id else {
                                return
                            }
                            model.searchMore()
                        })
                    }
                }
            }
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
    
    var paginationTrigger: Page.Identifier? {
        guard pages.count > 10 else {
            return nil
        }
        return pages[pages.endIndex.advanced(by: -10)].id
    }
}

struct WikipediaView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(model: SearchViewModel())
    }
}
