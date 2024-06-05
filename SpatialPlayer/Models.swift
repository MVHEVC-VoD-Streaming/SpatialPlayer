//
//  Models.swift
//  SpatialPlayer
//
//  Created by Bruski on 2024/6/5.
//

import Foundation

struct SessionData: Codable, CustomStringConvertible {
    let code: Int
    let data: SessionDetails
    let message: String

    var description: String {
        return """
        Code: \(code)
        Message: \(message)
        Data:
        \(data.description)
        """
    }
}

struct SessionDetails: Codable, CustomStringConvertible {
    let completeTime: String?
    let createTime: String
    let id: String
    let playlist: [PlaylistItem]
    let plistIdToIndexMap: [String: Int]
    let scoreMap: [String: Score]?
    let status: String
    let updateTime: String?
    let userId: String?

    enum CodingKeys: String, CodingKey {
        case completeTime = "complete_time"
        case createTime = "create_time"
        case id
        case playlist
        case plistIdToIndexMap = "plist_id_to_index_map"
        case scoreMap = "score_map"
        case status
        case updateTime = "update_time"
        case userId = "user_id"
    }

    var description: String {
        return """
        ID: \(id)
        Create Time: \(createTime)
        Status: \(status)
        Playlist Length: \(playlist.count)
        """
    }
}

struct PlaylistItem: Codable, CustomStringConvertible {
    let bitrate: String
    let ext: String
    let id: String
    let name: String
    let resolution: String
    let type: String
    let url: String

    var description: String {
        return """
        Name: \(name)
        Resolution: \(resolution)
        Type: \(type)
        URL: \(url)
        """
    }
}

struct Score: Codable {
    let depthQuality: Int
    let overallQoe: Int
    let videoQuality: Int
}
