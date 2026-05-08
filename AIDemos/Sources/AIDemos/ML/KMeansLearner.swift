import Foundation

/// k-Means clustering. Euclidean distance, random initialisation.
final class KMeansLearner {
    let k: Int
    private let maxIterations: Int
    private var rng: SeededRandom

    private(set) var centroids: [[Double]] = []
    private(set) var assignments: [Int] = []
    private(set) var iterationsRun: Int = 0

    init(k: Int, maxIterations: Int = 300, seed: UInt64 = 42) {
        self.k = k
        self.maxIterations = maxIterations
        self.rng = SeededRandom(seed: seed)
    }

    func fit(data: [[Double]]) {
        let n = data.count
        guard n >= k else { return }

        // Random init — pick k distinct indices
        var indices = Set<Int>()
        while indices.count < k {
            indices.insert(Int(rng.next() % UInt64(n)))
        }
        centroids = indices.map { data[$0] }
        assignments = Array(repeating: 0, count: n)

        for iteration in 0..<maxIterations {
            let newAssignments = (0..<n).map { closestCentroid(to: data[$0]) }
            if newAssignments == assignments && iteration > 0 { break }
            assignments = newAssignments
            iterationsRun = iteration + 1

            centroids = (0..<k).map { cluster in
                let members = data.enumerated().filter { assignments[$0.offset] == cluster }.map(\.element)
                guard !members.isEmpty else { return centroids[cluster] }
                let dim = members[0].count
                return (0..<dim).map { d in members.map { $0[d] }.reduce(0, +) / Double(members.count) }
            }
        }
    }

    private func closestCentroid(to point: [Double]) -> Int {
        centroids.enumerated().min(by: { euclidean($0.element, point) < euclidean($1.element, point) })!.offset
    }

    private func euclidean(_ a: [Double], _ b: [Double]) -> Double {
        zip(a, b).reduce(0) { $0 + ($1.0 - $1.1) * ($1.0 - $1.1) }.squareRoot()
    }
}

private struct SeededRandom {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 1 : seed }
    mutating func next() -> UInt64 {
        state ^= state << 13; state ^= state >> 7; state ^= state << 17
        return state
    }
    mutating func nextDouble() -> Double { Double(next()) / Double(UInt64.max) }
}
