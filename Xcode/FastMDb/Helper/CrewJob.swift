//
//  CrewJob.swift
//
//  Created by Daniel on 5/15/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

enum CrewJob: String, CaseIterable {
    case Director
    case Cinematographer = "Director of Photography"
    case Screenplay
    case Teleplay
    case Writer
    case OriginalWriter = "Original Film Writer"
    case Score = "Original Music Composer"
    case Music
    case Novel
    case Story
    case ShortStory = "Short Story"
}
