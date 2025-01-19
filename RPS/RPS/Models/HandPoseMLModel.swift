import CoreML
import Foundation

final class HandPoseMLModel: NSObject, Identifiable {
    let name: String
    let mlModel: MLModel
    let url: URL

    private var classLabels: [Any] {
        mlModel.modelDescription.classLabels ?? []
    }

    init(name: String, mlModel: MLModel, url: URL) {
        self.name = name
        self.mlModel = mlModel
        self.url = url
    }

    func predict(poses: HandPoseInput) throws -> HandPoseOutput? {
        let features = try mlModel.prediction(from: poses)
        let output = HandPoseOutput(features: features)
        return output
    }
}

class HandPoseInput {
    var poses: MLMultiArray

    init(poses: MLMultiArray) {
        self.poses = poses
    }
}

class HandPoseOutput {
    let provider: MLFeatureProvider

    lazy var labelProbabilities: [String: Double] = { [unowned self] in
        self.getOutputProbabilities()
    }()

    lazy var label: String = { [unowned self] in
        self.getOutputLabel()
    }()

    init(features: MLFeatureProvider) {
        provider = features
    }
}
