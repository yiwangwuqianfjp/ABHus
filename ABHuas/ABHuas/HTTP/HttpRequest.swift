//
//  HttpRequest.swift
//  ABHuas
//
//  Created by Apple on 2018/1/19.
//  Copyright © 2018年 Apple. All rights reserved.
//

import UIKit

class HttpRequest: NSObject {
    
    private let host = "http://20.10.10.240:5000/"
    
    private func sendRequest(request:URLRequest,result:@escaping (Any?)->Void) {
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, err) in
            guard data != nil else {
                print("-------error-------")
                result(nil)
                return
            }
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                DispatchQueue.main.async {
                    result(json)
                }
                print("请求的结果:------",json)
            }catch{
                DispatchQueue.main.async {
                    result(nil)
                }
                print(request,"--------catch-error---------",error)
            }
        }
        dataTask.resume()
    }
    
    private func receiveNewInfos(urlString:String, result:@escaping ([NSDictionary]?)->Void) {
        guard let url = URL.init(string: urlString) else {return}
        let urlRequest = NSMutableURLRequest.init(url:url)
        sendRequest(request: urlRequest as URLRequest) { (data) in
            guard data != nil else {return}
            let array = data as! [NSDictionary]
            result(array)
        }
    }
    
    private func sendInfo(urlString:String,parameters:[TaskInfo],result:@escaping(Error?)->Void) {
        guard let url = URL.init(string: urlString) else {return}
        let request = NSMutableURLRequest.init(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        // 用TaskInfo构造json对象
        var taskInfoArray = [Dictionary<String, Any>]()
        for taskInfo in parameters {
            var infoDic = Dictionary<String, Any>()
            infoDic["content"] = taskInfo.content
            infoDic["createDate"] = Int64((taskInfo.createDate?.timeIntervalSince1970)!)
            infoDic["expireDate"] = Int64((taskInfo.expireDate?.timeIntervalSince1970)!)
            infoDic["progress"] = taskInfo.progress
            infoDic["finish"] = taskInfo.finish
            taskInfoArray.append(infoDic)
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: taskInfoArray, options: JSONSerialization.WritingOptions.prettyPrinted)
            request.httpBody = jsonData
            if let jsonString = String.init(data: jsonData, encoding: String.Encoding.utf8){
                print("jsonString====",jsonString)
                sendRequest(request: request as URLRequest){ (data) in
                    guard data != nil else {return}
                    let dic:NSDictionary = data as! NSDictionary
                    if dic["info"] as! String == "ok"{
                        result(nil)
                    }
                }
            }
        }catch{
            print("-----send catch error------",error)
        }
    }
    
    /// 下载远程数据
    ///
    /// - Parameter result:
    func loadTaskInfo(result:@escaping ([NSDictionary]?)->Void){
        receiveNewInfos(urlString: host + "load", result: result)
    }
    
    /// 上传数据到远程
    ///
    /// - Parameters:
    ///   - parameters:
    ///   - result:
    func uploadTaskInfos(parameters:[TaskInfo],result:@escaping(Error?)->Void){
        sendInfo(urlString: host + "upload", parameters: parameters, result: result)
    }
}
