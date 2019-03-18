//
//  CXBRecordManager.swift
//  easytrans
//
//  Created by keyu zhang on 2019/3/5.
//  Copyright © 2019 chenxiubing. All rights reserved.
//

import UIKit
import SwiftyJSON

class CXBRecordManager : NSObject {
    static let instance = CXBRecordManager()
    fileprivate var recView:IFlyRecognizerView? = nil
    
    var resultString:String = ""
    func getRecordView(center: CGPoint) -> IFlyRecognizerView {
        if recView == nil {
            recView = IFlyRecognizerView.init(center: center)
            recView?.setParameter("", forKey: IFlySpeechConstant.params())
            recView?.setParameter("iat", forKey: IFlySpeechConstant.ifly_DOMAIN())
//            recView?.setParameter("iat.pcm", forKey: IFlySpeechConstant.asr_AUDIO_PATH())
//            recView?.setParameter("30000", forKey: IFlySpeechConstant.speech_TIMEOUT())
//            recView?.setParameter("3000", forKey: IFlySpeechConstant.vad_BOS())
//            recView?.setParameter("3000", forKey: IFlySpeechConstant.vad_EOS())
//            recView?.setParameter("20000", forKey: IFlySpeechConstant.net_TIMEOUT())
//            recView?.setParameter("16000", forKey: IFlySpeechConstant.sample_RATE())
//            recView?.setParameter("1", forKey: IFlySpeechConstant.asr_PTT())
            
            recView?.delegate = self
        }
        return recView!
    }
    func startRecord() {
        resultString = ""
        let lan = voiceTransType == 0 ? IFlySpeechConstant.language_ENGLISH() : IFlySpeechConstant.language_CHINESE()
        recView?.setParameter(lan , forKey: IFlySpeechConstant.language())
        if lan == IFlySpeechConstant.language_CHINESE() {
            recView?.setParameter(IFlySpeechConstant.accent_MANDARIN() , forKey: IFlySpeechConstant.accent())
        }
        recView?.start()
    }
    func stopRecord() {
        recView?.cancel()
    }
}

extension CXBRecordManager : IFlyRecognizerViewDelegate {
    func onResult(_ resultArray: [Any]!, isLast: Bool) {
        print("-------------\(String(describing: resultArray))")
        if resultArray == nil { return }
        for res in resultArray {
            let dic = res as! Dictionary<String,Any>
            guard let string = dic.keys.first else {return}
            print(string)
            if let dataFromString = string.data(using: .utf8, allowLossyConversion: false) {
                if let json = try? JSON(data: dataFromString) {
                    let wss = json["ws"].arrayValue
                    for ws in wss {
                        let cws = ws["cw"].arrayValue
                        for cw in cws {
                            let w = cw["w"].stringValue
                            if w.isEmpty == false {
                                resultString.append(w)
                            }
                        }
                    }
                }
            }
        }
    }
    func onCompleted(_ error: IFlySpeechError!) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "recordComplete"), object: nil)
    }
}
