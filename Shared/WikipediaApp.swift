import SwiftUI

@main
struct WikipediaApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SearchView(model: SearchViewModel())
            }
        }
    }
}
