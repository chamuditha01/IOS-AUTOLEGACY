//
//  AlertsView.swift
//  IOS Clinic App
//
//  Notification / alerts feed — matches "Alerts" Figma screen.
//  Unread items show a filled blue dot; tapping any row marks it as read.
//

import SwiftUI

// MARK: - Model

struct AlertItem: Identifiable {
    let id         = UUID()
    let title:     String
    let body:      String
    let time:      String
    var isUnread:  Bool
}

// MARK: - View

struct AlertsView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var expandedAlertIDs: Set<UUID> = []

    @State private var alerts: [AlertItem] = [
        AlertItem(title: "Lab reports released",
                  body:  "Your recent test results are now available. Tap to view your lab report summary.",
                  time:  "9:36 AM",
                  isUnread: true),
        AlertItem(title: "Appointment booked",
                  body:  "Your appointment has been confirmed. Please arrive 10 minutes early.",
                  time:  "9:00 AM",
                  isUnread: false),
        AlertItem(title: "Your appointment time is",
                  body:  "Reminder: your appointment is scheduled for today at 10:30 AM in Room 3B.",
                  time:  "9:00 AM",
                  isUnread: false),
        AlertItem(title: "Lab reports released",
                  body:  "That's what I'm talking about!",
                  time:  "8:58 AM",
                  isUnread: false),
        AlertItem(title: "Queue update",
                  body:  "You are now 2nd in the queue. Please proceed to the waiting area.",
                  time:  "8:45 AM",
                  isUnread: false),
    ]

    var body: some View {
        ZStack(alignment: .top) {
            Color.clinicSurface.ignoresSafeArea()

            VStack(spacing: 0) {
                navBar
                alertList
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        ZStack {
            Text("Alerts")
                .font(Font.navTitleSize)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)

            HStack {
                Button { dismiss() } label: {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 34, height: 34)
                        Image(systemName: "chevron.left")
                            .font(.app(size: 14, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                    .frame(width: AppSize.minTapTarget, height: AppSize.minTapTarget)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer()

                // Mark all read button
                if alerts.contains(where: { $0.isUnread }) {
                    Button {
                        withAnimation {
                            for i in alerts.indices { alerts[i].isUnread = false }
                        }
                    } label: {
                        Text("Mark all read")
                            .font(.app(size: 14, weight: .medium))
                            .foregroundStyle(Color.clinicPrimary)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, AppSpacing.xs)
                }
            }
            .padding(.horizontal, AppSpacing.md)
        }
        .frame(height: AppSize.minTapTarget)
        .padding(.top, AppSpacing.xs)
        .background(Color.clinicSurface)
    }

    // MARK: - Alert List

    private var alertList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppSpacing.sm) {
                ForEach(alerts.indices, id: \.self) { i in
                    AlertRow(
                        item: alerts[i],
                        isExpanded: expandedAlertIDs.contains(alerts[i].id)
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            alerts[i].isUnread = false

                            if expandedAlertIDs.contains(alerts[i].id) {
                                expandedAlertIDs.remove(alerts[i].id)
                            } else {
                                expandedAlertIDs.insert(alerts[i].id)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.xs)
            .padding(.bottom, AppSpacing.xxxl)
        }
    }
}

// MARK: - Alert Row

private struct AlertRow: View {
    let item:     AlertItem
    let isExpanded: Bool
    let onTap:    () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: AppSpacing.md) {

                // Unread dot (keeps width reserved so text aligns regardless)
                Circle()
                    .fill(item.isUnread ? Color.clinicPrimary : Color.clear)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)

                // Text block
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(item.title)
                            .font(.app(size: 15, weight: item.isUnread ? .bold : .semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(isExpanded ? nil : 1)

                        Spacer()

                        Text(item.time)
                            .font(.app(size: 13))
                            .foregroundStyle(.secondary)
                    }

                    Text(item.body)
                        .font(.app(size: 13))
                        .foregroundStyle(.secondary)
                        .lineLimit(isExpanded ? nil : 2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Chevron
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.app(size: 12, weight: .semibold))
                    .foregroundStyle(Color(.systemGray3))
                    .padding(.top, 4)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(item.isUnread ? Color.clinicPrimary.opacity(0.06) : Color.clinicSurfaceSecond)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .stroke(Color.clinicSeparator.opacity(item.isUnread ? 0.08 : 0.18), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AlertsView()
    }
}
