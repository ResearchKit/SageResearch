//: Playground - noun: a place where people can play

import UIKit

struct Item : Codable {
    public let identifier : String
    public let sectionIdentifier : String?
    public var detail: String?
}

struct Section : Codable {
    public let identifier: String
    public var detail: String?
}

struct List : Codable {
    public let items: [Item]
    public let sections: [Section]?
}

extension Substring {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

func parseMarkup(_ markup: String) -> List {
    var items: [Item] = []
    var sections: [Section] = []
    var currentSection: Section?
    var currentItem: Item?
    var hasSectionWithDetail: Bool = false
    
    let lines = markup.split(separator: "\n")
    for line in lines {
        if line.hasPrefix("#"), let idx = line.range(of: "#")?.upperBound {
            if let section = currentSection {
                sections.append(section)
            }
            if let item = currentItem {
                items.append(item)
            }
            let identifier = line.suffix(from: idx).trim()
            currentSection = Section(identifier: identifier, detail: nil)
            currentItem = nil
        }
        else if line.hasPrefix("(") {
            if currentItem != nil {
                currentItem!.detail = line.trim()
            } else {
                currentSection?.detail = line.trim()
                hasSectionWithDetail = true
            }
        }
        else {
            let identifier = line.trim()
            if identifier.count > 0 {
                if let item = currentItem {
                    items.append(item)
                }
                currentItem = Item(identifier: identifier, sectionIdentifier: currentSection?.identifier, detail: nil)
            }
        }
    }
    
    if let section = currentSection {
        sections.append(section)
    }
    if let item = currentItem {
        items.append(item)
    }
    
    return List(items: items, sections: hasSectionWithDetail ? sections : nil)
}

let markup =
"""
#Cognitive
(mental processing)

Amnesia
Compulsions
Confusion in the evening hours
Dementia
Difficulty doing complex tasks
Difficulty in multitasking
Difficulty thinking and understanding
Feeling like somebody is behind you
Hallucinations
Hand-eye coordination
Short term memory loss
(difficulty remembering)


#Facial

Jaw stiffness
Reduced facial expression
Blank stare
Drooling


#GI and Urinary

Constipation
Dribbling or leaking of urine
Frequent urination at night


#Mood

Anger
Anxiety
Apathy
(lack of interest or enthusiasm)
Depression
(low mood disorder)


#Muscular and Motor

Dexterity
Difficulty standing
Difficulty walking
Difficulty walking backwards
Difficulty with bodily movements
Falling
Freezing
Grip strength
Involuntary movements


#Nasal

Distorted sense of smell
Loss of smell


#Sleep

Acting out in your dreams
Daytime sleepiness
Early awakening
Night terrors
Nightmares
Restless sleep
Sleep disturbances
Yawning a lot


#Speech

Impaired voice
Soft speech
Voice box spasms
Talking fast


#Vision

Difficulty focusing visually


#Whole body

Aches and pains
Dizziness
Fatigue
Feeling cold
Feeling hot
Poor balance
Restlessness
Tingling of extremities
(hands, arms, or feet)
"""

let list = parseMarkup(markup)

// Check if the identifiers are unique
let itemsRef = Dictionary(grouping: list.items, by: { $0.identifier })
let itemsDuplicates = itemsRef.filter { $1.count > 1 }.map { $0.value.first!.identifier }
if itemsDuplicates.count > 0 {
    assertionFailure("Identifiers are not unique: \(itemsDuplicates)")
}
let sectionsRef = Dictionary(grouping: list.items, by: { $0.identifier })
let sectionsDuplicates = itemsRef.filter { $1.count > 1 }.map { $0.value.first!.identifier }
if sectionsDuplicates.count > 0 {
    assertionFailure("Identifiers are not unique: \(sectionsDuplicates)")
}

// Encode to json
var jsonEncoder = JSONEncoder()
jsonEncoder.outputFormatting = .prettyPrinted
let jsonData = try? jsonEncoder.encode(list)
var json = String(data: jsonData!, encoding: .utf8)!
var jsonString = ""

// The details is not encoded *after* the identifier (not really sure why) so force the desired pretty-print order.
var detailsLine: String?
for line in json.split(separator: "\n") {
    
    if line.contains("detail"), line.hasSuffix(","), let idx = line.range(of: ",", options: [.backwards], range: nil, locale: nil)?.lowerBound {
        detailsLine = String(line.prefix(upTo: idx))
    } else {
        jsonString.append("\(line)")
        if let details = detailsLine, !line.hasSuffix(",") {
            jsonString.append(",\n\(details)")
            detailsLine = nil
        }
        jsonString.append("\n")
    }
}

print(jsonString)




