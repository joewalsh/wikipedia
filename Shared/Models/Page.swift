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

extension Page {
    var contentURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "\(id.wiki.language.rawValue).wikipedia.org"
        components.percentEncodedPath = "/api/rest_v1/page/mobile-html/\(id.title.addingPercentEncoding(withAllowedCharacters: .encodeURIComponentAllowed) ?? id.title)"
        return components.url!
    }
}


