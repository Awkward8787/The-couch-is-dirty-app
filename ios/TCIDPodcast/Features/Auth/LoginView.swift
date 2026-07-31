import SwiftUI

struct LoginView: View {
    @Environment(AuthService.self) private var auth
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: TCIDSpacing.lg) {
                        Text("Sign In")
                            .font(TCIDTypography.largeTitle)
                            .foregroundStyle(TCIDColors.textPrimary)
                        Text("Use your tcidpodcast.com account to post.")
                            .font(TCIDTypography.body)
                            .foregroundStyle(TCIDColors.textSecondary)

                        TextField("Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .padding(TCIDSpacing.md)
                            .background(TCIDColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))

                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .padding(TCIDSpacing.md)
                            .background(TCIDColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))

                        if let error = auth.lastError {
                            Text(error)
                                .font(TCIDTypography.caption)
                                .foregroundStyle(TCIDColors.destructive)
                        }

                        Button {
                            Task {
                                do {
                                    try await auth.signIn(email: email, password: password)
                                    dismiss()
                                } catch {}
                            }
                        } label: {
                            Text(auth.isSubmitting ? "Signing In…" : "Sign In")
                                .font(TCIDTypography.headline)
                                .foregroundStyle(Color.black)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: TCIDSpacing.touchTarget)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))
                        }
                        .disabled(auth.isSubmitting || email.isEmpty || password.isEmpty)
                    }
                    .padding(TCIDSpacing.lg)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthService())
}
