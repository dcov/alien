import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewControl extends StatefulWidget {

  WebViewControl({
    Key key,
    @required this.url,
    this.onPageFinished,
    this.javascriptEnabled = false,
    this.gestureNavigationEnabled = false,
  }) : assert(url != null),
       super(key: key);

  final String url;

  final PageFinishedCallback onPageFinished;

  final bool javascriptEnabled;

  final bool gestureNavigationEnabled;
  
  @override
  _WebViewControlState createState() => _WebViewControlState();
}

class _WebViewControlState extends State<WebViewControl> {

  final GlobalKey _webViewKey = GlobalKey();

  WebViewController _controller;

  @override
  void didUpdateWidget(WebViewControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      _controller.loadUrl(widget.url);
    }
  }

  @override
  void dispose() {
    super.dispose();
    WebView.platform.clearCookies();
  }

  @override
  Widget build(_) {
    return WebView(
      key: _webViewKey,
      initialUrl: widget.url,
      javascriptMode: widget.javascriptEnabled ? JavascriptMode.unrestricted : JavascriptMode.disabled,
      onWebViewCreated: (WebViewController controller) {
        _controller = controller;
      },
      onPageFinished: widget.onPageFinished);
  }
}

