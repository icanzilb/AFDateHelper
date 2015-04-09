//
//  AF+Date+Extension.swift
//
//  Version 1.1
//
//  Created by Melvin Rivera on 7/15/14.
//  Copyright (c) 2014. All rights reserved.
//  Updated to Swift 1.2 by Marin Todorov

import Foundation

enum DateFormat {
    case ISO8601, DotNet, RSS, AltRSS
    case Custom(String)
}

extension NSDate {

    // MARK: Intervals In Seconds
    private struct TimeInterval {
        static let minuteInSeconds: Double = 60
        static let hourInSeconds: Double = 3600
        static let dayInSeconds: Double = 86400
        static let weekInSeconds: Double = 604800
        static let yearInSeconds: Double = 31556926
    }
    
    // MARK: Components
    private static let allComponentFlags: NSCalendarUnit = (.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitWeekOfMonth | .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond | .CalendarUnitWeekOfYear | .CalendarUnitWeekday | .CalendarUnitWeekOfYear)
    
    private class func components(#fromDate: NSDate) -> NSDateComponents! {
        return NSCalendar.currentCalendar().components(self.allComponentFlags, fromDate: fromDate)
    }
    
    public var components: NSDateComponents {
        return NSDate.components(fromDate: self)!
    }
    
    // MARK: Date From String
    
    convenience init(fromString string: String, format: DateFormat)
    {
        if string.isEmpty {
            self.init()
            return
        }
        
        let string = string as NSString
        
        switch format {
            
            case .DotNet:
                
                // Expects "/Date(1268123281843)/"
                let startIndex = string.rangeOfString("(").location + 1
                let endIndex = string.rangeOfString(")").location
                let range = NSRange(location: startIndex, length: endIndex-startIndex)
                let milliseconds = (string.substringWithRange(range) as NSString).longLongValue
                let interval = NSTimeInterval(milliseconds / 1000)
                self.init(timeIntervalSince1970: interval)
            
            case .ISO8601:
                
                var s = string
                if string.hasSuffix(" 00:00") {
                    s = s.substringToIndex(s.length-6) + "GMT"
                } else if string.hasSuffix("Z") {
                    s = s.substringToIndex(s.length-1) + "GMT"
                }
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
                if let date = formatter.dateFromString(string as String) {
                    self.init(timeInterval:0, sinceDate:date)
                } else {
                    self.init()
                }
                
            case .RSS:
                
                var s  = string
                if string.hasSuffix("Z") {
                    s = s.substringToIndex(s.length-1) + "GMT"
                }
                let formatter = NSDateFormatter()
                formatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss ZZZ"
                if let date = formatter.dateFromString(string as String) {
                    self.init(timeInterval:0, sinceDate:date)
                } else {
                    self.init()
                }
            
            case .AltRSS:
                
                var s  = string
                if string.hasSuffix("Z") {
                    s = s.substringToIndex(s.length-1) + "GMT"
                }
                let formatter = NSDateFormatter()
                formatter.dateFormat = "d MMM yyyy HH:mm:ss ZZZ"
                if let date = formatter.dateFromString(string as String) {
                    self.init(timeInterval:0, sinceDate:date)
                } else {
                    self.init()
                }
            
            case .Custom(let dateFormat):
                
                let formatter = NSDateFormatter()
                formatter.dateFormat = dateFormat
                if let date = formatter.dateFromString(string as String) {
                    self.init(timeInterval:0, sinceDate:date)
                } else {
                    self.init()
                }
        }
    }
     
    
    
    // MARK: Comparing Dates
    
    func isEqualToDateIgnoringTime(date: NSDate) -> Bool
    {
        let comp1 = NSDate.components(fromDate: self)
        let comp2 = NSDate.components(fromDate: date)
        return ((comp1.year == comp2.year) && (comp1.month == comp2.month) && (comp1.day == comp2.day))
    }
    
    func isToday() -> Bool
    {
        return self.isEqualToDateIgnoringTime(NSDate())
    }
    
    func isTomorrow() -> Bool
    {
        return self.isEqualToDateIgnoringTime(NSDate().dateByAddingDays(1))
    }
    
    func isYesterday() -> Bool
    {
        return self.isEqualToDateIgnoringTime(NSDate().dateBySubtractingDays(1))
    }
    
    func isSameWeekAsDate(date: NSDate) -> Bool
    {
        let comp1 = NSDate.components(fromDate: self)
        let comp2 = NSDate.components(fromDate: date)
        // Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
        if comp1.weekOfYear != comp2.weekOfYear {
            return false
        }
        // Must have a time interval under 1 week
        return abs(self.timeIntervalSinceDate(date)) < TimeInterval.weekInSeconds
    }
    
    func isThisWeek() -> Bool
    {
        return self.isSameWeekAsDate(NSDate())
    }
    
    func isNextWeek() -> Bool
    {
        let interval: NSTimeInterval = NSDate().timeIntervalSinceReferenceDate + TimeInterval.weekInSeconds
        let date = NSDate(timeIntervalSinceReferenceDate: interval)
        return self.isSameYearAsDate(date)
    }
    
    func isLastWeek() -> Bool
    {
        let interval: NSTimeInterval = NSDate().timeIntervalSinceReferenceDate - TimeInterval.weekInSeconds
        let date = NSDate(timeIntervalSinceReferenceDate: interval)
        return self.isSameYearAsDate(date)
    }
    
    func isSameYearAsDate(date: NSDate) -> Bool
    {
        let comp1 = NSDate.components(fromDate: self)
        let comp2 = NSDate.components(fromDate: date)
        return (comp1.year == comp2.year)
    }
    
    func isThisYear() -> Bool
    {
        return self.isSameYearAsDate(NSDate())
    }
    
    func isNextYear() -> Bool
    {
        let comp1 = NSDate.components(fromDate: self)
        let comp2 = NSDate.components(fromDate: NSDate())
        return (comp1.year == comp2.year + 1)
    }
    
    func isLastYear() -> Bool
    {
        let comp1 = NSDate.components(fromDate: self)
        let comp2 = NSDate.components(fromDate: NSDate())
        return (comp1.year == comp2.year - 1)
    }
    
    func isEarlierThanDate(date: NSDate) -> Bool
    {
        return self.earlierDate(date) == self
    }
    
    func isLaterThanDate(date: NSDate) -> Bool
    {
        return self.laterDate(date) == self
    }
    
  
    // MARK: Adjusting Dates
    
    func dateByAddingDays(days: Int) -> NSDate
    {
        let interval: NSTimeInterval = self.timeIntervalSinceReferenceDate + TimeInterval.dayInSeconds * Double(days)
        return NSDate(timeIntervalSinceReferenceDate: interval)
    }
    
    func dateBySubtractingDays(days: Int) -> NSDate
    {
        let interval: NSTimeInterval = self.timeIntervalSinceReferenceDate - TimeInterval.dayInSeconds * Double(days)
        return NSDate(timeIntervalSinceReferenceDate: interval)
    }
    
    func dateByAddingHours(hours: Int) -> NSDate
    {
        let interval: NSTimeInterval = self.timeIntervalSinceReferenceDate + TimeInterval.hourInSeconds * Double(hours)
        return NSDate(timeIntervalSinceReferenceDate: interval)
    }
    
    func dateBySubtractingHours(hours: Int) -> NSDate
    {
        let interval: NSTimeInterval = self.timeIntervalSinceReferenceDate - TimeInterval.hourInSeconds * Double(hours)
        return NSDate(timeIntervalSinceReferenceDate: interval)
    }
    
    func dateByAddingMinutes(minutes: Int) -> NSDate
    {
        let interval: NSTimeInterval = self.timeIntervalSinceReferenceDate + TimeInterval.minuteInSeconds * Double(minutes)
        return NSDate(timeIntervalSinceReferenceDate: interval)
    }
    
    func dateBySubtractingMinutes(minutes: Int) -> NSDate
    {
        let interval: NSTimeInterval = self.timeIntervalSinceReferenceDate - TimeInterval.minuteInSeconds * Double(minutes)
        return NSDate(timeIntervalSinceReferenceDate: interval)
    }
    
    func dateAtStartOfDay() -> NSDate
    {
        let components = self.components
        components.hour = 0
        components.minute = 0
        components.second = 0
        return NSCalendar.currentCalendar().dateFromComponents(components)!
    }
    
    func dateAtEndOfDay() -> NSDate
    {
        let components = self.components
        components.hour = 23
        components.minute = 59
        components.second = 59
        return NSCalendar.currentCalendar().dateFromComponents(components)!
    }
    
    func dateAtStartOfWeek() -> NSDate
    {
        let flags: NSCalendarUnit = .CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitWeekOfYear | .CalendarUnitWeekday
        var components = NSCalendar.currentCalendar().components(flags, fromDate: self)
        components.weekday = 1 // Sunday
        components.hour = 0
        components.minute = 0
        components.second = 0
        return NSCalendar.currentCalendar().dateFromComponents(components)!
    }
    
    func dateAtEndOfWeek() -> NSDate
    {
        let flags :NSCalendarUnit = .CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitWeekOfYear | .CalendarUnitWeekday
        var components = NSCalendar.currentCalendar().components(flags, fromDate: self)
        components.weekday = 7 // Sunday
        components.hour = 0
        components.minute = 0
        components.second = 0
        return NSCalendar.currentCalendar().dateFromComponents(components)!
    }
    
    
    // MARK: Retrieving Intervals
    
    func minutesAfterDate(date: NSDate) -> Int
    {
        let interval = self.timeIntervalSinceDate(date)
        return Int(interval / TimeInterval.minuteInSeconds)
    }
    
    func minutesBeforeDate(date: NSDate) -> Int
    {
        let interval = date.timeIntervalSinceDate(self)
        return Int(interval / TimeInterval.minuteInSeconds)
    }
    
    func hoursAfterDate(date: NSDate) -> Int
    {
        let interval = self.timeIntervalSinceDate(date)
        return Int(interval / TimeInterval.hourInSeconds)
    }
    
    func hoursBeforeDate(date: NSDate) -> Int
    {
        let interval = date.timeIntervalSinceDate(self)
        return Int(interval / TimeInterval.hourInSeconds)
    }
    
    func daysAfterDate(date: NSDate) -> Int
    {
        let interval = self.timeIntervalSinceDate(date)
        return Int(interval / TimeInterval.dayInSeconds)
    }
    
    func daysBeforeDate(date: NSDate) -> Int
    {
        let interval = date.timeIntervalSinceDate(self)
        return Int(interval / TimeInterval.dayInSeconds)
    }
    
    
    // MARK: Decomposing Dates
    
    var nearestHour: Int {
        let halfHour = TimeInterval.minuteInSeconds * 30
        var interval = self.timeIntervalSinceReferenceDate
        if  self.seconds < 30 {
            interval -= halfHour
        } else {
            interval += halfHour
        }
        let date = NSDate(timeIntervalSinceReferenceDate: interval)
        return date.hour
    }
    
    var year: Int { return self.components.year  }
    var month: Int { return self.components.month }
    var week: Int { return self.components.weekOfYear }
    var day: Int { return self.components.day }
    var hour: Int { return self.components.hour }
    var minute: Int { return self.components.minute }
    var seconds: Int { return self.components.second }
    var weekday: Int { return self.components.weekday }
    var nthWeekday: Int { return self.components.weekdayOrdinal } //// e.g. 2nd Tuesday of the month is 2
    var monthDays: Int { return NSCalendar.currentCalendar().rangeOfUnit(.CalendarUnitDay, inUnit: .CalendarUnitMonth, forDate: self).length }
    
    var firstDayOfWeek: Int {
        let distanceToStartOfWeek = TimeInterval.dayInSeconds * Double(self.components.weekday - 1)
        let interval: NSTimeInterval = self.timeIntervalSinceReferenceDate - distanceToStartOfWeek
        return NSDate(timeIntervalSinceReferenceDate: interval).day
    }
    var lastDayOfWeek: Int {
        let distanceToStartOfWeek = TimeInterval.dayInSeconds * Double(self.components.weekday - 1)
        let distanceToEndOfWeek = TimeInterval.dayInSeconds * Double(7)
        let interval: NSTimeInterval = self.timeIntervalSinceReferenceDate - distanceToStartOfWeek + distanceToEndOfWeek
        return NSDate(timeIntervalSinceReferenceDate: interval).day
    }
    
    var isWeekday: Bool {
        return !self.isWeekend
    }
    var isWeekend: Bool {
        let range = NSCalendar.currentCalendar().maximumRangeOfUnit(.CalendarUnitWeekday)
        return (self.weekday == range.location || self.weekday == range.length)
    }
    

    // MARK: To String
    
    var stringValue: String {
        return self.toString(dateStyle: .ShortStyle, timeStyle: .ShortStyle, doesRelativeDateFormatting: false)
    }
    
    func toString(#format: DateFormat) -> String
    {
        var dateFormat: String
        switch format {
            case .DotNet:
                let offset = NSTimeZone.defaultTimeZone().secondsFromGMT / 3600
                let nowMillis = 1000 * self.timeIntervalSince1970
                return  "/Date(\(nowMillis)\(offset))/"
            case .ISO8601:
                dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            case .RSS:
                dateFormat = "EEE, d MMM yyyy HH:mm:ss ZZZ"
            case .AltRSS:
                dateFormat = "d MMM yyyy HH:mm:ss ZZZ"
            case .Custom(let string):
                dateFormat = string
        }
        let formatter = NSDateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.stringFromDate(self)
    }

    func toString(#dateStyle: NSDateFormatterStyle, timeStyle: NSDateFormatterStyle, doesRelativeDateFormatting: Bool = false) -> String
    {
        let formatter = NSDateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        formatter.doesRelativeDateFormatting = doesRelativeDateFormatting
        return formatter.stringFromDate(self)
    }
    
    var relativeTimeString: String
    {
        let time = self.timeIntervalSince1970
        let now = NSDate().timeIntervalSince1970
        
        let seconds = now - time
        let minutes = round(seconds/60)
        let hours = round(minutes/60)
        let days = round(hours/24)
        
        if seconds < 10 {
            return NSLocalizedString("just now", comment: "relative time")
        } else if seconds < 60 {
            return NSLocalizedString("\(Int(seconds)) seconds ago", comment: "relative time")
        }
        
        if minutes < 60 {
            if minutes == 1 {
                return NSLocalizedString("1 minute ago", comment: "relative time")
            } else {
                return NSLocalizedString("\(Int(minutes)) minutes ago", comment: "relative time")
            }
        }
        
        if hours < 24 {
            if hours == 1 {
                return NSLocalizedString("1 hour ago", comment: "relative time")
            } else {
                return NSLocalizedString("\(Int(hours)) hours ago", comment: "relative time")
            }
        }
        
        if days < 7 {
            if days == 1 {
                return NSLocalizedString("1 day ago", comment: "relative time")
            } else {
                return NSLocalizedString("\(Int(days)) days ago", comment: "relative time")
            }
        }
        
        return self.stringValue
    }
    
       
    var weekdayString: String {
        return NSDateFormatter().weekdaySymbols[self.weekday-1] as! String
    }
    
    var shortWeekdayString: String {
        return NSDateFormatter().shortWeekdaySymbols[self.weekday-1] as! String
    }
    
    var veryShortWeekdayString: String {
        return NSDateFormatter().veryShortWeekdaySymbols[self.weekday-1] as! String
    }
    
    var monthString: String {
        return NSDateFormatter().monthSymbols[self.month-1] as! String
    }
    
    var shortMonthString: String {
        return NSDateFormatter().shortMonthSymbols[self.month-1] as! String
    }
    
    var veryShortMonthString: String {
        return NSDateFormatter().veryShortMonthSymbols[self.month-1] as! String
    }
   
}

