//
//  PlayerCacherLogger.swift
//
//
//  Created by https://zhgchg.li on 2022/8/31.
//

import Foundation

public struct PlayerCacherLevel: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let info = PlayerCacherLevel(rawValue: 1)
    public static let error = PlayerCacherLevel(rawValue: 2)
}

public protocol PlayerCacherLogger: AnyObject {
    var loggerLevel: PlayerCacherLevel { get set }

    func info(_ message: String)
    func error(_ message: String)
}

public extension PlayerCacherLogger {

    func info(_ message: String) {
        guard loggerLevel.contains(.info) else { return }

        abstractLog("InfoLog", message: message)
    }

    func error(_ message: String) {
        guard loggerLevel.contains(.error) else { return }

        abstractLog("ErrorLog❌", message: message)
    }

    private func abstractLog(_ logType: String, message: String) {
        print("[📹PlayerCacherLogger][%@]%@", logType, message)
    }
}
