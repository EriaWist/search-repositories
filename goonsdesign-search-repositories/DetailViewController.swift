//
//  DetailViewController.swift
//  goonsdesign-search-repositories
//
//  Created by 黃子騰 on 2023/9/26.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var language: UILabel!
    @IBOutlet weak var stars: UILabel!
    @IBOutlet weak var watch: UILabel!
    @IBOutlet weak var forks: UILabel!
    @IBOutlet weak var issue: UILabel!
    var repositoriesItem :RepositoriesItem? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = repositoriesItem?.owner.login
        self.titleLabel.text = repositoriesItem?.full_name
        if let imageData = repositoriesItem?.imageData{
            self.image.image = UIImage(data: imageData)
        }
        if let language = repositoriesItem?.language{
            self.language.text = "Written in \(language)"
        }
        
        
        self.stars.text = "\(String(describing: repositoriesItem!.stargazers_count)) stars"
        self.watch.text = "\(String(describing: repositoriesItem!.watchers_count)) watchers"
        self.forks.text = "\(String(describing: repositoriesItem!.forks_count)) forks"
        self.issue.text = "\(String(describing: repositoriesItem!.open_issues_count)) open issues"
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
