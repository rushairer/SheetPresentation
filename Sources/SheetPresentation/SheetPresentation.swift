import SwiftUI
import RoundedCorners

public enum SheetPresentationDetent {
    case large
    case medium
}

extension View {
    public func sheetPresentation<SheetContent: View, Background: View>
    (isPresented: Binding<Bool>,
     background: Background,
     hasGrabber: Bool = false,
     hasMaskView: Bool = false,
     isFullScreen: Bool = false,
     detents: [SheetPresentationDetent] = [.large],
     view: @escaping () -> SheetContent) -> some View {
        self.modifier(SheetPresentationViewModifier(isPresented: isPresented,
                                                    background: background,
                                                    hasGrabber: hasGrabber,
                                                    hasMaskView: hasMaskView,
                                                    isFullScreen: isFullScreen,
                                                    detents: detents,
                                                    view: view))
    }
}

public struct SheetPresentationViewModifier<SheetContent, Background>: ViewModifier where SheetContent: View, Background: View {
    
    @Binding var isPresented: Bool
    var background: Background
    var hasGrabber: Bool
    var hasMaskView: Bool
    var isFullScreen: Bool
    var view: () -> SheetContent
    var detents: [SheetPresentationDetent]
    
    @GestureState private var translation = CGPoint.zero
    @State private var offset = CGPoint.zero
    @State private var accumulated = CGPoint.zero
    
    private var screenSize: CGSize {
#if os(iOS) || os(tvOS)
        return UIScreen.main.bounds.size
#elseif os(watchOS)
        return WKInterfaceDevice.current().screenBounds.size
#else
        return NSScreen.main?.frame.size ?? .zero
#endif
    }
    
    private var screenHeight: CGFloat {
        screenSize.height
    }
    
    public init(isPresented: Binding<Bool>,
                background: Background,
                hasGrabber: Bool,
                hasMaskView: Bool,
                isFullScreen: Bool,
                detents: [SheetPresentationDetent],
                view: @escaping () -> SheetContent) {
        _isPresented = isPresented.animation()
        self.background = background
        self.hasGrabber = hasGrabber
        self.hasMaskView = hasMaskView
        self.isFullScreen = isFullScreen
        self.detents = detents
        self.view = view
    }
    
    public func body(content: Content) -> some View {
        let isMediumDetent: Bool = detents.count > 0 && detents.first == .medium
        
#if !os(tvOS)
        let hasTwoDetens: Bool = detents.count == 2
#endif

        GeometryReader { proxy in
            ZStack {
                content
                if hasMaskView {
                    Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
                        .opacity(isPresented ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5))
#if !os(tvOS)
                        .onTapGesture {
                            withAnimation {
                                isPresented = false
                            }
                        }
#endif
                }
                VStack {
                    if hasGrabber {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.secondary)
                            .frame(width: 50, height: 6)
                            .padding(12)
                            .opacity(0.4)
                    }
                    Spacer().frame(height: 0.3).opacity(0)
                    view().frame(maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(background)
                .cornerRadius(tl: 20, tr: 20, bl: 0, br: 0)
                .offset(y: isPresented ? offset.y : screenHeight)
                .shadow(color: Color.black.opacity(0.5), radius: 12, x: 0, y: 6)
                .edgesIgnoringSafeArea(isFullScreen ? .all : .bottom)
                .onChange(of: isPresented, perform: { isPresented in
                    if isPresented {
                        accumulated.y = isMediumDetent ? screenHeight * 0.4 - (isFullScreen ? 0 : proxy.safeAreaInsets.top): 0
                        offset = accumulated
                    }
                })
                
                .onChange(of: isFullScreen, perform: { isFullScreen in
                    if isPresented {
                        accumulated.y = isMediumDetent ? screenHeight * 0.4 - (isFullScreen ? 0 : proxy.safeAreaInsets.top): 0
                        offset = accumulated
                    }
                })
#if !os(tvOS)
                
                .highPriorityGesture(
                    DragGesture(minimumDistance: 20, coordinateSpace: .global)
                        .onChanged { value in
                            let newOffset = CGPoint(x: 0, y: value.translation.height + accumulated.y)
                            if newOffset.y >= 0 {
                                offset = newOffset
                            }
                        }
                        .onEnded { state in
                            let lastAccumulated = accumulated
                            accumulated = offset
                            
                            if hasTwoDetens {
                                if accumulated.y <= screenHeight * 0.2 {
                                    accumulated.y = 0
                                    withAnimation {
                                        offset = accumulated
                                    }
                                } else if accumulated.y > screenHeight * 0.2 && accumulated.y < screenHeight * 0.6 {
                                    accumulated.y =  screenHeight * 0.4 - (isFullScreen ? 0 : proxy.safeAreaInsets.top)
                                    withAnimation {
                                        offset = accumulated
                                    }
                                } else if accumulated.y >= screenHeight * 0.6 {
                                    withAnimation {
                                        isPresented = false
                                    }
                                }
                            } else {
                                if state.translation.height > screenHeight * 0.2 {
                                    withAnimation {
                                        isPresented = false
                                    }
                                } else {
                                    withAnimation {
                                        accumulated = lastAccumulated
                                        offset = lastAccumulated
                                    }
                                }
                            }
                        }
                )
#endif
                .animation(.easeInOut(duration: 0.5))
            }
        }
    }
}

struct SheetPresentationDemo_Previews: PreviewProvider {
    
    struct SheetPresentationDemo: View {
        @State private var showsSheetPresentation: Bool = false
        
        @State private var hasGrabber: Bool = false
        @State private var hasMaskView: Bool = false
        @State private var isFullScreen: Bool = false
        
        @State private var detents: [SheetPresentationDetent] = DetentsType.m.detents
        
        @State private var detentsType: DetentsType = .m
        enum DetentsType: String {
            case m
            case l
            case ml
            case lm
            
            var detents: [SheetPresentationDetent] {
                switch self {
                case .m:
                    return [.medium]
                case .l:
                    return [.large]
                case .ml:
                    return [.medium, .large]
                case .lm:
                    return [.large, .medium]
                }
            }
        }
        
#if os(iOS)
        private var background = Color(UIColor.systemBackground)
#elseif os(macOS)
        private var background = Color(NSColor.windowBackgroundColor)
#else
        private var background = Color.black
#endif
        
        var body:  some View {
            List {
#if os(watchOS)
                let pickerStyle = WheelPickerStyle()
#else
                let pickerStyle = SegmentedPickerStyle()
#endif
                
                Section(footer: Text("M: medium, L: Large")) {
                    Toggle("Grabber", isOn: $hasGrabber)
                    Toggle("MaskView", isOn: $hasMaskView)
                    Toggle("FullScreen", isOn: $isFullScreen)
                    Picker("Detents Type", selection: $detentsType.animation()) {
                        Text("M").tag(DetentsType.m)
                        Text("L").tag(DetentsType.l)
                        Text("M,L").tag(DetentsType.ml)
                        Text("L,M").tag(DetentsType.lm)
                    }
                    .pickerStyle(pickerStyle)
                }
                Section {
                    Button {
                        showsSheetPresentation = true
                    } label: {
                        Text("Show SheetPresentation")
                    }
                }
            }
            .onChange(of: detentsType) { detentsType in
                detents = detentsType.detents
            }
            .sheetPresentation(isPresented: $showsSheetPresentation,
                               background: background,
                               hasGrabber: hasGrabber,
                               hasMaskView: hasMaskView,
                               isFullScreen: isFullScreen,
                               detents: detents) {
                VStack {
                    background.frame(height: 48)
                    List {
                        Button {
                            showsSheetPresentation = false
                        } label: {
                            Text("Close")
                        }
                        
                        ForEach(0..<100) { index in
                            Text("\(index)")
                        }
                    }
                }
            }
        }
    }
    
    static var previews: some View {
        SheetPresentationDemo()
#if !os(tvOS)
        SheetPresentationDemo()
            .preferredColorScheme(.dark)
#endif
    }
}
