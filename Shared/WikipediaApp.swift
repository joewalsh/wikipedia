import SwiftUI

@main
struct WikipediaApp: App {
    var body: some Scene {
        WindowGroup {
            SearchView(model: SearchViewModel())
        }
    }
}
