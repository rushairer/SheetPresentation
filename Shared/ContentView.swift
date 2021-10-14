//
//  ContentView.swift
//  Shared
//
//  Created by Abenx on 2021/10/13.
//

import SwiftUI
import SheetPresentation

struct ContentView: View {
    @State private var showsSheetPresentation: Bool = false
    
    @State private var hasGrabber: Bool = true
    @State private var hasMaskView: Bool = false
    @State private var isFullScreen: Bool = false
    
    @State private var detents: [SheetPresentationDetent] = DetentsType.ml.detents
    
    @State private var detentsType: DetentsType = .ml
    
#if os(tvOS)
    @FocusState private var focusedField: Field?
#endif
    enum Field: Hashable {
        case show
        case close
    }
    
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
#if os(tvOS)
                    focusedField = .show
#endif

                } label: {
                    Text("Show SheetPresentation")
                }
#if os(tvOS)
                .focused($focusedField, equals: .close)
#endif
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
                Button {
                    showsSheetPresentation = false
#if os(tvOS)
                    focusedField = .close
#endif

                } label: {
                    Text("Close")
#if os(macOS)
                        .animation(nil)
#endif
                }
                
#if os(tvOS)
                .focused($focusedField, equals: .show)
#endif
                .padding()
                
                List(0..<100) { index in
                    Text("\(index)")
                }
            }
            
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
