//
//  NewsTableViewController.swift
//  HNR
//
//  Created by Tiago Alves on 14/03/2017.
//  Copyright © 2017 Tiago Alves. All rights reserved.
//

import UIKit
import Alamofire
import SafariServices

class NewsTableViewController: UITableViewController {
    
    var allNews : NSMutableArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "News"
        
        self.refreshControl?.addTarget(self, action: #selector(refreshNews), for: UIControlEvents.valueChanged)
        
        // Start refresh when view is loaded
        self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentOffset.y - 30), animated: false)
        self.tableView.refreshControl?.beginRefreshing()
        refreshNews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allNews.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsCell

        let news = self.allNews[indexPath.row] as! NSDictionary
        
        cell.titleLabel?.text = news.value(forKey: "title") as? String
        cell.titleLabel?.sizeToFit()
        
        cell.countLabel?.layer.masksToBounds = true
        cell.countLabel?.layer.cornerRadius = 11
        cell.countLabel?.text = String(describing: news.value(forKey: "score") as! Int)
        
        if news.value(forKey: "by") != nil {
            let author = news.value(forKey: "by")
            let attrs = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 15)]
            let boldString = NSMutableAttributedString(string: author as! String, attributes: attrs)
            
            let attributedString = NSMutableAttributedString(string:"by ")
            attributedString.append(boldString)
            
            cell.authorLabel?.attributedText = attributedString
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let news = self.allNews[indexPath.row] as! NSDictionary
        let title = news.value(forKey: "title") as? String
        let constraintRect = CGSize(width: tableView.bounds.size.width - 32, height: CGFloat(MAXFLOAT))
        let boundingBox = title?.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont(name: "Avenir Next", size: 20) as Any], context: nil)
        return (boundingBox!.height + 57.0)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = self.allNews[indexPath.row] as! NSDictionary
        
        if let url = news.value(forKey: "url") {
            let destination: URL = URL(string: url as! String)!
            
            let safari: SFSafariViewController = SFSafariViewController(url: destination)
            safari.preferredBarTintColor = UIColor(red:0.17, green:0.19, blue:0.27, alpha:1.00)
            
            self.present(safari, animated: true, completion: nil)
            
        }
    }
    
    func refreshNews() {
        var counter = 0
        let size = 20
        let allNewNews : NSMutableArray = []
        
        Alamofire.request("https://hacker-news.firebaseio.com/v0/topstories.json").responseJSON { response in
            if response.result.value != nil {
                
                let arrayOfNews = response.result.value as! NSArray
                
                for _ in arrayOfNews.subarray(with: NSRange(location: 0, length: size)) {
                    allNewNews.add(NSNull.init())
                }
                
                for (index, news) in arrayOfNews.subarray(with: NSRange(location: 0, length: size)).enumerated() {
                    Alamofire.request("https://hacker-news.firebaseio.com/v0/item/\(news).json").responseJSON { response in
                        counter += 1
                        if let JSON = response.result.value {
                            print("JSON: \(JSON)")
                            allNewNews.replaceObject(at: index, with: JSON)
                        }
                        if counter == size {
                            self.allNews = allNewNews
                            self.tableView.reloadData()
                            self.refreshControl?.endRefreshing()
                        }
                    }
                }
            }
        }
    }

}