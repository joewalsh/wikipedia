import Foundation
import Combine
import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var term: String = ""
    
    var statusMessage: String? {
        switch state {
        case .empty:
            return NSLocalizedString("No results", comment: "Shown when there are no search results")
        case .failure(let error):
            return error.localizedDescription
        default:
            return nil
        }
    }
    
    var pages: [Page] {
        switch state {
        case .searching(let pages):
            fallthrough
        case .results(let pages, _):
            return pages
        default:
            return []
        }
    }
    
    @Published private(set) var state: State = .idle {
        didSet {
            searchCancellable?.cancel()
            searchCancellable = nil
        }
    }
    
    let wiki = Wikipedia(language: .ar)

    enum State {
        case idle
        case empty
        case searching(_ pages: [Page])
        case results(_ pages: [Page], _ continuation: Continuation)
        case failure(_ error: Error)
    }
    
    private var searchDebouncer: AnyCancellable?
    
    init() {
        searchDebouncer = $term
            .debounce(for: .milliseconds(150), scheduler: DispatchQueue.main)
            .sink { [weak self] (term) in
                self?.search(with: term)
            }
    }
    
    
    private lazy var actionAPI: ActionAPIInterface = ActionAPIService(site: wiki)
    
    private var searchCancellable: AnyCancellable?
    
    private func search(with term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            state = .idle
            return
        }
        state = .searching([])
        searchCancellable = actionAPI.search(with: term, continuation: .no)
            .receive(on: DispatchQueue.main)
            .map { $0.pages.isEmpty ? State.empty : State.results($0.pages, $0.continuation) }
            .catch { Just(State.failure($0)) }
            .assign(to: \.state, on: self)
    }
    
    func onPaginate() {
        assert(Thread.isMainThread)
        switch state {
        case .results(let pages, let continuation):
            switch continuation {
            case .yes:
                state = .searching(pages)
                searchCancellable = actionAPI.search(with: term, continuation: continuation)
                    .receive(on: DispatchQueue.main)
                    .map { State.results(pages + $0.pages, $0.continuation) }
                    .replaceError(with: self.state)
                    .assign(to: \.state, on: self)
            case .no:
                return
            }
        default:
            break
        }
    }
    
    func listItem(_ page: Page) -> NavigationLink<Text, PageView> {
        NavigationLink(destination: PageView(model: PageViewModel(page: page))) {
            Text(page.id.title)
        }
    }
}
