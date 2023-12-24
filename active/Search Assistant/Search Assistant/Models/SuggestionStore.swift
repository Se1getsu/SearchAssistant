import Foundation

final class SuggestionStore {
    @Published private(set) var suggestions: [String] = [] {
        didSet {
            // Update Process
        }
    }
    @Published private(set) var fetchFailure = false
    static let shared = SuggestionStore()
    private init() {}

    func update(with newSuggestions: [String]) {
        self.suggestions = newSuggestions
    }

    func fetchSuggestions(from input: String) async throws {
        fetchFailure = false
        // URLを作成
        let suggestionAPIURL = "https://www.google.com/complete/search?hl=ja&output=toolbar&q="
        let encodedInput = input.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: suggestionAPIURL + encodedInput)!
        // API通信データを取得
        var data = Data()
        do {
            (data, _) = try await URLSession.shared.data(from: url)
        } catch {
            fetchFailure = true
            update(with: []) // FIXME: 重複
        }

        let xmlString = String(data: data, encoding: .shiftJIS)!
        let suggestions = convertXMLStringToArray(xmlString: xmlString)

        // suggestionsを反映
        update(with: suggestions) // FIXME: 重複
    }
}

extension SuggestionStore {
    private func convertXMLStringToArray(xmlString: String) -> [String] {
        var suggestions: [String] = .init()
        let unfinishedXmlElements = xmlString.components(separatedBy: "<CompleteSuggestion><suggestion data=\"")
        for (index, element) in xmlString.components(separatedBy: "<CompleteSuggestion><suggestion data=\"").enumerated() {
            if index == 0 {
                continue
            } else if index == unfinishedXmlElements.count-1 {
                suggestions.append(
                    element.replacingOccurrences(of: "\"/></CompleteSuggestion></toplevel>", with: "")
                )
            } else {
                suggestions.append(
                    element.replacingOccurrences(of: "\"/></CompleteSuggestion>", with: "")
                )
            }
        }
        return suggestions
    }
}
