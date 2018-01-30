//
//  DetailViewController.swift
//  ABHuas
//
//  Created by Apple on 2017/12/19.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit
import PKHUD

class DetailViewController: UIViewController,UITextViewDelegate {
    
    var task:TaskInfo?
    
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var progressView: CustomProgressView!
    private let requst = HttpRequest()
    override func viewDidLoad() {
        super.viewDidLoad()
        guard task != nil else {return}
        if task!.expireDate == Date.distantFuture {
            finishButton.setTitle("已终结", for: UIControlState.normal)
        }
        finishButton.isEnabled =  task!.expireDate!.timeIntervalSinceNow < 0
        self.textView.text = task!.content
        self.progressView.progress = Int(task!.progress)
        self.textView.isEditable = false
        self.textView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didClickRightItem(_ sender: UIBarButtonItem) {
        if sender.title == "编辑" {
            self.textView.isEditable = true
            self.textView.becomeFirstResponder()
            sender.title = "确定"
        }else{
            let alert = UIAlertController.init(title: "确定修改吗", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction.init(title: "确定修改", style: UIAlertActionStyle.default, handler: { (action) in
                DataHandler.sharedHandler.modifyTaskContent(task: self.task!, content: self.textView.text)
                self.postRemoteInfo(self.task!)
                self.navigationController?.popViewController(animated: true)
            })
            let cancelAction = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(action)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func didClickFinishButton(_ sender: UIButton) {
        if task?.progress == 6 {
            let alert = UIAlertController.init(title: "恭喜你,此任务已终结!", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction.init(title: "好的", style: UIAlertActionStyle.cancel, handler: {(action) in
                DataHandler.sharedHandler.finishTask(self.task!)
                self.postRemoteInfo(self.task!)
                self.navigationController?.popViewController(animated: true)
            })
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion:nil)
        }else{
            DataHandler.sharedHandler.finishTask(task!)
            self.postRemoteInfo(task!)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if text.count == 0 {
            let alert = UIAlertController.init(title: "任务内容不能为空", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction.init(title: "重新编辑", style: UIAlertActionStyle.cancel, handler: { (action) in
                self.textView.text = self.task!.content
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)            
        }
    }
    
    // 同步数据到远程
    private func postRemoteInfo(_ info:TaskInfo){
        requst.uploadTaskInfos(parameters: [info]) { (error) in
            HUD.flash(.labeledSuccess(title: "同步成功", subtitle: nil), delay: 0.3)
        }
    }
    
}
