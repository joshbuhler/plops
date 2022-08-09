import Foundation

print("May the Force be with us.")

//let logURL = Bundle.main.url(forResource: "log_2019", withExtension: "log")
//let logURL = URL(fileURLWithPath: "./testLogs/log_2019.log")
let logURL = URL(fileURLWithPath: "/Users/josh/Projects/plops/jyn/Sources/jyn/Resources/log_2019.log")
print ("logURL: \(logURL)")
guard let fileMon = try? FileMonitor(url: logURL) else {
    print ("Failed to create FileMonitor")
    exit(-1)
}

RunLoop.current.run()

print ("The Force was with us.")
