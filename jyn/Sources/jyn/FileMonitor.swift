//
//  FileMonitor.swift
//  
//
//  Created by Joshua Buhler on 8/8/22.
//

import Foundation

protocol FileMonitorDelegateProtocol:AnyObject {
    func didReceive(changes:String)
}

protocol FileMonitorProtocol {
    var delegate:FileMonitorDelegateProtocol? { get set }
    
    func stopMonitoring()
}

final class FileMonitor:FileMonitorProtocol {
    
    private let url:URL
    
    private var fileTimer:Timer?
    private var monitorInterval:TimeInterval

    weak var delegate: FileMonitorDelegateProtocol?
    
    private let fileHandle:FileHandle
    private var fileObserver:NSObjectProtocol?
        
    init(url: URL, monitorInterval:TimeInterval) throws {
        self.url = url
        self.monitorInterval = monitorInterval
        
        try fileHandle = FileHandle.init(forReadingFrom: url)
        setupFileHandler()
        
        self.resetTimer()
    }
    
    private func resetTimer () {
        stopMonitoring()
        
        if #available(macOS 10.12, *) {
            fileTimer = Timer.scheduledTimer(withTimeInterval: monitorInterval,
                                             repeats: true) {[weak self] timer in
                self?.fileHandle.readInBackgroundAndNotify()
            }
        } else {
            /// Fallback on earlier versions.
            /// No real fallback though - the timer method above works just fine
            /// Linux. It's just macOS complaining about the availability here.
        }
    }
    
    public func stopMonitoring () {
        fileTimer?.invalidate()
    }
    
    private func setupFileHandler () {
        let nc = NotificationCenter.default
        
        fileObserver = nc.addObserver(forName:FileHandle.readCompletionNotification,
                                      object: nil,
                                      queue: nil,
                                      using: { [weak self] n in
            guard let userinfo = n.userInfo,
                  let data = userinfo[NSFileHandleNotificationDataItem] as? Data else {
                print("No data available")
                return
            }
            self?.handleChanges(data: data)
        })
        
        // start reading
        fileHandle.readInBackgroundAndNotify()
    }
    
    ///
    /// Should probably start jyn as a separate process that does one of the following:
    ///     1. Run on a timer, posting findings to vapor routes
    ///     2. Save findings as json to vapor's public folder. This can then be used to generate status page
    
    private func handleChanges (data:Data) {
        guard let newData = String(data: data, encoding: .utf8) else {
            print ("Failed to load file")
            return
        }
        
        guard !newData.isEmpty else {
            return
        }
        
        delegate?.didReceive(changes: newData)
    }
}
