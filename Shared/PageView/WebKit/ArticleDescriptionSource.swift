public enum ArticleDescriptionSource: String {
    case none
    case unknown
    case central
    case local
    
    public static func from(string: String?) -> ArticleDescriptionSource {
        guard let sourceString = string else {
            return .none
        }
        guard let source = ArticleDescriptionSource(rawValue: sourceString) else {
            return .unknown
        }
        return source
    }
}
