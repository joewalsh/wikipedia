import Foundation

extension CharacterSet {
    // Match the functionality of encodeURIComponent() in JavaScript, using this Mozilla reference:
    // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent#Description
    // as per this comment: https://phabricator.wikimedia.org/T249284#6113747
    static let encodeURIComponentAllowed: CharacterSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.!~*'()")
}
