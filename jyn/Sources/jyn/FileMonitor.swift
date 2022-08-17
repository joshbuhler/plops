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
    
    let fileHandle:FileHandle
//    let source:DispatchSourceFileSystemObject
    weak var delegate: FileMonitorDelegate?
    
    let stdOut:Pipe?
    let process:Process?
    let token:NSObjectProtocol?
    
    init(url: URL) throws {
        self.url = url
        self.fileHandle = try FileHandle(forReadingFrom: url)
        
        stdOut = Pipe()
        process = Process()
        process?.launchPath = "/usr/bin/swift"
        process?.standardOutput = stdOut
        process?.launch()

        token = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable,
                                                       object: stdOut?.fileHandleForReading,
                                                       queue: nil) { note in
            let handle = note.object as! FileHandle
            // Read the available data ...
            handle.waitForDataInBackgroundAndNotify()
        }

        stdOut?.fileHandleForReading.waitForDataInBackgroundAndNotify()
    }
    
    deinit {
        //source.cancel()
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
