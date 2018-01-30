//
//  HomeTableViewController.swift
//  ABHuas
//
//  Created by Apple on 2017/12/19.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit
import MJRefresh
import PKHUD

class HomeTableViewController: UITableViewController {
    
    enum DataFilter {
        case current
        case all
        case finished
    }
    
    @IBOutlet weak var syncBarButtonItem: UIBarButtonItem!
    private var dataSource:[TaskInfo]?
    private var selectedIndexPath:IndexPath?
    private var filter = DataFilter.current
    private var requst = HttpRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "今日任务"
        addRefresh()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: nil) { (noti) in
            self.refreshData()
        }
        loadRemoteInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    @IBAction func clickSyncBarButtonItem(_ sender: UIBarButtonItem) {
        postRemoteInfo()
    }
    // 同步远程数据
    private func loadRemoteInfo(){
        requst.loadTaskInfo() { (infos) in
            guard infos != nil else {return}
            for dic in infos!{
                let timeInterval:Double = dic["createDate"] as! Double
                let createDate = NSDate.init(timeIntervalSince1970: timeInterval)
                if let taskArray = DataHandler.sharedHandler.fetchTasks(finish: nil, createDate: createDate) {
                    if taskArray.count > 0 {continue}
                }
                let content = dic["content"] as! String
                let finish:Bool = dic["finish"] as! Bool
                let progress:Int = dic["progress"] as! Int
                let _ = DataHandler.sharedHandler.insertTask(createDate: createDate, content: content, progress: progress, finish: finish)
            }
           self.refreshData()
        }
    }
    
    // 同步数据到远程
    private func postRemoteInfo(){
        requst.uploadTaskInfos(parameters: dataSource!) { (error) in
            HUD.flash(.labeledSuccess(title: "同步成功", subtitle: nil), delay: 0.3)
        }
    }

    // 添加刷新
    private func addRefresh(){
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.refreshData()
            self?.tableView.mj_header.endRefreshing()
        })
    }
    
    private func refreshData(){
        DataHandler.sharedHandler.refreshTask()
        dataSource = refreshData(filter: filter)
        tableView.reloadData()
    }
    
    private func refreshData(filter:DataFilter) -> [TaskInfo]? {
        switch filter {
        case .all:
            return DataHandler.sharedHandler.allTasks()
        case .current:
            return DataHandler.sharedHandler.currentTasks()
        case .finished:
            return DataHandler.sharedHandler.fetchTasks(finish: true, createDate: nil)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard dataSource != nil else {
            return 0
        }
        return dataSource!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let info:TaskInfo = dataSource?[indexPath.row] {
            let date = info.createDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy-MM-dd HH:mm"
            cell.textLabel?.text = info.content
            cell.detailTextLabel?.text = dateFormatter.string(from: date!)
            cell.textLabel?.textColor = info.finish ? UIColor.black : UIColor.red
        }
        return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let task = dataSource?.remove(at: indexPath.row){
                DataHandler.sharedHandler.removeTask(task)
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedIndexPath = indexPath
        return indexPath
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cell" {
            if let task = dataSource?[selectedIndexPath!.row] {
                let vc:DetailViewController = segue.destination as! DetailViewController
                vc.task = task
            }
        }
    }
    @IBAction func didClickFilterButton(_ sender: UIBarButtonItem) {
        let titles = ["所有任务","今日任务"]
        let filters = [DataFilter.all,DataFilter.current]
        if let i = titles.index(of: title!) {
            self.title = titles[1 - i]
            self.filter = filters[1 - i]
            refreshData()
        }
    }
}
