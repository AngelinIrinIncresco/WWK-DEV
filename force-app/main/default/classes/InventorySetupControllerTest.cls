@isTest
private class InventorySetupControllerTest {

    @isTest
    static void testCreateHotelClubRecord() {
        Map<String, Schema.RecordTypeInfo> accountRecordTypeInfo = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        
        // Create a Hotel account
        Account hotel = new Account(
            Name = 'Hotel',
            Payment_Type__c = 'Booking Fee',
            A_Show_Payment_Page__c = true,
            Booking_Fees__c = 5,
            Show_Babysitting_while_booking__c = true,
            Lock_after_hours_for_partner__c = 24,
            A_RM_s_Email__c = 'sridhar@gmail.com',
            CurrencyIsoCode = 'EUR',
            Display__c = true,
            Hotel_type__c = 'HOTEL client',
            RecordTypeId = accountRecordTypeInfo.get('Hotel').getRecordTypeId()
        );
        
        insert hotel;
        
        
        String startDate = '2024-04-01';
        String endDate = '2024-04-30';
        String clubName = 'Test Club';
        List<String> openingDays = new List<String>{'Monday', 'Tuesday', 'Wednesday'};
        List<String> closingDays = new List<String>{'Saturday', 'Sunday'};
        
        // Call the method
        Test.startTest();
        Id newRecordId = InventorySetupController.createHotelClubRecord(hotel.Id, startDate, endDate, clubName, openingDays, closingDays);
        Test.stopTest();
        
        // Verify
        Contract insertedRecord = [SELECT Id, StartDate, EndDate, Club_Name__c, Opening_Days__c, Closing_Days__c, AccountId, Status FROM Contract WHERE Id = :newRecordId];
       
    }
    
    @isTest
    static void testUpdateCheckbox() {
        // Test data
        Account hotel = new Account(Name = 'Test Hotel', Display__c = false);
        insert hotel;
        
        // Call the method
        Test.startTest();
        InventorySetupController.updateCheckbox(hotel.Id);
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testCheckPartner() {
         Map<String, Schema.RecordTypeInfo> accountRecordTypeInfo = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
       Account hotel = new Account(
            Name = 'Hotel',
            Payment_Type__c = 'Booking Fee',
            A_Show_Payment_Page__c = true,
            Booking_Fees__c = 5,
            Show_Babysitting_while_booking__c = true,
            Lock_after_hours_for_partner__c = 24,
            A_RM_s_Email__c = 'sridhar@gmail.com',
            CurrencyIsoCode = 'EUR',
            Display__c = true,
            Hotel_type__c = 'HOTEL client',
            RecordTypeId = accountRecordTypeInfo.get('Hotel').getRecordTypeId()
        );
        
        insert hotel;
        
       Contact contact = new Contact(
            AccountId = hotel.Id,
            LastName = 'lastname'
        );
        insert contact;
        
        // Query for the Hotel User Profile
        Profile partnerUserProfile = [SELECT Id FROM Profile WHERE Name='Hotel User Profile' LIMIT 1];
        
        // Create a partner user
        User partnerUser = new User(
            Alias = 'standt', 
            Email = 'wwkcPartnerUser@wwkc.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ContactId = contact.Id,
            ProfileId = partnerUserProfile.Id, 
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'wwkcPartnerUser@wwkc.com'
            
        );
        
        // Insert the partner user
        insert partnerUser;
        
        
        
        // Call the method when partner exists but no active user
      
        String resultPartnerNoUser = InventorySetupController.checkPartner(hotel.Id);
       
       
        
      
        
        String resultPartnerWithUser = InventorySetupController.checkPartner(hotel.Id);
       
        
    }
     @isTest
    static void testDeleteHotelClubRecord() {
          Map<String, Schema.RecordTypeInfo> accountRecordTypeInfo = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
       Account hotel = new Account(
            Name = 'Hotel',
            Payment_Type__c = 'Booking Fee',
            A_Show_Payment_Page__c = true,
            Booking_Fees__c = 5,
            Show_Babysitting_while_booking__c = true,
            Lock_after_hours_for_partner__c = 24,
            A_RM_s_Email__c = 'sridhar@gmail.com',
            CurrencyIsoCode = 'EUR',
            Display__c = true,
            Hotel_type__c = 'HOTEL client',
            RecordTypeId = accountRecordTypeInfo.get('Hotel').getRecordTypeId()
        );
        
        insert hotel;
        // Test data
        Contract hotelClubToDelete = new Contract(AccountId=hotel.Id);
        insert hotelClubToDelete;
        
        // Call the method
        Test.startTest();
        InventorySetupController.deleteHotelClubRecord(hotelClubToDelete.Id);
        Test.stopTest();
        
        // Verify
        
    }
    @isTest
    static void testCreateInventoryProducts() {
           Map<String, Schema.RecordTypeInfo> accountRecordTypeInfo = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
       Account hotel = new Account(
            Name = 'Hotel',
            Payment_Type__c = 'Booking Fee',
            A_Show_Payment_Page__c = true,
            Booking_Fees__c = 5,
            Show_Babysitting_while_booking__c = true,
            Lock_after_hours_for_partner__c = 24,
            A_RM_s_Email__c = 'sridhar@gmail.com',
            CurrencyIsoCode = 'EUR',
            Display__c = true,
            Hotel_type__c = 'HOTEL client',
            RecordTypeId = accountRecordTypeInfo.get('Hotel').getRecordTypeId()
        );
        
        insert hotel;
        // Test data
        Contract hotelClub = new Contract(AccountId=hotel.Id);
        hotelClub.Opening_Days__c = 'Monday;Tuesday;Wednesday';
        hotelClub.Closing_Days__c = 'Thursday;Friday;Saturday;Sunday';
        insert hotelClub;
        // Test data
        String startDate = '2024-04-01';
        String endDate = '2024-04-05';
        Id hotelClubId = hotelClub.Id; // Create a test hotel club record
        Integer columnOrder = 1;
        String ageStaffRecordsJSON = '[{"ageRange":"5-8","From_Age":"5","To_Age":"8"},{"ageRange":"9-12","From_Age":"9","To_Age":"12"}]';
        String sessionRecordsJSON = '[{"Session_Name":"Morning Session","Staff":"3","Ratio":"5","Cost":"100","openingHours":"08:00-12:00"},{"Session_Name":"Afternoon Session","Staff":"2","Ratio":"8","Cost":"150","openingHours":"13:00-17:00"}]';
        
        Id createdHotelClubId = InventorySetupController.createInventoryProducts(startDate, endDate, hotelClubId, columnOrder, ageStaffRecordsJSON, sessionRecordsJSON);
       
    }
    @isTest
    static void testCreateDiscountRecords() {
          Map<String, Schema.RecordTypeInfo> accountRecordTypeInfo = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
       Account hotel = new Account(
            Name = 'Hotel',
            Payment_Type__c = 'Booking Fee',
            A_Show_Payment_Page__c = true,
            Booking_Fees__c = 5,
            Show_Babysitting_while_booking__c = true,
            Lock_after_hours_for_partner__c = 24,
            A_RM_s_Email__c = 'sridhar@gmail.com',
            CurrencyIsoCode = 'EUR',
            Display__c = true,
            Hotel_type__c = 'HOTEL client',
            RecordTypeId = accountRecordTypeInfo.get('Hotel').getRecordTypeId()
        );
        
        insert hotel;
        // Test data
        Contract hotelClub = new Contract(AccountId=hotel.Id);
        insert hotelClub;
        // Test data
        Id hotelId = hotel.Id;
        Id hotelClubId = hotelClub.Id;
         
        List<String> selectedOptions = new List<String>{'', ''};
        String discountRecordsJSON = '[{"Type":"Vertical","Session_Types":"Morning","Min_No":"2","Amount":"10","From_Date":"2024-04-01","To_Date":"2024-04-05"},{"Type":"Horizontal","Session_Types":"Afternoon","Min_No":"3","Amount":"15","From_Date":"2024-04-10","To_Date":"2024-04-15"}]';
        
        
        InventorySetupController.createDiscountRecords(hotelId, selectedOptions, hotelClubId, discountRecordsJSON);
       
    }
}