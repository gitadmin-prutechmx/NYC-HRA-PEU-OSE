//
//  ChartsViewController.swift
//  EngageNYC
//
//  Created by Kamal on 07/01/18.
//  Copyright © 2018 mtxb2b. All rights reserved.
//

import UIKit
import Charts

class ChartDO{
    var chartLabel:String!
    var chartValue:String!
    var chartColor:UIColor!
    var percentage:String!
}

class ChartsViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource
{
    
    var dashboardInfo : DashboardInfo?{
        didSet{
            self.reloadView()
        }
    }
    
    @IBOutlet weak var colChart: UICollectionView!
    
    var viewModel:ChartViewModel!
    var arrCharts = [ChartDO]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    
    func setupView() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.bindView()
        }
    }
    
    func reloadView(){

        DispatchQueue.main.async {
           guard let info = self.dashboardInfo else { return }
           self.arrCharts = info.arrCharts
           self.colChart.reloadData()
        }
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        colChart.collectionViewLayout.invalidateLayout()
    }
    
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrCharts.count
    }
    
   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chartCell", for: indexPath as IndexPath)as!ChartCollectionViewCell
        
        cell.setupView(forCellObject: arrCharts[indexPath.row], index: indexPath)
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    

}

extension ChartsViewController{
    func bindView(){
        self.viewModel = ChartViewModel.getViewModel()
    }
}







