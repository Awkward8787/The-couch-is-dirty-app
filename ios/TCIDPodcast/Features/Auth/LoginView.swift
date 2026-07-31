import SwiftUI

private enum LoginIntent: String, CaseIterable, Identifiable {
    case listener
    #if DEBUG
    case administrator
    #endif

    var id: String { rawValue }

    var title: String {
        switch self {
        case .listener: "Listener"
        #if DEBUG
        case .administrator: "Administrator"
        #endif
        }
    }
}

struct LoginView: View {
    @Environment(AuthService.self) private var auth
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var intent: LoginIntent = .listener
    @State private var email = ""
    @State private var password = ""
    @State private var formError: String?
    @State private var recoveryEmail = ""
    @State private var showsForgotPassword = false
    @State private var recoveryMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                TCIDColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: TCIDSpacing.lg) {
                        TCIDWordmark(logoSize: 32, showsTagline: false, alignment: .leading)

                        Text("Sign In")
                            .font(TCIDTypography.largeTitle)
                            .foregroundStyle(TCIDColors.textPrimary)

                        #if DEBUG
                        Picker("Sign in as", selection: $intent) {
                            ForEach(LoginIntent.allCases) { option in
                                Text(option.title).tag(option)
                            }
                        }
                        .pickerStyle(.segmented)
                        .accessibilityLabel("Sign in as")
                        #endif

                        Text(intentSubtitle)
                            .font(TCIDTypography.body)
                            .foregroundStyle(TCIDColors.textSecondary)

                        TextField("Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .padding(TCIDSpacing.md)
                            .background(TCIDColors.surfaceElevated)
                            .overlay(
                                RoundedRectangle(cornerRadius: TCIDRadius.md)
                                    .stroke(TCIDColors.border, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))

                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .padding(TCIDSpacing.md)
                            .background(TCIDColors.surfaceElevated)
                            .overlay(
                                RoundedRectangle(cornerRadius: TCIDRadius.md)
                                    .stroke(TCIDColors.border, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))

                        Button("Forgot password?") {
                            recoveryEmail = email
                            recoveryMessage = nil
                            showsForgotPassword = true
                        }
                        .font(TCIDTypography.caption.weight(.medium))
                        .foregroundStyle(TCIDColors.accent)

                        if let error = formError ?? auth.lastError {
                            Text(error)
                                .font(TCIDTypography.caption)
                                .foregroundStyle(TCIDColors.destructive)
                        }

                        TCIDPrimaryButton(title: submitButtonTitle) {
                            Task { await submitSignIn() }
                        }
                        .disabled(auth.isSubmitting || email.isEmpty || password.isEmpty)
                        .opacity(auth.isSubmitting || email.isEmpty || password.isEmpty ? 0.5 : 1)

                        #if DEBUG
                        if intent == .administrator {
                            adminDashboardSection
                        }
                        #endif
                    }
                    .padding(TCIDSpacing.lg)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showsForgotPassword) {
                forgotPasswordSheet
            }
            .onAppear {
                clearCredentials()
            }
            .onChange(of: intent) { _, _ in
                formError = nil
                clearCredentials()
            }
        }
    }

    private var forgotPasswordSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: TCIDSpacing.lg) {
                Text("We’ll email a link to reset your password.")
                    .font(TCIDTypography.body)
                    .foregroundStyle(TCIDColors.textSecondary)

                TextField("Email", text: $recoveryEmail)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .padding(TCIDSpacing.md)
                    .background(TCIDColors.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: TCIDRadius.md)
                            .stroke(TCIDColors.border, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: TCIDRadius.md))

                if let recoveryMessage {
                    Text(recoveryMessage)
                        .font(TCIDTypography.caption)
                        .foregroundStyle(TCIDColors.textSecondary)
                }

                TCIDPrimaryButton(title: auth.isSubmitting ? "Sending…" : "Send Reset Link") {
                    Task { await sendRecovery() }
                }
                .disabled(auth.isSubmitting || recoveryEmail.isEmpty)
                .opacity(auth.isSubmitting || recoveryEmail.isEmpty ? 0.5 : 1)

                Spacer()
            }
            .padding(TCIDSpacing.lg)
            .background(TCIDColors.background.ignoresSafeArea())
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { showsForgotPassword = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var intentSubtitle: String {
        switch intent {
        case .listener:
            "Use your tcidpodcast.com account to post on the feed."
        #if DEBUG
        case .administrator:
            "Creator dashboard access. Enter your Appwrite credentials — nothing is prefilled."
        #endif
        }
    }

    private var submitButtonTitle: String {
        if auth.isSubmitting {
            #if DEBUG
            return intent == .administrator ? "Signing In as Admin…" : "Signing In…"
            #else
            return "Signing In…"
            #endif
        }
        #if DEBUG
        return intent == .administrator ? "Sign In as Administrator" : "Sign In"
        #else
        return "Sign In"
        #endif
    }

    #if DEBUG
    private var adminDashboardSection: some View {
        VStack(alignment: .leading, spacing: TCIDSpacing.sm) {
            Divider().background(TCIDColors.border)

            Text("Creator dashboard")
                .font(TCIDTypography.caption.weight(.semibold))
                .foregroundStyle(TCIDColors.textSecondary)

            Text("Manage episodes, feed, and RSS sync in the web admin dashboard (opens in Safari).")
                .font(TCIDTypography.caption)
                .foregroundStyle(TCIDColors.textSecondary)

            Button {
                openURL(AppConfig.adminDashboardURL)
            } label: {
                HStack(spacing: 6) {
                    Text("Open Admin Dashboard")
                    Image(systemName: "arrow.up.right")
                        .font(.caption.weight(.semibold))
                }
                .font(TCIDTypography.body.weight(.medium))
                .foregroundStyle(TCIDColors.accent)
            }
            .accessibilityLabel("Open admin dashboard in Safari")
        }
        .padding(.top, TCIDSpacing.sm)
    }
    #endif

    private func clearCredentials() {
        email = ""
        password = ""
    }

    private func submitSignIn() async {
        formError = nil
        do {
            try await auth.signIn(email: email, password: password)

            #if DEBUG
            if intent == .administrator {
                guard auth.communityRole == .admin else {
                    formError =
                        "Signed in, but this account is not on the administrators team. Contact support if you need admin access."
                    return
                }
                openURL(AppConfig.adminDashboardURL)
            }
            #endif

            dismiss()
        } catch {
            // AuthService sets lastError
        }
    }

    private func sendRecovery() async {
        recoveryMessage = nil
        do {
            try await auth.sendPasswordRecovery(email: recoveryEmail)
            recoveryMessage = "If an account exists for that email, a reset link is on the way."
        } catch {
            recoveryMessage = auth.lastError ?? error.localizedDescription
        }
    }
}

#Preview("Listener") {
    LoginView()
        .environment(AuthService())
}
