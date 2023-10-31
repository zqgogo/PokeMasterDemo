import Combine
import Foundation

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

//let s1 = check("Subject") {
//    () -> PassthroughSubject<Int, Never> in
//    let subject = PassthroughSubject<Int, Never>()
//    delay(1) {
//        subject.send(1)
//        delay(1) {
//            subject.send(2)
//            delay(1) {
//                subject.send(completion: .finished)
//            }
//        }
//    }
//    return subject
//}

//let subject_example1 = PassthroughSubject<Int, Never>()
//let subject_example2 = PassthroughSubject<Int, Never>()
//check("Subject Order") {
//    subject_example1.merge(with: subject_example2)
//}
//subject_example1.send(20)
//subject_example2.send(1)
//subject_example1.send(40)
//subject_example1.send(60)
//subject_example2.send(1)
//subject_example1.send(80)
//subject_example1.send(100)
//subject_example1.send(completion: .finished)
//subject_example2.send(completion: .finished)


//let subject1 = PassthroughSubject<Int, Never>()
//let subject2 = PassthroughSubject<String, Never>()
//check("Zip") {
//    subject1.zip(subject2)
//}
//subject1.send(1)
//subject2.send("A")
//subject1.send(2)
//subject2.send("B")
//subject2.send("C")
//subject2.send("D")
//subject1.send(3)
//subject1.send(4)
//subject1.send(5)
////subject1.send(completion: .finished)
//subject2.send(completion: .finished)

//let subject3 = PassthroughSubject<String, Never>()
//let subject4 = PassthroughSubject<String, Never>()
//check("Combine Latest") {
//    subject3.combineLatest(subject4)
//}
//subject3.send("1")
//subject4.send("A")
//subject3.send("2")
//subject4.send("B")
//subject4.send("C")
//subject4.send("D")
//subject3.send("3")
//subject3.send("4")
//subject3.send("5")

//let future = check("Future") {
//    Future<(Data, URLResponse), Error> { promise in
//        loadPage(url: URL(string: "https://example.com")!) {
//            data, response, error in
//            if let data = data, let response = response {
//                promise(.success((data, response)))
//            } else {
//                promise(.failure(error!))
//            }
//        }
//    }
//}

//let subject = PassthroughSubject<Date, Never>()
//Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
//    subject.send(Date())
//}
//let timer = check("Timer") {
//    subject.map { "---\($0)" }
//}

// -------
struct Response: Decodable {
    struct Args: Decodable {
        let foo: String
    }
    let args: Args?
    let headers: Dictionary<String, String>?
    let url: String?
}
//
//let subscription = check("URL Session") {
//    URLSession.shared
//        .dataTaskPublisher(
//            for: URL(string: "https://httpbin.org/get?foo=bar")!)
//        .mapError { error in
//            MyError.myError
//        }
//        .map { data, _ in data }
//        .decode(type: Response.self, decoder: JSONDecoder())
//        .compactMap { $0.args?.foo }
//}

// ----
//let timerPublish = Timer.publish(every: 1, on: .main, in: .default)
//let a = check("Timer Connected") {
//    timerPublish
//}
//timerPublish.connect()

// -----
//class Wrapper {
//    @Published var text: String = "hoho"
//}
//var wrapper = Wrapper()
//check("Published") {
//    wrapper.$text
//}
//wrapper.text = "123"
//wrapper.text = "abc"

// -------
//class Clock {
//    var timeString: String = "--:--:--" {
//        didSet { print("\(timeString)") }
//    }
//}
//
//let clock = Clock()
//let formatter = DateFormatter()
//formatter.timeStyle = .medium
//let timer = Timer.publish(every: 1, on: .main, in: .default)
//var token = timer
//    .map { formatter.string(from: $0) }
//    .assign(to: \.timeString, on: clock)
//timer.connect()

// -----
//class LoadingUI {
//    var isSuccess: Bool = false {
//        didSet { print("\(isSuccess)") }
//    }
//    var text: String = "" {
//        didSet { print("\(text)") }
//    }
//}
//
//let dataTaskPublisher = URLSession.shared
//    .dataTaskPublisher(
//        for: URL(string: "https://httpbin.org/get?foo=bar")!).print().share()
//
//let isSuccess = dataTaskPublisher
//    .map { data, response -> Bool in
//        guard let httpRes = response as? HTTPURLResponse else {
//            return false
//        }
//        return httpRes.statusCode == 200
//    }
//    .replaceError(with: false)
//let latestText = dataTaskPublisher
//    .map { data, _ in data }
//    .decode(type: Response.self, decoder: JSONDecoder())
//    .compactMap { $0.args?.foo }
//    .replaceError(with: "")
//
//let ui = LoadingUI()
//var token1 = isSuccess.assign(to: \.isSuccess, on: ui)
//var token2 = latestText.assign(to: \.text, on: ui)

// -------
let searchText = PassthroughSubject<String, Never>()
let a = check("Debounce") {
    searchText
//        .scan("") { result, curr in
//        if result.isEmpty {
//            return curr
//        }
//        return result + " " + curr
//    }
    .throttle(for: 10, scheduler: RunLoop.main, latest: true)
//        .debounce(for: .seconds(1), scheduler: RunLoop.main)
}
delay(0) { searchText.send("S") }
delay(0.1) { searchText.send("Sw") }
delay(0.2) { searchText.send("Swi") }
delay(1.3) { searchText.send("Swif") }
delay(1.4) { searchText.send("Swift") }
