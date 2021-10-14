# SheetPresentation

![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/rushairer/SheetPresentation) ![GitHub](https://img.shields.io/github/license/rushairer/SheetPresentation) ![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/rushairer/SheetPresentation?include_prereleases) ![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/rushairer/SheetPresentation.svg)

SheetPresentation for SwiftUI. 
Multiple devices support: iOS, watchOS, tvOS, macOS, macCatalyst.

`NOT UISheetPresentationController wapped version.`

## Screenshots

<img src="https://github.com/rushairer/SheetPresentation/blob/demo/screenshot.gif" width="600"/>
<img src="https://raw.githubusercontent.com/rushairer/SheetPresentation/screenshots/screenshot_phone.gif" width="300"/><img src="https://raw.githubusercontent.com/rushairer/SheetPresentation/screenshots/screenshot_watch.gif" width="300"/>

## Overview

```swift
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
```
## Demo App

[DEMO](https://github.com/rushairer/SheetPresentation/tree/demo)

## LICENSE

[The MIT License (MIT)](./LICENSE)

