import SwiftUI
import os.log

struct PageViewControllerWrapper: UIViewControllerRepresentable {
    @ObservedObject var model: PageViewModel
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PageViewControllerWrapper>) -> PageViewController {
        let pageViewController = PageViewController(pageViewModel: model)
        pageViewController.messageHandler = context.coordinator
        return pageViewController
    }
    
    func updateUIViewController(_ uiViewController: PageViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> PageViewControllerWrapper.Coordinator {
        return Coordinator(model: model)
    }
}


extension PageViewControllerWrapper {
    class Coordinator: ArticleWebMessageHandling {
        let model: PageViewModel
        init(model: PageViewModel) {
            self.model = model
        }
        func didRecieve(action: ArticleWebMessagingController.Action) {
            switch action {
            case .link(_, _, let title):
                guard let title = title else {
                    return
                }
                model.push(page: Page(id: Page.Identifier(wiki: Wikipedia(language: .en), title: title, namespace: .main)))
            default:
                break
            }
        }
    }
}

