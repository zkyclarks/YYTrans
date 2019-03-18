//
//  CXBLearnController.swift
//  easytrans
//
//  Created by keyu zhang on 2019/3/2.
//  Copyright © 2019 chenxiubing. All rights reserved.
//

import UIKit
import SVProgressHUD

class CXBTextTransController: CXBBaseViewController {
    var itlbl:UILabel!
    var input:UITextView!
    var table:UITableView!
    var datas:Array<String> = [String]()
    override func viewDidLoad() {
        title = locateString("文字翻译")
        super.viewDidLoad()
        
        setupNavItem()
        
        
        
        datas = CXBTranslateManager.getTextResult()
        setupInputView()
        setupTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: NSNotification.Name(rawValue: "languageChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(historyCacheCleared), name: NSNotification.Name(rawValue: "historyCacheCleared"), object: nil)
    }
    
    func setupLeftItem() {
        var tt = locateString("英文>中文")
        if textTransType == 1 {
            tt = locateString("中文>英文")
        }
        let leftItm = UIBarButtonItem(title: tt, style: UIBarButtonItem.Style.plain, target: self, action: #selector(changeTransType))
        navigationItem.leftBarButtonItem = leftItm
    }
    
    func setupNavItem() {
        let rightItm = UIBarButtonItem(title: locateString("翻译"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(startTranselate))
        navigationItem.rightBarButtonItem = rightItm
        setupLeftItem()
    }
    
    @objc func changeTransType() {
        textTransType = textTransType == 0 ? 1 : 0
        setupLeftItem()
    }
    
    func setupInputView() {
        itlbl = UILabel()
        itlbl.textColor = UIColor.lightGray
        itlbl.text = locateString("请在下面输入需要翻译的文本")
        itlbl.font = UIFont.systemFont(ofSize: 10)
        itlbl.frame = CGRect(x: 5, y: topBarHeight, width: screenW - 10, height: 24)
        view.addSubview(itlbl)
        input = UITextView()
        input.frame = CGRect(x: 5, y: itlbl.frame.maxY, width: screenW - 10, height: 100)
        input.layer.cornerRadius = 2
        input.layer.masksToBounds = true
        input.layer.borderColor = UIColor.gray.cgColor
        input.layer.borderWidth = 0.5
        view.addSubview(input)
        input.returnKeyType = UIReturnKeyType.done
        input.delegate = self
    }
    
    func setupTableView() {
        table = UITableView()
        table.frame = CGRect(x: 0, y: input.frame.maxY + 2, width: screenW, height: screenH - tabBarHeight - input.frame.maxY - 2)
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        table.register(CXBTextTransCell.self, forCellReuseIdentifier: "textTransCellId")
        view.addSubview(table)
    }
    
    @objc func startTranselate() {
        if input.text.isEmpty  {
            SVProgressHUD.setMaximumDismissTimeInterval(2)
            SVProgressHUD.showInfo(withStatus: locateString("请输入文本"))
            return
        }
        guard let text = input.text else { return }
        CXBTranslateManager.trancelate(type:textTransType, string: text) { [unowned self] (src, dst) in
            CXBTranslateManager.saveTextResult(src: src, dst: dst)
            self.datas = CXBTranslateManager.getTextResult()
            self.table.reloadData()
            self.input.text = nil
        }
    }
    
    @objc func languageChanged() {
        title = locateString("文字翻译")
        itlbl.text = locateString("请在下面输入需要翻译的文本")
        let rightItm = UIBarButtonItem(title: locateString("翻译"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(startTranselate))
        navigationItem.rightBarButtonItem = rightItm
        setupLeftItem()
    }
    
    @objc func historyCacheCleared() {
        datas = CXBTranslateManager.getTextResult()
        table.reloadData()
    }
}


extension CXBTextTransController:UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            startTranselate()
            return false
        }
        return true
    }
}

extension CXBTextTransController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "textTransCellId", for: indexPath) as! CXBTextTransCell
        let transStr = datas[indexPath.row]
        let strs = transStr.split(separator: "+")
        if strs.count < 2 {
            return CXBTextTransCell()
        }
        cell.sourceString = String(strs[0])
        cell.destString = String(strs[1])

        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let transStr = datas[indexPath.row]
        let strs = transStr.split(separator: "+")
        if strs.count < 2 {
            return 0
        }
        let src = String(strs[0])
        let dst = String(strs[1])
        let height = 25 + getHeightWithString(src, width: screenW - 30, fontSize: 13) + getHeightWithString(dst, width: screenW - 30, fontSize: 15)
        return height
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class CXBTextTransCell: UITableViewCell {

    lazy var sourceLabel = { () -> UILabel in
        let v = UILabel()
        v.textColor = UIColor.gray
        v.font = UIFont.systemFont(ofSize: 13)
        v.numberOfLines = 0
        v.lineBreakMode = NSLineBreakMode.byWordWrapping
        addSubview(v)
        return v
    }()
    lazy var destLabel = { () -> UILabel in
        let v = UILabel()
        v.textColor = UIColor.black
        v.font = UIFont.systemFont(ofSize: 15)
        v.numberOfLines = 0
        v.lineBreakMode = NSLineBreakMode.byWordWrapping
        addSubview(v)
        return v
    }()
    var sourceString:String? = nil
    var destString:String? = nil
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let ss = sourceString else { return }
        let sw = screenW - 30
        let sh = getHeightWithString(ss, width: sw, fontSize: 13)
        sourceLabel.frame = CGRect(x:15, y:10, width:sw, height:sh)
        guard let ds = destString else { return }
        let dw = screenW - 30
        let dh = getHeightWithString(ds, width: dw, fontSize: 15)
        destLabel.frame = CGRect(x:15, y:10 + sh + 5, width:dw, height:dh)
        sourceLabel.text = sourceString
        destLabel.text = destString
    }
}
