global class vf_searchacc_controller {

    // to hold the distance from the vf page
    public Decimal distance {get; set;}
    
    // to hold the city lat long and used to center the map
    public decimal longitude {get; set;}
    public decimal latitude {get; set;}
    
    // to hold the user city name
    public String city {get; set;}
    
    // to store the accounts from soql query
    private List<Account> acc;
    
    // to hold the selected accounts
    public List<Account> selectedAcc {get; set;}
    
    // date value from the vf page
    public Date datePicker {get; set;}
    
    // to show the accouts using pagination
    public List<accSelection> accsToShow {get; set;}
    
    //Navigation variables
    Integer counter = 0; //To track the number of records parsed
    Integer limitSize = 10; //Number of records to be displayed
    Integer totalSize =0; //To Store the total number of records available
    
    public vf_searchacc_controller() {
        acc = new List<Account>();
        accsToShow = new List<accSelection>();
    }
    
    // to populate the data for the given city and distance
    public void searchData() {
        
        if(accsToShow.size() > 0) {
            accsToShow.clear();
        }
        
        // calling the Goolge Maps Api for finding lat and lng for city name using a helper class
        Location userLocation = GeoLocation_GoogleMapsApi.findLatLong(city);
        longitude = userLocation.longitude;
        latitude = userLocation.latitude;
        System.debug('Location of '+city+' : '+userLocation);
        
        // before quering database, we are updating the Location__c field in Account
        AccountUtils.updateLocationField();
        
        acc = [SELECT ID, NAME, BillingStreet, BillingCity, BillingState, 
               BillingPostalCode, BillingLatitude, BillingLongitude, 
               Location__c, CreatedDate, OwnerId FROM ACCOUNT 
               WHERE DISTANCE(Location__c, GEOLOCATION(:userLocation.latitude, :userLocation.longitude), 'mi') < :distance];
        
        // store the size of the list
        totalSize = acc.size();
        
        //Intial adding of contacts to accsToShow
        //check the total records are more than limitSize and assign the records
        if((counter+limitSize) <= totalSize){
            for(Integer i=0;i<limitSize;i++){
                accsToShow.add(new accSelection(acc.get(i)));
            }
        }else{
            for(Integer i=0;i<totalSize;i++){
                accsToShow.add(new accSelection(acc.get(i)));
            }
        }
        
        System.debug('SearchData() - Counter: '+counter+' Limitsize: '+limitSize+' totalSize: '+totalSize);        
    }
    
    public void addToInteniery() {
        
        if(datePicker == null) {
            datePicker = Date.today();
        }
        
        List<Event> events = new List<Event>();
        List<Site_Visit__c> siteVisits = new List<Site_Visit__c>();
        
        for(Account a : selectedAcc) {
            // adding event to the calander
            Event e = new Event();
            e.WhatId = a.Id;
            e.Subject = 'Meeting';
            e.StartDateTime = DateTime.newInstance(datePicker, Time.newInstance(8, 00, 00, 00));
            e.EndDateTime = DateTime.newInstance(datePicker, Time.newInstance(16, 00, 00, 00));
            e.Description = 'you have an appointment with this account';
            events.add(e);
            
            // creating a new sitevisit for account
            Site_Visit__c siteVisit = new Site_Visit__c();
            siteVisit.Account_Site__c = a.Id;
            siteVisit.Date_Visited__c = datePicker;
            siteVisit.Name = 'Site Visit 1';
            siteVisit.Visited_By__c = UserInfo.getUserId();
                siteVisits.add(siteVisit);
        }
        
        insert events;
        insert siteVisits;
        
    }
    
    //Navigation methods
    public void next(){
                
        accsToShow.clear();
        counter=counter+limitSize;
       System.debug('Next() - Counter: '+counter+' Limitsize: '+limitSize+' totalSize: '+totalSize);
        if((counter+limitSize) <= totalSize){
            for(Integer i=counter-1;i<(counter+limitSize);i++){
                accsToShow.add(new accSelection(acc.get(i)));
            }
        } else{
            for(Integer i=counter;i<totalSize;i++){
                accsToShow.add(new accSelection(acc.get(i)));
            }
        }
        System.debug('Next() - Counter: '+counter+' Limitsize: '+limitSize+' totalSize: '+totalSize);
        System.debug(accsToShow);
        System.debug(acc);
    }
    
    public void previous(){
   
        accsToShow.clear();

        counter=counter-limitSize;       
       
        for(Integer i=counter;i<(counter+limitSize); i++){
            accsToShow.add(new accSelection(acc.get(i)));
        }
         System.debug('Previous() - Counter: '+counter+' Limitsize: '+limitSize+' totalSize: '+totalSize);
         System.debug(accsToShow);
    }
    
    // to disable the next button
    public Boolean getDisableNext(){
                System.debug('DisableNext() - Counter: '+counter+' Limitsize: '+limitSize+' TotalSize: '+totalSize);
        if((counter+limitSize) >= totalSize )
            return true;
        else
            return false;
    }
   	
    // to disable the previous button
    public Boolean getDisablePrevious(){
                System.debug('DisablePrevious() - Counter: '+counter+' Limitsize: '+limitSize+' TotalSize: '+totalSize);
        if(counter == 0)
            return true;
        else
            return false;
    }
    
    public PageReference getSelected() {
     	 if(selectedAcc == null) {
            selectedAcc = new List<Account>();
        } else {
            selectedAcc.clear();
        }
        for(accSelection a : accsToShow) {
            if(a.selected == true) {
                selectedAcc.add(a.acc);
            }
        }
        System.debug(selectedAcc);
       return null;
    }
    
    // helper class to hold the account and its corresponding selection value
    public class accSelection {
        public Account acc {get; set;}
        public Boolean selected {get; set;}
        
        public accSelection(Account a) {
            this.acc = a;
                selected = false;
        }
    } 
}