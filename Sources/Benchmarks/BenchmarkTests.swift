import Foundation

extension Benchmark {
    struct RunningTest {
        var name: String
        var start: Date
    }

    struct FinishedTest {
        var name: String
        var start: Date
        var end: Date

        var duration: TimeInterval {
            return end.timeIntervalSince(start)
        }
    }
}
