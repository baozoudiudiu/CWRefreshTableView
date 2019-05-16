//
//  CWRefreshTableView.swift
//  CWRefreshTableView
//
//  Created by chenwang on 2018/9/26.
//  Copyright © 2018年 chenwang. All rights reserved.
//

import UIKit
import MJRefresh

class CWRefreshTableView: UITableView {
    
    /// 刷新类型枚举
    ///
    /// - refresh: 下拉刷新
    /// - loadmore: 上拉加载
    enum CWRefreshType {
        case refresh
        case loadmore
    }
    
    //MARK: - 属性 PROPERTY
    /// 刷新回调
    fileprivate var refreshBlock: (()->Void)?
    
    /// 加载回调
    fileprivate var loadMoreBlock: (()->Void)?
    
    /// 分页每页数据量,默认为10
    var pageSize: Int = 20
    
    /// 数据缺省图
    var noDataRemindView: UIView! {
        didSet
        {
            if let oldView = oldValue
            {
                oldView.removeFromSuperview()
            }
            noDataRemindView.center = CGPoint.init(x: self.frame.width * 0.5,
                                                   y: self.frame.height * 0.5)
            self.addSubview(noDataRemindView)
            noDataRemindView.isHidden = true
        }
    }
    
    
    //MARK: - 构造方法 INITIAL
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame,
                   style: style)
        self.configureView()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
    }
}



// MARK: - UI设置 CONFIGURE UI
extension CWRefreshTableView {
    
    fileprivate func configureView() {
        self.estimatedRowHeight = 0
        self.estimatedSectionHeaderHeight = 0
        self.estimatedSectionFooterHeight = 0
        self.tableFooterView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 1, height: 0.01))
        self.defaultNoDataView()
    }
    
    
    fileprivate func defaultNoDataView() {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: 30))
        let label = UILabel.init(frame: view.bounds)
        label.text = "没有数据"
        label.textAlignment = .center
        view.addSubview(label)
        self.addSubview(view)
        self.noDataRemindView = view
        self.noDataRemindView.isHidden = true
        
        label.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        
        view.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
    }
}


//MARK: - 业务逻辑 LOGIC
extension CWRefreshTableView {
    func beginRefresh() {
        if let header = self.mj_header
        {
            self.mj_footer?.isHidden = true
            header.beginRefreshing()
        }
    }
    
    
    func beginLoadMore() {
        if let footer = self.mj_footer
        {
            footer.beginRefreshing()
        }
    }
    
    
    func endRefresh(refreshType: CWRefreshType, pageCount: Int) {
        switch refreshType
        {
        case .refresh:()
        if self.mj_header.isRefreshing
        {
            self.mj_header.endRefreshing()
        }
        
        self.mj_footer?.isHidden = self.noDataViewIsShow()
        if pageCount < self.pageSize
        {
            self.mj_footer?.endRefreshingWithNoMoreData()
        }
        else
        {
            self.mj_footer?.resetNoMoreData()
            }
        case .loadmore:()
        if self.mj_footer.isRefreshing
        {
            if pageCount < self.pageSize
            {
                self.mj_footer.endRefreshingWithNoMoreData()
            }
            else
            {
                self.mj_footer.endRefreshing()
            }
            }
        }
    }
    
    
    func handleData<T>(networkDatas: [T], targetArr: inout [T], pageIndex: Int) {
        let type: CWRefreshType = pageIndex == 1 ? .refresh : .loadmore
        if type == .refresh
        {   targetArr.removeAll()
            targetArr.append(contentsOf: networkDatas)
            if networkDatas.isEmpty
            {
                self.showNoDataView()
            }
            else
            {
                self.hiddenNoDataView()
            }
        }
        else
        {
            targetArr.append(contentsOf: networkDatas)
        }
        self.endRefresh(refreshType: type, pageCount: networkDatas.count)
    }
    
    
    
    func showNoDataView() {
        self.noDataRemindView.isHidden = false
        self.mj_footer?.isHidden = true
    }
    
    
    func hiddenNoDataView() {
        self.noDataRemindView.isHidden = true
    }
    
    
    func noDataViewIsShow() -> Bool {
        return !self.noDataRemindView.isHidden
    }
}



// MARK: - 下拉刷新相关
extension CWRefreshTableView {
    /// 设置刷新头
    ///
    /// - Parameters:
    ///   - header: 刷新头类型,传nil,则默认为MJRefreshNormalHeader
    ///   - block: 刷新回调, 传nil, 则默认没有下拉刷新功能呢
    func setRefreshHeader<T: MJRefreshHeader>(header: T.Type?, block: (()->Void)?) {
        
        guard block != nil else
        {
            self.mj_header = nil
            self.refreshBlock = nil
            return
        }
        
        var refreshHeader: MJRefreshHeader = MJRefreshNormalHeader.init(refreshingTarget: self,
                                                                        refreshingAction: #selector(refreshHandle))
        if let _ = header
        {
            refreshHeader = T(refreshingTarget: self,
                              refreshingAction: #selector(refreshHandle))
        }
        self.refreshBlock = block
        self.mj_header = refreshHeader
        
        self.mj_header.refreshingBlock = { [weak self] in
            if let footer = self?.mj_footer
            {
                footer.isHidden = true
            }
        }
    }
    
    
    /// 下拉刷新处理
    @objc fileprivate func refreshHandle() {
        self.refreshBlock?()
    }
}



// MARK: - 上拉加载相关
extension CWRefreshTableView {
    /// 上拉加载处理
    @objc fileprivate func loadmoreHandle() {
        self.loadMoreBlock?()
    }
    
    
    /// 设置上拉加载
    ///
    /// - Parameters:
    ///   - footer: 上拉加载控件类型, 传nil则默认为MJRefreshBackNormalFooter
    ///   - block: 上拉加载回调, 传nil,默认为没有该功能
    func setLoadmoreFooter<T: MJRefreshFooter>(footer: T.Type?, block: (()->Void)?) {
        guard block != nil else
        {
            self.mj_footer = nil
            self.loadMoreBlock = nil
            return
        }
        
        var loadmoreFooter: MJRefreshFooter = MJRefreshBackNormalFooter.init(refreshingTarget: self,
                                                                             refreshingAction: #selector(loadmoreHandle))
        if let _ = footer
        {
            loadmoreFooter = T(refreshingTarget: self,
                               refreshingAction: #selector(loadmoreHandle))
        }
        self.loadMoreBlock = block
        self.mj_footer = loadmoreFooter
        self.mj_footer.isHidden = true
    }
}
