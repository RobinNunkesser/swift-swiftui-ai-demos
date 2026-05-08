import Foundation
import Observation

struct IrisPoint: Identifiable {
    let id = UUID()
    let sepalLength: Double
    let sepalWidth: Double
    let cluster: Int
    let trueLabel: Int  // 0 Setosa, 1 Versicolor, 2 Virginica
}

@Observable
final class IrisKMeansViewModel {
    var k: Int = 3
    var isTrained: Bool = false
    var isTraining: Bool = false
    var points: [IrisPoint] = []
    var iterationsRun: Int = 0

    let kOptions = [2, 3, 4]

    func train() {
        isTraining = true
        isTrained = false
        let kv = k
        Task.detached { [weak self] in
            guard let self else { return }
            let (features, labels) = Self.irisData()
            let kmeans = KMeansLearner(k: kv, seed: 42)
            kmeans.fit(data: features)

            let pts = features.enumerated().map { idx, f in
                IrisPoint(sepalLength: f[0], sepalWidth: f[1],
                          cluster: kmeans.assignments[idx], trueLabel: labels[idx])
            }
            await MainActor.run {
                self.points = pts
                self.iterationsRun = kmeans.iterationsRun
                self.isTrained = true
                self.isTraining = false
            }
        }
    }

    // Iris dataset: sepal length, sepal width (first 2 features, 150 samples)
    // Labels: 0=Setosa, 1=Versicolor, 2=Virginica
    private static func irisData() -> (features: [[Double]], labels: [Int]) {
        // 50 Setosa, 50 Versicolor, 50 Virginica
        let raw: [(Double, Double, Int)] = [
            // Setosa (0)
            (5.1,3.5,0),(4.9,3.0,0),(4.7,3.2,0),(4.6,3.1,0),(5.0,3.6,0),
            (5.4,3.9,0),(4.6,3.4,0),(5.0,3.4,0),(4.4,2.9,0),(4.9,3.1,0),
            (5.4,3.7,0),(4.8,3.4,0),(4.8,3.0,0),(4.3,3.0,0),(5.8,4.0,0),
            (5.7,4.4,0),(5.4,3.9,0),(5.1,3.5,0),(5.7,3.8,0),(5.1,3.8,0),
            (5.4,3.4,0),(5.1,3.7,0),(4.6,3.6,0),(5.1,3.3,0),(4.8,3.4,0),
            (5.0,3.0,0),(5.0,3.4,0),(5.2,3.5,0),(5.2,3.4,0),(4.7,3.2,0),
            (4.8,3.1,0),(5.4,3.4,0),(5.2,4.1,0),(5.5,4.2,0),(4.9,3.1,0),
            (5.0,3.2,0),(5.5,3.5,0),(4.9,3.6,0),(4.4,3.0,0),(5.1,3.4,0),
            (5.0,3.5,0),(4.5,2.3,0),(4.4,3.2,0),(5.0,3.5,0),(5.1,3.8,0),
            (4.8,3.0,0),(5.1,3.8,0),(4.6,3.2,0),(5.3,3.7,0),(5.0,3.3,0),
            // Versicolor (1)
            (7.0,3.2,1),(6.4,3.2,1),(6.9,3.1,1),(5.5,2.3,1),(6.5,2.8,1),
            (5.7,2.8,1),(6.3,3.3,1),(4.9,2.4,1),(6.6,2.9,1),(5.2,2.7,1),
            (5.0,2.0,1),(5.9,3.0,1),(6.0,2.2,1),(6.1,2.9,1),(5.6,2.9,1),
            (6.7,3.1,1),(5.6,3.0,1),(5.8,2.7,1),(6.2,2.2,1),(5.6,2.5,1),
            (5.9,3.2,1),(6.1,2.8,1),(6.3,2.5,1),(6.1,2.8,1),(6.4,2.9,1),
            (6.6,3.0,1),(6.8,2.8,1),(6.7,3.0,1),(6.0,2.9,1),(5.7,2.6,1),
            (5.5,2.4,1),(5.5,2.4,1),(5.8,2.7,1),(6.0,2.7,1),(5.4,3.0,1),
            (6.0,3.4,1),(6.7,3.1,1),(6.3,2.3,1),(5.6,3.0,1),(5.5,2.5,1),
            (5.5,2.6,1),(6.1,3.0,1),(5.8,2.6,1),(5.0,2.3,1),(5.6,2.7,1),
            (5.7,3.0,1),(5.7,2.9,1),(6.2,2.9,1),(5.1,2.5,1),(5.7,2.8,1),
            // Virginica (2)
            (6.3,3.3,2),(5.8,2.7,2),(7.1,3.0,2),(6.3,2.9,2),(6.5,3.0,2),
            (7.6,3.0,2),(4.9,2.5,2),(7.3,2.9,2),(6.7,2.5,2),(7.2,3.6,2),
            (6.5,3.2,2),(6.4,2.7,2),(6.8,3.0,2),(5.7,2.5,2),(5.8,2.8,2),
            (6.4,3.2,2),(6.5,3.0,2),(7.7,3.8,2),(7.7,2.6,2),(6.0,2.2,2),
            (6.9,3.2,2),(5.6,2.8,2),(7.7,2.8,2),(6.3,2.7,2),(6.7,3.3,2),
            (7.2,3.2,2),(6.2,2.8,2),(6.1,3.0,2),(6.4,2.8,2),(7.2,3.0,2),
            (7.4,2.8,2),(7.9,3.8,2),(6.4,2.8,2),(6.3,2.8,2),(6.1,2.6,2),
            (7.7,3.0,2),(6.3,3.4,2),(6.4,3.1,2),(6.0,3.0,2),(6.9,3.1,2),
            (6.7,3.1,2),(6.9,3.1,2),(5.8,2.7,2),(6.8,3.2,2),(6.7,3.3,2),
            (6.7,3.0,2),(6.3,2.5,2),(6.5,3.0,2),(6.2,3.4,2),(5.9,3.0,2),
        ]
        return (raw.map { [$0.0, $0.1] }, raw.map { $0.2 })
    }
}
