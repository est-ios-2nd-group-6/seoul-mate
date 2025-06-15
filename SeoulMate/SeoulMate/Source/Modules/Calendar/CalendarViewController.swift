//
//  CalendarViewController.swift
//  SeoulMate
//
//  Created by 하재준 on 6/10/25.
//

import UIKit
import CoreData

//TODO: - 이미 등록된 일정은 다르게 표시하기
class CalendarViewController: UIViewController {
    
    
    
    @IBOutlet weak var registerScheduleButton: UIButton!
    @IBOutlet weak var calendarView: UICalendarView!
    
    @IBAction func registerScheduleAction(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError()}
        let context = appDelegate.persistentContainer.viewContext
        let tour = Tour(context: context)
        tour.id = UUID()
        tour.createdAt = Date()
        tour.startDate = selectedDateObjects.first
        tour.endDate = selectedDateObjects.last
        
        for date in selectedDateObjects {
            let schedule = Schedule(context: context)
            schedule.id = UUID()
            schedule.date = date
            schedule.tour = tour
        }
        
        do {
            try context.save()
            //            performSegue(withIdentifier: "MapViewController", sender: tour)
        } catch {
            print(error)
        }
    }
    var selectedDays: [String] = []
    var rangeStart: Date?
    var selectedDateObjects: [Date] = []
    private var savedTourDates: Set<Date> = []
    private var SavedDates: [Date] = []
    
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy.MM.dd"
        return f
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let calendar = Calendar(identifier: .gregorian)
        calendarView.calendar = calendar
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.fontDesign = .default
        calendarView.delegate = self
        calendarView.tintColor = .main
        calendarView.fontDesign = .rounded
        
        registerScheduleButton.isHidden = true
        
        let dateSelection = UICalendarSelectionMultiDate(delegate: self)
        calendarView.selectionBehavior = dateSelection
        
        fetch()
        
    }
    
    func fetch() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Tour> = Tour.fetchRequest()
        do {
            let tours = try context.fetch(fetchRequest)
            print("총 Tour 개수: \(tours.count)")
            var allDates = Set<Date>()
            
            for tour in tours {
                if let days = tour.days as? Set<Schedule> {
                    for day in days {
                        if let d = day.date {
                            allDates.insert(d)
                        }
                    }
                }
            }
            
            savedTourDates = allDates
            SavedDates = allDates.sorted()
            
            let comps = savedTourDates.map {
                Calendar.current.dateComponents([.year, .month, .day], from: $0)
            }
            calendarView.reloadDecorations(forDateComponents: comps, animated: true)
            
            for t in tours {
                let title = t.title ?? ""
                let start = t.startDate?.description ?? ""
                let end   = t.endDate?.description   ?? ""
                let dayCount = t.days?.count ?? 0
                print("\(title) / \(start) ~ \(end) / \(dayCount)일")
            }
            
        } catch {
            print(error)
        }
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MapViewController,
           let tour = sender as? Tour {
            vc.tour = tour
        }
    }
    
    private func generateDates(from start: Date, to end: Date) -> [Date] {
        var dates: [Date] = []
        var current = start
        let calendar = Calendar(identifier: .gregorian)
        while current <= end {
            dates.append(current)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return dates
    }
    
    
}

extension CalendarViewController: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        let day = DateComponents(calendar: dateComponents.calendar, year: dateComponents.year, month: dateComponents.month, day: dateComponents.day)
        guard let date = Calendar.current.date(from: day) else { return nil }
        
        
        // 저장되어있는 여행일정 표시
        if let savedDate = Calendar.current.date(from: dateComponents),
           savedTourDates.contains(where: {
               Calendar.current.isDate($0, equalTo: savedDate, toGranularity: .day)
           }) {

            
            return .default(color: .systemBlue, size: .medium)

            
        }
        
        // 선택한 날짜에 표시
        if selectedDateObjects.count > 0 {
            if date == selectedDateObjects.first {
                return .customView {
                    let emoji = UILabel()
                    emoji.text = "🛫"
                    return emoji
                }
            } else if date == selectedDateObjects.last {
                return .customView {
                    let emoji = UILabel()
                    emoji.text = "🛬"
                    return emoji
                }
            }
        }
        return nil
    }
    
}

extension CalendarViewController: UICalendarSelectionMultiDateDelegate {
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didSelectDate dateComponents: DateComponents) {
        guard let tappedDate = Calendar.current.date(from: dateComponents) else { return }
        //        print("선택: \(dateComponents)")
        let oldComps = selectedDateObjects.map {
            Calendar.current.dateComponents([.year, .month, .day], from: $0)
        }
        registerScheduleButton.isHidden = false
        if rangeStart == nil {
            // 첫 탭: 시작일만 선택
            rangeStart = tappedDate
            selection.setSelectedDates([dateComponents], animated: true)
            selectedDateObjects = [tappedDate]
            let dateText = formatter.string(from: tappedDate)
            registerScheduleButton.setTitle("\(dateText) 당일 여행 등록", for: .normal)
        } else {
            // 두 번째 탭: 시작종료 사이 날짜 모두 생성
            let start = min(rangeStart!, tappedDate)
            let end   = max(rangeStart!, tappedDate)
            let dates = generateDates(from: start, to: end)
            // DateComponents 배열 생성
            let comps = dates.map {
                Calendar.current.dateComponents([.year, .month, .day], from: $0)
            }
            // 전체 날짜 한 번에 선택 (하이라이트)
            selection.setSelectedDates(comps, animated: true)
            selectedDateObjects = dates
            // 문자열 포맷으로 변환해 저장
            selectedDays = dates.map { formatter.string(from: $0) }
            
            let startText = formatter.string(from: start)
            let endText   = formatter.string(from: end)
            registerScheduleButton.setTitle("\(startText) ~ \(endText) 등록", for: .normal)
            
            rangeStart = nil
        }
        
        let newComps = selectedDateObjects.map {
            Calendar.current.dateComponents([.year, .month, .day], from: $0)
        }
        
        let allComps = Array(Set(oldComps + newComps))
        
        calendarView.reloadDecorations(forDateComponents: allComps, animated: true)
        
    }
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didDeselectDate dateComponents: DateComponents) {
        // 탭된 DateComponents → Date 변환
        let oldComps = selectedDateObjects.map {
            Calendar.current.dateComponents([.year, .month, .day], from: $0)
        }
        
        guard let tappedDate = Calendar.current.date(from: dateComponents) else { return }
        
        // 이전 선택 모두 지우고, 탭한 날짜를 새 시작일로 선택
        rangeStart = tappedDate
        selection.setSelectedDates([dateComponents], animated: true)
        
        selectedDateObjects = [tappedDate]
        selectedDays = [formatter.string(from: tappedDate)]
        let dateText = formatter.string(from: tappedDate)
        registerScheduleButton.setTitle("\(dateText) 당일 여행 등록", for: .normal)
        
        let newComps = selectedDateObjects.map {
            Calendar.current.dateComponents([.year, .month, .day], from: $0)
        }
        
        let allComps = Array(Set(oldComps + newComps))
        
        calendarView.reloadDecorations(forDateComponents: allComps, animated: true)
    }
    
    
}
