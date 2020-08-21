import Foundation

struct Page: Identifiable {
    struct Identifier {
        let wiki: Wikipedia
        let title: String
        let namespace: Namespace
    }
    let id: Identifier
}

extension Page.Identifier: Equatable {
    static func == (lhs: Page.Identifier, rhs: Page.Identifier) -> Bool {
        return lhs.wiki == rhs.wiki && lhs.namespace == rhs.namespace && lhs.title == rhs.title
    }
}

extension Page.Identifier: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(wiki)
        hasher.combine(namespace)
        hasher.combine(title)
    }
}
