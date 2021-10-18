//
//  Teacher.swift
//  Apollo
//
//  Created by QUANG HUNG on 08/Oct/2021.
//

import Foundation

struct Teacher: Codable {
    let id, createdAt, updatedAt, deletedAt: String?
    let name, role, avatarLink, email: String?
    let teacherCode: String?
}

enum TeacherDto: Codable {
    case string(String)
    case teacherClass(Teacher)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(Teacher.self) {
            self = .teacherClass(x)
            return
        }
        throw DecodingError.typeMismatch(TeacherDto.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for TeacherDTO"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x):
            try container.encode(x)
        case .teacherClass(let x):
            try container.encode(x)
        }
    }
}
