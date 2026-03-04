import AppKit
import WebKit

final class WebViewController: NSViewController {
    private var webView: WKWebView!

    private static let loginURL = URL(
        string: "https://id.jobcan.jp/users/sign_in?app_key=atd&redirect_to=https://ssl.jobcan.jp/jbcoauth/callback"
    )!

    override func loadView() {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        let js = """
            var s = document.createElement('style');
            s.textContent = '#adit-button-push:focus { box-shadow: inset 0 0 0 5px #ccc !important; }';
            document.head.appendChild(s);
            var btn = document.getElementById('adit-button-push');
            if (btn) { btn.focus(); }
            """
        let script = WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(script)

        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 480, height: 700), configuration: configuration)
        webView.autoresizingMask = [.width, .height]

        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        var request = URLRequest(url: Self.loginURL)
        request.setValue("ja-JP,ja;q=0.9", forHTTPHeaderField: "Accept-Language")
        webView.load(request)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.makeKey()
        webView.becomeFirstResponder()
    }
}
