//
//  Date+Utils.swift
//  Active
//
//  Created by Tiago Maia Lopes on 09/06/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// Adds Utilities used by the app to the Date type.
extension Date {

    // MARK: Properties

    /// The date's components according to the system's calendar.
    var components: DateComponents {
        return getCurrentCalendar().dateComponents(
            [.second, .minute, .hour, .day, .month, .year],
            from: self
        )
    }

    /// Indicates if the date is in today or not.
    var isInToday: Bool {
        return getCurrentCalendar().isDateInToday(self)
    }

    /// Indicates if the date is in the future or not.
    var isFuture: Bool {
        return timeIntervalSinceNow > 0
    }

    /// Indicates if the date is in the past or not.
    var isPast: Bool {
        return timeIntervalSinceNow < 0
    }

    // MARK: Imperatives

    /// Gets the configured current calendar.
    private func getCurrentCalendar() -> Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        return calendar
    }

    /// Gets a new date representing the beginning of the current date's day value.
    /// - Returns: the current date at midnight (beginning of day).
    func getBeginningOfDay() -> Date {
        return getCurrentCalendar().startOfDay(for: self)
    }

    /// Gets a new date representing the end of the current date's day value.
    /// - Returns: the current date at the end of the day (23:59 PM).
    func getEndOfDay() -> Date {
        // Declare the components to calculate the end of the current date's day.
        var components = DateComponents()
        components.day = 1
        // One day (24:00:00) minus one second (23:59:59). Resulting in the end
        // of the previous day.
        components.second = -1

        let dayAtEnd = getCurrentCalendar().date(byAdding: components, to: getBeginningOfDay())

        // Is there a mistake with the computation of the date?
        assert(dayAtEnd != nil, "Date+Utils -- getEndOfDay: the computation of the end of the day couldn't be performed.")

        return dayAtEnd!
    }

    /// Creates a new date by adding the asked number of minutes.
    /// - Parameter numberOfMinutes: The number of minutes to be
    ///                              added to the date.
    /// - Returns: A new date with the minutes added.
    func byAddingMinutes(_ numberOfMinutes: Int) -> Date? {
        return getCurrentCalendar().date(
            byAdding: .minute,
            value: numberOfMinutes,
            to: self
        )
    }

    /// Creates a new date by adding the asked number of days.
    /// - Parameter numberOfDays: The number of days to be added to the date.
    /// - Returns: A new date with the days added.
    func byAddingDays(_ numberOfDays: Int) -> Date? {
        return getCurrentCalendar().date(
            byAdding: .day,
            value: numberOfDays,
            to: self
        )
    }

    /// Creates a new date by adding the asked number of years.
    /// - Parameter numberOfYears: The number of years to be added.
    /// - Returns: A new date with the added years.
    func byAddingYears(_ numberOfYears: Int) -> Date? {
        return getCurrentCalendar().date(
            byAdding: .year,
            value: numberOfYears,
            to: self
        )
    }

    /// Calculates the difference in days between the receiver and the passed
    /// date.
    /// - Note: If the difference is negative, it means its n days
    ///         before the receiver.
    /// - Returns: The difference of days being an integer number.
    func getDifferenceInDays(from date: Date) -> Int {
        return getCurrentCalendar().dateComponents(
            [.day],
            from: self,
            to: date
        ).day ?? 0
    }
}

/// Adds some common formatter factories used by the controllers
/// to display dates in an specific format.
extension DateFormatter {

    /// Creates a new DateFormatter used to display notification fire times.
    /// - Returns: The FireTime date formatter.
    static func makeFireTimeDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm"

        return formatter
    }

}
