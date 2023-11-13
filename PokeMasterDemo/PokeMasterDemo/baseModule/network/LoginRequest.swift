//
//  LoginRequest.swift
//  PokeMasterDemo
//
//  Created by qilitech.ltd on 2023/11/1.
//

import Foundation
import Combine

// 这儿一般可以提供三个api，一个是普通的block的异步，一个是协程版的异步，一个是publish版的异步，核心操作封装函数，尽量复用---要写成库的话。
struct LoginRequest {
    let email: String
    let password: String
    // 1
    var publisher: AnyPublisher<UserModel, AppError> {
        Future { promise in
            // 2
            DispatchQueue.global()
                .asyncAfter(deadline: .now() + 1.5)
            {
                if self.password == "123456" {
                    let user = UserModel(
                        email: self.email,
                        favoritePokemonIDs: []
                    )
                    promise(.success(user))
                } else {
                    promise(.failure(.passwordWrong))
                }
            }
        }
        // 3
        .receive(on: DispatchQueue.main)
        // 4
        .eraseToAnyPublisher()
    }
}

struct RegisterRequest {
    let email: String
    let password: String
    // 1
    var publisher: AnyPublisher<UserModel, AppError> {
        Future { promise in
            // 2
            DispatchQueue.global()
                .asyncAfter(deadline: .now() + 1.5)
            {
                // 模拟注册成功
                if self.password == "123456" {
                    let user = UserModel(
                        email: self.email,
                        favoritePokemonIDs: []
                    )
                    promise(.success(user))
                } else {
                    let error = MyError(domain: "register", code: 999, userInfo: ["msg": "注册网络错误"])
                    promise(.failure(.networkingFailed(error)))
                }
            }
        }
        // 3
        .receive(on: DispatchQueue.main)
        // 4
        .eraseToAnyPublisher()
    }
}


