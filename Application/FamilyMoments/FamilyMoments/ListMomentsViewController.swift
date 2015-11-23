//
//  ListMomentsController.swift
//  FamilyMoments
//
//  Created by Paulo Miguel Almeida Rodenas on 11/22/15.
//  Copyright © 2015 Paulo Miguel Almeida Rodenas. All rights reserved.
//

import UIKit

class ListMomentsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    var momentsArray:Array<CLIListMomentsResponse_Items_item>?
    
    
    //MARK: View Controller life cycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadMoments()
    }
    
    //MARK: TableView delegates
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (momentsArray?.count ?? 0)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ListMomentsTableViewCell") as! ListMomentsTableViewCell
        let item = momentsArray![indexPath.row]
        
        cell.momentCommentLabel.text = item.comment
        cell.momentImageView.downloadImage(NSURL(string: "https://s3.amazonaws.com/awslambdacognitoapigatewaylecture/\(item.s3Object)")!)
        
        return cell
    }
    
    //MARK: Network methods
    func loadMoments(){
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = "Loading"
    
        let serviceClient = CLIFamilyMomentsClient(forKey: "anonymousAccess")
        let awsTask = serviceClient.momentsGet()
        awsTask.continueWithBlock { (task:AWSTask!) -> AnyObject! in
            if task.error != nil {
                print(task.error)
            } else {
                if let response = task.result as! CLIListMomentsResponse?{
                    self.momentsArray = response.items as! Array<CLIListMomentsResponse_Items_item>?
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                        loadingNotification.hide(true)
                    }
                }
            }
            
            return nil
        }
    }
    
}
