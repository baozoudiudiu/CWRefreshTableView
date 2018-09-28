//
//  ViewController.swift
//  CWRefreshTableView
//
//  Created by 罗泰 on 2018/9/26.
//  Copyright © 2018年 chenwang. All rights reserved.
//

import UIKit
import MJRefresh


class ViewController: UIViewController {

    var pageIndex: Int = 1
    var dataArr: [Int] = [Int]()
    var tb:CWRefreshTableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let tableView = CWRefreshTableView.init(frame: self.view.bounds,
                                                style: .plain)
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView.init()
        
        tableView.setRefreshHeader(header: nil) { [weak self] in
            self?.requestData(pageIndex: 1)
        }
        
        tableView.setLoadmoreFooter(footer:  MJRefreshAutoNormalFooter.self) { [weak self] in
            let index = self?.pageIndex ?? 1
            self?.requestData(pageIndex: index + 1)
        }
        
        self.tb = tableView
    }

    
    
    func requestData(pageIndex: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            let count = Int(arc4random()%11)
            var arr: [Int] = [Int]()
            for i in self.dataArr.count..<(self.dataArr.count + count)
            {
                arr.append(i)
            }
            
            self.tb?.handleData(networkDatas: arr,
                                targetArr: &(self.dataArr),
                                pageIndex: pageIndex)
            
            if !arr.isEmpty
            {
                self.pageIndex = pageIndex
            }
            self.tb?.reloadData()
        }
    }
    
    
    func handleData() {
        
    }
}



extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellId")
        
        if cell == nil
        {
            cell = UITableViewCell.init(style: .default,
                                        reuseIdentifier: "cellId")
        }
        
        cell?.textLabel?.text = String(self.dataArr[indexPath.row])
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArr.count
    }
}

