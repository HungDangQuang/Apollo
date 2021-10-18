//
//  Course.swift
//  Apollo
//
//  Created by QUANG HUNG on 08/Oct/2021.
//

import Foundation

struct Course: Codable {
    let id, createdAt, updatedAt: String?
    let deletedAt: String?
    let courseCode, type: String?
    let desc: String?
    let room, startTime, endTime: String?
    let qrCode: String?
    let teacher: TeacherDto?
    let timesCheckin: String?
}

struct CourseList: Decodable  {
    let data: [Course]
}
