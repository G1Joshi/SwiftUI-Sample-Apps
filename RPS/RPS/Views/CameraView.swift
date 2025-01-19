import SwiftUI

struct CameraView: View {
    @EnvironmentObject var appModel: AppModel
    var showNodes: Bool = false

    private var showWarning: Bool {
        appModel.viewfinderImage != nil && appModel.currentMLModel != nil && !appModel.isHandInFrame
    }

    private var previewImageSize: CGSize {
        appModel.camera.previewImageSize
    }

    private var handJointPoints: [CGPoint] {
        appModel.nodePoints
    }

    var body: some View {
        ViewfinderView(image: $appModel.viewfinderImage)
            .overlay(alignment: .center) {
                if showNodes {
                    HandPoseNodeOverlay(size: previewImageSize,
                                        points: handJointPoints)
                }
            }
            .overlay(alignment: .center) {
                if showWarning {
                    CameraFrameOverlay()
                        .animation(.default, value: appModel.isHandInFrame)
                }
            }
            .task {
                await appModel.camera.start()
            }
            .onReceive(appModel.predictionTimer) { _ in
                guard appModel.currentMLModel != nil else { return }
                appModel.canPredict = true
            }
            .onDisappear {
                appModel.canPredict = false
            }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView(showNodes: true)
            .environmentObject(AppModel())
    }
}
