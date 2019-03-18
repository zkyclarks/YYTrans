//
//  CXBTabBarController.swift
//  easytrans
//
//  Created by keyu zhang on 2019/3/2.
//  Copyright © 2019 chenxiubing. All rights reserved.
//

import UIKit

class CXBTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupControllers()
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: NSNotification.Name(rawValue: "languageChanged"), object: nil)
    }

    func setupControllers() {
        addChild(CXBNavigationController(rootViewController:CXBTransIndexController()))
        addChild(CXBNavigationController(rootViewController:CXBTextTransController()))
        addChild(CXBNavigationController(rootViewController:CXBSettingController()))
        
        setTabBarItem()
    }
    
    func setTabBarItem() {
        let imgTitles = [("fanyiIcon", locateString("语音翻译")),
                         ("learnIcon", locateString("文字翻译")),
                         ("settingIcon", locateString("设置"))]
        
        var i = 0
        for vc in children {
            let tt = imgTitles[i]
            vc.tabBarItem.image = UIImage(named: tt.0)?.withRenderingMode(.alwaysOriginal)
            vc.tabBarItem.title = tt.1
            i+=1
        }
    }
    
    @objc func languageChanged() {
        setTabBarItem()
    }
}
