//
//  TableMenuView.swift
//  Zouqiba
//
//  Created by Miibox on 8/19/16.
//  Copyright © 2016 Miibox. All rights reserved.
//

import UIKit

protocol TableMenuDelegate{
    func tableMenuDidChangedToIndex(_ menuId: Int, btnIndex:Int)
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
    
    func setupTableMenu(_ frame: CGRect){
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor.clear
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UIColor.clear

        self.addSubview(tableView)
        
        self.tableView = tableView
        self.tableView?.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    

    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return titles.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.text = titles[(indexPath as NSIndexPath).item] as String
        cell.textLabel?.font = font
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.textAlignment = NSTextAlignment.center
        
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        cell.layer.shadowOpacity = 0.1
        cell.layer.shadowRadius = 0.1
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.delegate?.tableMenuDidChangedToIndex(menuId, btnIndex: (indexPath as NSIndexPath).row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


}
