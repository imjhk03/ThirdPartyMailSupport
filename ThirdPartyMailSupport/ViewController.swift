//
//  ViewController.swift
//  ThirdPartyMailSupport
//
//  Created by Joo Hee Kim on 21. 02. 21..
//

import UIKit
import MessageUI

final class ViewController: UIViewController {
    
    private let receiver = "imjhk03@gmail.com"
    private let subject = "Bug report: "
    private let message = """
    Hello,

    App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? 1.0)
    iOS Version: \(UIDevice().systemVersion)
    """

    @IBOutlet private weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        button.setTitle("이메일 보내기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.titleEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        button.layer.cornerRadius = 8
        button.titleLabel?.adjustsFontSizeToFitWidth = true
    }

    @IBAction private func buttonTapped(_ sender: UIButton) {
        sendEmail()
    }
    
    private func sendEmail() {
        let composerVC = MFMailComposeViewController()
        
        if MFMailComposeViewController.canSendMail() {
            composerVC.mailComposeDelegate = self
            
            // Configure the fields of the interface.
            composerVC.setToRecipients([receiver])
            composerVC.setSubject(subject)
            composerVC.setMessageBody(message, isHTML: false)
            
            // Present the view controller modally.
            present(composerVC, animated: true, completion: nil)
        } else {
            sendEmailByThirdParty()
        }
    }
    
    typealias AvailableApps = (url: URL?, title: String)
    
    private func sendEmailByThirdParty() {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? subject
        let bodyEncoded = message.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? message
        
        let gmailUrl = URL(string: "googlegmail://co?to=\(receiver)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(receiver)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(receiver)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        
        let sendViaGmail = (url: gmailUrl, title: "Gmail")
        let sendViaOutlook = (url: outlookUrl, title: "Outlook")
        let sendViaSpark = (url: sparkUrl, title: "Spark")
        
        // Check if the app can open URL
        let availableApps = [sendViaGmail, sendViaOutlook, sendViaSpark].filter { availableApp -> Bool in
            guard let url = availableApp.url else { return false }
            return UIApplication.shared.canOpenURL(url)
        }
        
        guard !availableApps.isEmpty else {
            presentAlertCanNotSendEmail()
            return
        }
        
        presentAlertSheetThirdPartyEmailApps(availableApps)
    }
    
    private func presentAlertCanNotSendEmail() {
        let alert = UIAlertController(title: "Alert", message: "It seems there is no way to send email in your device. Please send email to bugReport@email.com", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func presentAlertSheetThirdPartyEmailApps(_ availableApps: [AvailableApps]) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for app in availableApps {
            alert.addAction(UIAlertAction(title: app.title, style: .default, handler: { _ in
                guard let url = app.url else { return }
                // Handle open url to
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
}

// MARK: - MFMailComposeViewControllerDelegate
extension ViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        if result == .sent {
            
        } else {
            
        }
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true)
    }
}
