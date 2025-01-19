import Charts
import SwiftUI

struct TrainingView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.displayScale) private var displayScale

    @EnvironmentObject var appModel: AppModel
    @ObservedObject var trainerDataModel: TrainerDataModel
    @State private var modelName: String = ""
    @State private var chosenValidationDataset: String = ""
    @Binding var newDatasets: [Dataset]
    @FocusState private var focusField: Bool

    private var trainingDataset: Dataset? {
        trainerDataModel.currentTrainingDataset
    }

    private var validationDataset: Dataset? {
        trainerDataModel.currentValidationDataset
    }

    private var completed: Int {
        Int(trainerDataModel.completed)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            if trainerDataModel.currentState == .active {
                trainingSessionInfo()
            } else {
                modelNameTextField()
                datasets()
            }
        }
        .padding(.horizontal)
        .toolbar {
            cancelButton()
            trainButton()
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(trainingDataset?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: trainerDataModel.currentState) { _ in
            switch trainerDataModel.currentState {
            case .finished, .error:
                closeView()
            default: break
            }
        }
    }

    private func modelNameTextField() -> some View {
        VStack(alignment: .leading) {
            Text("Model Name")
                .font(.subheadline)
            TextField("New model name", text: $modelName)
                .focused($focusField)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                .onChange(of: modelName) { _ in
                    trainerDataModel.modelName = modelName
                }
                .disabled(trainerDataModel.currentState == .active)
        }
    }

    private func trainingSessionInfo() -> some View {
        VStack(alignment: .leading) {
            HStack {
                ProgressView("Training Progress - Do not leave the screen", value: trainerDataModel.completed, total: 100)
                    .font(.subheadline)
                    .tint(.accent)
            }
            if !trainerDataModel.currentPhase.isEmpty {
                Text("Current training phase: \(trainerDataModel.currentPhase)")
                    .font(.subheadline)
            }
        }
        .padding(.bottom)
    }

    private func datasets() -> some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Training Datasets")
                    .font(.subheadline)
                if let trainingDataset = trainingDataset,
                   let subDirectories = trainingDataset.directory?.subDirectories
                {
                    ForEach(subDirectories, id: \.self) { directory in
                        let count = trainingDataset.getImages(from: directory).count
                        trainingDatasetCell(for: directory.lastPathComponent, with: trainingDataset, count: count)
                    }
                }
                validationDatasetView()
            }
            Spacer()
        }
    }

    private func validationDatasetView() -> some View {
        VStack(alignment: .leading) {
            Text("Validation Dataset")
                .font(.subheadline)
                .padding(.top)
            Picker("Pick a validation dataset", selection: $chosenValidationDataset) {
                Text("None").tag("")
                ForEach(trainerDataModel.localValidationDatasetNames, id: \.self) { name in
                    Text(name)
                }
            }
            .tint(.accent)
            if let dataset = validationDataset {
                let count = dataset.getTotalImageCount()
                validationDatasetCell(with: dataset, count: count)
                    .animation(.default, value: chosenValidationDataset.isEmpty)
            }
        }
        .onChange(of: chosenValidationDataset) { _ in
            updateValidationDataset()
        }
    }

    private func trainingDatasetCell(for move: String, with dataset: Dataset, count: Int) -> some View {
        NavigationLink {
            TrainingDatasetImageGrid(trainerDataModel: trainerDataModel, dataset: dataset, label: move)
        } label: {
            CellView(name: move, count: count)
        }
        .modifier(CellStyle())
    }

    private func validationDatasetCell(with dataset: Dataset, count: Int) -> some View {
        NavigationLink {
            ValidationDatasetImageGrid(dataset: dataset)
        } label: {
            CellView(name: dataset.name, count: count)
        }
        .modifier(CellStyle())
    }

    private func trainButton() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if trainerDataModel.currentState != .active {
                Button {
                    train()
                } label: {
                    Text("Train")
                }
                .foregroundColor(.accent)
                .disabled(trainerDataModel.disableTrainingButton)
                .opacity(trainerDataModel.disableTrainingButton ? 0.3 : 1.0)
            }
        }
    }

    private func cancelButton() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                closeView()
            } label: {
                Text("Cancel")
            }
            .foregroundColor(.accent)
        }
    }

    private func updateValidationDataset() {
        guard !chosenValidationDataset.isEmpty,
              let validationDataset = trainerDataModel.localValidationDatasets.first(where: { $0.name == chosenValidationDataset })
        else {
            trainerDataModel.currentValidationDataset = nil
            return
        }

        trainerDataModel.currentValidationDataset = validationDataset
    }

    private func closeView() {
        updateNewDataset()
        trainerDataModel.reset()
        presentationMode.wrappedValue.dismiss()
    }

    private func updateNewDataset() {
        guard let dataset = trainingDataset, dataset.isNew else { return }
        guard trainerDataModel.currentState == .finished else {
            dataset.delete()
            return
        }
        dataset.moveDirectoryTo(modelName)
        dataset.name = modelName
        dataset.isNew = false
        newDatasets.append(dataset)
    }

    private func train() {
        guard trainerDataModel.currentTrainingDataset != nil else { return }
        let trainer = HandPoseTrainer()
        trainerDataModel.currentTrainer = trainer
        Task(priority: .userInitiated) {
            do {
                try await trainer.train(with: trainerDataModel)
            } catch {
                print("Could not train ML model: \(error.localizedDescription)")
            }
        }
    }
}
