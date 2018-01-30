//
//  LocalNotificationHandler.swift
//  ABHuas
//
//  Created by Apple on 2017/12/26.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit

class LocalNotificationHandler: NSObject {
    
    class func createLocalNotifaction(date:Date) {
        // 创建通知
        let localNotifi = UILocalNotification()
        // 2.设置通知的必选参数
        // 设置通知显示的内容
        localNotifi.alertBody = "你有新的任务"
        // 设置通知的发送时间,单位秒
        localNotifi.fireDate = date
        // 解锁滑动时的事件
        localNotifi.alertAction = "赶紧的"
        // 收到通知时的APP icon的角标
        localNotifi.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        // 推送时带的声音提醒,设置默认的字段为UILocalNotificationDefaultSoundName
        localNotifi.soundName = UILocalNotificationDefaultSoundName
        // 发送通知
        // 方式1 根据通知的发送时间fireDate发送通知
        UIApplication.shared.scheduleLocalNotification(localNotifi)
    }
}

