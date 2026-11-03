public with sharing class InventorySetupController {
        @AuraEnabled
        public static Id createHotelClubRecord(Id hotelId, String startDate, String endDate, String clubName, List<String> openingDays, List<String> closingDays) {
            Contract newRecord = new Contract();
            newRecord.StartDate = Date.valueOf(startDate);
            newRecord.EndDate = Date.valueOf(endDate);
            newRecord.Club_Name__c = clubName;
            newRecord.Opening_Days__c = String.join(openingDays, ';');
            newRecord.Closing_Days__c = String.join(closingDays, ';');
            newRecord.AccountId = hotelId;
            newRecord.Status = 'Open';
            
            insert newRecord;
            return newRecord.Id;
        }

        @AuraEnabled
        public static void updateCheckbox(Id hotelId){
            Account hotel = [SELECT Id, Display__c FROM Account WHERE Id=:hotelId];
            hotel.Display__c = true; // Set Display__c checkbox to true
            update hotel;
        }
        @AuraEnabled
        public static String checkPartner(Id hotelId){
            /**if(Test.IsRunningTest()){
                return 'true';
            }**/
            
            List<Contact> partners = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId=:hotelId];
            if(partners.isEmpty()){
                return 'false';
            }
            else{
                for(Contact partner : partners) {
                    List<User> partnerUsers = [SELECT Id, Name, IsActive FROM User WHERE Name=:partner.Name];
                    if(!partnerUsers.isEmpty() && partnerUsers[0].IsActive){ // Also, corrected the comparison
                        return 'true';
                    }
                }
            }
            return 'false';
        }
        
   
    
    

//     @AuraEnabled
//    public static void createInventoryProducts(String startDate, String endDate,Id hotelClubId, String ageStaffRecordsJSON, String sessionRecordsJSON) {
//     List<Object> ageStaffRecords = (List<Object>)JSON.deserializeUntyped(ageStaffRecordsJSON);
//     List<Object> sessionRecords = (List<Object>)JSON.deserializeUntyped(sessionRecordsJSON);

//     List<Inventory_Product__c> inventoryProductsToInsert = new List<Inventory_Product__c>();

//     for (Object ageStaffRecordObj : ageStaffRecords) {
//         Map<String, Object> ageStaffRecord = (Map<String, Object>)ageStaffRecordObj;
//         for (Object sessionRecordObj : sessionRecords) {
//             Map<String, Object> sessionRecord = (Map<String, Object>)sessionRecordObj;
//             String sessionName = (String)sessionRecord.get('Session_Name');
//             Integer staff = Integer.valueOf((String)ageStaffRecord.get('Staff'));
//             Integer ratio = Integer.valueOf((String)ageStaffRecord.get('Ratio'));
//             Integer cost = Integer.valueOf((String)sessionRecord.get('Cost'));
//             String openHours = (String)sessionRecord.get('openingHours'); 


//             Inventory_Product__c newRecord = new Inventory_Product__c();
//             newRecord.Hotel_Club__c = hotelClubId;
//             newRecord.Club_Type__c = sessionName;
//             newRecord.Staff_No__c = staff;
//             newRecord.Ratio__c = ratio;
//             newRecord.Cost__c = cost;
//             newRecord.Club_Date__c = currentDate;
//             newRecord.Opening_Hours__c = openHours;
   

//             inventoryProductsToInsert.add(newRecord);
//         }
//     }

//     insert inventoryProductsToInsert;
// }

@AuraEnabled
public static Id createInventoryProducts(String startDate, String endDate, Id hotelClubId, Integer columnOrder, String ageStaffRecordsJSON, String sessionRecordsJSON) {
    System.debug('**** startDate: ' + startDate);
    System.debug('**** endDate: ' + endDate);
    System.debug('**** hotelClubId: ' + hotelClubId);
    System.debug('**** columnOrder: ' + columnOrder);
    System.debug('**** ageStaffRecordsJSON: ' + ageStaffRecordsJSON);
    System.debug('**** sessionRecordsJSON: ' + sessionRecordsJSON);
    
    List<Contract> lstHotelClubs = new List<Contract>();
    Set<String> setOpeningDays = new Set<String>();
    
    lstHotelClubs = [Select Id, Opening_Days__c from Contract where Id = :hotelClubId];
    if(lstHotelClubs != null && lstHotelClubs.size() > 0){
        Contract hotelClub = lstHotelClubs[0];
        if(hotelClub != null && hotelClub.Opening_Days__c != null && hotelClub.Opening_Days__c != ''){
            List<String> lstOpeningDays = hotelClub.Opening_Days__c.split(';');
            if(lstOpeningDays != null && lstOpeningDays.size() > 0){
                setOpeningDays = new Set<String>(lstOpeningDays);
            }
        }
    }
    System.debug('*** setOpeningDays ' + setOpeningDays);
    
    List<Object> ageStaffRecords = (List<Object>) JSON.deserializeUntyped(ageStaffRecordsJSON);
    List<Object> sessionRecords = (List<Object>) JSON.deserializeUntyped(sessionRecordsJSON);
    
    // Convert startDate and endDate to Date objects
    Date startDateObj = Date.valueOf(startDate);
    Date endDateObj = Date.valueOf(endDate);

    List<Inventory_Product__c> inventoryProductsToInsert = new List<Inventory_Product__c>();

    // Loop through each date between startDate and endDate
    for (Date currentDate = startDateObj; currentDate <= endDateObj; currentDate = currentDate.addDays(1)){    
        Datetime dtCurrentDateTime = (DateTime)currentDate;
        String strDayOfWeek = dtCurrentDateTime.format('EEEE');
        System.debug('*** strDayOfWeek ' + strDayOfWeek);
        
        if(!setOpeningDays.contains(strDayOfWeek)){
            System.debug('*** Current date NOT in opening days, skipping this loop');
            Continue;
        }
        System.debug('*** Current date in opening days');
        
        for (Object ageStaffRecordObj : ageStaffRecords) {
            Map<String, Object> ageStaffRecord = (Map<String, Object>) ageStaffRecordObj;
            for (Object sessionRecordObj : sessionRecords) {
                Map<String, Object> sessionRecord = (Map<String, Object>) sessionRecordObj;
                String sessionName = (String) sessionRecord.get('Session_Name');
                Integer staff = Integer.valueOf((String) sessionRecord.get('Staff'));
                Integer ratio = Integer.valueOf((String) sessionRecord.get('Ratio'));
                Integer cost = Integer.valueOf((String) sessionRecord.get('Cost'));
                String openHours = (String) sessionRecord.get('openingHours');
                String ageRange = (String) ageStaffRecord.get('ageRange');
                Integer minAge = Integer.valueOf((String) ageStaffRecord.get('From_Age'));
                Integer maxAge = Integer.valueOf((String) ageStaffRecord.get('To_Age'));
                String kcUniqueId = openHours+cost+ageRange+hotelClubId+columnOrder;
                kcUniqueId = String.valueOf( kcUniqueId.hashCode() * -1 );
                

                Inventory_Product__c newRecord = new Inventory_Product__c();
                newRecord.Hotel_Club__c = hotelClubId;
                newRecord.Club_Type__c = sessionName;
                newRecord.Staff_No__c = staff;
                newRecord.Ratio__c = ratio;
                newRecord.Cost__c = cost;
                newRecord.KC_Date__c = currentDate;
                newRecord.Opening_Hours__c = openHours;
                newRecord.Age_Range__c = ageRange;
                newRecord.Minimum_Age__c = minAge;
                newRecord.Maximum_Age__c = maxAge;
                newRecord.KC_Column_Order__c = columnOrder;
                newRecord.KC_Group_Id__c = kcUniqueId;


                inventoryProductsToInsert.add(newRecord);
            }
        }
    }

    insert inventoryProductsToInsert;
    return hotelClubId;
}

@AuraEnabled
    public static void deleteHotelClubRecord(Id hotelClubId) {
        try {
  
            Contract hotelClubToDelete = [SELECT Id FROM Contract WHERE Id = :hotelClubId LIMIT 1];
            if (hotelClubToDelete != null) {
        
                delete hotelClubToDelete;
            }
        } catch (Exception e) {

            throw new AuraHandledException('Error deleting hotel club record: ' + e.getMessage());
        }
    }
    
@AuraEnabled
public static void createDiscountRecords(Id hotelId, List<String> selectedOptions, Id hotelClubId, String discountRecordsJSON){
    List<Object> discountRecords = (List<Object>) JSON.deserializeUntyped(discountRecordsJSON);

    for (Object discountRecordsObj : discountRecords) {
        Map<String, Object> discountRecord = (Map<String, Object>) discountRecordsObj;

        String type = (String) discountRecord.get('Type');
        String Session_Types = (String) discountRecord.get('Session_Types');
        
        Integer minimumNumberOfRecords = Integer.valueOf((String) discountRecord.get('Min_No'));
        Integer Amount = Integer.valueOf((String) discountRecord.get('Amount'));
        String startDateString = (String) discountRecord.get('From_Date');
        String endDateString = (String) discountRecord.get('To_Date');
        
        Date startDate = Date.valueOf(startDateString);
        Date endDate = Date.valueOf(endDateString);
        
        if(selectedOptions.size()>0){
            String clubTypes = String.join(selectedOptions, ';');
            Discount__c newRecord = new Discount__c();
            newRecord.HotelClub__c = hotelClubId;
            newRecord.Hotel__c = hotelId;
            newRecord.DiscountType__c = type;
            //newRecord.Club_Type__c = Session_Types;
            newRecord.Club_Type__c = clubTypes;
            newRecord.Min_Number_of_Records_Selected__c = minimumNumberOfRecords;
            newRecord.Discount_Amount__c = Amount;
            newRecord.From_Date__c = startDate;
            newRecord.To_Date__c = endDate;
            newRecord.Record_Type__c = 'discount';
            insert newRecord;
        }
        else{
            Discount__c newRecord = new Discount__c();
            newRecord.HotelClub__c = hotelClubId;
            newRecord.Hotel__c = hotelId;
            newRecord.DiscountType__c = type;
            newRecord.Club_Type__c = Session_Types;
            // newRecord.Club_Type__c = clubType;
            newRecord.Min_Number_of_Records_Selected__c = minimumNumberOfRecords;
            newRecord.Discount_Amount__c = Amount;
            newRecord.From_Date__c = startDate;
            newRecord.To_Date__c = endDate;
            newRecord.Record_Type__c = 'discount';
            insert newRecord;
        }
    }
}
}