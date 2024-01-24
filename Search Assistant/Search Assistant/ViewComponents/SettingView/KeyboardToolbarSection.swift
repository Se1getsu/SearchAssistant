import SwiftUI

struct KeyboardToolbarSection: View {
    private let keyboardToolbarValisButtons: Set<SASerchPlatform>
    private let action: @MainActor (SASerchPlatform) -> Void
    private let feedbackGenerator = UINotificationFeedbackGenerator()

    init(
        keyboardToolbarValisButtons: Set<SASerchPlatform>,
        action: @escaping @MainActor (SASerchPlatform) -> Void
    ) {
        self.keyboardToolbarValisButtons = keyboardToolbarValisButtons
        self.action = action
    }

    var body: some View {
        Section {
            ForEach(SASerchPlatform.allCases) { platform in
                RowLikeToggleButton(
                    text: platform.rawValue,
                    isValid: keyboardToolbarValisButtons.contains(platform),
                    action: { action(platform) },
                    feedbackAction: {                        feedbackGenerator.notificationOccurred(.success)
                    }
                )
            }
        } header: {
            Text("ツールバーボタン")
        } footer: {
            Text("ツールバーに表示する検索ボタンを設定できます。")
        }
    }
}

struct RowLikeToggleButton: View {
    private let text: String
    private let isValid: Bool
    private let action: @MainActor () -> Void
    private let feedbackAction: () -> Void

    init(
        text: String,
        isValid: Bool,
        action: @escaping @MainActor () -> Void,
        feedbackAction: @escaping () -> Void
    ) {
        self.text = text
        self.isValid = isValid
        self.action = action
        self.feedbackAction = feedbackAction
    }

    var body: some View {
        Button(
            action: { action(); feedbackAction(); },
            label: {
                HStack {
                    Text(text)
                    Spacer()
                    Image(systemName: "checkmark")
                        .bold()
                        .foregroundStyle(isValid ? .green : .clear)
                }
            })
        .foregroundStyle(.primary)
    }
}

#Preview {
    List {
        KeyboardToolbarSection(
            keyboardToolbarValisButtons: Set(SASerchPlatform.allCases),
            action: { _ in}
        )
    }
}
