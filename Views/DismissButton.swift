import SwiftUI

struct DismissButton: View {
    let onDismiss: ()->Void
    
    var body: some View {
        Button {
            onDismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color(.secondaryLabel))
                .frame(width: 36.0, height: 36.0, alignment: .center)
                .background(Color(.quaternarySystemFill), in: Circle())
        }
    }
}
