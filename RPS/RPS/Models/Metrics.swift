import CreateML
import Foundation

struct TrainingMetric: Identifiable {
    var id: Double { x }
    let x: Double
    let y: Double
}

class TrainingMetrics: ObservableObject {
    var allMetricTypes = [String]()
    var data: [String: [TrainingMetric]] = [:]

    init() {}

    func addDatapointForType(type: String, x: Double, y: Double) {
        let metric = TrainingMetric(x: x, y: y)
        if var currentMetricArray = data[type] {
            currentMetricArray.append(metric)
            data[type] = currentMetricArray
        } else {
            allMetricTypes.append(type)
            data[type] = [metric]
        }
    }
}

struct PredictionMetric: Identifiable {
    var id: String { category }
    let category: String
    let value: Double
}

extension PredictionMetric: Equatable {
    static func == (lhs: PredictionMetric, rhs: PredictionMetric) -> Bool {
        return lhs.id == rhs.id &&
            lhs.category == rhs.category &&
            lhs.value == rhs.value
    }
}

class PredictionMetrics: ObservableObject, Identifiable {
    var data = [PredictionMetric]()
    var dictionary: [String: Double] = [:]
    init() {}

    func getNewPredictions(from probabilities: [String: Double]) {
        var tempData = [PredictionMetric]()
        dictionary = probabilities

        _ = dictionary.map { (key: String, value: Double) in
            tempData.append(PredictionMetric(category: key, value: value))
        }
        data = tempData.sorted(by: { $0.category > $1.category })
    }
}
