import SwiftUI




struct ResultView: View {
    
    let result: ScanResult
    
    let onDismiss: ()->Void
    
    func displayTitleForThreats(id: String) -> String {
        if id.hasSuffix("Free") {
            return String(
                id[
                    id.startIndex..<id.index(id.endIndex, offsetBy: -5)
                ]
            )
        }
        else{ return "Not \(id)"}
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0, content: {
            HStack(alignment: .top, spacing: nil, content: {
                Spacer()
                DismissButton(onDismiss: onDismiss)
            })
            if !result.textDetected {
                Image(systemName: "questionmark.circle.fill")
                    .resizable()
                    .foregroundColor(.secondary)
                    .frame(width: 64.0, height: 64.0, alignment: .center)
                    .frame(maxWidth:.infinity)
            }
            else if result.safe {
                Image(systemName: "checkmark.seal.fill")
                    .resizable()
                    .foregroundColor(.green)
                    .frame(width: 64.0, height: 64.0, alignment: .center)
                    .frame(maxWidth:.infinity)
            }
            else {
                Image(systemName: "exclamationmark.octagon.fill")
                    .resizable()
                    .foregroundColor(.yellow)
                    .frame(width: 64.0, height: 64.0, alignment: .center)
                    .frame(maxWidth:.infinity)
            }
            Text(result.describe())
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth:.infinity)
                .padding(.vertical, 16.0)
            
            
            
            VStack(alignment: .leading, spacing: 8.0) {
                ForEach(result.potentialThreats.indices, id:\.self) { it in
                    VStack(alignment: .leading, spacing: 8.0) {
                        HStack(spacing: 16.0) {
                            Text(result.potentialThreats[it].icon)
                                .font(.largeTitle)
                                .frame(width: 54.0, height: 54.0)
                                .background(
                                    RoundedRectangle(cornerSize: CGSize(width: 16.0, height: 16.0), style: .continuous)
                                        .fill(
                                            Color(.systemGroupedBackground))
                                )
                            
                            VStack(alignment:.leading) {
                                Text(displayTitleForThreats(id: result.potentialThreats[it].id))
                                    .font(.headline)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .truncationMode(.tail)
                                
                                Spacer()
                                Text(result.potentialThreats[it].items.map { it in
                                    it.capitalized
                                }.joined(separator: ", "))
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .truncationMode(.tail)
                            }
                            .padding(.vertical, 8.0)
                            .frame(maxWidth: .infinity)
                            
                            
                        }
                        .frame(maxHeight: 54.0)
                        
                        if it != result.potentialThreats.count - 1 {
                            Rectangle()
                                .fill(.foreground.opacity(0.1))
                                .padding(.trailing, 54.0)
                                .frame(maxWidth: .infinity, maxHeight: 1)
                            
                                .offset(x: 70.0, y: 0.0)
                            
                        }
                    }
                    
                }
            }.padding(.top, 16.0)
            //            }.frame(maxWidth: .infinity)
            
            
            //            Spacer()
            Button {
                onDismiss()
            } label: {
                Text("OK")
                    .font(.headline)
                    .frame(height: 36)
                    .frame(maxWidth:360)
                
            }
            .buttonBorderShape(.roundedRectangle(radius: 12.0))
            .tint(.blue)
            .buttonStyle(.borderedProminent)
            .padding(.top)
            .frame(maxWidth:.infinity)
        }).padding()
        
        //            .navigationTitle(result.describe())
        //            .toolbar {
        //                ToolbarItem(placement: .primaryAction) {
        //                    DismissButton(onDismiss: onDismiss)
        //                }
        //            }
        //        }
    }
}
