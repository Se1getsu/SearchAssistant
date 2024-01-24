import SwiftUI

@MainActor
final class SettingViewModel: ObservableObject {
    @AppStorage(AppStorageKey.autoFocus) private(set) var settingAutoFocus = true
    @AppStorage(AppStorageKey.searchButton_Left) private(set) var settingLeftSearchButton = false
    @AppStorage(AppStorageKey.colorScheme) private(set) var appStorageColorScheme = ColorSchemeSetting.dark.rawValue
    @AppStorage(AppStorageKey.openInSafariView) private(set) var openInSafariView = true
    @Published private(set) var keyboardToolbarValidButtons = Set(SerchPlatform.allCases)

    init() {
        fetchKeyboardToolbarValidButtons()
    }

    private let keyboardToolbarValidButtonRepository = UserDefaultsRepository<Set<SerchPlatform>>(key: UserDefaultsKey.keyboardToolbarValidButtons)

    private func saveKeyboardToolbarValidButton() throws {
        try keyboardToolbarValidButtonRepository.save(keyboardToolbarValidButtons)
    }

    func fetchKeyboardToolbarValidButtons() {
        do {
            keyboardToolbarValidButtons = try keyboardToolbarValidButtonRepository.fetch()
        } catch {
            reportError(error)
            keyboardToolbarValidButtons = Set(SerchPlatform.allCases)
        }
    }

    func toggleToolbarButtonAvailability(_ platform: SerchPlatform) {
        let preKeyboardToolbarValidButtons = keyboardToolbarValidButtons
        if keyboardToolbarValidButtons.contains(platform) {
            keyboardToolbarValidButtons.remove(platform)
        } else {
            keyboardToolbarValidButtons.insert(platform)
        }
        do {
            try keyboardToolbarValidButtonRepository.save(keyboardToolbarValidButtons)
        } catch {
            reportError(error)
            keyboardToolbarValidButtons = preKeyboardToolbarValidButtons
        }
    }
}
