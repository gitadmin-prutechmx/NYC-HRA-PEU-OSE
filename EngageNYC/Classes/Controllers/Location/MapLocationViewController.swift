//
//  MapLocationViewController.swift
//  Knock
//
//  Created by Kamal on 15/06/17.
//  Copyright © 2017 mtxb2b. All rights reserved.
//

import UIKit
import ArcGIS
import Zip


//Default (Pending), Completed, Inaccessible/Vacant, In Progress, Address Does Not Exist

enum locationStatus:String{
    case pending = "Pending"
    case inprogress = "In Progress"
    case completed = "Completed"
    case inaccessible = "Inaccessible"
    case vacant = "Vacant"
    case addressNotExist = "Address Does Not Exist"
}


class MapLocationDO{
    var locId : String!
    var locName : String!
    var assignmentLocId:String!
    
    var additionalAddress:String!
    
    var locStatus:String!
    var street:String!
    var city:String!
    var state:String!
    var zip:String!
    
    var streetNum:String!
    var streetName:String!
    var borough:String!
    
    var totalUnits:String!
    var totalClients:String!
    var noOfUnitsAttempt:String!
    var lastModifiedName:String!
}

class MapLocationViewController: BroadcastReceiverViewController ,UITableViewDataSource, UITableViewDelegate , AGSGeoViewTouchDelegate, AGSCalloutDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var btnLoginName: UIButton!
    @IBOutlet weak var lblAssignment: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    
    @IBOutlet weak var tblLocations: UITableView!
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    private var mapPackage:AGSMobileMapPackage!
    var locatorTask:AGSLocatorTask?
    private var geocodeParameters:AGSGeocodeParameters!
    private var reverseGeocodeParameters:AGSReverseGeocodeParameters!
    private var locatorTaskOperation:AGSCancelable!
    private var markerGraphicsOverlay = AGSGraphicsOverlay()
    private var routeGraphicsOverlay = AGSGraphicsOverlay()
    private var geodatabase:AGSGeodatabase!
    private var map:AGSMap!
    var geodatabaseFeatureTable:AGSGeodatabaseFeatureTable!
    var featureLayerExtent:AGSEnvelope?
    
    var searchActive : Bool = false
    var isSyncDataFromLocation:Bool = false
    var arrMapLocationsMain = [MapLocationDO]()
    var arrMapLocationsFiltered = [MapLocationDO]()
    var selectedIndex:IndexPath!
    var viewModel:MapLocationViewModel!
    var canvasserTaskDataObject:CanvasserTaskDataObject!
    var filterfeaturesExpression = ""
    var isUpdateLocationView = false
    var selectedLocationObj:MapLocationDO!
    
    var styleResourcesDirectory:URL!
    var vtpkMapFile:URL!
    
    var containerDirectory:URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.show(withStatus: "Loading map", maskType: SVProgressHUDMaskType.gradient)
        
       // self.setUpMapLicense()
        
        //Bind viewModel
        self.setupView()
        
        //SetUp UI
        self.setUpUI()
        
        //Bind Locations data
         self.reloadView()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
  }
    
    override func onReceive(notification: NSNotification) {
        super.onReceive(notification: notification)
        
        if (notification.name.rawValue == SF_NOTIFICATION.LOCATIONLISTING_SYNC.rawValue)
        {
            self.reloadView()
        }
    }
    
    
    @IBAction func btnLeftBarPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnLoginNamePressed(_ sender: Any) {
        Utility.openNavigationItem(btnLoginUserName: btnLoginName, vc: self)
    }
    
    @IBAction func btnResetMapPressed(_ sender: Any) {
        self.mapView.callout.dismiss()
        
        self.mapView.setViewpoint(AGSViewpoint(targetExtent: featureLayerExtent!), completion: nil)
        
        //self.mapView.setViewpoint(AGSViewpoint(latitude: 40.717111188296814, longitude: -73.99110721511707,scale: 9027.977411), duration: 2, completion: nil)
    }
    
    func setUpMapLicense(){
        
        //Lite license
        //runtimelite,1000,rud5534926029,none,LHH93PJPXLJMXH46C006
        
        //Standard License
        //runtimestandard,1000,rud000103692,07-sep-2017,D7LFD4SZ8P00JERSX234
        
        //Streetmap premium
        //runtimesmpna,1000,rud000103692,07-sep-2017,HC4TL0PL40MLF9HHT041
        
        
        //  license the app with the supplied License key
        
        // //,extensions: ["runtimesmpna,1000,rud000103692,07-sep-2017,HC4TL0PL40MLF9HHT041"]
        
//
//        do {
//            let result = try AGSArcGISRuntimeEnvironment.setLicenseKey("runtimelite,1000,rud5534926029,none,LHH93PJPXLJMXH46C006",extensions: ["runtimesmpna,1000,rud000103692,07-sep-2017,HC4TL0PL40MLF9HHT041"])
//
//
//            print("License Result : \(result.licenseStatus)")
//        }
//        catch let error as NSError {
//            print("error: \(error)")
//        }
    }
    
    func setUpUI(){
        
        lblAssignment.text = canvasserTaskDataObject.assignmentObj.assignmentName
       
        btnLoginName.setTitle(canvasserTaskDataObject.userObj.userName, for: .normal)
        
        
        
        self.searchBar.delegate = self
        self.tblLocations.tableFooterView = UIView()
       
        //initialize geocode params
        self.geocodeParameters = AGSGeocodeParameters()
        self.geocodeParameters.resultAttributeNames.append(contentsOf: ["Match_addr"])
        self.geocodeParameters.minScore = 75

    }
    
    func setupView() {
        
        CustomNotificationCenter.registerReceiver(receiver: self.broadcastReceiver, notificationName: SF_NOTIFICATION.LOCATIONLISTING_SYNC)
        
        self.bindView()
        self.UnzipMapFile()
    }
    
    func reloadView(){
        
        DispatchQueue.main.async {
            self.arrMapLocationsMain = self.viewModel.loadLocations(assignmentId: self.canvasserTaskDataObject.assignmentObj.assignmentId)
            
            self.lblLocation.text = "Locations (\(self.arrMapLocationsMain.count))"
            
            self.filterfeaturesExpression = self.viewModel.filterfeaturesExpression
            let endIndex = self.filterfeaturesExpression.index(self.filterfeaturesExpression.endIndex, offsetBy: -3)
            self.filterfeaturesExpression = self.filterfeaturesExpression.substring(to: endIndex)
            
            self.tblLocations.reloadData()
            self.showVTPKMap()
           // self.showMap()
        }
    }
    
    
    // Cleanup notifications added in viewDidLoad
    deinit {
        NotificationCenter.default.removeObserver("UpdateLocationView")
    }
    
   
    
    func UnzipMapFile(){
        
        do {
        
            
            
            let mapDataPath = Bundle.main.path(forResource: "MapData", ofType: "zip")
   
            let unZipFilePath = try Zip.quickUnzipFile(URL(string: mapDataPath!)!) // Unzip
                
            let mapDirpath = unZipFilePath.absoluteString + "MapData"
      
            vtpkMapFile = URL(string:(mapDirpath + "/NewYorkCity.vtpk"))
            styleResourcesDirectory = URL(string:(mapDirpath + "/VTPKResources"))
                
//                containerDirectory = unZipFilePath.appendingPathComponent("MapData")
//
//                vtpkMapFile = URL(fileURLWithPath: "NewYorkCity.vtpk", relativeTo: containerDirectory)
//
//                styleResourcesDirectory = URL(fileURLWithPath: "VTPKResources", isDirectory: true, relativeTo: containerDirectory)
                
                
                
                print(unZipFilePath)
                
            
            
        }
        catch {
            Utility.showSwiftErrorMessage(error: "Something went wrong while unzip geodatabase.")
        }
        
        
    }
    
    
    func showVTPKMap(){
        
         isUpdateLocationView = false
        
    
        
//        containerDirectory = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("VTPKs")
//
//        vtpkMapFile = URL(fileURLWithPath: "NewYorkCity.vtpk", relativeTo: containerDirectory)
//
//
//
//       styleResourcesDirectory = URL(fileURLWithPath: "VTPKResources", isDirectory: true, relativeTo: containerDirectory)

        
        if(FileManager.default.fileExists(atPath: vtpkMapFile.path) == true && Utility.directoryExistsAtPath(styleResourcesDirectory.path) == true){
            
            let vectorCache = AGSVectorTileCache(fileURL: vtpkMapFile)
            
            let resourceCache = AGSItemResourceCache(fileURL: styleResourcesDirectory)
            
            let vectorLayer = AGSArcGISVectorTiledLayer(vectorTileCache: vectorCache, itemResourceCache: resourceCache)
            
            
            
            let map = AGSMap(basemap: AGSBasemap(baseLayer: vectorLayer))
            
            
            
//            let ext = AGSEnvelope(xMin: -8271401.806445, yMin: 4933175.027794,
//
//                                  xMax: -8206454.295366, yMax: 5003544.051723,
//
//                                  spatialReference: AGSSpatialReference.webMercator())
//
//            map.initialViewpoint = AGSViewpoint(targetExtent: ext)
            
            self.mapView.map = map
            
            SVProgressHUD.dismiss()
            
            //touch delegate
            self.mapView.touchDelegate = self
            
            //add graphic overlays
            self.mapView.graphicsOverlays.addObjects(from: [self.routeGraphicsOverlay, self.markerGraphicsOverlay])
        
            self.showLayers()
       
            
        }
        
       
        
    }
    
    
    
    func showMap(isSyncDataFromLoc:Bool?=false){
        
        isUpdateLocationView = false
        
        //initialize map package
        self.mapPackage = AGSMobileMapPackage(name: "NewYorkCity")
        
        
        if(self.mapPackage != nil){
            
            //load map package
            self.mapPackage.load { [weak self] (error: Error?) in
                if let error = error {
                    SVProgressHUD.dismiss()
                    Utility.showSwiftErrorMessage(error: "Error while loading map:  \(error.localizedDescription). Please refresh again.")
                    
                }
                else {
                    if let weakSelf = self {
                        if weakSelf.mapPackage.maps.count > 0 {
                            
                            weakSelf.map = weakSelf.mapPackage.maps[0]
                            
                            //weakSelf.map.minScale =
                            
                            weakSelf.mapView.map = weakSelf.map
                        
                            //touch delegate
                            weakSelf.mapView.touchDelegate = weakSelf
                            
                            //add graphic overlays
                            weakSelf.mapView.graphicsOverlays.addObjects(from: [weakSelf.routeGraphicsOverlay, weakSelf.markerGraphicsOverlay])
                            
                            self?.locatorTask = self?.mapPackage.locatorTask
                            
                            self?.showLayers()
                            
                           // self?.isSyncDataFromLocation = false
                            
                            
                        }
                        else {
                            
                        }
                    }
                }
            }
        }
        
        
    }
    
    
    
    
    func showLayers(){
        
        //instantiate geodatabase with name
        self.geodatabase = AGSGeodatabase(name: "NewYorkLayers")
        
        
        
        geodatabase.load(completion: { [] (error:Error?) -> Void in
            if let error = error {
                SVProgressHUD.dismiss()
                Utility.showSwiftErrorMessage(error: "Error while fetching data from ESRI server:  \(error.localizedDescription). Please refresh again.")
                
                print(error)
            }
            else {
                
                SVProgressHUD.dismiss()
                
//                let i = 1
//                for i in 1..<self.map.operationalLayers.count
//                {
//                    print("Number \(i)")
//                    self.map.operationalLayers.removeObject(at: i)
//                }
                
                
                
                AGSLoadObjects(self.geodatabase.geodatabaseFeatureTables, { (success: Bool) in
                    if success {
                        for featureTable in self.geodatabase.geodatabaseFeatureTables.reversed() {
                            //check if feature table has geometry
                            if featureTable.hasGeometry{
                                
                                if(featureTable.layerInfo!.geometryType.hashValue == 1 ){
                                    
                                    self.geodatabaseFeatureTable = self.geodatabase.geodatabaseFeatureTable(withName: featureTable.tableName)!
                                    
                                    
                                    let featureLayer = AGSFeatureLayer(featureTable: (self.geodatabaseFeatureTable)!)
                                    
                                    featureLayer.definitionExpression = (self.filterfeaturesExpression)
                                    
                                    self.mapView.map?.operationalLayers.add(featureLayer)
                                    
                                    self.featureLayerExtent =  featureTable.layerInfo!.extent!
                                    
                                    
                                    if(self.isUpdateLocationView == false){
                                        self.mapView.setViewpoint(AGSViewpoint(targetExtent: self.featureLayerExtent!), completion: nil)
                                    }
                                    
                                }
                                else{
                                    let featureTable = self.geodatabase.geodatabaseFeatureTable(withName: featureTable.tableName)!
                                    
                                    
                                    let featureLayer = AGSFeatureLayer(featureTable: featureTable)
                                    
                                    self.mapView.map?.operationalLayers.add(featureLayer)
                                }
                                
                            }
                        }
                        
                        if(self.isUpdateLocationView == false && self.arrMapLocationsMain.count > 0){
                            self.selectFeature(isShowCallOut: false, objLoc:self.arrMapLocationsMain[0])
                        }
                        
                    }
                })
            }
        })
        
        
    }
    
    
    func selectFeature(isShowCallOut:Bool = true,objLoc:MapLocationDO){
        
        let queryParams = AGSQueryParameters()
        queryParams.whereClause = "Name = '\(objLoc.locName!)'"
        
        
        if(geodatabaseFeatureTable != nil){
            
            self.geodatabaseFeatureTable.queryFeatures(with: queryParams, completion: { [weak self] (result:AGSFeatureQueryResult?, error:Error?) -> Void in
                if let error = error {
                    SVProgressHUD.dismiss()
                    print(error.localizedDescription)
                    
                }
                else if let features = result?.featureEnumerator().allObjects {
                    if features.count > 0 {
                        
//                        features[0].attributes["street_name"] = "CHRYSTIE STREET 1"
//
//
//                        self?.geodatabaseFeatureTable.update(features[0]) { [weak self] (error: Error?) -> Void in
//                            if let error = error {
//                                SVProgressHUD.showError(withStatus: error.localizedDescription)
//                            }
//                            else {
//                                    print("Update")
//                            }
//                        }
//
                       
                        
                        SVProgressHUD.dismiss()
                        
                        //zoom to the selected feature
                        
                        self?.mapView.setViewpointCenter(features[0].geometry! as! AGSPoint,scale:2000,completion: nil)
                        
                        if(isShowCallOut){
                            self?.showCalloutForGraphic(graphic: AGSGraphic(), tapLocation: features[0].geometry! as! AGSPoint, animated: true, offset: false,objLoc: objLoc)
                        }
                        
                        
                        
                        
                    }
                    else {
                        SVProgressHUD.dismiss()
                        Utility.showSwiftErrorMessage(error: "Address does not exist.\(objLoc.locName)")
                        
                    }
                    
                }
            })
            
        }
        else{
            SVProgressHUD.dismiss()
            Utility.showSwiftErrorMessage(error: "MapLocationVC:- Select feature:-  geodatabaseFeatureTable does not exist.")
            
            
            
        }
        
    }
    
    
    
    
    
    //method returns the symbol for the route graphic
    func routeSymbol() -> AGSSimpleLineSymbol {
        let symbol = AGSSimpleLineSymbol(style: .solid, color: UIColor.blue, width: 5)
        return symbol
    }
    
    //method returns a graphic object for the point and attributes provided
    private func graphicForPoint(point: AGSPoint, attributes: [String: AnyObject]?) -> AGSGraphic {
        let markerImage = UIImage(named: "MapPin")!
        let symbol = AGSPictureMarkerSymbol(image: markerImage)
        symbol.leaderOffsetY = markerImage.size.height/2
        symbol.offsetY = markerImage.size.height/2
        let graphic = AGSGraphic(geometry: point, symbol: symbol, attributes: attributes)
        return graphic
    }
    
    
    
    private func showCalloutForGraphic(graphic:AGSGraphic, tapLocation:AGSPoint, animated:Bool, offset:Bool,objLoc:MapLocationDO) {
        
        self.mapView.callout.isAccessoryButtonHidden = true
        
        self.mapView.callout.delegate = self
        self.mapView.callout.accessoryButtonImage = UIImage(named: "ForwardIcon")
        
        let nib = UINib(nibName: "MapViewCallout", bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! MapViewCallout
        
        view.lblNoOfUnits.text = objLoc.totalUnits
        view.lblNoClients.text = objLoc.totalClients
        view.lblAttemptPrecentage.text = objLoc.noOfUnitsAttempt + "%"
        view.lblName.text = objLoc.lastModifiedName
        view.lblLocationStatus.text = objLoc.locStatus
        view.lblAddress.text = objLoc.locName
        
        //Default (Pending) = #0b5394, Completed = #b0ffb6, Inaccessible/Vacant = #cccccc, In Progress = #ffff80, Address Does Not Exist = #ff6060
        
        if(objLoc.locStatus == locationStatus.pending.rawValue){
            view.viewLocationStatus.backgroundColor = UIColor(red: 11/255.0, green: 83/255.0, blue: 148/255.0, alpha: 1.0)
            view.lblLocationStatus.textColor = UIColor.white
        }
        else if(objLoc.locStatus == locationStatus.completed.rawValue){
            view.viewLocationStatus.backgroundColor = UIColor(red: 176/255.0, green: 255/255.0, blue: 182/255.0, alpha: 1.0)
        }
        else if(objLoc.locStatus == locationStatus.inaccessible.rawValue){
            view.viewLocationStatus.backgroundColor = UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1.0)
        }
        else if(objLoc.locStatus == locationStatus.vacant.rawValue){
            view.viewLocationStatus.backgroundColor = UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1.0)
        }
        else if(objLoc.locStatus == locationStatus.inprogress.rawValue){
            view.viewLocationStatus.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 128/255.0, alpha: 1.0)
        }
        else{
            view.viewLocationStatus.backgroundColor = UIColor(red: 255/255.0, green: 96/255.0, blue: 96/255.0, alpha: 1.0)
        }
        
        selectedLocationObj = objLoc
        
        view.btnEditLocation.addTarget(self, action: #selector(MapLocationViewController.navigateToEditLocationView(_:)), for: .touchUpInside)
        
       
        view.btnViewUnits.addTarget(self, action: #selector(MapLocationViewController.navigateToUnitView(_:)), for: .touchUpInside)
        
        self.mapView.callout.customView = view
        self.mapView.callout.show(for: graphic, tapLocation: tapLocation, animated: animated)
        
        
        
    }
    
   
    // MARK: Button Unit Action
    func navigateToUnitView(_ sender: AnyObject?)
    {
        self.mapView.callout.dismiss()
        
        if let locationUnitVC = LocationUnitStoryboard().instantiateViewController(withIdentifier: "LocationUnitViewController") as? LocationUnitViewController
        {
            canvasserTaskDataObject.locationObj = LocationDataObject(objMapLocation: selectedLocationObj)
            
            locationUnitVC.canvasserTaskDataObject = canvasserTaskDataObject
            locationUnitVC.modalPresentationStyle = UIModalPresentationStyle.formSheet
            self.navigationController?.pushViewController(locationUnitVC, animated: true)
        }
        
        
        
    }
    
    
    // MARK: Button EditLocation Action
    func navigateToEditLocationView(_ sender: AnyObject?)
    {
        
       // self.mapView.callout.dismiss()
        
        if let assignmentLocationVC = AssignmentLocationStoryboard().instantiateViewController(withIdentifier: "AssignmentLocationViewController") as? AssignmentLocationViewController{
            
            canvasserTaskDataObject.locationObj = LocationDataObject(objMapLocation: selectedLocationObj)
            
            assignmentLocationVC.canvasserTaskDataObject = canvasserTaskDataObject
            assignmentLocationVC.delegate = self
            let navigationController = UINavigationController(rootViewController: assignmentLocationVC)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
            self.present(navigationController, animated: true)
        }
    }
    
   
    
    
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        
        //dismiss the callout if already visible
        self.mapView.callout.dismiss()
        
        
        self.mapView.identifyLayers(atScreenPoint: screenPoint, tolerance: 12, returnPopupsOnly: false, maximumResultsPerLayer: 10) { [weak self] (results: [AGSIdentifyLayerResult]?, error: Error?) -> Void in
            
            if let error = error {
                SVProgressHUD.dismiss()
                Utility.showSwiftErrorMessage(error: "MapLocationVC:- GeoView: \(error.localizedDescription)")
            }
            else {
                SVProgressHUD.dismiss()
                
                
                for result in results! {
                    for geoElement in result.geoElements {
                        
                        let address = geoElement.attributes["Name"] as! String
                        
                        let mapLocObject = self?.viewModel.locationAddressDict[address]
                        
                        if let count = self?.arrMapLocationsMain.count{
                            if(count > 0){
                                
                                if(self?.arrMapLocationsMain.contains {$0.locName == address})!{
                                    
                                    self?.showCalloutForGraphic(graphic: AGSGraphic(), tapLocation: geoElement.geometry! as! AGSPoint, animated: true, offset: false,objLoc: mapLocObject!)
                                    
                                    if let i = self?.arrMapLocationsMain.index(where: {$0.locName == address})
                                    {
                                        print(i)
                                        let indexpath = IndexPath.init(row: i, section: 0)
                                        self?.tblLocations.selectRow(at: indexpath, animated: false, scrollPosition: .none)
                                        
                                    }
                                    
                                }
                            }
                        }
                        
                        
                    }
                }
                
            }
        }//end of geoview layers
        
    }
    
    
    
    
    
}

//Searching locations
extension MapLocationViewController{
    
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        arrMapLocationsFiltered = arrMapLocationsMain.filter {
            
            var isSearch = false
            
            if(searchText != ""){
                isSearch = ($0.locName.lowercased() as NSString).contains(searchText.lowercased())
            }
            
            return isSearch
            
            
        }
        
        if(arrMapLocationsFiltered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        
        if(self.arrMapLocationsFiltered.count > 0){
            self.lblLocation.text = "Locations (\(self.arrMapLocationsFiltered.count))"
        }
        else{
            self.lblLocation.text = "Locations (\(self.arrMapLocationsMain.count))"
        }
        self.tblLocations.reloadData()
        
    }
    
}

extension MapLocationViewController{
    
    func bindView(){
        self.viewModel = MapLocationViewModel.getViewModel()
    }
}

extension MapLocationViewController{
    
    
    // MARK: UITableViewDataSource
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(searchActive) {
            return arrMapLocationsFiltered.count
        }
        
        return arrMapLocationsMain.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:LocationTableViewCell = self.tblLocations.dequeueReusableCell(withIdentifier: "mapLocationCell") as! LocationTableViewCell!
        
        if(searchActive && arrMapLocationsFiltered.count > 0){
            cell.setupView(forCellObject:arrMapLocationsFiltered[indexPath.row],index:indexPath)
        }
        else{
            cell.setupView(forCellObject:arrMapLocationsMain[indexPath.row],index:indexPath)
        }
        
        
        
        return cell
        
        
    }
    
    
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selected, so set textField to relevant value, hide tableView
        // endEditing can trigger some other action according to requirements
        
        selectedIndex = indexPath
        if(searchActive && arrMapLocationsFiltered.count > 0){
            self.selectFeature(objLoc: arrMapLocationsFiltered[indexPath.row])
        }
        else{
            self.selectFeature(objLoc: arrMapLocationsMain[indexPath.row])
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}
/*
extension MapLocationViewController : AssignmentLocationDelegate{
    func updateLocationStatus(assignmentLocId: String,locStatus:String) {
        //update location status
        self.viewModel.updateLocationStatus(assignmentLocId:assignmentLocId,locStatus:locStatus)
        
        self.reloadView()
    }
    
  
}
 */
extension MapLocationViewController : AssignmentLocationDelegate{
    func updateLocationStatus(assignmentLocId: String,locStatus:String) {
        //update location status
        self.viewModel.updateLocationStatus(assignmentLocId:assignmentLocId,locStatus:locStatus)
         //self.tblLocations.reloadData()
        
      //  let indexPath = IndexPath(item: selectedIndex.row, section: 0)
      //  tblLocations.reloadRows(at: [indexPath], with: .top)
        
        DispatchQueue.main.async {
            
            self.arrMapLocationsMain = self.viewModel.loadLocations(assignmentId: self.canvasserTaskDataObject.assignmentObj.assignmentId)
            
            self.tblLocations.reloadData()
            
            
            self.tblLocations.selectRow(at: self.selectedIndex, animated: false, scrollPosition: .none)
            self.tblLocations.delegate?.tableView!(self.tblLocations, didSelectRowAt: self.selectedIndex!)
        }
       
    }
    
    
}

extension MapLocationViewController : ListingPopoverDelegate{
    func selectedItem(withObj obj: ListingPopOverDO, selectedIndex index: Int, popOverType type: PopoverType) {
         Utility.selectedNavigationItem(obj: obj, vc: self)
    }
    
}
