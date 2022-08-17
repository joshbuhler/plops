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
    
    var lastLength:Int = 0
    
//    let stdOut:Pipe?
//    let process:Process?
//    let token:NSObjectProtocol?
    
    init(url: URL) throws {
        self.url = url
        
        self.resetTimer()
    }
    
    deinit {
        //source.cancel()
    }
    
    func resetTimer () {
        fileTimer?.invalidate()
        
        if #available(macOS 10.12, *) {
            fileTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) {[weak self] timer in
                print ("timer")
                self?.processFile()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func processFile () {
        guard let fileContents = try? String.init(contentsOfFile: url.path) else {
            print ("Failed to load file")
            return
        }
        
        print ("fileLength: \(fileContents.count)")
        lastLength = fileContents.count
        
//        let newStuff = fileContents.suffix(100)
//        delegate?.didReceive(changes: newStuff)
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
