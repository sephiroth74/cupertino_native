import SwiftUI

struct CupertinoSwitchView: View {
  @ObservedObject var model: SwitchModel

  var body: some View {
    let base = Toggle("", isOn: $model.value)
      .labelsHidden()
      .controlSize(model.controlSize)
      .disabled(!model.enabled)
      .onChange(of: model.value, initial: model.value) { oldValue, newValue in
        model.handleChange(newValue)
      }
      .toggleStyle(.switch)

    if #available(macOS 12.0, *) {
      base.tint(model.tintColor)
    } else {
      base.accentColor(model.tintColor)
    }
  }
}

class SwitchModel: ObservableObject {
  @Published var value: Bool
  @Published var enabled: Bool
  @Published var tintColor: Color = .accentColor
  @Published var controlSize: ControlSize = .regular

  var onChange: (Bool) -> Void
  
  private var suppressChangeCallback = false

  init(value: Bool, enabled: Bool, onChange: @escaping (Bool) -> Void) {
    self.value = value
    self.enabled = enabled
    self.onChange = onChange
  }

  func handleChange(_ newValue: Bool) {
    if suppressChangeCallback {
      return
    }
    onChange(newValue)
  }

  func setValueFromDart(_ newValue: Bool) {
    suppressChangeCallback = true
    value = newValue
    suppressChangeCallback = false
  }
}
