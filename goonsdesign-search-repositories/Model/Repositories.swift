//
//  Repositories.swift
//  goonsdesign-search-repositories
//
//  Created by 黃子騰 on 2023/9/26.
//

import Foundation

struct Repositories:Codable{
    var items:[RepositoriesItem]
    var total_count:Int
}
class RepositoriesItem:Codable{
    var full_name:String
    var description:String?
    var language:String?
    var owner:RepositoriesOwner
    var stargazers_count:Int
    var watchers_count:Int
    var forks_count:Int
    var open_issues_count:Int
    var imageData:Data?
}
struct RepositoriesOwner:Codable{
    var avatar_url:String
}
