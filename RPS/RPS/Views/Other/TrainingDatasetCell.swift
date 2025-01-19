import SwiftUI

struct TrainingDatasetCell: View {
    @EnvironmentObject var appModel: AppModel
    @StateObject var trainerDataModel: TrainerDataModel
    var dataset: Dataset
    @State private var newDatasets: [Dataset] = []
    private var totalImages: Int {
        dataset.getTotalImageCount()
    }

    var body: some View {
        NavigationLink {
            TrainingView(trainerDataModel: trainerDataModel, newDatasets: $newDatasets)
                .environmentObject(appModel)
                .onAppear {
                    trainerDataModel.currentTrainingDataset = dataset
                }
        } label: {
            CellView(name: dataset.name, count: totalImages)
        }
        .modifier(CellStyle())
    }
}
