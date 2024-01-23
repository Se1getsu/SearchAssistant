import SwiftUI

@MainActor
final class ContentViewModel: ContentViewModelProtocol {
    ///
    ///
    ///
    /// 【Search History】
    ///
    /// ContentViewModel内部で保持する検索履歴
    @Published private var _historys: [SASerachHistory] = []
    /// 外部に公開する整形された検索履歴
    var historys: [HistoryInfo] {
        self._historys.map { history in
            HistoryInfo(
                userInput: history.userInput,
                platform: history.platform,
                dateString: self.dateFormatter.string(from: history.date),
                id: history.id
            )
        }
    }
    /// ContentViewに提供する検索履歴
    struct HistoryInfo: Identifiable {
        let userInput: String
        let platform: SASerchPlatform
        let dateString: String
        let id: UUID
    }
    /// 検索履歴を保管するためのクラス
    private let historyStore = HistoryStore.shared
    /// 検索履歴を追加する
    private func appendHistory(userInput: String, platform: SASerchPlatform) {
        historyStore.append(userInput: userInput, platform: platform)
    }
    /// 特定の検索履歴を削除する
    func removeHistory(atOffsets indexSet: IndexSet) {
        historyStore.remove(atOffsets: indexSet)
    }
    /// 全ての検索履歴を削除する
    func removeAllHistorys() {
        historyStore.removeAll()
    }
    ///
    ///
    ///
    ///
    ///
    /// 【Search Suggestion】
    ///
    /// 検索候補を保持する変数
    @Published private(set) var suggestions: [String]? = []
    /// 検索候補を取得するクラス
    private let suggestionFetcher = SuggestionFetcher.shared
    /// ユーザー入力から検索候補を取得する
    func getSuggestion(from userInput: String) async {
        do {
            try await suggestions = suggestionFetcher.fetch(from: userInput)
        } catch {
            suggestions = nil
        }
    }
    ///
    ///
    ///
    ///
    ///
    /// 【Search Executer】
    ///
    /// 検索を行うためのクラス
    var searcher = SearchExecuter()
    /// ユーザー入力とプラットフォームを元に検索を実行し、履歴に追加する
    func search(_ userInput: String, on platform: SASerchPlatform) {
        do {
            try searcher.Search(userInput, on: platform)
            appendHistory(userInput: userInput, platform: platform)
            self.userInput.removeAll()
        } catch {
            switch error {
            case SearchExecuter.SearchExecuterError.userInputContainsWhitespaceOnInstagramSearch:
                isShowInstagramErrorAlert = true
            default:
                reportError(error)
            }
        }
    }
    ///
    ///
    ///
    ///
    ///
    /// 【Presentation】
    ///
    /// 設定画面の表示状態を管理する変数
    @Published var isPresentedSettingView = false
    /// インスタグラムエラーアラートの表示状態を管理する変数
    @Published var isShowInstagramErrorAlert = false
    /// 全履歴削除の確認を行うプロンプトの表示状態を管理する変数
    @Published var isShowPromptToConfirmDeletionOFAllHistorys = false
    ///
    ///
    ///
    ///
    ///
    /// 【Settings】
    ///
    /// キーボードの自動表示の設定を保持する変数
    @AppStorage(AppStorageKey.autoFocus)
    private(set) var settingAutoFocus = true
    /// 検索ボタンの位置の設定を保持する変数
    @AppStorage(AppStorageKey.searchButton_Left)
    private(set) var settingLeftSearchButton = false
    ///
    ///
    ///
    ///
    ///
    /// 【Setting: KeyboardToolbarValidButton】
    ///
    /// 有効化されているキーボードツールバーボタンを保持する変数
    @Published private(set) var keyboardToolbarValidButtons: Set<SASerchPlatform>
    /// キーボードツールバーボタンの有効無効を管理するクラス
    private let keyboardToolbarValidButtonManager = UserDefaultsRepository<Set<SASerchPlatform>>(key: UserDefaultsKey.keyboardToolbarValidButtons)
    /// 有効化されているキーボードツールバーボタンを取得する
    func fetchKeyboardToolbarValidButtons() {
        do {
            keyboardToolbarValidButtons = try keyboardToolbarValidButtonManager.fetch()
        } catch {
            reportError(error)
            keyboardToolbarValidButtons = Set(SASerchPlatform.allCases)
        }
    }
    ///
    ///
    ///
    ///
    ///
    /// 【Others】
    ///
    /// テキストフィールドで用いるテキストを保持する変数
    @Published var userInput = ""
    /// 日付フォーマットが"yyyy/MM/dd"で設定されているDateFormatter
    private let dateFormatter: DateFormatter
    ///
    ///
    ///
    ///
    ///
    /// 【Initializer】
    ///
    init() {
        /// 内部で使用するdateFormatter設定する
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.calendar = Calendar.autoupdatingCurrent
        self.dateFormatter = dateFormatter
        /// 保存されている有効化されているキーボードツールバーボタンを取得する
        /// 失敗時には全てのキーボードツールバーボタンを有効化する
        do {
            keyboardToolbarValidButtons = try keyboardToolbarValidButtonManager.fetch()
        } catch {
            reportError(error)
            keyboardToolbarValidButtons = Set(SASerchPlatform.allCases)
        }
        /// historyStoreが保持するhistorysの変更を内部の_historys変数に伝播させる
        historyStore.$historys
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$_historys)
    }
}
