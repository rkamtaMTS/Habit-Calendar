//
//  HabitDetailsViewController.swift
//  Active
//
//  Created by Tiago Maia Lopes on 02/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData
import JTAppleCalendar

class HabitDetailsViewController: UIViewController {

    // MARK: Properties

    /// The habit presented by this controller.
    var habit: HabitMO!

    /// The habit's ordered challenge entities to be displayed.
    /// - Note: This array mustn't be empty. The existence of challenges is ensured
    ///         in the habit's creation and edition process.
    private var challenges: [DaysChallengeMO]! {
        didSet {
            // Store the initial and final calendar dates.
            initialDate = challenges.first!.fromDate!
            finalDate = challenges.last!.toDate!
        }
    }

    /// The initial calendar date.
    private var initialDate: Date!

    /// The final calendar date.
    private var finalDate: Date!

    /// The habit storage used to manage the controller's habit.
    var habitStorage: HabitStorage!

    /// The persistent container used by this store to manage the
    /// provided habit.
    var container: NSPersistentContainer!

    /// The month header view, with the month label and next/prev buttons.
    @IBOutlet weak var monthHeader: MonthHeaderView! {
        didSet {
            monthTitleLabel = monthHeader.monthLabel
            nextMonthButton = monthHeader.nextButton
            previousMonthButton = monthHeader.previousButton
        }
    }

    /// The month title label in the calendar's header.
    private weak var monthTitleLabel: UILabel!

    /// The next month header button.
    private weak var nextMonthButton: UIButton!

    /// The previous month header button.
    private weak var previousMonthButton: UIButton!

    //    /// View holding the prompt to ask the user if the activity
//    /// was executed in the current day.
//    @IBOutlet weak var promptView: UIView!

//    /// The positive prompt button.
//    @IBOutlet weak var positivePromptButton: UIButton!

//    /// The negative prompt button.
//    @IBOutlet weak var negativePromptButton: UIButton!

    /// The cell's reusable identifier.
    private let cellIdentifier = "Habit day cell id"

    /// The calendar view showing the habit days.
    /// - Note: The collection view will show a range with
    ///         the Habit's first days until the last ones.
    @IBOutlet weak var calendarView: JTAppleCalendarView!

    // MARK: ViewController Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        checkDependencies()
        // Get the habit's challenges to display in the calendar.
        challenges = getChallenges(from: habit)

        // Configure the calendar.
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self

        title = habit.name
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Configure the appearance of the prompt view.
//        handlePrompt()
    }

    // MARK: Actions

    @IBAction func deleteHabit(_ sender: UIButton) {
        // Alert the user to see if the deletion is really wanted:

        // Declare the alert.
        let alert = UIAlertController(
            title: "Delete",
            message: """
Are you sure you want to delete this habit? Deleting this habit makes all the history \
information unavailable.
""",
            preferredStyle: .alert
        )
        // Declare its actions.
        alert.addAction(UIAlertAction(title: "delete", style: .destructive) { _ in
            // If so, delete the habit using the container's viewContext.
            // Pop the current controller.
            self.habitStorage.delete(
                self.habit, from:
                self.container.viewContext
            )
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "cancel", style: .default))

        // Present it.
        present(alert, animated: true)
    }

    @IBAction func savePromptResult(_ sender: UIButton) {
        guard let currentHabitDay = habit.getCurrentDay() else {
            assertionFailure(
                "Inconsistency: There isn't a current habit day but the prompt is being displayed."
            )
            return
        }

        currentHabitDay.managedObjectContext?.perform {
//            if sender === self.positivePromptButton {
//                // Mark it as executed.
//                currentHabitDay.wasExecuted = true
//            } else if sender === self.negativePromptButton {
//                // Mark is as non executed.
//                currentHabitDay.wasExecuted = false
//            }

            // Save the result.
            try? currentHabitDay.managedObjectContext?.save()

            DispatchQueue.main.async {
                // Hide the prompt header.
                self.handlePrompt()
                // Reload calendar to show the executed day.
                self.calendarView.reloadData()
            }
        }
    }

    // MARK: Imperatives

    /// Asserts on the values of the main controller's dependencies.
    private func checkDependencies() {
        // Assert on the required properties to be injected
        // (habit, habitStorage, container and the calendar header views):
        assert(
            habit != nil,
            "Error: the needed habit wasn't injected."
        )
        assert(
            habitStorage != nil,
            "Error: the needed habitStorage wasn't injected."
        )
        assert(
            container != nil,
            "Error: the needed container wasn't injected."
        )
        assert(
            monthTitleLabel != nil,
            "Error: the month title label wasn't set."
        )
        assert(
            nextMonthButton != nil,
            "Error: the next month button wasn't set."
        )
        assert(
            previousMonthButton != nil,
            "Error: the previous month button wasn't set."
        )
    }

    /// Gets the challenges from the passed habit ordered by the fromDate property.
    /// - Returns: The habit's ordered challenges.
    private func getChallenges(from habit: HabitMO) -> [DaysChallengeMO] {
        // Declare and configure the fetch request.
        let request: NSFetchRequest<DaysChallengeMO> = DaysChallengeMO.fetchRequest()
        request.predicate = NSPredicate(format: "habit = %@", habit)
        request.sortDescriptors = [NSSortDescriptor(key: "fromDate", ascending: true)]

        // Fetch the results.
        let results = (try? container.viewContext.fetch(request)) ?? []

        // Assert on the values, the habit must have at least one challenge entity.
        assert(!results.isEmpty, "Inconsistency: A habit entity must always have at least one challenge entity.")

        return results
    }

    /// Gets the challenge matching a given date.
    /// - Note: The challenge is found if the date is in between or is it's begin or final.
    /// - Returns: The challenge entity, if any.
    private func getChallenge(from date: Date) -> DaysChallengeMO? {
        // Try to get the matching challenge by filtering through the habit's fetched ones.
        // The challenge matches when the passed date or is in between,
        // or is one of the challenge's limit dates (begin or end).
        return challenges.filter {
            date.isInBetween($0.fromDate!, $0.toDate!) || date == $0.fromDate! || date == $0.toDate!
        }.first
    }

    /// Show the prompt view if today is a day(HabitDayMO) being tracked
    /// by the app.
    private func handlePrompt() {
        // Try to get a habit day for today.
        if let currentDay = habit.getCurrentDay(),
            currentDay.wasExecuted == false {
            // Configure the appearance of the prompt.
//            promptView.isHidden = false
        } else {
//            promptView.isHidden = true
        }
    }
}

extension HabitDetailsViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {

    // MARK: JTAppleCalendarViewDataSource Methods

    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        return ConfigurationParameters(
            startDate: initialDate,
            endDate: finalDate
        )
    }

    // MARK: JTAppleCalendarViewDelegate Methods

    func calendar(
        _ calendar: JTAppleCalendarView,
        cellForItemAt date: Date,
        cellState: CellState,
        indexPath: IndexPath
    ) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(
            withReuseIdentifier: cellIdentifier,
            for: indexPath
        )

        guard let dayCell = cell as? CalendarDayCell else {
            assertionFailure("Couldn't get the expected details calendar cell.")
            return cell
        }
        handleAppearanceOfCell(dayCell, using: cellState)

        return dayCell
    }

    func calendar(
        _ calendar: JTAppleCalendarView,
        willDisplay cell: JTAppleCell,
        forItemAt date: Date,
        cellState: CellState,
        indexPath: IndexPath
    ) {
        guard let dayCell = cell as? CalendarDayCell else {
            assertionFailure("Couldn't get the expected details calendar cell.")
            return
        }
        handleAppearanceOfCell(dayCell, using: cellState)
    }

    func calendar(
        _ calendar: JTAppleCalendarView,
        shouldSelectDate date: Date,
        cell: JTAppleCell?,
        cellState: CellState
    ) -> Bool {
        return false
    }

    /// Configures the appearance of a given cell when it's about to be displayed.
    /// - Parameters:
    ///     - cell: The cell being displayed.
    ///     - cellState: The cell's state.
    private func handleAppearanceOfCell(
        _ cell: CalendarDayCell,
        using cellState: CellState
    ) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.dayTitleLabel.text = cellState.text

            // Try to get the matching challenge for the current date.
            if getChallenge(from: cellState.date) != nil {
                // If there's a challenge, show cell as being part of it.
                cell.backgroundColor = HabitMO.Color(rawValue: habit.color)?.getColor()
                cell.dayTitleLabel.textColor = .white

                if cellState.date.isInToday {
                    cell.circleView.backgroundColor = .white
                    cell.dayTitleLabel.textColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1)
                } else if cellState.date.isFuture {
                    // Days to be completed in the future should have a less bright color.
                    cell.backgroundColor = cell.backgroundColor?.withAlphaComponent(0.5)
                }
            }
        } else {
            cell.dayTitleLabel.text = ""
            cell.backgroundColor = .white
        }
    }
}
