//
//  webViewController.swift
//  Moodle
//
//  Created by Adam Bratin on 11/13/14.
//  Copyright (c) 2014 Bratin. All rights reserved.
//

import UIKit
import WebKit

class webViewController: UIViewController, WKNavigationDelegate, NSURLConnectionDelegate, UIAlertViewDelegate, WKScriptMessageHandler {
    var domain : String = ""
    var creds : Dictionary<String,String> = Dictionary<String,String>()
    var startTouchID : Bool = false
    @IBOutlet var webView : WKWebView!
    @IBOutlet var stopLoadingButton : UIBarButtonItem!
    @IBOutlet var reloadButton : UIBarButtonItem!
    @IBOutlet var forwardButton : UIBarButtonItem!
    @IBOutlet var backwardButton : UIBarButtonItem!
    @IBAction func reload(sender : AnyObject) {
        self.webView.reload()
    }
    @IBAction func stopLoad(sender : AnyObject) {
        self.webView.stopLoading()
    }
    @IBAction func forward(sender : AnyObject) {
        self.webView.goForward()
    }
    @IBAction func backward(sender : AnyObject) {
        self.webView.goBack()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var userContentController = WKUserContentController()
        var configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        self.webView = WKWebView(frame:view.frame, configuration: WKWebViewConfiguration())
        self.webView.navigationDelegate = self;
        self.view.addSubview(self.webView)
        self.webView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        self.webView.allowsBackForwardNavigationGestures = true
        var url : NSURL! = NSURL(string: Constants.moodleURL + self.domain)
        var request :NSURLRequest! = NSURLRequest(URL: url)
        self.webView.loadRequest(request)
        SecurityControl.evaluateTouch(self, withDomain: self.domain)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createLoginScript() {
        if let usr = creds["password"] {
            var password = creds["password"]
            var username = creds["username"]
            
            var script : String = "document.getElementById(\"username\").value = \"\(username!)\"; \n"
            script += "document.getElementById(\"password\").value = \"\(password!)\"; \n"
//            document.getElementById("password").parentNode.submit()
            script += "document.getElementById(\"password\").parentNode.submit()"
            var userScript : WKUserScript = WKUserScript(source: script, injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, forMainFrameOnly: true)
            self.webView.configuration.userContentController.addUserScript(userScript)
            self.webView.reload()
//            self.webView.evaluateJavaScript(script, completionHandler: {(result : AnyObject!, error : NSError!) -> Void in
//                if(error != nil) {
//                    println("Error: \(error.localizedDescription)")
//                    println(script)
//                }
//            })
        } else {
            SecurityControl.evaluateTouch(self, withDomain: domain)
        }
    }
    
     func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        println("got message: \(message.body)")
    }
}
