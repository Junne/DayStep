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
    
    func readStepCount() {
        
        let endDate = NSDate()
        let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitMonth, value: -1, toDate: endDate, options: nil)
        
        let weightSampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        let query = HKSampleQuery(sampleType: weightSampleType, predicate: predicate, limit: 0, sortDescriptors: nil, resultsHandler: {
            (query, results, error) in
            if results == nil {
                println("There was an error running the query: \(error)")
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                var dailyAVG:Double = 0
                for steps in results as! [HKQuantitySample]
                {
                    // add values to dailyAVG
                    dailyAVG += steps.quantity.doubleValueForUnit(HKUnit.countUnit())
                    println(dailyAVG)
                    println(steps)
                }
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
        
        if let birthDay = healthKitStore.dateOfBirthWithError(&error) {
            let today = NSDate()
            let calendar = NSCalendar.currentCalendar()
            let differenceComponents = NSCalendar.currentCalendar().components(.CalendarUnitYear, fromDate: birthDay, toDate: today, options: NSCalendarOptions(0))
            age = differenceComponents.year
        }
        if error != nil {
            println("Error reading Birthday: \(error)")
        }
        
        var biologicalSex:HKBiologicalSexObject? = healthKitStore.biologicalSexWithError(&error)
        if error != nil {
            println("Error reading Biological Sex:\(error)")
        }
        
        var bloodType:HKBloodTypeObject? = healthKitStore.bloodTypeWithError(&error)
        if error != nil {
            
            println("Error reading Blood Type: \(error)")
        }
        return(age, biologicalSex, bloodType)
    }
   
}
