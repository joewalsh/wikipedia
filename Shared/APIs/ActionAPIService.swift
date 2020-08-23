import Foundation
import Combine

enum Continuation {
    case no
    case yes(_ params: [String: String])
}

struct SearchResponse {
    let pages: [Page]
    let continuation: Continuation
}

protocol ActionAPIInterface {
    func search(with term: String, continuation: Continuation) -> AnyPublisher<SearchResponse, Error>
}

struct ActionAPIService: ActionAPIInterface {
    let site: Wikipedia
    let session: URLSession = URLSession.shared
    
    func buildURL(with params: [String: String]) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = site.host
        components.path = "/w/api.php"
        components.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        guard let builtURL = components.url else {
            throw WikipediaError.invalidParameters
        }
        return builtURL
    }

    func search(with term: String, continuation: Continuation) -> AnyPublisher<SearchResponse, Error> {
        do {
            let limit = 50
            var params = [
                "action": "query",
                "prop": "description|pageprops|pageimages|revisions|coordinates",
                "coprop": "type|dim",
                "ppprop": "displaytitle",
                "generator": "search",
                "gsrsearch": term,
                "gsrnamespace": "0",
                "gsrwhat": "text",
                "gsrinfo": "",
                "gsrprop": "redirecttitle",
                "gsroffset": "0",
                "gsrlimit": "\(limit)",
                "piprop": "thumbnail",
                "pilimit": "\(limit)",
                "rvprop": "ids",
                "continue": "",
                "format": "json",
                "formatversion": "2",
                "redirects": "1"
            ]
            switch continuation {
            case .no:
                break
            case .yes(let continuationParams):
                continuationParams.forEach { (kv) in
                    params[kv.key] = kv.value
                }
            }
            let url = try buildURL(with: params)
            return session.dataTaskPublisher(for: url)
                .tryMap { try JSONDecoder().decode(SearchAPIResponse.self, from: $0.data) }
                .tryMap { response in
                    guard let query = response.query else {
                        return SearchResponse(pages: [], continuation: .no)
                    }
                    let continuation: Continuation
                    if let responseContinuation = response.continuation {
                        var continuationParams = ["continue": responseContinuation.continuation]
                        if let cocontinue = responseContinuation.cocontinue {
                            continuationParams["cocontinue"] = cocontinue
                        }
                        if let gsroffset = responseContinuation.gsroffset {
                            continuationParams["gsroffset"] = "\(gsroffset)"
                        }
                        continuation = .yes(continuationParams)
                    } else {
                        continuation = .no
                    }
                    let pages = query.pages
                        .sorted { $0.index < $1.index }
                        .map { (responsePage) -> Page in
                            let namespace = Page.Namespace(rawValue: responsePage.ns) ?? .unknown
                            let id = Page.Identifier(wiki: site, title: responsePage.title, namespace: namespace)
                            return Page(id: id)
                        }
                    return SearchResponse(pages: pages, continuation: continuation)
                }
                .eraseToAnyPublisher()
        } catch let error {
            return Fail(error: error).eraseToAnyPublisher()
        }
       
    }
}

fileprivate struct SearchAPIResponse: Codable {
    struct SearchResults: Codable {
        let pages: [PageResponse]
    }
    struct PageResponse: Codable {
        let title: String
        let description: String?
        let descriptionsource: String?
        let ns: Int
        let pageid: Int
        let index: Int
        struct PageProps: Codable {
            let displaytitle: String?
        }
        let pageprops: PageProps?
    }
    let query: SearchResults?
    struct SearchContinuation: Codable {
        let gsroffset: Int?
        let cocontinue: String?
        let continuation: String
        enum CodingKeys: String, CodingKey {
            case gsroffset
            case continuation = "continue"
            case cocontinue
        }
    }
    let continuation: SearchContinuation?
    enum CodingKeys: String, CodingKey {
        case query
        case continuation = "continue"
    }
}
