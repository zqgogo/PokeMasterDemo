import Combine

//check("empty") {
//    Empty<Int, SampleError>()
//}
//
//check("just") {
//    Just(1)
//}
//
//check("sequence") {
//    Publishers.Sequence<[Int], Never>(sequence: [1,2,3])
//}
//
//check("array") {
//    [4, 5, 6].publisher.map { $0 * 2 }
//}
//
//check("reduce") {
//    [4, 5, 6].publisher.reduce(0, +)
//}
//
//check("Scan") {
//    [1,2,3,4,5].publisher.scan(0, +)
//}
//
//check("compact") {
//    ["1","2","3","4u","5"].publisher.compactMap { Int($0) }
//}

//check("Flat Map 1") {
//    [[1, 2, 3], ["a", "b", "c"]]
//    //        .publisher.map { $0 }
//        .publisher
//        .flatMap {
//            print("-")
//            return $0.publisher
//        }
//}
//
//check("Flat Map 2") {
//    ["A", "B", "C"]
//        .publisher
//        .flatMap { letter in
//            [1, 2, 3]
//                .publisher
//                .map { "\(letter)\($0)" }
//        }
//}

//check("Remove Duplicates") {
//    ["S", "Sw", "Sw", "Sw", "Swi",
//     "Swif", "Swift", "Swift", "Swif"]
//        .publisher
//        .removeDuplicates()
//}

//check("Fail") {
//    Fail<Int, SampleError>(error: .sampleError).mapError { _ in
//        MyError.myError
//    }
//}

//check("Throw") {
//    ["1", "2", "Swift", "4"].publisher
//        .tryMap { s -> Int in
//            guard let value = Int(s) else {
//                throw MyError.myError
//            }
//            return value
//        }
//}

//check("Replace Error") {
//    ["1", "2", "Swift", "4"].publisher
//        .tryMap { s -> Int in
//            guard let value = Int(s) else {
//                throw MyError.myError
//            }
//            return value
//        }
//        .replaceError(with: -1)
//}

//check("Catch with Just") {
//    ["1", "2", "Swift", "4"].publisher
//        .tryMap { s -> Int in
//            guard let value = Int(s) else {
//                throw MyError.myError
//            }
//            return value
//        }
//        .catch { _ in [-1, -2, -3].publisher }
//}

//check("Catch and Continue") {
//    ["1", "2", "Swift", "4"].publisher.print("original")
//        .flatMap { s in
//            return Just(s)
//                .tryMap { s -> Int in
//                    guard let value = Int(s) else {
//                        throw MyError.myError
//                    }
//                    return value
//                }.print("trymap")
//                .catch { _ in Just(-1).print("just") }
//                .print("catch")
//        }
//}

let s1 = check("Subject") {
    () -> PassthroughSubject<Int, Never> in
    let subject = PassthroughSubject<Int, Never>()
    delay(1) {
        subject.send(1)
    }
//    delay(1) {
//        subject.send(1)
//        delay(1) {
//            subject.send(2)
//            delay(1) {
//                subject.send(completion: .finished)
//            }
//        }
//    }
    return subject
}

