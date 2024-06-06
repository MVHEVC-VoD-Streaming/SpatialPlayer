//
//  FontConfig.swift
//  SpatialPlayer
//
//  Created by Bruski on 2024/6/6.
//

import SwiftUI

struct TitleFontKey: EnvironmentKey {
    static let defaultValue: Font = .system(size: 28, weight: .bold)
}

struct ContentFontKey: EnvironmentKey {
    static let defaultValue: Font = .system(size: 18)
}

extension EnvironmentValues {
    var titleFont: Font {
        get { self[TitleFontKey.self] }
        set { self[TitleFontKey.self] = newValue }
    }

    var contentFont: Font {
        get { self[ContentFontKey.self] }
        set { self[ContentFontKey.self] = newValue }
    }
}


struct TitleFontModifier: ViewModifier {
    @Environment(\.titleFont) var titleFont


    func body(content: Content) -> some View {
        content.font(titleFont)
    }
}

struct ContentFontModifier: ViewModifier {
    @Environment(\.contentFont) var contentFont

    func body(content: Content) -> some View {
        content.font(contentFont)
    }
}

extension View {
    func titleFont(size: CGFloat) -> some View {
        self.modifier(TitleFontModifier())
    }

    func contentFont(size: CGFloat) -> some View {
        self.modifier(ContentFontModifier())
    }
}
