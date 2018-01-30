//
//  ProgressView.swift
//  ABHuas
//
//  Created by Apple on 2017/12/21.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit

let kScreenWidth = UIScreen.main.bounds.size.width
class CustomProgressView: UIView {
    
    private lazy var progressView:UIProgressView = {
        let pro = UIProgressView(frame: CGRect(x: 0, y: 40, width: kScreenWidth, height: 2))
        addSubview(pro)
        return pro
    }()
    private lazy var labels:[UILabel] = {
        let textArray = ["0.5h","12d","1d","2d","4d","7d","15d"]
        var labelArray = [UILabel]()
        for (i ,text) in textArray.enumerated() {
            let label = UILabel()
            label.text = text
            label.textAlignment = NSTextAlignment.center
            addSubview(label)
            let space:CGFloat = 5
            let labelWidth:CGFloat = kScreenWidth / 7 - space * 2
            label.mj_origin = CGPoint(x:space + (labelWidth + space * 2) * CGFloat(i), y: 10)
            label.mj_size = CGSize(width:labelWidth, height: 30)
            labelArray.append(label)
        }
        return labelArray
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var progress = 0 {
        willSet{
            let count = newValue == 6 ? 7 : newValue
            progressView.progress = Float(count) / 7.0
            for (i, label) in labels.enumerated() {
                label.textColor = i < count ? UIColor.blue : i == count ? UIColor.red : UIColor.gray
            }
        }
    }
    
    
}
