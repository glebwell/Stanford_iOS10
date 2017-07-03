//
//  WebViewController.swift
//  Smashtag
//
//  Created by Gleb on 25.06.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {

    var pageURL: URL?

    @IBAction func toRootViewController(_ sender: UIBarButtonItem) {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    @IBOutlet weak var webView: UIWebView!
    {
        didSet {
            if let url = pageURL {
                webView.delegate = self
                title = url.host
                webView.scalesPageToFit = true
                webView.loadRequest(URLRequest(url: url))
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if navigationItem.leftBarButtonItem == nil {
            let bar = UIBarButtonItem(image: UIImage(named: "back"),
                                      style: .plain,
                                      target: self,
                                      action: #selector(toRootViewControllerOrBack))

            navigationItem.setLeftBarButton(bar, animated: true)
        }

    }

    @objc private func toRootViewControllerOrBack(_ item: UIBarButtonItem) {
        if let view = webView, view.canGoBack {
            view.goBack()
        } else {
            toRootViewController(item)
        }
    }

    // MARK: - UIWebViewDelegate

    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        spinner?.startAnimating()
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        spinner?.stopAnimating()
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        spinner?.stopAnimating()
    }
}
