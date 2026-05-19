import SwiftUI

enum Demo: String, CaseIterable, Identifiable {
    case xorNeuralNet = "XOR Neural Net"
    case irisKMeans   = "Iris k-Means"
    case perceptron   = "Perceptron"
    case restaurantID3 = "Restaurant ID3"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .xorNeuralNet: return "brain.head.profile"
        case .irisKMeans:   return "circles.hexagongrid"
        case .perceptron:   return "network"
        case .restaurantID3: return "fork.knife"
        }
    }

    var topic: String {
        switch self {
        case .xorNeuralNet: return "Deep Learning"
        case .irisKMeans:   return "Unsupervised Learning"
        case .perceptron:   return "Linear Classifier"
        case .restaurantID3: return "Decision Tree Learning"
        }
    }
}

struct ContentView: View {
    @State private var selectedDemo: Demo? = .xorNeuralNet

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedDemo) {
                ForEach(Demo.allCases) { demo in
                    NavigationLink(value: demo) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(demo.rawValue).fontWeight(.medium)
                                Text(demo.topic).font(.caption).foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: demo.icon)
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 220)
            .navigationTitle("AI Demos")
        } detail: {
            switch selectedDemo {
            case .xorNeuralNet:
                XorNeuralNetView()
            case .irisKMeans:
                IrisKMeansView()
            case .perceptron:
                PerceptronView()
            case .restaurantID3:
                RestaurantID3View()
            case nil:
                Text("Bitte ein Demo auswählen")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
