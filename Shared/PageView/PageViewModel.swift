import Foundation

class PageViewModel: ObservableObject {
    let page: Page

    enum ForwardState {
        case none
        case available(_ model: PageViewModel)
        case active(_ model: PageViewModel)
    }
    @Published private(set) var forwardState: ForwardState = .none
    
    var forwardPage: PageViewModel? {
        get {
            switch forwardState {
            case .none:
                return nil
            case .available(let next):
                fallthrough
            case .active(let next):
                return next
            }
        }
    }
    
    var isForwardPageActive: Bool {
        get {
            switch forwardState {
            case .active:
                return true
            default:
                return false
            }
        }
        set {
            switch forwardState {
            case .none:
                break
            case .available(let next):
                if newValue {
                    forwardState = .active(next)
                }
            case .active(let next):
                if !newValue {
                    forwardState = .available(next)
                }
            }
        }
    }
    
    init(page: Page) {
        self.page = page
    }
    
    func push(page: Page) {
        forwardState = .active(PageViewModel(page: page))
    }
    
    func goForward() {
        switch forwardState {
        case .available(let next):
            forwardState = .active(next)
        default:
            break
        }
    }
}
