import SwiftUI
import AudioToolbox

struct BottomBarLayer: View {
    var body: some View {
        GeometryReader { safeGeometry in
            
            Rectangle()
                .fill(.thinMaterial)
                .environment(\.colorScheme, .dark)
                .frame(width: safeGeometry.size.width, height: safeGeometry.safeAreaInsets.bottom, alignment: .center)
                .offset(x: 0, y: safeGeometry.size.height)
                .shadow(color:.black.opacity(0.2), radius: 24.0, x:0, y:0)
            
            Rectangle()
                .fill(.white.opacity(0.15))
                .environment(\.colorScheme, .dark)
                .frame(width: safeGeometry.size.width, height: 0.5, alignment: .center)
                .offset(x: 0, y: safeGeometry.size.height-0.5)
            
        }
    }
}

extension ScannerStatus {
    func hints() -> String {
        if self == .streaming {
            return "Tap to scan the ingredient list of your food"
        }
        else if self == .capturedAndRecognizing {
            return "Recognizing ingredients"
        }
        else {
            return "Recognition completed"
        }
    }
}

struct Pill: View {
    
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.vertical, 8)
            .padding(.horizontal, 16.0)
            .background(
                ZStack {
                    Capsule(style: .continuous)
                        .fill(.thinMaterial)
                    Capsule(style: .continuous)
                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                }
            )
            .environment(\.colorScheme, .dark)
            .padding(16.0)
    }
}

struct ExampleButton: View {
    
    let onClick: () -> Void
    
    var body: some View {
        Button {
            onClick()
        } label: {
            VStack(spacing: 4.0) {
                Image("IngredientListExample")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 72.0, maxHeight: 44.0, alignment: .center)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 8, height: 8), style: .continuous))
                Text("Try Example")
                    .foregroundColor(.blue)
                    .brightness(0.3)
                    .font(.caption)
            }.padding(8.0)
                .background(
                    ZStack {
                        RoundedRectangle(cornerSize: CGSize(width: 16, height: 16), style: .continuous)
                            .fill(.thinMaterial)
                        RoundedRectangle(cornerSize: CGSize(width: 16, height: 16), style: .continuous)
                            .stroke(.white.opacity(0.2), lineWidth: 0.5)
                    }
                )
                .environment(\.colorScheme, .dark)
        }
        
    }
}

struct CaptureButton: View {
    
    @Binding var status: ScannerStatus
    
    @State var hintDisplayed = false
    
    let onTap: () -> Void
    
    var body: some View {
        VStack {
            Pill(text: status.hints())
            
            ZStack {
                if (status == .streaming) {
                    Circle()
                        .fill(.white)
                        .frame(width: 72.0, height: 72.0, alignment: .center)
                        .shadow(color: .black.opacity(0.2), radius: 12.0, x: 0.0, y: 8.0)
                }
                else {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                Circle()
                    .stroke(.white, lineWidth: 4.0)
                    .frame(width: status == .streaming ? 84.0 : 48.0, height: status == .streaming ? 84.0 : 48.0, alignment: .center)
                    .animation(.interactiveSpring(), value: status)
                
            }
            .frame(height: 84.0, alignment: .center)
            .onTapGesture{
                guard status == .streaming else { return }
                onTap()
            }
            
        }
        
    }
}

struct ScannerView: View {
    @StateObject var model = ScannerViewModel()
    
    @ObservedObject var recipeModel: RecipeViewModel
    
    @State var isSheetDisplayed = false
    @State var scanResult: ScanResult = .safeResult
    
    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { unsafeGeometry in
                if let image = model.capturedImage ?? model.image {
                    Image(image, scale: 1.0, orientation: .up, label: Text("Scanner Output"))
                        .resizable()
                        .scaledToFill()
                        .frame(width: unsafeGeometry.size.width, height: unsafeGeometry.size.height, alignment: .center)
                        .clipped()
                }
            }.ignoresSafeArea()
            
            
            BottomBarLayer().zIndex(10.0)
            
            CaptureButton(status: $model.status) {
                Task {
                    await model.captureAndRecognize(
                        onGetObservations: { observations in
                            return recipeModel.detectRecipes(on: observations)
                        },
                        onRecognized: { result in
                            scanResult = result
                            withAnimation(.default) {
                                isSheetDisplayed = true
                            }
                        }
                    )
                }
            }
            .padding(32.0)
            .zIndex(1.0)
            
            if isSheetDisplayed {
                ResultView(
                    result: scanResult,
                    onDismiss: {
                        model.restartCapturing()
                        withAnimation(.default) {
                            isSheetDisplayed = false
                        }
                    }
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .background(
                    RoundedRectangle(cornerRadius: 24.0, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                        .shadow(color: .black.opacity(0.2), radius: 12.0, x: 0.0, y: 8.0)
                )
                .padding(.all)
                .zIndex(8.0)
                .transition(.move(edge: .bottom))
            }
            
            
            ExampleButton {
                Task {
                    await model.captureAndRecognize(
                        onGetObservations: { observations in
                            return recipeModel.detectRecipes(on: observations)
                        },
                        onRecognized: { result in
                            scanResult = result
                            withAnimation(.default) {
                                isSheetDisplayed = true
                            }
                        },
                        forceImage: UIImage(named: "IngredientListExample")?.cgImage
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(32.0)
            
            
        }
    }
}
