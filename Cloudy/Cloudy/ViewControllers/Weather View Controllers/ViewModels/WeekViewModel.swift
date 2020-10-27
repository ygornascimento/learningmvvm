//
//  WeekViewModel.swift
//  Cloudy
//
//  Created by Ygor Nascimento on 26/10/20.
//  Copyright © 2020 Cocoacasts. All rights reserved.
//

import UIKit

struct WeekViewModel {
    
    let weatherData: [WeatherDayData]
    private let dateFormatter = DateFormatter()
    
    var numberOfSections: Int {
        1
    }
    
    var numberOfDays: Int {
        weatherData.count
    }
    
    func day(for index: Int) -> String {
        let weatherDayData = weatherData[index]
        dateFormatter.dateFormat = "EEEE"
        
        return dateFormatter.string(from: weatherDayData.time)
    }
    
    func date(for index: Int) -> String {
        let weatherDayData = weatherData[index]
        dateFormatter.dateFormat = "MMMM d"
        
        return dateFormatter.string(from: weatherDayData.time)
    }
    
    func temperature(for index: Int) -> String {
        let weatherDayData = weatherData[index]
        let min = format(temperature: weatherDayData.temperatureMin)
        let max = format(temperature: weatherDayData.temperatureMax)
        
        return "\(min) - \(max)"
    }
    
    func windSpeed(for index: Int) -> String {
        let weatherDayData = weatherData[index]
        let windSpeed = weatherDayData.windSpeed
        
        switch UserDefaults.unitsNotation {
            case .imperial:
                return String(format: "%.f MPH", windSpeed)
            case .metric:
                return String(format: "%.f KPH", windSpeed.toKPH)
        }
    }
    
    func image(for index: Int) -> UIImage? {
        let weatherDayData = weatherData[index]
        
        return UIImage.imageForIcon(with: weatherDayData.icon)
    }
    
    private func format(temperature: Double) -> String {
        switch UserDefaults.temperatureNotation {
            case .fahrenheit:
                return String(format: "%.0f ºF", temperature)
            case .celsius:
                return String(format: "%.0f ºC", temperature.toCelcius)
        }
    }
}
