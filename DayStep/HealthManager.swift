//
//  HealthManager.swift
//  DayStep
//
//  Created by Junne on 9/4/15.
//  Copyright (c) 2015 Junne. All rights reserved.
//

import UIKit
import HealthKit

class HealthManager: NSObject {
    
    let healthKitStore:HKHealthStore = HKHealthStore()
    
    func authorizeHealthKit(completion:((success:Bool,error:NSError!) -> Void)!) {
        
        let healthKitTypesToRead = Set([
            
           HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth),
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBloodType),
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount),
            HKObjectType.workoutType()
            ])
        
        let healthKitTypesToWrite = Set([
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning),
            HKQuantityType.workoutType()
            ])
        
        if !HKHealthStore.isHealthDataAvailable() {
            let error = NSError(domain: "io.github.junne.DayStep", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if(completion != nil) {
                completion(success:false,error:error)
            }
            return
        }
        
        healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: healthKitTypesToRead) { (success, error) -> Void in
            if(completion != nil) {
                completion(success:success,error:error)
            }
        }
    }
    
    func readTodayStepCount(sampleType:HKSampleType,completion:((Int!,NSError!) -> Void)!) {
        
        let lastMidnight = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
        let nowDate = NSDate()
        let predicate = HKQuery.predicateForSamplesWithStartDate(lastMidnight, endDate:nowDate, options: .None)
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 0, sortDescriptors: nil) { (query, results, error) -> Void in
            if error != nil {
                print("There was an error running the query: \(error)")
                completion(0,error)
                return;
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                var todayStepCounts:Double = 0
                for steps in results as! [HKQuantitySample] {
                    todayStepCounts += steps.quantity.doubleValueForUnit(HKUnit.countUnit())
                }
                let todayStepCountsInt = Int(todayStepCounts)
                completion(todayStepCountsInt,error)
                print("Today Step Counts = \(todayStepCountsInt)")
            })
        }
        healthKitStore.executeQuery(query)
        
    }
    
    func read7DaysStepCounts(completion:(([NSDate: Int]!,NSError!)-> Void)!) {
        
        let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let preservedComponents: NSCalendarUnit = ([.Year, .Month, .Day])
        let midnight: NSDate! = calendar.dateFromComponents(calendar.components(preservedComponents, fromDate:now))
        let dailyInterval = NSDateComponents()
        dailyInterval.day = 1
        let tomorrow = calendar.dateByAddingUnit(NSCalendarUnit.Year, value: 1, toDate: midnight, options: [])
        let oneMonthAgo = calendar.dateByAddingUnit(NSCalendarUnit.Month, value: -1, toDate: midnight, options: [])
        let oneWeekAgo = calendar.dateByAddingUnit(NSCalendarUnit.Day, value: -6, toDate: midnight, options: [])
        
        let predicate = HKQuery.predicateForSamplesWithStartDate(oneWeekAgo, endDate: tomorrow, options: .None)
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType!,
            quantitySamplePredicate: predicate,
            options: HKStatisticsOptions.CumulativeSum,
            anchorDate: midnight,
            intervalComponents: dailyInterval)

            
        query.initialResultsHandler = { query, results, error -> Void in
            var data:[NSDate: Int] = [:]
            if error != nil {
                print(error)
            } else {
                
                results!.enumerateStatisticsFromDate(oneWeekAgo, toDate: midnight) { statistics, stop in
                    if let quantity = statistics.sumQuantity() {
                        let date = statistics.startDate
                        let value = Int(quantity.doubleValueForUnit(HKUnit.countUnit()))
                        data[date] = value
                    }
                }
            }
            completion(data,error)
        }
        healthKitStore.executeQuery(query)
        
    }
    
    func readStepCount() {
        
        let endDate = NSDate()
        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.Month, value: -1, toDate: endDate, options: [])
        let calendar = NSCalendar.currentCalendar()
        let preservedComponents: NSCalendarUnit = ([.Year, .Month, .Day])
        let midnigt:NSDate! = calendar.dateFromComponents(calendar.components(preservedComponents, fromDate: NSDate()))
        
        let lastMidnight = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
        
        let weightSampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let predicate = HKQuery.predicateForSamplesWithStartDate(lastMidnight, endDate: endDate, options: .None)
        
        let query = HKSampleQuery(sampleType: weightSampleType!, predicate: predicate, limit: 0, sortDescriptors: nil, resultsHandler: {
            (query, results, error) in
            if results == nil {
                print("There was an error running the query: \(error)")
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                var dailyAVG:Double = 0
                for steps in results as! [HKQuantitySample]
                {
                    // add values to dailyAVG
                    dailyAVG += steps.quantity.doubleValueForUnit(HKUnit.countUnit())
                    print(dailyAVG)
                    print(steps)
                }
                print("Today Step count = \(dailyAVG)")
            }
        })
        
        healthKitStore.executeQuery(query)
    }
    
//    func readStepCount() -> (stepCount: Int?) {
//        
//        let hkQuantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
//        let hkStepCountQuery = HKSampleQuery(sampleType: hkQuantityType, predicate: nil, limit: 1, sortDescriptors: nil) { (hkStepCountQuery, result, error) -> Void in
//            if error != nil {
//                return;
//            }
//            
//            let stepCount = result
//            return stepCount
//        }
//        
//
//    }
    
    func readProfile() -> (age:Int?, biologicalsex:HKBiologicalSexObject?, bloodtype:HKBloodTypeObject?) {
        
        var error:NSError?
        var age:Int?
        
        do {
            let birthDay = try healthKitStore.dateOfBirthWithError()
            let today = NSDate()
            let calendar = NSCalendar.currentCalendar()
            let differenceComponents = NSCalendar.currentCalendar().components(.Year, fromDate: birthDay, toDate: today, options: NSCalendarOptions(0))
            age = differenceComponents.year
        } catch var error1 as NSError {
            error = error1
        }
        if error != nil {
            print("Error reading Birthday: \(error)")
        }
        
        var biologicalSex:HKBiologicalSexObject?
        do {
            biologicalSex = try healthKitStore.biologicalSexWithError()
        } catch var error1 as NSError {
            error = error1
            biologicalSex = nil
        }
        if error != nil {
            print("Error reading Biological Sex:\(error)")
        }
        
        var bloodType:HKBloodTypeObject?
        do {
            bloodType = try healthKitStore.bloodTypeWithError()
        } catch var error1 as NSError {
            error = error1
            bloodType = nil
        }
        if error != nil {
            
            print("Error reading Blood Type: \(error)")
        }
        return(age, biologicalSex, bloodType)
    }
   
}
