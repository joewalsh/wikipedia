import Foundation

protocol SiteInterface: Equatable {
    var host: String { get }
}

enum Host: String {
    case wikipedia = "wikipedia.org"
}

public struct Wikipedia: SiteInterface {
    enum Language: String {
        case en
        case ar
        var isRTL: Bool {
            switch self {
            case .ar:
                return true
            default:
                return false
            }
        }
    }
    let language: Language
    var host: String {
        return language.rawValue + "." + Host.wikipedia.rawValue
    }
}

extension Wikipedia: Hashable { }
