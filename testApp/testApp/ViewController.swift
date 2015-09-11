//
//  ViewController.swift
//  testApp
//
//  Created by ShunEndo on 2015/09/10.
//  Copyright (c) 2015年 Cloud9. All rights reserved.
//



import UIKit
import SpriteKit
import AVFoundation

class ViewController: UIViewController, NSURLSessionDownloadDelegate {
    
    // Download
    @IBOutlet weak var progressView: UIProgressView!
    // Play Sound
    @IBOutlet weak var playBtn: UIButton!
    
    var fileName: String!
    var myAudioPlayer : AVAudioPlayer!
    var downloadPath : NSString?
    var itemArray : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ボタン生成
        let downloadButton = UIButton()
        downloadButton.setTitle("Download", forState: .Normal)
        downloadButton.setTitleColor(UIColor.whiteColor(), forState:.Normal)
        downloadButton.frame = CGRectMake(0, 0, 100, 50)
        downloadButton.layer.position = CGPoint(x: self.view.frame.width/2, y:100)
        downloadButton.backgroundColor = UIColor(red: 0.7, green: 0.2, blue: 0.7, alpha: 1.0)
        downloadButton.setTitle("Download", forState: .Highlighted)
        downloadButton.setTitleColor(UIColor(red: 0.5, green: 0.1, blue: 0.5, alpha: 0.7), forState: .Highlighted)
        downloadButton.addTarget(self, action: Selector("downloadWithFile"), forControlEvents: .TouchUpInside)
        self.view.addSubview(downloadButton)
        
        
        
        
        //-------UIObject設置--------//
        //ボタンの生成(Play)
        playBtn.backgroundColor = UIColor.cyanColor()
        playBtn.setTitle("▶︎", forState: UIControlState.Normal)
        playBtn.layer.masksToBounds = true
        playBtn.layer.cornerRadius = 50.0
        playBtn.titleLabel!.font = UIFont(name: "▶︎", size: 80.0)
        //myAudioPlayer.volume = DEFAULT_VOLUME / 100
        //myAudioPlayer.currentTime = 0.0
        
    }
    
    @IBAction func tappedStartSession(sender: AnyObject) {
        self.downloadWithFile()
    }
    
    func downloadWithFile() {
        var accessUrl: String = "http://54.68.143.213/cgi-bin/getLocation.cgi?lang=Lan001" // アクセス先のURL
        // ファイル名を取り出す
        var pos = (accessUrl as NSString).rangeOfString("/", options:NSStringCompareOptions.BackwardsSearch).location
        fileName = accessUrl.substringFromIndex(advance(accessUrl.startIndex, pos+1))
        println(fileName)
        
        // NSURLSessionの準備
        let url = NSURL(string: accessUrl)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config,
            delegate: self,
            delegateQueue: NSOperationQueue.mainQueue())
        
        let task = session.downloadTaskWithURL(url!)
        
        task.resume()
    }
    
    // 通信の最初に呼ばれる
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        println("start")
    }
    
    // 通信中に呼ばれる（プログレスバーの更新）
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        //progressView.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        //println(progressView.progress)
        //println("write:\(bytesWritten) / \(totalBytesWritten) -> \(totalBytesExpectedToWrite)")
    }
    
    // 通信終了時に呼ばれる
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        //progressView.progress = 1.0
        
        var fileData = NSData(contentsOfURL: location)
        
        if fileData?.length == 0 {
            NSLog("Error")
        } else {
            NSLog("Success")
            
            // ドキュメントのパス
            //let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            // ライブラリのパス
            let libraryPath = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as! String
            
            let languagePath = libraryPath + "/LanguageFiles"
            downloadPath = NSString(UTF8String: languagePath)
            
            // ディレクトリの生成
            if (NSFileManager.defaultManager().fileExistsAtPath(languagePath)) {
                println("fileExists")
            } else {
                NSFileManager.defaultManager().createDirectoryAtPath(languagePath, withIntermediateDirectories: true, attributes: nil, error: nil)
                addSkipBackupAttributeToItemAtURL(NSURL(string: languagePath)!)
                println("fineNotExists")
            }
            
            fileData?.writeToFile("\(languagePath)/\(fileName)", atomically: false) // ファイル書き込み
            
            print("location: ")
            println(location)
            print("Path: ")
            println(languagePath)
            
            // Preferenceに保存するテスト
            let userDefaults = NSUserDefaults.standardUserDefaults()
            //userDefaults.setObject(fileData, forKey: "LanguageList")
            //userDefaults.synchronize()
            // Preferenceからの読み出し
            var nsData: NSData = userDefaults.dataForKey("LanguageList")!
            var str = NSString(data: nsData, encoding:NSUTF8StringEncoding) as! String
            //println(str)
            
            var lineIndex = 0;
            str.enumerateLines { line, stop in
                
                // ここに1行ずつ行いたい処理を書く
                //println("\(lineIndex) : \(line)")
                self.itemArray = split(line, allowEmptySlices: true, isSeparator: {$0==","})
                println(self.itemArray[0])
                
                //ここでAVAudioPlayerを逐次作成する
                
                lineIndex += 1
            }

            
            
            
            
            
        }
        
        session.invalidateAndCancel()
        println("finish")
        
        myAudioPlayer = makeAudioPlayer(downloadPath!)
    }
    
    // do not backup attribute 付与
    func addSkipBackupAttributeToItemAtURL(URL:NSURL) ->Bool{
        
        let fileManager = NSFileManager.defaultManager()
        assert(fileManager.fileExistsAtPath(URL.path!))
        
        var error:NSError?
        let success:Bool = URL.setResourceValue(NSNumber(bool: true),forKey: NSURLIsExcludedFromBackupKey, error: &error)
        
        if !success{
            println("Error excluding \(URL.lastPathComponent) from backup \(error)")
        }
        
        println(success)
        return success;
    }
    
    
    
    /*
     *  Play Sound Function
     *
     */
    
    // AVAudioPlayer作成
    func makeAudioPlayer(soundDir: NSString) -> AVAudioPlayer {
        
        var soundName = (soundDir as String) + "/test.mp3"
        let path : NSURL = NSURL.fileURLWithPath(soundName as String)!
        println(path)
        //let path = NSBundle.mainBundle().pathForResource(soundName, ofType: "")!
        //let url = NSURL.fileURLWithPath(soundName as String)
        
        //AudioPlayer 作成
        return AVAudioPlayer(contentsOfURL: path, error: nil)
    }
    
    
    
    
    
    
    
    @IBAction func onClickPlayBtn(sender: AnyObject) {
        if myAudioPlayer.playing == true {
            //myAudioPlayerを一時停止.
            myAudioPlayer.pause()
            sender.setTitle("▶︎", forState: .Normal)
        } else {
            //myAudioPlayerの再生.
            myAudioPlayer.play()
            sender.setTitle("■", forState: .Normal)
        }
    }
    
    
    
    
}