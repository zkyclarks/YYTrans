//
//  CXBSettingController.swift
//  easytrans
//
//  Created by keyu zhang on 2019/3/2.
//  Copyright © 2019 chenxiubing. All rights reserved.
//

import UIKit

class CXBSettingController: CXBBaseViewController {

    let rowTitles = ["清空历史记录", "语言", "版本号"]
    var table:UITableView!
    override func viewDidLoad() {
        title = locateString("设置")
        super.viewDidLoad()
        setupTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: NSNotification.Name(rawValue: "languageChanged"), object: nil)
    }
    func setupTableView() {
        table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.frame = CGRect(x: 0, y: 80, width: screenW, height: screenH - 160)
        view.addSubview(table)
        table.register(CXBSettingCell.self, forCellReuseIdentifier: "settingCellId")
        table.tableFooterView = UIView()
    }
    @objc func languageChanged() {
        title = locateString("设置")
        table.reloadData()
    }
    func clearCache() {
        let ac = UIAlertController.init(title: locateString("温馨提示"), message: locateString("您确定要清空历史记录吗？"), preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: locateString("确定"), style: UIAlertAction.Style.default) { (action) in
            UserDefaults.standard.removeObject(forKey: "textTranslateResult")
            UserDefaults.standard.removeObject(forKey: "voiceTranslateResult")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "historyCacheCleared"), object: nil)
        }
        let cancelAction = UIAlertAction(title: locateString("取消"), style: UIAlertAction.Style.cancel)
        ac.addAction(okAction)
        ac.addAction(cancelAction)
        present(ac, animated: true, completion: nil)
    }
}

fileprivate let cellHeight = CGFloat(46)
extension CXBSettingController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCellId", for: indexPath) as! CXBSettingCell

        cell.titleView.text = locateString(rowTitles[indexPath.row])
        if indexPath.row == 1 {
            cell.valueView.text = language == 1 ? locateString("中文") : locateString("英文")
        } else if indexPath.row == 2 {
            cell.valueView.text = "v1.0 build 3.0"
        } else {
            cell.valueView.text = nil
        }
        cell.showArrow = indexPath.row != 2
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            clearCache()
        } else if indexPath.row == 1 {
            language = language == 1 ? 2 : 1
            tableView.reloadData()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "languageChanged"), object: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}


class CXBSettingCell: UITableViewCell {
    lazy var titleView = { () -> UILabel in
        let v = UILabel()
        v.textColor = UIColor.black
        v.font = UIFont.systemFont(ofSize: 15)
        addSubview(v)
        return v
    }()
    lazy var valueView = { () -> UILabel in
        let v = UILabel()
        v.textColor = UIColor.gray
        v.font = UIFont.systemFont(ofSize: 14)
        v.textAlignment = NSTextAlignment.right
        addSubview(v)
        return v
    }()
    lazy var arrowView = { () -> UIImageView in
        let v = UIImageView()
        v.image = UIImage(named: "arrowIcon")
        addSubview(v)
        v.contentMode = ContentMode.scaleAspectFit
        return v
    }()
    var showArrow = false
    override func layoutSubviews() {
        super.layoutSubviews()
        titleView.frame = CGRect(x: 15, y: 0, width: 200, height: cellHeight)
        var x = screenW - 115
        if showArrow {
            x -= 20
            arrowView.frame = CGRect(x: screenW - 30, y: 13, width: 15, height: 20)
        }
        valueView.frame = CGRect(x: x, y: 0, width: 100, height: cellHeight)
        arrowView.isHidden = !showArrow
    }
}
