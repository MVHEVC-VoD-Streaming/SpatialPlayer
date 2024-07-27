//
//  Utils.swift
//  SpatialPlayer
//
//  Created by Sizhe on 7/27/24.
//

import Foundation

enum JSONError: Error {
    case conversionFailed(String)
}

func formatJSON(_ dict: [String: Any]) throws -> String {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        throw JSONError.conversionFailed("Failed to convert JSON data to string.")
    } catch {
        throw JSONError.conversionFailed(error.localizedDescription)
    }
}

func formatBitrate(_ bitrate: Double, unit: String = "bps") -> String {
    let confMap = [
        "bps": [
            "ratio": 1.0,
            "format": "%.0f"
        ],
        "kbps": [
            "ratio": 1_000.0,
            "format": "%.2f"
        ],
        "mbps": [
            "ratio": 1_000_000.0,
            "format": "%.2f"
        ]
    ]
    let conf = confMap[unit] ?? confMap["bps"]
    
    let _bitrate = bitrate / (conf?["ratio"] as! Double)
    return String(format: conf?["format"] as! String, _bitrate)
}
