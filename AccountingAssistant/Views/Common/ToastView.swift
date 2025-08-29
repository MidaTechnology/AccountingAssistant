//
//  DetailView.swift
//  AccountingAssistant
//
//  Created by mathwallet on 2025/8/27.
//
import SwiftUI
import PopupView

struct ToastModifier: ViewModifier {
    @Binding var message: ToastMessage?
    
    func body(content: Content) -> some View {
        content.popup(item: $message) { value in
            ToastView(message: value)
        } customize: {
            $0
                .type(.floater(useSafeAreaInset: true))
                .position(.bottom)
                .closeOnTap(false)
                .closeOnTapOutside(false)
                .autohideIn(2)
        }
    }
}

extension View {
    func toast(_ message: Binding<ToastMessage?>) -> some View {
        modifier(ToastModifier(message: message))
    }
}


struct ToastView: View {
    @State var message: ToastMessage
    var body: some View {
        VStack(spacing: 8) {
            Text(message.text)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .foregroundStyle(Color.white)
        .background(message.isError ? Color.red : Color.accent)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

#Preview {
    Group {
        ToastView(message: ToastMessage(text: "Toast text"))
        ToastView(message: ToastMessage(error: AccountingError.unknown))
    }
}
