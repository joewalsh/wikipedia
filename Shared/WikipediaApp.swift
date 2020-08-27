import SwiftUI

@main
struct WikipediaApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SearchView(model: SearchViewModel())
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarHidden(true)
            }
            .accentColor(.primary)
        }
    }
}
