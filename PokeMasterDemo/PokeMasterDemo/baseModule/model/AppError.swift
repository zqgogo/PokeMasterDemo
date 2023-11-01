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
}
// 3
extension AppError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .passwordWrong: return "密码错误"
        }
    }
}
