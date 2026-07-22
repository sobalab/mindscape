import SwiftUI

/// A therapist the user could book. Static in the prototype.
struct Professional: Identifiable, Hashable {
    let id = UUID()
    let initials: String
    let name: String
    let specialties: [String]
}

struct ConnectSupportScreen: View {
    var onBack: () -> Void = {}
    @State private var providerCode = ""
    @State private var requestSent = false

    private let professionals = [
        Professional(initials: "SM", name: "Sarah M.", specialties: ["sleep", "stress"]),
        Professional(initials: "JK", name: "James K.", specialties: ["OCD", "anxiety"]),
        Professional(initials: "DK", name: "Dr. Kim",  specialties: ["ADHD", "CBT"]),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                BackLink { onBack() }
                    .padding(.leading, -10)
                    .padding(.bottom, 14)

                ScreenTitle(first: "Connect", second: "support")
                    .padding(.bottom, 30)

                SectionHeader("YOUR HEALTHCARE PROVIDER").padding(.bottom, 14)
                linkCard.padding(.bottom, 14)

                Text("Your provider will need a Mindscape account.")
                    .font(.custom(PJS.bold, size: 13, relativeTo: .footnote))
                    .foregroundStyle(Color.mutedViolet)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 34)

                SectionHeader("RECOMMENDED PROFESSIONALS").padding(.bottom, 14)
                professionalsCard
            }
            .padding(.horizontal, Theme.screenInset)
            .padding(.bottom, Theme.tabBarClearance)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .mindscapeBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var linkCard: some View {
        PromptCard {
            VStack(alignment: .leading, spacing: 0) {
                Badge(text: "LINK AN EXISTING PROVIDER").padding(.bottom, 18)

                Text("Already working with a therapist? Connect their account to share your journal insights and receive prescribed exercises.")
                    .font(.custom(PJS.extraBold, size: 18, relativeTo: .body))
                    .foregroundStyle(Color.mutedViolet)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 22)

                // The inner field sits on the page background, not the card fill.
                TextField("", text: $providerCode, prompt:
                    Text("enter provider code or email...")
                        .foregroundStyle(Color.fieldPlaceholder))
                    .font(.custom(PJS.bold, size: 16, relativeTo: .callout))
                    .foregroundStyle(.textPrimary)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.horizontal, 22)
                    .padding(.top, 20)
                    .padding(.bottom, 55)   // Figma's field box is 95pt tall
                    .background {
                        let shape = RoundedRectangle(cornerRadius: Theme.cardRadius)
                        shape.fill(Color.backgroundTop).overlay {
                            shape.strokeBorder(.tagStrokeUnactive, lineWidth: 3)
                        }
                    }
                    .padding(.bottom, 24)

                PrimaryButton(title: requestSent ? "Request Sent" : "Send Request",
                              showsArrow: !requestSent,
                              isEnabled: !providerCode.isEmpty && !requestSent) {
                    requestSent = true
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 22)
        }
    }

    private var professionalsCard: some View {
        PanelCard {
            VStack(spacing: 0) {
                ForEach(Array(professionals.enumerated()), id: \.element.id) { index, person in
                    ProfessionalRow(person: person)
                        .overlay(alignment: .top) {
                            if index > 0 { RowDivider() }
                        }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
    }
}

struct ProfessionalRow: View {
    let person: Professional

    var body: some View {
        HStack(spacing: 14) {
            Text(person.initials)
                .font(.custom(PJS.semibold, size: 18, relativeTo: .body))
                .foregroundStyle(.textPrimary)
                .frame(width: 55, height: 55)
                .background(Color.connectedEnd.opacity(0.2), in: .circle)

            VStack(alignment: .leading, spacing: 5) {
                Text(person.name)
                    .msStyle(.msCardTitle, tracking: 0.32)
                    .foregroundStyle(.white)
                Text(person.specialties.joined(separator: "  ∙  "))
                    .font(.custom(PJS.semibold, size: 16, relativeTo: .callout))
                    .foregroundStyle(Color.chipInactiveText)
            }

            Spacer(minLength: 8)

            Button {} label: {
                HStack(spacing: 8) {
                    Text("book")
                        .font(.custom(PJS.semibold, size: 16, relativeTo: .callout))
                        .lineLimit(1)
                    ArrowGlyph(size: 18)
                }
                .fixedSize()
                .foregroundStyle(.textPrimary)
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 9)
                .background {
                    let shape = RoundedRectangle(cornerRadius: 20)
                    shape.fill(LinearGradient(colors: [Color.bookStart, Color.bookEnd],
                                              startPoint: .leading, endPoint: .trailing))
                        .overlay { shape.strokeBorder(.textMuted, lineWidth: 1) }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Book with \(person.name)")
        }
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack { ConnectSupportScreen() }
        .mindscapeBackground()
        .environment(AppModel())
}
