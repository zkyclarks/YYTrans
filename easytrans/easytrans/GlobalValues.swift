//
//  GlobalValues.swift
//  easytrans
//
//  Created by keyu zhang on 2019/3/3.
//  Copyright © 2019 chenxiubing. All rights reserved.
//


let screenW = UIScreen.main.bounds.width
let screenH = UIScreen.main.bounds.height
let statusBarHeight = UIApplication.shared.statusBarFrame.height
let topBarHeight = statusBarHeight + 44
let tabBarHeight = (CGFloat)(isIphoneX() ? (49.0 + 34.0) : (49.0))

var language = getLanguage() // 1：中文， 2：英文
var textTransType = 0//0:english>chinese, 1:chinese>english
var voiceTransType = 0

func isIphoneX() -> Bool {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }

    switch identifier {
        case "iPhone10,3", "iPhone10,6":                 return true
        case "iPhone11,2":                               return true
        case "iPhone11,4", "iPhone11,6":                 return true
        case "iPhone11,8":                               return true
        default:                                         return false
    }
}

func getCurrentLanguage() -> String {
    let preferredLang = NSLocale.preferredLanguages.first! as NSString
    switch String(describing: preferredLang) {
    case "en-US", "en-CN":
        return "en"//英文
    case "zh-Hans-US","zh-Hans-CN","zh-Hant-CN","zh-TW","zh-HK","zh-Hans":
        return "cn"//中文
    default:
        return "en"
    }
}

func getLanguage() -> Int {
    let lan = UserDefaults.standard.integer(forKey: "currentLanguage")
    if lan == 0 {
        let lanStr = getCurrentLanguage()
        if lanStr == "cn" {
            return 1
        } else {
            return 2
        }
    }
    return lan
}

func locateString(_ string:String) -> String {
    if language == 1 {
        return string
    }
    let lan = ["语音翻译" : "Speech translation", "文字翻译" : "Text translation", "设置" : "Setting", "清空历史记录" : "Clear up historical records", "语言" : "Language", "版本号" : "Version", "中文" : "Chinese", "英文" : "English", "点此开始录音" : "Start Record", "正在录音，请讲话，点中间开始翻译" : "recording,Click on the middle to start translating", "请在下面输入需要翻译的文本" : "Please enter the text to be translated below.", "翻译" : "translate", "中文>英文" : "CHS>EN", "英文>中文" : "EN>CHS", "正在翻译，请稍候。":"Translating...", "请输入文本":"Please enter text", "温馨提示":"Reminder", "您确定要清空历史记录吗？":"Are you sure you want to clear the history?", "确定":"Yes", "取消":"No"][string]
    guard let res = lan else {
        return ""
    }
    return res
}

func getHeightWithString(_ str:String, width:CGFloat, fontSize:CGFloat) -> CGFloat {
    let options:NSStringDrawingOptions = .usesLineFragmentOrigin
    let boundingRect = str.boundingRect(with: CGSize(width: width, height: 0), options: options, attributes:[NSAttributedString.Key.font:UIFont.systemFont(ofSize: fontSize)], context: nil)
    return boundingRect.height
}

func decode64(string: String) -> String {
    guard let data = NSData(base64Encoded:string, options:NSData.Base64DecodingOptions(rawValue: 0)) else { return "{}" }
    guard let sfDecode = NSString(data:data as Data, encoding:String.Encoding.utf8.rawValue) else { return "{}" }
    let su = sfDecode as String
    return su
}

import Foundation
// 导入CommonCrypto
import CommonCrypto

// 直接给String扩展方法
extension String {
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        free(result)
        return String(format: hash as String)
    }
}
