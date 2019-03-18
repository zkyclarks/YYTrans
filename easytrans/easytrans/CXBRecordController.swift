//
//  CXBRecordController.swift
//  easytrans
//
//  Created by keyu zhang on 2019/3/3.
//  Copyright © 2019 chenxiubing. All rights reserved.
//

import UIKit


class CXBXunfeiManager {

    let xunfeiAppid = "5baafc91"
    func xunfeiInit() {
        let initString = "appid=\(xunfeiAppid)"
        IFlySpeechUtility.createUtility(initString)
    }
    func record() {
        
    }
}
