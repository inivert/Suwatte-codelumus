//
//  Backup+Content.swift
//  Suwatte (iOS)
//
//  Created by Mantton on 2022-04-06.
//

import Foundation
import RealmSwift

extension StoredContent: Codable {
    enum CodingKeys: String, CodingKey {
        case id, sourceId, contentId, title, additionalTitles, additionalCovers, cover, creators, status
        case originalLanuguage, summary, adultContent, webUrl, properties, recommendedReadingMode, contentType, trackerInfo
        case acquisitionLink, streamable
    }

    convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id) ?? "" // Can be Null as it can also be set with the CID & SID
        sourceId = try container.decodeIfPresent(String.self, forKey: .sourceId) ?? UUID().uuidString
        contentId = try container.decode(String.self, forKey: .contentId)
        title = try container.decode(String.self, forKey: .title)
        cover = try container.decodeIfPresent(String.self, forKey: .cover) ?? ""
        if let covers = try container.decodeIfPresent(List<String>.self, forKey: .additionalCovers) {
            additionalCovers.append(objectsIn: covers)
        }
        if let titles = try container.decodeIfPresent(List<String>.self, forKey: .additionalTitles) {
            additionalTitles.append(objectsIn: titles)
        }
        if let creators = try container.decodeIfPresent(List<String>.self, forKey: .creators) {
            self.creators.append(objectsIn: creators)
        }
        status = try container.decodeIfPresent(ContentStatus.self, forKey: .status) ?? .UNKNOWN
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        adultContent = try container.decodeIfPresent(Bool.self, forKey: .adultContent) ?? false
        webUrl = try container.decodeIfPresent(String.self, forKey: .webUrl)
        if let props = try container.decodeIfPresent(List<StoredProperty>.self, forKey: .properties) {
            properties.append(objectsIn: props)
        }
        recommendedReadingMode = try container.decodeIfPresent(ReadingMode.self, forKey: .recommendedReadingMode) ?? .PAGED_MANGA
        contentType = try container.decodeIfPresent(ExternalContentType.self, forKey: .contentType) ?? .unknown
        if let info = try container.decodeIfPresent(Map<String, String>.self, forKey: .trackerInfo) {
            trackerInfo = info
        }

        acquisitionLink = try container.decodeIfPresent(String.self, forKey: .acquisitionLink)
        streamable = try container.decodeIfPresent(Bool.self, forKey: .streamable) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(sourceId, forKey: .sourceId)
        try container.encode(contentId, forKey: .contentId)
        try container.encode(title, forKey: .title)
        try container.encode(cover, forKey: .cover)
        try container.encode(additionalTitles, forKey: .additionalTitles)
        try container.encode(additionalCovers, forKey: .additionalCovers)
        try container.encode(creators, forKey: .creators)
        try container.encode(status, forKey: .status)
        try container.encode(summary, forKey: .summary)
        try container.encode(adultContent, forKey: .adultContent)
        try container.encode(webUrl, forKey: .webUrl)
        try container.encode(properties, forKey: .properties)
        try container.encode(recommendedReadingMode, forKey: .recommendedReadingMode)
        try container.encode(contentType, forKey: .contentType)
        try container.encode(trackerInfo, forKey: .trackerInfo)
        try container.encode(streamable, forKey: .streamable)
        try container.encode(acquisitionLink, forKey: .acquisitionLink)
    }
}

// MARK: Stored Tag

extension StoredTag: Codable {
    enum CodingKeys: String, CodingKey {
        case id, label, adultContent
    }

    convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        label = try container.decode(String.self, forKey: .label)
        adultContent = try container.decodeIfPresent(Bool.self, forKey: .adultContent) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(label, forKey: .label)
        try container.encode(adultContent, forKey: .adultContent)
    }
}

// MARK: StoredProperty

extension StoredProperty: Codable {
    enum Keys: String, CodingKey {
        case label, tags, id
    }

    convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.container(keyedBy: Keys.self)

        tags = try container.decode(List<StoredTag>.self, forKey: .tags)
        label = try container.decode(String.self, forKey: .label)
        id = try container.decode(String.self, forKey: .id)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)

        try container.encode(label, forKey: .label)
        try container.encode(tags, forKey: .tags)
        try container.encode(id, forKey: .id)
    }
}
