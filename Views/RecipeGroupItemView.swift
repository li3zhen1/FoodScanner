import SwiftUI

struct RecipeGroupItemView: View {
    let recipeGroup: RecipeGroup
    let isSelected: Bool?
    let checkAction: () -> Void
    let detailAction: () -> Void
    @State var isToggleOn = false
    
    var background: AnyShapeStyle {
        if isSelected == true {
            return AnyShapeStyle(
                recipeGroup.color.getGradient()
            )
        }
        else {
            return AnyShapeStyle(
                Color(.secondarySystemGroupedBackground)
            )
        }
    }
    
    var textColor: Color {
        if isSelected == true {
            return Color(.white)
        }
        else {
            return Color(.tertiaryLabel)
        }
    }
    
    var chevronColor: Color {
        if isSelected == true {
            return Color(.white)
        }
        else {
            return Color(.tertiaryLabel)
        }
    }
    
    var emojiBackgroundColor: Color {
        if isSelected == true {
            return Color(.black).opacity(0.18)
        }
        else {
            return Color(.black).opacity(0.06)
        }
    }
    var emojiSaturation: Double {
        if isSelected == true {
            return 0.0
        }
        else {
            return 1.0
        }
    }
    
    var emojiBlendMode: BlendMode {
        if isSelected == true {
            return .luminosity
        }
        else {
            return .normal
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            Button {
                checkAction()
            } label: {
                
                VStack(alignment: .leading) {
                    HStack(alignment: .top, spacing: nil, content: {
                        
                        Text(recipeGroup.iconName)
                            .font(.largeTitle)
                        
                            .saturation(emojiSaturation)
                            .blendMode(emojiBlendMode)
                        
                            .frame(width: 54.0, height: 54.0, alignment: .center)
                            .background(
                                RoundedRectangle(cornerSize: CGSize(width: 16.0, height: 16.0), style: .continuous)
                                    .fill(emojiBackgroundColor)
                            )
                            .mask {
                                if isSelected == true{
                                    Path { p in
                                        let offset = 4.0
                                        let sz = 54.0
                                        p.move(to: CGPoint(x: offset,y: 0.0))
                                        p.addLine(to: CGPoint(x: sz, y:0.0))
                                        p.addLine(to: CGPoint(x: sz, y:sz-offset))
                                        p.closeSubpath()
                                        
                                        p.move(to: CGPoint(x: 0.0,y: offset))
                                        p.addLine(to: CGPoint(x: 0.0, y:sz))
                                        p.addLine(to: CGPoint(x: sz - offset, y:sz))
                                        p.closeSubpath()
                                    }
                                }
                                else {
                                    Rectangle()
                                }
                            }
                        Spacer()
                    })
                    Spacer()
                    HStack(alignment: .center) {
                        Text(recipeGroup.id)
                            .font(.system(.headline, design: .default, weight: .semibold))
                            .foregroundColor(textColor)
                        Spacer()
                        Button {
                            detailAction()
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(chevronColor)
                        }
                    }
                }
                .padding(.leading, 16.0)
                .padding(.trailing, 12.0)
                .padding(.bottom, 12.0)
                .padding(.top, 16.0)
                .frame(maxWidth: .infinity, minHeight: 144.0)
                .background(
                    RoundedRectangle(cornerSize: CGSize(width: 24.0, height: 24.0), style: .continuous)
                        .fill(background)
                )
                
            }
        }
    }
}
