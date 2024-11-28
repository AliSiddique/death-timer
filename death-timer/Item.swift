//
//  Item.swift
//  death-timer
//
//  Created by Ali Siddique on 11/12/24.
//

import Foundation
import SwiftData
import SwiftUI
import SwiftData

@Model
final class UserData {
    var name: String
    var birthDate: Date
    var timerStartDate: Date?
    var predictedDeathDate: Date?
    var country: String?   
    var createdAt: Date
    var quizResponses: [QuizResponse]
    var bucketList: [BucketListItem]
    var reflections: [Reflection]
    var lifeLesson: [LifeLesson]
    var timeDisplayMode: TimeDisplayMode = TimeDisplayMode.split
    
    init(
        name: String = "",
        birthDate: Date = Date(),
        timerStartDate: Date? = nil,
        quizResponses: [QuizResponse] = []
    ) {
        self.name = name
        self.birthDate = birthDate
        self.timerStartDate = timerStartDate
        self.createdAt = Date()
        self.quizResponses = quizResponses
        self.bucketList = []
        self.reflections = []
        self.lifeLesson = []
        self.timeDisplayMode = .split
    }
}

@Model
final class BucketListItem {
    var title: String
    var content: String
    var category: BucketListCategory
    var targetDate: Date?
    var isCompleted: Bool
    var completedDate: Date?
    var photos: [PhotoMemory]
    var priority: Priority
    var reflection: String?
    var order: Int
    
    init(title: String, content: String, category: BucketListCategory, priority: Priority) {
        self.title = title
        self.content = content
        self.category = category
        self.priority = priority
        self.isCompleted = false
        self.photos = []
        self.order = 0
    }
}

enum BucketListCategory: String, Codable, CaseIterable {
    case personal
    case health
    case career
    case relationships
    case travel
    case experiences
    case skills
    case financial
}

@Model
final class Reflection {
    var content: String
    var date: Date
    var type: ReflectionType
    var photos: [PhotoMemory]
    var associatedLesson: LifeLesson?
    var tags: [String]
    var urges: Int? // For tracking urges/temptations
    var energyLevel: Int? // 1-10 scale
    var triggers: [String]?
    
    init(content: String, type: ReflectionType) {
        self.content = content
        self.date = Date()
        self.type = type
        self.photos = []
        self.tags = []
    }
}

enum ReflectionType: String, Codable, CaseIterable {
    case daily
    case weekly
    case milestone
    case breakthrough
    case setback
    case gratitude
}

@Model
final class PhotoMemory {
    var title: String
    var imageData: Data
    var date: Date
    var location: String?
    var tags: [String]
    var associatedReflection: Reflection?
    
    init(title: String, imageData: Data) {
        self.title = title
        self.imageData = imageData
        self.date = Date()
        self.tags = []
    }
}

@Model
final class LifeLesson {
    var title: String
    var content: String
    var date: Date
    var category: LessonCategory
    var relatedPhotos: [PhotoMemory]
    var impact: ImpactLevel
    var tags: [String]
    var actionSteps: [String]?
    
    init(title: String, content: String, category: LessonCategory, impact: ImpactLevel) {
        self.title = title
        self.content = content
        self.date = Date()
        self.category = category
        self.impact = impact
        self.relatedPhotos = []
        self.tags = []
    }
}

enum LessonCategory: String, Codable, CaseIterable {
    case mindset
    case triggers
    case relationships
    case selfControl
    case habits
    case recovery
    case growth
}

enum ImpactLevel: String, Codable, CaseIterable {
    case transformative
    case significant
    case moderate
    case minor
}

enum Priority: String, Codable, CaseIterable {
    case high
    case medium
    case low
}



@Model
final class QuizResponse {
    var question: String
    var answer: String
    var category: QuizCategory
    var date: Date
    
    init(question: String, answer: String, category: QuizCategory) {
        self.question = question
        self.answer = answer
        self.category = category
        self.date = Date()
    }
}

enum QuizCategory: String, Codable, CaseIterable {
    case motivation
    case triggers
    case goals
    case lifestyle
}

enum TimeDisplayMode: String, Codable, CaseIterable {
    case split    // shows years, months, days separately
    case years    // shows total in years
    case months   // shows total in months
    case days     // shows total in days
    case hours    // shows total in hours
    case minutes  // shows total in minutes
    case seconds  // shows total in seconds
}
