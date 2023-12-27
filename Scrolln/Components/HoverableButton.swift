//
//  HoverableButton.swift
//  Scrolln
//
//  Created by Luca Archidiacono on 27.12.2023.
//

import Foundation
import SwiftUI

struct HoverableButton: View {
	@State private var isHovered = false

	enum Action {
		case quit
		case custom(text: String, shortcut: KeyboardShortcut)
	}

	struct KeyboardShortcut {
		let key: KeyEquivalent
		let modifier: EventModifiers

		static let quit = KeyboardShortcut(key: "q", modifier: .command)

		var description: String {
			return "\(modifier.description)\(key.character.uppercased())"
		}

		init(key: Character, modifier: EventModifiers) {
			self.key = KeyEquivalent(key)
			self.modifier = modifier
		}
	}

	let action: Action
	let onTap: () -> Void

	var body: some View {
		Button(action: onTap) {
			HStack {
				Text(buttonText)
				Spacer()
				Text(shortcut.description)
			}
			.foregroundColor(isHovered ? .white : .accentColor)
			.padding()
			.background(isHovered ? Color.accentColor : Color.clear)
			.cornerRadius(8)
		}
		.buttonStyle(PlainButtonStyle())
		.onHover { hovering in
			withAnimation {
				isHovered = hovering
			}
		}
		.keyboardShortcut(shortcut.key, modifiers: shortcut.modifier)
	}

	private var buttonText: String {
		switch action {
		case .quit: return "Quit"
		case .custom(let text, _): return text
		}
	}

	private var shortcut: KeyboardShortcut {
		switch action {
		case .quit: return .quit
		case .custom(_, let shortcut): return shortcut
		}
	}
}

extension EventModifiers {
	var description: String {
		var descriptions: [String] = []
		if contains(.command) {
			descriptions.append("⌘")
		}
		if contains(.control) {
			descriptions.append("⌃")
		}
		if contains(.option) {
			descriptions.append("⌥")
		}
		if contains(.shift) {
			descriptions.append("⇧")
		}
		return descriptions.joined()
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		List {
			HoverableButton(action: .quit) {
				print("Tapped on quit")
			}
			HoverableButton(action: .custom(text: "Custom", shortcut: .init(key: "c", modifier: .command))) {
				print("Tapped on custom")
			}
		}
	}
}

