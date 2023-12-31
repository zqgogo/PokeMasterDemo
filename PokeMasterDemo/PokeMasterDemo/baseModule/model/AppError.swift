//
//  AppError.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/11/1.
//

import Foundation

// 1
enum AppError: Error, Identifiable {
    // 2
    var id: String { localizedDescription }
    case passwordWrong
    case networkingFailed(Error)
}

class MyError: NSError {
    
    override var localizedDescription: String {
        (userInfo["msg"] as? String) ?? "unknow error"
    }
}

// 3
extension AppError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .passwordWrong: return "密码错误"
        case .networkingFailed(let error):
            return error.localizedDescription
        }
    }
}
