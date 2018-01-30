//
//  EditViewController.swift
//  ABHuas
//
//  Created by Apple on 2017/12/19.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit
import PKHUD

class EditViewController: UIViewController,UITextViewDelegate {

    @IBOutlet weak var confirmButton: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    
    private let requst = HttpRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        confirmButton.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirm(_ sender: UIBarButtonItem) {
        let obj = DataHandler.sharedHandler.insertTask(createDate: NSDate(), content: self.textView.text, progress: 0)
        // 同步到远程
        requst.uploadTaskInfos(parameters: [obj]) { (error) in
            HUD.flash(.labeledSuccess(title: "同步成功", subtitle: nil), delay: 0.3)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        confirmButton.isEnabled = text.count > 0 
    }
   
}
