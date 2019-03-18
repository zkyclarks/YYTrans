//
//  CXBXunfeiManager.swift
//  easytrans
//
//  Created by keyu zhang on 2019/3/12.
//  Copyright © 2019 chenxiubing. All rights reserved.
//

import UIKit

class CXBXunfeiManager: NSObject {
    var iFlySpeechSynthesizer:IFlySpeechSynthesizer!
    static let instance = CXBXunfeiManager()
    func xunfeiInit() {
        IFlySpeechUtility.createUtility("appid=5baafc91")
        //获取语音合成单例
        iFlySpeechSynthesizer = IFlySpeechSynthesizer.sharedInstance()
        //设置协议委托对象
        iFlySpeechSynthesizer.delegate = self;
        //设置合成参数
        //设置在线工作方式
        iFlySpeechSynthesizer.setParameter(IFlySpeechConstant.type_CLOUD(), forKey:IFlySpeechConstant.engine_TYPE())
        //设置音量，取值范围 0~100
        iFlySpeechSynthesizer.setParameter("50", forKey: IFlySpeechConstant.volume())
        //发音人，默认为”xiaoyan”，可以设置的参数列表可参考“合成发音人列表”
        iFlySpeechSynthesizer.setParameter(" xiaoyan ", forKey:IFlySpeechConstant.voice_NAME())
        //保存合成文件名，如不再需要，设置为nil或者为空表示取消，默认目录位于library/cache下
        iFlySpeechSynthesizer.setParameter(" tts.pcm", forKey:IFlySpeechConstant.tts_AUDIO_PATH())
    }
    
    func startSpeek(_ text:String) {
        //启动合成会话
        iFlySpeechSynthesizer.startSpeaking(text)
    }
}

extension CXBXunfeiManager: IFlySpeechSynthesizerDelegate {
    func onCompleted(_ error: IFlySpeechError!) {
        
    }
    
//    - (void) onCompleted:(IFlySpeechError *) error {}
//    //合成开始
//    - (void) onSpeakBegin {}
//    //合成缓冲进度
//    - (void) onBufferProgress:(int) progress message:(NSString *)msg {}
//    //合成播放进度
//    - (void) onSpeakProgress:(int) progress beginPos:(int)beginPos endPos:(int)endPos {}
}
