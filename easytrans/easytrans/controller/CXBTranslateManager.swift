//
//  CXBTranslateManager.swift
//  easytrans
//
//  Created by keyu zhang on 2019/3/7.
//  Copyright © 2019 chenxiubing. All rights reserved.
//

import UIKit
import Alamofire

class CXBTranslateManager: NSObject {
//    class func trancelate(string:String, callBack: @escaping (String, String) -> ()) {
//        let url = "https://fanyi.baidu.com/transapi"
//        let parameters:Dictionary = ["from":"auto", "to":"auto", "query":string]
//        Alamofire.request(url, method: .get, parameters: parameters)
//            .responseJSON { response in
//                if let jsonValue = response.result.value {
//                    let dic = jsonValue as! NSDictionary
//                    let data = ((dic["data"] as! NSArray).firstObject) as! NSDictionary
//                    let src = data["src"] as! String
//                    let dst = data["dst"] as! String
//                    callBack(src, dst)
//                }
//        }
//    }
//
//    class func trancelates(type:Int, string:String, callBack: @escaping (String, String) -> ()) {
//        let url = "https://fanyi.baidu.com/transapi"
//        var from = "en"
//        var to = "zh"
//        if type == 1 {
//            from = "zh"
//            to = "en"
//        }
//        let parameters:Dictionary = ["from":from, "to":to, "query":string]
//        Alamofire.request(url, method: .get, parameters: parameters)
//            .responseJSON { response in
//                if let jsonValue = response.result.value {
//                    let dic = jsonValue as! NSDictionary
//                    let data = ((dic["data"] as! NSArray).firstObject) as! NSDictionary
//                    let src = data["src"] as! String
//                    let dst = data["dst"] as! String
//                    callBack(src, dst)
//                }
//        }
//    }
    
    class func trancelate(type:Int, string:String, callBack: @escaping (String, String) -> ()) {
        //        q    TEXT    Y    请求翻译query    UTF-8编码
        //        from    TEXT    Y    翻译源语言    语言列表(可设置为auto)
        //        to    TEXT    Y    译文语言    语言列表(不可设置为auto)
        //        appid    INT    Y    APP ID    可在管理控制台查看
        //        salt    INT    Y    随机数
        //        sign    TEXT    Y    签名    appid+q+salt+密钥 的MD5值
//        let srcString = string.utf8String()
        let appid = "20190315000277355"
        let bdkey = "7hH4UEYLgKkxWPpkOlP3"
        let salt = arc4random()
        let sign = "\(appid)\(string)\(salt)\(bdkey)".md5().lowercased()
        let url = "http://api.fanyi.baidu.com/api/trans/vip/translate"
        var from = "en"
        var to = "zh"
        if type == 1 {
            from = "zh"
            to = "en"
        }
        let parameters:Dictionary = ["from":from, "to":to, "q":string, "appid":appid, "salt":"\(salt)", "sign":sign]
        Alamofire.request(url, method: .get, parameters: parameters)
            .responseJSON { response in
                if let jsonValue = response.result.value {
                    let dic = jsonValue as! NSDictionary
                    guard let result = dic["trans_result"] else { return }
                    let data = ((result as! NSArray).firstObject) as! NSDictionary
                    let src = data["src"] as! String
                    let dst = data["dst"] as! String
                    callBack(src, dst)
                }
        }
    }
    
    class func saveTextResult(src:String, dst:String) {
        saveResult(src: src, dst: dst, key: "textTranslateResult")
    }
    
    class func getTextResult(from:Int, size:Int) -> ArraySlice<String> {
        return getResult(from: from, size: size, key: "textTranslateResult")
    }
    
    class func saveVoiceResult(src:String, dst:String) {
        saveResult(src: src, dst: dst, key: "voiceTranslateResult")
    }
    
    class func getVoiceResult(from:Int, size:Int) -> ArraySlice<String> {
        return getResult(from: from, size: size, key: "voiceTranslateResult")
    }
    
    class func saveResult(src:String, dst:String, key:String) {
        var result = UserDefaults.standard.stringArray(forKey: key)
        if result == nil {
            result = Array<String>()
        }
        result?.insert("\(src)+\(dst)", at: 0)
        UserDefaults.standard.set(result, forKey: key)
        UserDefaults.standard.synchronize()
    }
    class func getResult(from:Int, size:Int, key:String) -> ArraySlice<String> {
        let array = UserDefaults.standard.stringArray(forKey: key)
        if array == nil { return ArraySlice<String>() }
        guard let results = array else { return ArraySlice<String>() }
        var s = from
        if s < 0 { s = 0 }
        var e = from + size
        if e > results.endIndex { e = results.endIndex }
        let res = results[s..<e]
        return res
    }
    
    class func getTextResult() -> Array<String> {
        guard let array = UserDefaults.standard.stringArray(forKey: "textTranslateResult") else { return Array<String>() }
        return array
        
    }
    class func getVoiceResult() -> Array<String> {
        guard let array = UserDefaults.standard.stringArray(forKey: "voiceTranslateResult") else { return Array<String>() }
        return array
        
    }
}
