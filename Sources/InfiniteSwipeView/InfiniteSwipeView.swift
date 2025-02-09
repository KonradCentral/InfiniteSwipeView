//
//  SwipeView.swift
//  Plan&Journal
//
//  Created by Dan on 24/06/2023.
//

import SwiftUI


public enum Orientation {
    case horizontal
    case vertical
}

@available(macOS 11, *)
public struct InfiniteSwipeView<Content:View>: View {
    @Binding var index: Int
    var orientation: Orientation
    @State var isLocked: Bool
    let content: (Int) -> Content
    
    @State private var internalIndex = 2
    private let maxIndex = 3, middleIndex = 2
    @State private var step: Int = 0
    
    
    public init(index: Binding<Int>, orientation: Orientation = .horizontal, isLocked: Bool = false, @ViewBuilder content: @escaping (Int) -> Content) {
        self._index = index
        self.content = content
        self.orientation = orientation
        self.isLocked = isLocked
    }
    
    public var body: some View {
        tabViewWrapper {
            self.content(index - 1).tag(1)
            self.content(index + 0).tag(2)
                .onDisappear {
                    internalIndex = middleIndex
                    index += step
                    step = 0
                }
            self.content(index + 1).tag(3)
        }
    }
    
    
    @ViewBuilder
    private func tabViewWrapper<V: View>(@ViewBuilder content: @escaping () -> V) -> some View {
        GeometryReader { proxy in
            if self.orientation == .horizontal {
                TabView(selection: $internalIndex) {
                    content()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .contentShape(Rectangle())
                        .gesture(isLocked ? DragGesture() : nil)
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif
                .coordinateSpace(name: "scroll")
                .onChange(of: internalIndex) { newValue in
                    if [1, 3].contains(newValue) {
                        step = newValue - middleIndex
                    }
                }
            }
            else {
                TabView(selection: $internalIndex) {
                    content()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .rotationEffect(.degrees(-90))
                        .contentShape(Rectangle())
                        .gesture(isLocked ? DragGesture() : nil)
                }
                .frame(width: proxy.size.height, height: proxy.size.width)
                .rotationEffect(.degrees(90), anchor: .topLeading)
                .offset(x: proxy.size.width)
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif
                .coordinateSpace(name: "scroll")
                .onChange(of: internalIndex) { newValue in
                    if [1, 3].contains(newValue) {
                        step = newValue - middleIndex
                    }
                }
            }
        }
    }
}

@available(macOS 11, *)
struct InfiniteSwipeView_Previews: PreviewProvider {
    static var previews: some View {
        @State var index = 0
        VStack {
            InfiniteSwipeView(index: $index, orientation: .horizontal) { _ in
                Text("<-- Drag -->")
            }
            Divider()
            InfiniteSwipeView(index: $index, orientation: .vertical) { _ in
                Text("Vertical 👆")
            }
        }
    }
}
