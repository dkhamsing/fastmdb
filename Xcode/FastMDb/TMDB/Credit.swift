//
//  Credit.swift
//
//  Created by Daniel on 10/10/19.
//  Copyright © 2019 dkhamsing. All rights reserved.
//

struct Credit: Codable {
    var id: Int?
    var credit_id: String?

    var name: String?
    var original_name: String?

    var title: String?
    var original_title: String?

    var poster_path: String?
    var profile_path: String?

    var episode_count: Int?
    var first_air_date: String?

    var known_for_department: String?
    var known_for: [Media]?

    var movie_credits: Credits?
    var tv_credits: Credits?

    var vote_average: Double?
    var vote_count: Int?

    var biography: String?
    var birthday: String?
    var place_of_birth: String?
    var character: String?
    var deathday: String?
    var external_ids: ExternalIds?
    var genre_ids: [Int]?
    var original_language: String?
    var popularity: Double?
    var release_date: String?

    var images: Images?
    var tagged_images: ImageSearch?

    // Crew
    var job: String?

    // Aggregate Credits
    var roles: [Role]?
}
