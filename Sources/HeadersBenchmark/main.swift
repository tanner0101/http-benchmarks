import Benchmarks

public func addTestHeaders<T: Fooable>(foo: inout T) {
    foo.add("Host", "localhost:8080")
    foo.add("User-Agent", "curl/7.54.0")
    foo.add("Accept", "*/*")
    foo.add("Cookie", "foo=bar")
    foo.add("Cookie", "buz=cux")
}


public protocol Fooable {
    init()
    mutating func add(_ key: String, _ value: String)
    func get(_ key: String) -> String?
    func cookies() -> [String]
}

public struct FooElement: Fooable {
    var s: [String: String]
    var _cookies: [String]

    public init() {
        self.s = [:]
        self._cookies = []
    }

    public mutating func add(_ key: String, _ value: String) {
        if key.lowercased() == "cookie" {
            self._cookies.append(value)
        } else {
            if self.s[key.lowercased()] == nil {
                self.s[key.lowercased()] = value
            }
        }
    }

    public func get(_ key: String) -> String? {
        return self.s[key.lowercased()]
    }

    public func cookies() -> [String] {
        return self._cookies
    }

    public var count: Int {
        return self.s.count + self._cookies.count
    }
}

public struct FooTuple: Fooable {
    var s: [(key: String, val: String)]

    public init() {
        self.s = []
    }

    public mutating func add(_ key: String, _ value: String) {
        s.append((key, value))
    }

    public func get(_ key: String) -> String? {
        for (k, val) in s {
            if k == key {
                return val
            }
        }

        return nil
    }

    public func cookies() -> [String] {
        return s.flatMap { tuple in
            if tuple.key.lowercased() == "cookie" {
                return tuple.val
            } else {
                return nil
            }
        }
    }

    public var count: Int {
        return s.count
    }
}

public struct FooList: Fooable {
    var s: [String: [String]]

    public init() {
        self.s = [:]
    }

    public mutating func add(_ key: String, _ value: String) {
        let k = key.lowercased()
        if self.s[k] == nil {
            self.s[k] = [value]
        } else {
            self.s[k]!.append(value)
        }
    }

    public func get(_ key: String) -> String? {
        return self.s[key.lowercased()]?.first
    }

    public func cookies() -> [String] {
        return self.s["cookie"] ?? []
    }

    public var count: Int {
        return self.s.count
    }
}

func calculateRandomChecksum<T: Fooable>(foo: T) -> Int {
    var randomChecksum = 0
    for _ in foo.cookies() {
        randomChecksum += 1
    }
    for x in ["Host", "User-Agent", "Accept"] {
        randomChecksum += foo.get(x).map { _ in 1 } ?? 0
    }
    return randomChecksum
}

var randomChecksum = 0
let iterations = 1_000_000

let benchmark = Benchmark(name: "HTTP Headers")

// Single Element
do {
    try benchmark.start(name: "Single Element List")
    for _ in 0..<iterations {
        var foo = FooList()
        addTestHeaders(foo: &foo)
        randomChecksum += calculateRandomChecksum(foo: foo)
    }
    try benchmark.end()
}

// No List
do {
    try benchmark.start(name: "No List")
    for _ in 0..<iterations {
        var foo = FooElement()
        addTestHeaders(foo: &foo)
        randomChecksum += calculateRandomChecksum(foo: foo)
    }
    try benchmark.end()
}

// Tuple
do {
    try benchmark.start(name: "Tuple")
    for _ in 0..<iterations {
        var foo = FooTuple()
        addTestHeaders(foo: &foo)
        randomChecksum += calculateRandomChecksum(foo: foo)
    }
    try benchmark.end()
}

try benchmark.printResults()
