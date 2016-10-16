//
//  TableMenuView.swift
//  Zouqiba
//
//  Created by Miibox on 8/19/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit

protocol TableMenuDelegate{
    func tableMenuDidChangedToIndex(menuId: Int, btnIndex:Int)
}

class TableMenuView: UIView, UITableViewDelegate, UITableViewDataSource {
    var titles = [NSString]()
    var delegate : TableMenuDelegate?
    var tableView : UITableView?
    var font: UIFont!
    var menuId: Int!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.setupTableMenu(frame)
    }
    
    func setupTableMenu(frame: CGRect){
        let tableView = UITableView(frame: CGRectMake(0, 0, frame.size.width, frame.size.height))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor.clearColor()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.backgroundColor = UIColor.clearColor()

        self.addSubview(tableView)
        
        self.tableView = tableView
        self.tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    

    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return titles.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reuseIdentifier)
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.text = titles[indexPath.item] as String
        cell.textLabel?.font = font
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        
        cell.layer.shadowColor = UIColor.grayColor().CGColor
        cell.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        cell.layer.shadowOpacity = 0.1
        cell.layer.shadowRadius = 0.1
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.delegate?.tableMenuDidChangedToIndex(menuId, btnIndex: indexPath.row)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


}
