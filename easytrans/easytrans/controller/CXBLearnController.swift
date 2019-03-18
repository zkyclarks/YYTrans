//
//  CXBLearnController.swift
//  easytrans
//
//  Created by keyu zhang on 2019/3/11.
//  Copyright © 2019 chenxiubing. All rights reserved.
//

import UIKit

class CXBLearnController: CXBBaseViewController {
    
    var web = UIWebView()
    var urlStr:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL(string: urlStr)
        let req = NSURLRequest(url: url! as URL)
        web.loadRequest(req as URLRequest)
        var bh:CGFloat = 0
        if isIphoneX() { bh = 34 }
        web.frame = CGRect(x: 0, y: statusBarHeight, width: screenW, height: screenH - statusBarHeight - bh)
        view.addSubview(web)
    }
}
