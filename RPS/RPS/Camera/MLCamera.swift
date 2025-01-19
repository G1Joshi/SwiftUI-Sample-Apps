import Foundation
import Vision

final class MLCamera: Camera {
    lazy var handPoseRequest: VNDetectHumanHandPoseRequest = {
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 1
        return request
    }()

    var currentMLModel: HandPoseMLModel?
}
