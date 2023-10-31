import Foundation
import UIKit
import Combine

public enum SampleError: Error {
    case sampleError
}

public enum MyError: Error {
    case myError
}

public func check<P: Publisher>(
    _ title: String,
    publisher: () -> P
) -> AnyCancellable
{
    print("----- \(title) -----")
    defer { print("") }
    return publisher()
        .print()
        .sink(
            receiveCompletion: { _ in},
            receiveValue: { _ in }
        )
}

public func delay(_ intravel: Double, exe:@escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + intravel) {
        exe()
    }
}

public func loadPage(
    url: URL,
    handler: @escaping (Data?, URLResponse?, Error?) -> Void)
{
    URLSession.shared.dataTask(with: url) {
        data, response, error in
        handler(data, response, error)
    }.resume()
}

extension Sequence {
    public func scan<ResultElement>(
        _ initial: ResultElement,
        _ nextPartialResult: (ResultElement, Element) -> ResultElement
    ) -> [ResultElement] {
        var result: [ResultElement] = []
        for x in self {
            result.append(nextPartialResult(result.last ?? initial, x))
        }
        return result
    }
}

