import SwiftUI

struct ContentView: View {
    @State private var model = AppModel()

    var body: some View {
        Group {
            switch model.currentScreen {
            case .hero:
                HeroView(model: model)
            case .home:
                HomeView(model: model)
            case .confirm:
                CallConfirmationView(model: model)
            case .inCall:
                InCallView(model: model)
            case .newFamily:
                ContactFormView(model: model, mode: .newFamily)
            case .newOther:
                ContactFormView(model: model, mode: .newOther)
            case .editContact(let contact):
                ContactFormView(model: model, mode: .edit(contact))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: model.currentScreen)
    }
}
