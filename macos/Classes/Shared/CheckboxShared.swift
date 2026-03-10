import SwiftUI


struct CupertinoCheckboxView: View {
  @ObservedObject var model: CheckboxModel

  var body: some View {
    let base = Toggle(
      isOn: $model.value
    ) {
      if let label = model.label, let systemImage = model.systemImage {
        Label(label, systemImage: systemImage).labelStyle(.titleAndIcon)
      } else if let label = model.label {
        Text(label)
      } else if let systemImage = model.systemImage {
        Image(systemName: systemImage)
      } else {
        EmptyView()
      }
    }
    .controlSize(model.controlSize)
    .disabled(!model.enabled)
    .onChange(
      of: model.value, initial: model.value,
      { oldValue, newValue in
        if oldValue != newValue {
          model.handleChange(newValue)
        }
      }
    )
    .toggleStyle(.checkbox)

    if #available(macOS 12.0, *) {
      base.tint(model.tintColor)
    } else {
      base.accentColor(model.tintColor)
    }
  }
}

class CheckboxModel: ObservableObject {
  @Published var value: Bool
  @Published var tintColor: Color = .accentColor
  @Published var controlSize: ControlSize = .regular
  @Published var label: String? = nil
  @Published var systemImage: String? = nil
  @Published var enabled: Bool
  var onChange: (Bool) -> Void

  private var suppressChangeCallback = false

  init(value: Bool, label: String? = nil, systemImage: String? = nil, enabled: Bool, onChange: @escaping (Bool) -> Void) {
    self.value = value
    self.label = label
    self.systemImage = systemImage
    self.enabled = enabled
    self.onChange = onChange
  }

  func handleChange(_ newValue: Bool) {
    onChange(newValue)
  }

  func setValueFromDart(_ newValue: Bool) {
    value = newValue
  }
}
