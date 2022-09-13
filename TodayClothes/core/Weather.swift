//
//  WeatherData.swift
//  TodayClothes
//
//  Created by Hosung Lim on 2022/09/09.
//


import Foundation

struct WeatherResponse : Decodable {
    let weather : [Weather]
    let main : Main
    let name : String
}

struct Main : Decodable {
    let temp : Double
    let temp_min : Double
    let temp_max : Double
    let feels_like : Double
}

struct Weather : Decodable {
    let id: Int
    let main: String
    let description :String
    let icon: String
}

