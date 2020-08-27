import SwiftUI
import WebKit


struct PageView: View {
    @ObservedObject var model: PageViewModel
    
    var body: some View {
        PageViewControllerWrapper(model: model)
            .navigationBarItems(trailing: forwardButton)
        if let next = model.forwardPage {
            NavigationLink(
                destination: PageView(model: next),
                isActive: $model.isForwardPageActive,
                label: {
                    EmptyView()
                        .hidden()
                })
        }
    }
    
    var forwardButton: some View {
        Button {
            model.goForward()
        } label: {
            Text("Forward")
                .font(.body)
            Image(systemName: "chevron.forward")
                .imageScale(.large)
        }
        .opacity(forwardButtonOpacity)
        .animation(.default)
           
    }
    
    var forwardButtonOpacity: Double {
        switch model.forwardState {
        case .active:
            fallthrough
        case .available:
            return 1
        default:
            return 0
        }
    }
}
