import SwiftUI

struct MLModelListView: View {
    @EnvironmentObject var appModel: AppModel
    @State private var selection: HandPoseMLModel?

    private var mlModels: [HandPoseMLModel] {
        Array(appModel.availableHandPoseMLModels)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(mlModels) { mlModel in
                Button {
                    selection = mlModel
                    appModel.currentMLModel = mlModel
                } label: {
                    mlModelView(mlModel, isSelected: selection == mlModel)
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Available ML Models")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selection = appModel.currentMLModel
        }
    }

    private func mlModelView(_ model: HandPoseMLModel, isSelected: Bool) -> some View {
        HStack {
            Image(systemName: isSelected ? "circle.fill" : "circle")
                .padding(.trailing)
            VStack(alignment: .leading, spacing: 5) {
                Text(model.name)
                    .fontWeight(.bold)
                if model == appModel.defaultMLModel {
                    Text("Default ML model built into the app")
                        .font(.caption2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .modifier(CellStyle(cornerRadius: 10))
        }
    }
}
