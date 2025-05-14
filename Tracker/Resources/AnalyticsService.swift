//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Ilya Grishanov on 14.05.2025.
//

import Foundation
import YandexMobileMetrica

final class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    func report(event: String, screen: String, item: String? = nil) {
        var params: [AnyHashable: Any] = [
            "event": event,
            "screen": screen
        ]
        
        if let item = item {
            params["item"] = item
        }
        
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: \(error.localizedDescription)")
        })
        
        print("Analytics Event: \(params)")
    }
    static func activate() {
        let configuration = YMMYandexMetricaConfiguration(apiKey: "236fc182-9bff-43a0-917b-c0b67d89af3f")
        YMMYandexMetrica.activate(with: configuration!)
    }
}
