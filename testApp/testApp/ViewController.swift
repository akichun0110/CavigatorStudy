//
//  ViewController.swift
//  testApp
//
//  Created by ShunEndo on 2015/09/10.
//  Copyright (c) 2015年 Cloud9. All rights reserved.
//



import UIKit

class ViewController: UIViewController, NSURLSessionDownloadDelegate {
    
    @IBOutlet weak var progressView: UIProgressView!
    
    var fileName: String!
    
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
        
    }
    
    @IBAction func tappedStartSession(sender: AnyObject) {
        self.downloadWithFile()
    }
    
    func downloadWithFile() {
        var accessUrl: String = "http://54.68.143.213/CaviNet/Lan001/Voice/Loc031.ogg" // アクセス先のURL
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
            
            // ディレクトリの生成
            if (NSFileManager.defaultManager().fileExistsAtPath(languagePath)) {
                println("fileExists")
            } else {
                NSFileManager.defaultManager().createDirectoryAtPath(languagePath, withIntermediateDirectories: true, attributes: nil, error: nil)
                addSkipBackupAttributeToItemAtURL(NSURL(string: languagePath)!)
                println("fineNotExists")
            }
            
            fileData?.writeToFile("\(languagePath)/\(fileName)", atomically: false) // ファイル書き込み
            
            println(location)
        }
        
        session.invalidateAndCancel()
        println("finish")
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
}