//
//  FileMonitor.swift
//  
//
//  Created by Joshua Buhler on 8/8/22.
//  Basically stolen from: https://swiftrocks.com/dispatchsource-detecting-changes-in-files-and-folders-in-swift.html
//

import Foundation

protocol FileMonitorDelegate:AnyObject {
    func didReceive(changes:String)
}

final class FileMonitor {
    
    let url:URL
    
    var fileTimer:Timer?

    weak var delegate: FileMonitorDelegate?
    
    let fileHandle:FileHandle
    var fileObserver:NSObjectProtocol?
    
    var lastLength:Int = 0
    
//    let stdOut:Pipe?
//    let process:Process?
//    let token:NSObjectProtocol?
    
    init(url: URL) throws {
        self.url = url
        
        try fileHandle = FileHandle.init(forReadingFrom: url)
        setupFileHandler()
        
//        self.resetTimer()
    }
    
    deinit {
        //source.cancel()
    }
    
    func resetTimer () {
        fileTimer?.invalidate()
        
        if #available(macOS 10.12, *) {
            fileTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) {[weak self] timer in
                print ("timer")
//                self?.processFile()
                self?.fileHandle.readInBackgroundAndNotify()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func setupFileHandler () {
        let nc = NotificationCenter.default
        
        fileObserver = nc.addObserver(forName:FileHandle.readCompletionNotification,
                                      object: nil,
                                      queue: nil,
                                      using: { [weak self] n in
            print("readCompletionNotification")
            guard let userinfo = n.userInfo,
                  let data = userinfo[NSFileHandleNotificationDataItem] as? Data else {
                print("No data available")
                return
            }
            self?.processFile(data: data)
        })
        
        // start reading
        fileHandle.readInBackgroundAndNotify()
        
        resetTimer()
    }
        
    func processFile (data:Data) {
        guard let fileContents = String(data: data, encoding: .utf8) else {
            print ("Failed to load file")
            return
        }
        
        print ("fileLength: \(fileContents.count)")
        lastLength = fileContents.count
        
//        print ("fileContents: \(fileContents)")
        
//        let newStuff = fileContents.suffix(100)
        delegate?.didReceive(changes: fileContents)
    }
    
//    func process(event: DispatchSource.FileSystemEvent) {
//        guard event.contains(.extend) else {
//            return
//        }
//        let newData = self.fileHandle.readDataToEndOfFile()
//        let string = String(data: newData, encoding: .utf8)!
//        self.delegate?.didReceive(changes: string)
//    }
}
