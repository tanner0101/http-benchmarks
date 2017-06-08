// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "HTTPBenchmarks",
    targets: [
    	Target(name: "Benchmarks"),
    	Target(name: "HeadersBenchmark", dependencies: ["Benchmarks"])
    ]
)
