//
//  DataHandler.swift
//  ABHuas
//
//  Created by Apple on 2017/12/20.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit
import CoreData

private let day:TimeInterval = 24 * 3600

class DataHandler: NSObject {
    
    // 任务时间 0.5h 0.5d 1d 2d 4d 7d 15d
    private let delayArray = [30.0 * 60.0 ,0.5 * day - 7200 , day - 7200 ,2 * day - 7200,4 * day - 7200, 7 * day - 7200, 15 * day - 7200]
//    private let delayArray = [30.0,60.0,90.0,120.0,150.0,180.0,210.0]
    
    private lazy var managedContext: NSManagedObjectContext = {
        // 从应用程序包中加载模型文件
        let managedObjModel = NSManagedObjectModel.mergedModel(from: nil)
        // 传入模型对象, 初始化NSPersistentStoreCoordinator
        let psc = NSPersistentStoreCoordinator.init(managedObjectModel: managedObjModel!)
        // 构建sqlite数据库文件的路径
        let docs = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last
        let url = NSURL.init(fileURLWithPath: docs!.appending("/abhous.data"))
        // 添加持久化数据库,这里使用sqlite作为数据库
        do {
            let store = try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url as URL, options: nil)
        }catch{
            print("----------errot--------",error)
        }
        
        // 初始化上下文,设置persistenStoreCoordinator
        let context = NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        context.persistentStoreCoordinator = psc
        return context
    }()
    
    static let sharedHandler = DataHandler()
    private override init() {}
    
    // 添加新任务
    func insertTask(createDate:NSDate,content:String,progress:Int = 0,finish: Bool = true) -> TaskInfo {
        // 传入上下文,创建一个实体对象
        let taskInfo = NSEntityDescription.insertNewObject(forEntityName: "TaskInfo", into: self.managedContext)
        // 设置属性
        taskInfo.setValue(content, forKey: "content")
        taskInfo.setValue(createDate, forKey: "createDate")
        // 下次过期日期
        let expireDate = self.expireDate(progress: progress,sinceDate: createDate)
        taskInfo.setValue(expireDate, forKey: "expireDate")
        // 当前任务是否完成
        taskInfo.setValue(finish, forKey: "finish")
        taskInfo.setValue(progress, forKey: "progress")
        
        // 利用上下文对象,将数据同步到持久化数据库
        do {
            try managedContext.save()
        } catch {
            print(error)
        }
        return taskInfo as! TaskInfo
    }
    
    func expireDate(progress:Int, sinceDate:NSDate) -> NSDate {
        let currentDelay = delayArray[progress]
        let date = NSDate.init(timeInterval: currentDelay, since: sinceDate as Date)
        LocalNotificationHandler.createLocalNotifaction(date:date as Date)
        return date
    }
    
    // 获取当前任务
    func currentTasks() -> [TaskInfo]? {
        return fetchTasks(finish: false,createDate: nil)
    }
    
    // 获取所有任务
    func allTasks() -> [TaskInfo]? {
        return fetchTasks(finish: nil, createDate: nil)
    }
    
    // 获取任务
    func fetchTasks(finish:Bool?,createDate:NSDate?) ->[TaskInfo]?{
        // 初始化一个查询请求
        let request = NSFetchRequest<NSFetchRequestResult>()
        // 设置要查询的实体
        request.entity = NSEntityDescription.entity(forEntityName: "TaskInfo", in: self.managedContext)
        // 设置排序
        let sort = NSSortDescriptor.init(key: "createDate", ascending: true)
        request.predicate = predicate(finish: finish, createDate: createDate)
        request.sortDescriptors = [sort]
        // 执行请求
        do {
            return try self.managedContext.fetch(request) as? [TaskInfo]
        } catch {
            print(error)
        }
        return nil
    }
    
    func predicate(finish:Bool?,createDate:NSDate?) -> NSPredicate? {
        var pre : NSPredicate? = nil
        if finish == nil && createDate == nil {
            return pre
        }
        if finish == nil && createDate != nil {
            pre = NSPredicate.init(format: "createDate = %@",createDate!)
        }
        if finish != nil && createDate != nil {
            pre = NSPredicate.init(format: "finish = \(finish!) AND createDate = %@",createDate!)
        }
        if finish != nil && createDate == nil {
            pre = NSPredicate.init(format: "finish = \(finish!)")
        }
        return pre
    }
    
    // 根据创建日期删除任务
    func removeTask(createDate:NSDate) {
       
        if let task = self.fetchTasks(finish: nil, createDate: createDate)?.first {
            removeTask(task)
        }
    }
    
    // 删除任务
    func removeTask(_ task:TaskInfo) {
        self.managedContext.delete(task)
        do {
            try self.managedContext.save()
        } catch  {
            print(error)
        }
    }
    
    // 修改任务
    func modifyTaskContent(task:TaskInfo,content:String) {
        task.content = content
        do {
            try self.managedContext.save()
        } catch  {
            print(error)
        }
    }
    
    func updateFinishState(task:TaskInfo, finish:Bool) {
        task.finish = finish
        if finish {
            if task.progress < 6 {
                task.progress += 1
                task.expireDate = expireDate(progress: Int(task.progress), sinceDate: task.createDate! as NSDate) as Date
            }else{
                task.expireDate = NSDate.distantFuture
            }
        }
        do {
            try self.managedContext.save()
        } catch  {
            print(error)
        }
    }
    
    func refreshTask() {
        
        guard let allTasks = self.allTasks() else {
            return
        }
        for task in allTasks {
            // 跟当前时间比较
            guard task.expireDate != nil else {continue}
            if task.expireDate!.timeIntervalSinceNow < 0 {
                updateFinishState(task: task, finish: false)
            }
        }
    }
    
    func finishTask(_ task: TaskInfo) {
        self.updateFinishState(task: task, finish: true)
    }
}
