import Combine
import CoreML
import CreateML
import Foundation

extension HandPoseTrainer {
    typealias TrainingSession = MLJob<MLHandPoseClassifier>

    private static func constructModelPath(with name: String) -> URL? {
        guard let modelDirectory = URL.modelDirectory else { return nil }
        let modelPath = modelDirectory.appendingPathComponent(name).appendingPathExtension("mlmodel")

        return modelPath
    }

    func saveMLModelToDisk(as name: String, with classifier: MLHandPoseClassifier) throws {
        guard let modelPath = HandPoseTrainer.constructModelPath(with: name) else {
            return
        }
        try classifier.write(to: modelPath)
        print("\(name).mlmodel was successfully saved to \(modelPath.relativePath)")
    }

    func runTrainingSession(with dataSource: MLHandPoseClassifier.DataSource, dataModel: TrainerDataModel, modelParameters: MLHandPoseClassifier.ModelParameters) async throws {
        let mlJob = try MLHandPoseClassifier.train(trainingData: dataSource,
                                                   parameters: modelParameters)
        session = mlJob
        Task { @MainActor in
            dataModel.currentState = .active
        }

        var subscriptions = Set<AnyCancellable>()

        mlJob.progress
            .publisher(for: \.fractionCompleted)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: RunLoop.main)
            .sink { completed in
                guard let progress = MLProgress(progress: mlJob.progress) else { return }

                if progress.phase.rawValue != dataModel.currentPhase {
                    dataModel.currentPhase = progress.phase.rawValue
                }

                dataModel.completed = round(completed * 100)
                let metrics = MLProgress.Metric.allCases
                print("Progress \(dataModel.completed)%")
                for metric in metrics {
                    guard let value = progress.metrics[metric] else { continue }
                    guard let valueD = value as? Double else { return }
                    dataModel.trainingMetrics.addDatapointForType(type: metric.rawValue, x: completed, y: valueD)
                    print("Metric [\(metric.rawValue)]: \(value)")
                }
            }
            .store(in: &subscriptions)

        mlJob.result
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: RunLoop.main)
            .sink { _ in

            } receiveValue: { classifier in
                dataModel.completed = 100.0
                self.classifier = classifier
                let name = dataModel.modelName ?? "customMLModel"
                do {
                    try self.saveMLModelToDisk(as: name, with: classifier)
                    dataModel.currentState = .finished
                } catch {
                    print("Error saving model: \(error.localizedDescription)")
                    dataModel.currentState = .error
                }
            }
            .store(in: &subscriptions)
    }

    func cancel() {
        session?.cancel()
    }
}

extension HandPoseMLModel {
    static func loadMLModel(from url: URL, as name: String) async throws -> HandPoseMLModel? {
        let compiledModelURL = try await MLModel.compileModel(at: url)
        let model = try MLModel(contentsOf: compiledModelURL)
        return HandPoseMLModel(name: name, mlModel: model, url: url)
    }

    static func getDefaultMLModel() async -> HandPoseMLModel? {
        guard let rpsModel = URL.defaultMLModel else { return nil }
        do {
            return try await HandPoseMLModel.loadMLModel(from: rpsModel, as: AppModel.defaultMLModelName)
        } catch {
            print("Could not load default ML model: \(error.localizedDescription)")
            return nil
        }
    }

    static func findExistingModels(exclude existingModelURLs: [URL] = []) async -> [HandPoseMLModel] {
        guard let modelDirectory = URL.modelDirectory, modelDirectory.directoryExists else { return [] }
        var models: [HandPoseMLModel] = []
        do {
            let modelURLs = modelDirectory.directoryContentsOrderedByDate
            for url in modelURLs {
                guard !existingModelURLs.contains(url) else { continue }
                guard let model = try await getMLModel(from: url) else { continue }
                models.append(model)
            }
        } catch {
            print("Error finding existing models \(error.localizedDescription)")
        }

        return models
    }

    static func getLastTrainedModel() async -> HandPoseMLModel? {
        return await HandPoseMLModel.findExistingModels().first
    }

    private static func getMLModel(from url: URL) async throws -> HandPoseMLModel? {
        let name = url.lastPathComponent
        guard let handposeMLModel = try await HandPoseMLModel.loadMLModel(from: url, as: name) else { return nil }
        return handposeMLModel
    }
}

extension HandPoseInput: MLFeatureProvider {
    var featureNames: Set<String> {
        return ["poses"]
    }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "poses" {
            return MLFeatureValue(multiArray: poses)
        }
        return nil
    }
}

extension HandPoseOutput: MLFeatureProvider {
    var featureNames: Set<String> {
        return provider.featureNames
    }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        return provider.featureValue(for: featureName)
    }
}

extension HandPoseOutput {
    func getOutputProbabilities() -> [String: Double] {
        return provider.featureValue(for: "labelProbabilities")?.dictionaryValue as? [String: Double] ?? [:]
    }

    func getOutputLabel() -> String {
        return provider.featureValue(for: "label")?.stringValue ?? ""
    }
}
