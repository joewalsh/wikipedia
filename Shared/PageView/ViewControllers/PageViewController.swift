import UIKit
import WebKit
import os.log

class PageViewController: UIViewController {
    let pageViewModel: PageViewModel
    weak var messageHandler: ArticleWebMessageHandling?
    
    init(pageViewModel: PageViewModel) {
        self.pageViewModel = pageViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static let sharedProcessPool: WKProcessPool = WKProcessPool()
    
    lazy var webViewConfiguration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = PageViewController.sharedProcessPool
        return configuration
    }()
    
    lazy var webView: WKWebView = {
        return WKWebView(frame: .zero, configuration: webViewConfiguration)
    }()
    
    lazy var messagingController: ArticleWebMessagingController = {
        let mc = ArticleWebMessagingController()
        mc.delegate = messageHandler
        return mc
    }()
    
    override func loadView() {
        view = webView
        do {
            try messagingController.setup(with: webView, language: "en", theme: theme, layoutMargins: view.layoutMargins, leadImageHeight: 0, areTablesInitiallyExpanded: false, userGroups: [])
        } catch let error {
            Logger.standard.error("Error setting up messaging controller: \(error as NSObject)")
        }
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateMargins()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.load(URLRequest(url: pageViewModel.page.contentURL))
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        messagingController.updateTheme(theme)
    }
    
    var theme: Theme {
        return traitCollection.userInterfaceStyle == .dark ? Theme.black : Theme.light
    }

    private func updateMargins() {
        let hMargin = view.readableContentGuide.layoutFrame.minX
        let newMargins = UIEdgeInsets(top: 8, left: hMargin, bottom: 0, right: hMargin)
        messagingController.updateMargins(with: newMargins, leadImageHeight: 0)
    }
}
