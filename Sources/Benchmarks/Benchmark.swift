import Foundation

public final class Benchmark {
    var name: String
    var tests: [FinishedTest]
    var currentTest: RunningTest?

    public init(name: String) {
        self.name = name
        self.tests = []
    }

    public func start(name: String) throws {
        guard currentTest == nil else {
            throw Error.testAlreadyRunning
        }
        print("Running \(name)...", terminator: "")

        let test = RunningTest(
            name: name,
            start: Date()
        )
        currentTest = test
    }

    public func end() throws {
        guard let runningTest = currentTest else {
            throw Error.noTestRunning
        }
        print("Done.")

        let test = FinishedTest(
            name: runningTest.name,
            start: runningTest.start,
            end: Date()
        )
        tests.append(test)
        currentTest = nil
    }

    public func printResults() {
        print("\(name) Benchmark Results:")
        for test in tests {
            print("\(test.name): \(test.duration)")
        }
    }
}
