import CoreML
import SwiftUI
import Vision

final class AppModel: ObservableObject {
    static let defaultMLModelName = "rockpaperscissors.mlmodel"
    let camera = MLCamera()
    let predictionTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    @Published var currentMLModel: HandPoseMLModel? {
        didSet {
            guard let model = currentMLModel else { return }
            camera.mlDelegate?.updateMLModel(with: model)
        }
    }

    @Published var defaultMLModel: HandPoseMLModel?
    @Published var availableHandPoseMLModels = Set<HandPoseMLModel>()

    @Published var nodePoints: [CGPoint] = []
    @Published var isHandInFrame: Bool = false

    @Published var predictionProbability = PredictionMetrics()
    @Published var canPredict: Bool = false
    @Published var predictionLabel: String = ""
    @Published var isGatheringObservations: Bool = true

    @Published var viewfinderImage: Image?
    @Published var shouldPauseCamera: Bool = false {
        didSet {
            if shouldPauseCamera {
                camera.stop()
                isGatheringObservations = false
            } else {
                Task {
                    await camera.start()
                }
            }
        }
    }

    private var handposeMLModelURLs: [URL] {
        let urls = availableHandPoseMLModels.map { $0.url }
        return urls
    }

    init() {
        camera.mlDelegate = self
        setDefaultMLModel()
        Task {
            await handleCameraPreviews()
        }
    }

    func findExistingModels() async {
        let models = await HandPoseMLModel.findExistingModels(exclude: handposeMLModelURLs)
        for model in models {
            availableHandPoseMLModels.insert(model)
        }
    }

    func useLastTrainedModel() async {
        guard let lastTrained = await HandPoseMLModel.getLastTrainedModel() else {
            print("Couldn't find any recently trained ML models.")
            return
        }

        Task { @MainActor in
            self.currentMLModel = lastTrained
            print("Using last trained ML model in your RPS game: \(lastTrained.name)")
        }
    }

    private func handleCameraPreviews() async {
        let imageStream = camera.previewStream.map { $0.image }
        for await image in imageStream {
            Task { @MainActor in
                self.viewfinderImage = image
            }
        }
    }

    private func setDefaultMLModel() {
        Task {
            guard let mlModel = await HandPoseMLModel.getDefaultMLModel() else { return }
            Task { @MainActor in
                self.defaultMLModel = mlModel
                self.currentMLModel = mlModel
                self.availableHandPoseMLModels.insert(mlModel)
            }
        }
    }
}

extension AppModel: MLDelegate {
    func updateMLModel(with model: NSObject) {
        guard let mlModel = model as? HandPoseMLModel else { return }
        camera.currentMLModel = mlModel
    }

    func gatherObservations(pixelBuffer: CVImageBuffer) async {
        guard canPredict else { return }

        Task { @MainActor in
            canPredict = false
        }

        guard let mlModel = camera.currentMLModel else {
            await resetPrediction()
            return
        }

        Task {
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
            do {
                try imageRequestHandler.perform([camera.handPoseRequest])
                guard let observation = camera.handPoseRequest.results?.first else {
                    await resetPrediction()
                    return
                }

                Task { @MainActor in
                    isHandInFrame = true
                    isGatheringObservations = true
                }

                let poseMultiArray = try observation.keypointsMultiArray()

                let input = HandPoseInput(poses: poseMultiArray)
                guard let output = try mlModel.predict(poses: input) else { return }
                await updatePredictions(output: output)

                let jointPoints = try gatherHandPosePoints(from: observation)
                await updateNodes(points: jointPoints)
            } catch {
                print("Error performing request: \(error)")
            }
        }
    }

    private func gatherHandPosePoints(from observation: VNHumanHandPoseObservation) throws -> [CGPoint] {
        let allPointsDict = try observation.recognizedPoints(.all)
        var allPoints: [VNRecognizedPoint] = Array(allPointsDict.values)
        allPoints = allPoints.filter { $0.confidence > 0.5 }
        let points: [CGPoint] = allPoints.map { $0.location }
        return points
    }

    @MainActor
    private func updateNodes(points: [CGPoint]) {
        nodePoints = points
    }

    @MainActor
    private func updatePredictions(output: HandPoseOutput) {
        predictionLabel = output.label.capitalized
        predictionProbability.getNewPredictions(from: output.labelProbabilities)
    }

    @MainActor
    private func resetPrediction() {
        nodePoints = []
        predictionLabel = ""
        predictionProbability = PredictionMetrics()
        isHandInFrame = false
    }
}

private extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}
