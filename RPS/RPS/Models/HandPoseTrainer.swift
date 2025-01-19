import CoreML
import CreateML
import Foundation

final class HandPoseTrainer {
    private var augmentationParameters = MLHandPoseClassifier.ImageAugmentationOptions()

    var classifier: MLHandPoseClassifier?

    var session: TrainingSession?

    func train(with dataModel: TrainerDataModel) async throws {
        guard let trainingDataset = dataModel.currentTrainingDataset?.directory else { return }
        var modelParameters = MLHandPoseClassifier.ModelParameters()

        if let validationDataset = dataModel.currentValidationDataset?.directory {
            modelParameters.validation = .dataSource(.labeledDirectories(at: validationDataset))
        } else {
            modelParameters.validation = .none
        }

        augmentationParameters.insert(.rotate)
        augmentationParameters.insert(.translate)
        augmentationParameters.insert(.horizontallyFlip)
        modelParameters.augmentationOptions = augmentationParameters

        let trainingDataSource = MLHandPoseClassifier.DataSource.labeledDirectories(at: trainingDataset)
        try await runTrainingSession(with: trainingDataSource, dataModel: dataModel, modelParameters: modelParameters)
    }
}
