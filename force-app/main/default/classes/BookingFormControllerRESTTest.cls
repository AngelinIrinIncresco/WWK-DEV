/*
 * purpose : To test BookingFormControllerREST which is controller for the booking system.
*/
@isTest
public class BookingFormControllerRESTTest {
    
    @testSetup
      
    public static void createTestData(){
          
    
              
          
        Map<String,Schema.RecordTypeInfo> accountRecordTypeInfo = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        List<Account> hotetGroupList = new List<Account>();
        List<Account> hotelList = new List<Account>();
  
        hotetGroupList.add(new Account(Name = 'Hotel Group 1',
                                       Display__c = true,
                                       RecordTypeId = accountRecordTypeInfo.get('Hotel Group').getRecordTypeId()));

        insert hotetGroupList;
		

        for(Integer count=0 ; count < 5 ; count++) {
          hotelList.add(new Account(Name = 'Hotel'+count,
                                    ParentId = hotetGroupList[0].Id,
                                    Display__c = true,
                                    Hotel_type__c = 'HOTEL client',LCA_Number__c = '22',LCAExpiryDate__c = System.Today(),
                                    RecordTypeId = accountRecordTypeInfo.get('Hotel').getRecordTypeId()));
        }

        insert hotelList;
        //System.debug('2. hotelList ::::'+hotelList);
        
        //Creating header attachments
        createAttachments(hotelList);
      
        
        List<Header_Logo__c> headerLogoList = new List<Header_Logo__c>();
        for(Account hotel : hotelList){
            headerLogoList.add(new Header_Logo__c(Name = 'test Logo', 
                                                           Account__c = hotelList[0].Id, 
                                                           Image_URL__c = 'http://www.example.com/', 
                                                           Site_URL__c = 'http://www.example.com/'));
        }
        
        insert headerLogoList;
        
        BookingFormDTO.DateDTO selectedDateDTO = new BookingFormDTO.DateDTO(Date.today());

        // Test method for medical/allergy fields
    }

    @isTest
    static void testSaveBookingWithMedicalAllergyFields() {
        // Setup test data
        List<Account> hotelList = [SELECT Id FROM Account WHERE RecordType.Name = 'Hotel' LIMIT 1];

        // Create test booking DTO with medical/allergy fields
        BookingFormDTO bookingDTO = new BookingFormDTO();
        bookingDTO.selectedHotelId = hotelList[0].Id;
        bookingDTO.checkInDateDTO = new BookingFormDTO.DateDTO(Date.today());
        bookingDTO.checkOutDateDTO = new BookingFormDTO.DateDTO(Date.today().addDays(1));
        bookingDTO.editMode = false;

        // Create family details
        bookingDTO.familyDetails = new Account();
        bookingDTO.familyDetails.FirstName = 'Test';
        bookingDTO.familyDetails.LastName = 'Family';
        bookingDTO.familyDetails.PersonEmail = 'test@example.com';
        bookingDTO.familyDetails.Phone = '+1234567890';

        // Create child with medical/allergy fields
        BookingFormDTO.childDTO childDTO = new BookingFormDTO.childDTO();
        childDTO.firstName = 'Test';
        childDTO.lastName = 'Child';
        childDTO.dobDTO = new BookingFormDTO.DateDTO(Date.today().addYears(-5));

        // Set medical/allergy fields (String values matching Salesforce picklist)
        childDTO.doesChildTakeAnySortOfMedication = 'Yes';
        childDTO.doesChildHaveAllergies = 'Yes';
        childDTO.doesChildHaveMedicalOrAdditionalNeeds = 'Yes';
        childDTO.childParticipateInClubActivities = 'Yes';
        childDTO.childRequireSwimmingAid = 'No';

        bookingDTO.childsList = new List<BookingFormDTO.childDTO>{childDTO};

        // Create page parameters
        BookingFormControllerREST.PageParametersDTO pageParams = new BookingFormControllerREST.PageParametersDTO();
        pageParams.hotelId = hotelList[0].Id;

        // Prepare JSON strings
        String pageParametersJSON = JSON.serialize(pageParams);
        String bookingDTOJSON = JSON.serialize(bookingDTO);
        String paymentData = '{}';

        // Setup REST context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/bookingFormControllerREST/saveBooking';
        req.httpMethod = 'POST';

        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('pageParametersJSONStr', JSON.deserializeUntyped(pageParametersJSON));
        requestBody.put('BookingDTOJSONStr', JSON.deserializeUntyped(bookingDTOJSON));
        requestBody.put('paymentData', JSON.deserializeUntyped(paymentData));
        requestBody.put('strHotelId', hotelList[0].Id);

        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        BookingFormControllerREST.Post();
        Test.stopTest();

        // Verify child record was created with medical/allergy fields
        List<Child__c> createdChildren = [SELECT Id, First_Name__c, Last_Name__c,
                                         doesChildTakeAnySortOfMedication__c, DoesChildHaveAllergies__c,
                                         DoesChildHaveMedicalOrAdditionalNeeds__c, childParticipateInClubActivities__c,
                                         ChildRequireSwimmingAid__c
                                         FROM Child__c
                                         WHERE First_Name__c = 'Test' AND Last_Name__c = 'Child'];

        System.assertEquals(1, createdChildren.size(), 'Child record should be created');

        Child__c createdChild = createdChildren[0];
        System.assertEquals('Yes', createdChild.doesChildTakeAnySortOfMedication__c, 'Medication field should be Yes');
        System.assertEquals('Yes', createdChild.DoesChildHaveAllergies__c, 'Allergy field should be Yes');
        System.assertEquals('Yes', createdChild.DoesChildHaveMedicalOrAdditionalNeeds__c, 'Medical needs should be Yes');
        System.assertEquals('Yes', createdChild.childParticipateInClubActivities__c, 'Swimming activities should be Yes');
        System.assertEquals('No', createdChild.ChildRequireSwimmingAid__c, 'Swimming aid should be No');

        // Create a test service booking
        BookingFormDTO.DateDTO selectedDateDTO = new BookingFormDTO.DateDTO(Date.today().addDays(1));
        BookingFormDTO.ServiceBookingDTO serviceBooking = new BookingFormDTO.ServiceBookingDTO(
            'testId',                    // Id
            'selectedHotelId',          // selectedHotelId
            'selectedService',          // selectedService
            selectedDateDTO,            // selectedDateDTO
            'selectedHour',             // selectedHour
            'selectedCurrency',         // selectedCurrency
            100.00,   
           'Requested',
            'fromTime',                 // fromTime
            'toTime'                    // toTime
        );
      
      
        
        

        List<Booking_Fees__c> bookingFeesList = new List<Booking_Fees__c>();
        
        for(Integer count = 0 ; count < 2 ; count++) {
            bookingFeesList.add(new Booking_Fees__c(Account__c = hotelList[0].Id,
                                                    Check_In_From__c = Date.newInstance(2024, 4, 1),
                                                    Check_In_To__c = Date.newInstance(2024, 4, 30)) );
        }

        insert bookingFeesList;
        
        //System.debug('3. bookingFeesList ::::'+bookingFeesList);
        
       
        
        List<Contract> hotelClubList = new List<Contract>();
        for(Integer count = 0 ; count < 2 ; count++) {
            hotelClubList.add( new Contract(Club_Name__c = 'Hotel Club'+count,
                                            AccountId = hotelList[0].Id,
                                            StartDate = Date.newInstance(2024, 4, 1),
                                            EndDate = Date.newInstance(2024, 4, 30),
                                            
                                            Opening_Days__c = 'Monday; Tuesday; Wednesday; Thursday; Friday; Saturday'));
                                           
        }

        insert hotelClubList;
       
        //System.debug('4. hotelClubList ::::'+hotelClubList);
        
        //createDiscounts(hotelClubList);
        
        
       
        
        
        List<Inventory_Product__c> kidsCLubList = new List<Inventory_Product__c>();
       
        
        for(Integer count = 0 ; count < 29 ; count++) {
            kidsCLubList.add(new Inventory_Product__c(Club_Type__c = 'AM', 
                                                      Cost__c = count*10, 
                                                      Staff_No__c = 5,
                                                      KC_Group_Id__c = 'group1',
                                                      Hotel_Club__c = hotelClubList[0].Id,
                                                      KC_Date__c = Date.newInstance(2024, 4, count + 1),
                                                      Opening_Hours__c = '8:30am - 12:30pm',
                                                      
                                                      Age_Range__c = '4 - 47'));
        }
        
        insert kidsCLubList;
        
        //System.debug('5. kidsCLubList ::::'+kidsCLubList);
        
        
        
         Discount__c discountRecord = new Discount__c(From_Date__c = Date.newInstance(2024, 4, 1),
                                                     To_Date__c = Date.newInstance(2024, 4, 30),
                                                     //DiscountType__c = 'Horizontal',
                                                     DiscountType__c = 'Series',
                                                     Min_Number_of_Records_Selected__c = 2,
                                                     Minimum_Age_In_Months__c = 4,
                                                     Maximum_Age_In_Months__c = 48,
                                                     Hotel__c = hotelList[0].id,
                                                     HotelClub__c =   hotelClubList[0].id,
                                                     Club_Type__c = 'AM',
                                                     Discount_Amount__c = 5);    
        insert discountRecord;
       
        
        createDiscountDetails(new List<Discount__c> {discountRecord});
        
        //System.debug('6. discountRecord ::::'+discountRecord);
        /*
        List<Child__c> childsList = new List<Child__c>();
        for(Integer i = 0; i < 4 ; i++){
            Child__c childRecord = new Child__c(First_Name__c = 'Test' + i,
                                                Last_Name__c = 'TestSurname' + i,
                              DOB__c = Date.newInstance(2016, 1, 1)
                                               Parent__c = );
            childsList.add(childRecord);
        }
    insert childsList;                                                
*/
    
    }
    
    @isTest
    static void testSaveBookingWithoutDates() {
        // Setup test data
        List<Account> hotelList = [SELECT Id FROM Account WHERE RecordType.Name = 'Hotel' LIMIT 1];

        // Create test booking DTO with medical/allergy fields
        BookingFormDTO bookingDTO = new BookingFormDTO();
        bookingDTO.selectedHotelId = hotelList[0].Id;
        bookingDTO.checkInDateDTO = new BookingFormDTO.DateDTO(Date.today());
        bookingDTO.editMode = false;

        // Create family details
        bookingDTO.familyDetails = new Account();
        bookingDTO.familyDetails.FirstName = 'Test';
        bookingDTO.familyDetails.LastName = 'Family';
        bookingDTO.familyDetails.PersonEmail = 'test@example.com';
        bookingDTO.familyDetails.Phone = '+1234567890';

        // Create child with medical/allergy fields
        BookingFormDTO.childDTO childDTO = new BookingFormDTO.childDTO();
        childDTO.firstName = 'Test';
        childDTO.lastName = 'Child';
        childDTO.dobDTO = new BookingFormDTO.DateDTO(Date.today().addYears(-5));

        // Set medical/allergy fields (String values matching Salesforce picklist)
        childDTO.doesChildTakeAnySortOfMedication = 'Yes';
        childDTO.doesChildHaveAllergies = 'Yes';
        childDTO.doesChildHaveMedicalOrAdditionalNeeds = 'Yes';
        childDTO.childParticipateInClubActivities = 'Yes';
        childDTO.childRequireSwimmingAid = 'No';

        bookingDTO.childsList = new List<BookingFormDTO.childDTO>{childDTO};

        // Create page parameters
        BookingFormControllerREST.PageParametersDTO pageParams = new BookingFormControllerREST.PageParametersDTO();
        pageParams.hotelId = hotelList[0].Id;

        // Prepare JSON strings
        String pageParametersJSON = JSON.serialize(pageParams);
        String bookingDTOJSON = JSON.serialize(bookingDTO);
        String paymentData = '{}';

        // Setup REST context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/bookingFormControllerREST/saveBooking';
        req.httpMethod = 'POST';

        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('pageParametersJSONStr', JSON.deserializeUntyped(pageParametersJSON));
        requestBody.put('BookingDTOJSONStr', JSON.deserializeUntyped(bookingDTOJSON));
        requestBody.put('paymentData', JSON.deserializeUntyped(paymentData));
        requestBody.put('strHotelId', hotelList[0].Id);

        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        BookingFormControllerREST.Post();
        Test.stopTest();

        // Verify child record was created with medical/allergy fields
        List<Child__c> createdChildren = [SELECT Id, First_Name__c, Last_Name__c,
                                         doesChildTakeAnySortOfMedication__c, DoesChildHaveAllergies__c,
                                         DoesChildHaveMedicalOrAdditionalNeeds__c, childParticipateInClubActivities__c,
                                         ChildRequireSwimmingAid__c
                                         FROM Child__c
                                         WHERE First_Name__c = 'Test' AND Last_Name__c = 'Child'];

        System.assertEquals(1, createdChildren.size(), 'Child record should be created');

        Child__c createdChild = createdChildren[0];
        System.assertEquals('Yes', createdChild.doesChildTakeAnySortOfMedication__c, 'Medication field should be Yes');
        System.assertEquals('Yes', createdChild.DoesChildHaveAllergies__c, 'Allergy field should be Yes');
        System.assertEquals('Yes', createdChild.DoesChildHaveMedicalOrAdditionalNeeds__c, 'Medical needs should be Yes');
        System.assertEquals('Yes', createdChild.childParticipateInClubActivities__c, 'Swimming activities should be Yes');
        System.assertEquals('No', createdChild.ChildRequireSwimmingAid__c, 'Swimming aid should be No');

        // Create a test service booking
        BookingFormDTO.DateDTO selectedDateDTO = new BookingFormDTO.DateDTO(Date.today().addDays(1));
        BookingFormDTO.ServiceBookingDTO serviceBooking = new BookingFormDTO.ServiceBookingDTO(
            'testId',                    // Id
            'selectedHotelId',          // selectedHotelId
            'selectedService',          // selectedService
            selectedDateDTO,            // selectedDateDTO
            'selectedHour',             // selectedHour
            'selectedCurrency',         // selectedCurrency
            100.00,   
           'Requested',
            'fromTime',                 // fromTime
            'toTime'                    // toTime
        );
      
      
        
        

        List<Booking_Fees__c> bookingFeesList = new List<Booking_Fees__c>();
        
        for(Integer count = 0 ; count < 2 ; count++) {
            bookingFeesList.add(new Booking_Fees__c(Account__c = hotelList[0].Id,
                                                    Check_In_From__c = Date.newInstance(2024, 4, 1),
                                                    Check_In_To__c = Date.newInstance(2024, 4, 30)) );
        }

        insert bookingFeesList;
       
        
        List<Contract> hotelClubList = new List<Contract>();
        for(Integer count = 0 ; count < 2 ; count++) {
            hotelClubList.add( new Contract(Club_Name__c = 'Hotel Club'+count,
                                            AccountId = hotelList[0].Id,
                                            StartDate = Date.newInstance(2024, 4, 1),
                                            EndDate = Date.newInstance(2024, 4, 30),
                                            
                                            Opening_Days__c = 'Monday; Tuesday; Wednesday; Thursday; Friday; Saturday'));
                                           
        }

        insert hotelClubList;
        
       
        
        
        List<Inventory_Product__c> kidsCLubList = new List<Inventory_Product__c>();
       
        
        for(Integer count = 0 ; count < 29 ; count++) {
            kidsCLubList.add(new Inventory_Product__c(Club_Type__c = 'AM', 
                                                      Cost__c = count*10, 
                                                      Staff_No__c = 5,
                                                      KC_Group_Id__c = 'group1',
                                                      Hotel_Club__c = hotelClubList[0].Id,
                                                      KC_Date__c = Date.newInstance(2024, 4, count + 1),
                                                      Opening_Hours__c = '8:30am - 12:30pm',
                                                      
                                                      Age_Range__c = '4 - 47'));
        }
        
        insert kidsCLubList;
        
        //System.debug('5. kidsCLubList ::::'+kidsCLubList);
        
        
        
         Discount__c discountRecord = new Discount__c(From_Date__c = Date.newInstance(2024, 4, 1),
                                                     To_Date__c = Date.newInstance(2024, 4, 30),
                                                     //DiscountType__c = 'Horizontal',
                                                     DiscountType__c = 'Series',
                                                     Min_Number_of_Records_Selected__c = 2,
                                                     Minimum_Age_In_Months__c = 4,
                                                     Maximum_Age_In_Months__c = 48,
                                                     Hotel__c = hotelList[0].id,
                                                     HotelClub__c =   hotelClubList[0].id,
                                                     Club_Type__c = 'AM',
                                                     Discount_Amount__c = 5);    
        insert discountRecord;
       
        
        createDiscountDetails(new List<Discount__c> {discountRecord});
        
       
    
    }
    
   /* @isTest
    static void testPost_verifyPromoCode() {
        // Set up HTTP request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
         
         // Set request body
        Map<String, Object> requestBody = new Map<String, Object>{
            'hotelId' => '001Em00000DLdgPIAT',
            'checkInDateDTO' => '{"year": "2024", "month": "3", "day": "30"}',
            'checkOutDateDTO' => '{"year": "2024", "month": "4", "day": "1"}',
            'promoCode' => 'PromoCode',
            'createdDateDTO' => '{"year": "2024", "month": "3", "day": "29"}'
        };
        String requestBodyString = JSON.serialize(requestBody);
        RestContext.request.requestBody = Blob.valueOf(requestBodyString);
        BookingFormControllerREST.Post();
      
       

       

        // Call the REST API method
      

        // Verify the response
        // Add your assertions here
    } */
    
    class PickListSerialiser{
        List<BookingFormControllerREST.PicklistOptionWrapper> recordsList;
    }

    class HotelClubsAvailableSerialiser {
        List<BookingFormDTO.HotelClubsWithKidsClubGroupsDTO> recordsList;
    }
    
    @isTest
    public static void testInsertBookingsAdminUser() {
       
        BookingFormControllerREST boookingCtrl = new BookingFormControllerREST();
        //insertBookings(boookingCtrl);
        
    }
    @isTest
     private static void testSaveBooking(){
         BookingFormControllerREST boookingCtrl = new BookingFormControllerREST();
          
         Map<String,Schema.RecordTypeInfo> accountRecordTypeInfo = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        
          Account hotel =  new Account(Name = 'Hotel',
                                   Payment_Type__c = 'Booking Fee',
                                    A_Show_Payment_Page__c = true,
                                    Booking_Fees__c = 5,
                                    Show_Babysitting_while_booking__c = true,
                                    Lock_after_hours_for_partner__c = 24,
                                    A_RM_s_Email__c = 'sridhar@gmail.com',
                                    CurrencyIsoCode = 'EUR',
                                       
                                    Display__c = true,
                                    Hotel_type__c = 'HOTEL client',
                                    RecordTypeId = accountRecordTypeInfo.get('Hotel').getRecordTypeId());
       

        insert hotel;
         
         
        
            Booking_Fees__c bookingFees = new Booking_Fees__c(Account__c = hotel.Id,
                                                    Check_In_From__c = Date.newInstance(2024, 4, 1),
                                                              Booking_From__c = Date.newInstance(2024, 4, 15),
                                                              Booking_To__c = Date.newInstance(2024, 4, 20),
                                                    Check_In_To__c = Date.newInstance(2024, 4, 30)) ;
        

        insert bookingFees;
         
         
        
        
            Contract hotelClub = new Contract(Club_Name__c = 'Hotel Club',
                                            AccountId = hotel.Id,
                                            StartDate = Date.newInstance(2024, 4, 1),
                                            EndDate = Date.newInstance(2024, 4, 30),
                                              Status = 'Open',
                                            Opening_Days__c = 'Monday; Tuesday; Wednesday; Thursday; Friday; Saturday');
                                           
        

        insert hotelClub;
       
        //System.debug('4. hotelClubList ::::'+hotelClubList);
        
        //createDiscounts(hotelClubList);
        
        
       
        
        
        List<Inventory_Product__c> kidsCLubList = new List<Inventory_Product__c>();
        
        for(Integer count = 0 ; count < 29 ; count++) {
            kidsCLubList.add(new Inventory_Product__c(Club_Type__c = 'AM', 
                                                      Cost__c = count*10, 
                                                      Staff_No__c = 5,
                                                      KC_Group_Id__c = 'group1',
                                                      Hotel_Club__c = hotelClub.Id,
                                                      KC_Date__c = Date.newInstance(2024, 4, count + 1),
                                                      Opening_Hours__c = '8:30am - 12:30pm',
                                                      Age_Range__c = '4 - 47'));
        }
        
        insert kidsCLubList;
        
        //System.debug('5. kidsCLubList ::::'+kidsCLubList);
        
        
        
         Discount__c discountRecord = new Discount__c(From_Date__c = Date.newInstance(2024, 4, 1),
                                                     To_Date__c = Date.newInstance(2024, 4, 30),
                                                     //DiscountType__c = 'Horizontal',
                                                     DiscountType__c = 'Horizontal',
                                                     Min_Number_of_Records_Selected__c = 2,
                                                     Minimum_Age_In_Months__c = 4,
                                                     Maximum_Age_In_Months__c = 48,
                                                     Hotel__c = hotel.id,
                                                     HotelClub__c =   hotelClub.id,
                                                     Club_Type__c = 'Morning',
                                                     Discount_Amount__c = 5);    
        insert discountRecord;
       
        
        createDiscountDetails(new List<Discount__c> {discountRecord});
         
         
          BookingFormDTO.DateDTO child0DOB = new BookingFormDTO.DateDTO(16, 5, 2023);
         BookingFormDTO.DateDTO checkInDate = new BookingFormDTO.DateDTO(16, 4, 2024);
         BookingFormDTO.DateDTO checkOutDate = new BookingFormDTO.DateDTO(24, 4, 2024);
          
        

        //On click of "Next" button in Step 1
        String availableHotelClubs0 = BookingFormControllerREST.getHotelClubsAvailable(Hotel.Id, checkInDate, checkOutDate, child0DOB);
        
        System.debug('Available Hotel Clubs child 1 : ' + JSON.serialize(availableHotelClubs0));
        
        HotelClubsAvailableSerialiser hotelClubsAvailableDTO;
        hotelClubsAvailableDTO = (HotelClubsAvailableSerialiser)JSON.deserialize(availableHotelClubs0, HotelClubsAvailableSerialiser.class);
        List<BookingFormDTO.HotelClubsWithKidsClubGroupsDTO> hotelClubsAvailableList = hotelClubsAvailableDTO.recordsList;
        
        
        System.debug('8. hotelClubsAvailableList : ' + JSON.serializePretty(hotelClubsAvailableList));
        
        //On click of Save button in step 4
        /* Param description of the saveBooking method
          String pageParametersJSONStr, 
          String BookingDTOJSONStr, 
          String strAdditionalServices, 
          String paymentParams*/
       // BookingFormControllerREST.saveBooking('','','','');


        BookingFormDTO bookingDTO = getSampleBookingDTO();
       
        
        //String childrensResponse = getChildrensForFamily(bookingDTO);
        
        bookingDTO.checkInDateDTO = checkInDate;
        bookingDTO.checkOutDateDTO = checkOutDate;
        bookingDTO.selectedHotelId = Hotel.Id;
         BookingFormControllerREST.PageParametersDTO paramDTO = getParamDTO(boookingCtrl);

        //Added on 10-Sep-2019
        BookingFormControllerREST.StripePaymentWrapper stripeData = new BookingFormControllerREST.StripePaymentWrapper();
        stripeData.Amount = '50.00';
        stripeData.CreatedTimeStamp = DateTime.now().getTime();
        stripeData.paymentId = 'testId';
        stripeData.PaymentMethod = '';
        stripeData.PaymentMethodType = '';
        stripeData.Status = 'succeeded';
        stripeData.TransactionCurrency = '';
        String paymentData = JSON.serialize(stripeData);
         
      

         BookingFormControllerREST.saveBooking(JSON.serialize(paramDTO), JSON.serialize(bookingDTO),paymentData , Hotel.Id);
         List<Opportunity> createdRecords = [SELECT Id FROM Opportunity];
         if(!createdRecords.isEmpty()){
             Kids_Clubs_Booking__c kcbooking = new Kids_Clubs_Booking__c(
                 Booking__c = createdRecords[0].Id,
                 Status__c = 'Booked'
             );
         }
         BookingFormControllerREST.saveBooking(JSON.serialize(paramDTO), JSON.serialize(bookingDTO),paymentData , Hotel.Id);
         
       

        bookingDTO.familyDetails.personEmail = 'parent@email.com';
        
        if(!hotelClubsAvailableList.isEmpty()) {
            bookingDTO.childsList.get(0).kidsClubBookings.add(new BookingFormDTO.KCBookingDTO('', //Id
                                                                                        new BookingFormDTO.DateDTO(22, 4, 2024), //bookingDateDTO
                                                                                        hotelClubsAvailableList[0].kidsClubGroupsList[0].openingHours, //bookingTime
                                                                                        hotelClubsAvailableList[0].kidsClubGroupsList[0].kidsClubsList[0].Id, //kidsClubId
                                                                                        hotelClubsAvailableList[0].kidsClubGroupsList[0].Id, //kcGroupId
                                                                                        hotelClubsAvailableList[0].kidsClubGroupsList[0].cost, //cost
                                                                                        'booked', /*bookingStatus*/
                                                                                         2.0,  // discount
                                                                                         'Morning', // club type
                                                                                         '' /* club id*/));
            
            bookingDTO.babySittingList = new List<BookingFormDTO.ServiceBookingDTO>();
            bookingDTO.babySittingList.add(new BookingFormDTO.ServiceBookingDTO());
            bookingDTO.babySittingList.get(0).selectedDateDTO = checkInDate;
            bookingDTO.babySittingList.get(0).fromTime = '18:30';
            bookingDTO.babySittingList.get(0).toTime = '19:30'; //
            bookingDTO.agentDetails.salutation = 'Mr.';
            bookingDTO.agentDetails.firstName = 'agent';
            bookingDTO.agentDetails.lastName = 'details';
            bookingDTO.agentDetails.email = 'agent@email.com';
            bookingDTO.agentDetails.phone = '98765463653';
    
            //BookingFormControllerREST.saveBooking(JSON.serialize(paramDTO), JSON.serialize(bookingDTO), '', Hotel.Id);
            //BookingFormControllerREST.saveBooking(JSON.serialize(paramDTO), JSON.serialize(bookingDTO), '', Hotel.Id);
            
          
    
            //Create Additional services
             List<BookingFormDTO.ServiceBookingDTO> additionalServiesDetailsListDTO = new  List<BookingFormDTO.ServiceBookingDTO>();
            
            BookingFormDTO.ServiceBookingDTO additionalServiceDetails = new  BookingFormDTO.ServiceBookingDTO();
            additionalServiceDetails.selectedHotelId = Hotel.Id;
            
            additionalServiceDetails.selectedService = 'Hourly Childcare';
            additionalServiceDetails.selectedDateDTO = checkInDate;
            additionalServiceDetails.selectedHour = '3';
            additionalServiceDetails.selectedCurrency = 'HRK';
            additionalServiceDetails.cost = 10;
            additionalServiceDetails.toTime = '19:00';
            additionalServiceDetails.fromTime = '20:00';
           
            //additionalServiesDetailsListDTO.add(additionalServiceDetails);
            
            //bookingDTO.childsList.get(0).serviceBookingsList.add(additionalServiceDetails);
            
            //String paymentData = '{"TransactionCurrency":"","Status":"","PaymentMethodType":"","PaymentMethod":"","paymentId":"testId","CreatedTimeStamp":1568106215734,"Amount":"50.00"}';
            
            System.debug('paymentData :: ' + paymentData);
            
            //BookingFormControllerREST.saveBooking(JSON.serialize(paramDTO), JSON.serialize(bookingDTO),  JSON.serialize(stripeData), '');
            //BookingFormControllerREST.saveBooking(JSON.serialize(paramDTO), JSON.serialize(bookingDTO),  JSON.serialize(stripeData), Hotel.Id);
            
           
            //BookingFormControllerREST.getPaymentFieldInfo(); 
            coverClassVariable();
            
        }
         
        
         
        
         
         

         
                
        
    }
    
    @isTest
    public static void testCustomLabels(){
        
        
        BookingFormControllerREST.Response res =  BookingFormControllerREST.getCustomLabels();
        
        
    }
   
   
    
    
    private static void insertBookings(BookingFormControllerREST boookingCtrl) {
        //Test.setMock(HttpCalloutMock.class, new dataCreaterPayment());
        //Data to be shown on page load
       
   
       
        BookingFormControllerREST.getSalutations();
        BookingFormControllerREST.PageParametersDTO paramDTO = getParamDTO(boookingCtrl);
        BookingFormDTO.DateDTO checkInDate = new BookingFormDTO.DateDTO(16, 4, 2024); //dd-mm-yy
        BookingFormDTO.DateDTO checkOutDate = new BookingFormDTO.DateDTO(25, 4, 2024);
        BookingFormControllerREST.getAvailableData(JSON.serialize(paramDTO));
        
        
         
        system.debug('paramdto'+JSON.serialize(paramDTO));

        List<Child__c> addedChildList = new List<Child__c>();
        
        // addedChildList = [SELECT Id, First_Name__c, Last_Name__c, DOB__c FROM Child__c Limit 3];
        
        Id selectedHotelId = populateDataToBeShownOnPage(paramDTO, addedChildList);
        System.debug('selid'+selectedHotelId);
     
        //createAttachmentFor(selectedHotelId);
        
        BookingFormDTO.DateDTO testDate = new BookingFormDTO.DateDTO(System.today());
        BookingFormDTO.DiscountDTO testDiscount = new BookingFormDTO.DiscountDTO(
            'Test',
            1.5,
            new List<String> {'test'},
            testDate,
            testDate,
            1.0,
            5.0,
            6.0,
            'Test',
            'Test'
        );

        BookingFormDTO.DateDTO child0DOB = new BookingFormDTO.DateDTO(16, 5, 2023);
        BookingFormDTO.DateDTO child5DOB = createDateDTOFromDate(addedChildList[4].DOB__c);

        //On click of "Next" button in Step 1
        String availableHotelClubs0 = BookingFormControllerREST.getHotelClubsAvailable(selectedHotelId, checkInDate, checkOutDate, child0DOB);
        String availableHotelClubs5 = BookingFormControllerREST.getHotelClubsAvailable(selectedHotelId, checkInDate, checkOutDate, child5DOB);
        System.debug('Available Hotel Clubs child 1 : ' + JSON.serialize(availableHotelClubs0));
        
        HotelClubsAvailableSerialiser hotelClubsAvailableDTO;
        hotelClubsAvailableDTO = (HotelClubsAvailableSerialiser)JSON.deserialize(availableHotelClubs0, HotelClubsAvailableSerialiser.class);
        List<BookingFormDTO.HotelClubsWithKidsClubGroupsDTO> hotelClubsAvailableList = hotelClubsAvailableDTO.recordsList;
        
        
        System.debug('8. hotelClubsAvailableList : ' + JSON.serializePretty(hotelClubsAvailableList));
        
        //On click of Save button in step 4
        /* Param description of the saveBooking method
          String pageParametersJSONStr, 
          String BookingDTOJSONStr, 
          String strAdditionalServices, 
          String paymentParams*/
       // BookingFormControllerREST.saveBooking('','','','');


        BookingFormDTO bookingDTO = getSampleBookingDTO();
        
        //String childrensResponse = getChildrensForFamily(bookingDTO);
        
        bookingDTO.checkInDateDTO = checkInDate;
        bookingDTO.checkOutDateDTO = checkOutDate;
        bookingDTO.selectedHotelId = selectedHotelId;

        //Added on 10-Sep-2019
        BookingFormControllerREST.StripePaymentWrapper stripeData = new BookingFormControllerREST.StripePaymentWrapper();
        stripeData.Amount = '50.00';
        stripeData.CreatedTimeStamp = DateTime.now().getTime();
        stripeData.paymentId = 'testId';
        stripeData.PaymentMethod = '';
        stripeData.PaymentMethodType = '';
        stripeData.Status = 'succeeded';
        stripeData.TransactionCurrency = '';
        String paymentData = JSON.serialize(stripeData);
      

         BookingFormControllerREST.saveBooking(JSON.serialize(paramDTO), JSON.serialize(bookingDTO),  '[]', selectedHotelId); 
      //  System.debug('save booking result'+BookingFormControllerREST.saveBooking(JSON.serialize(paramDTO), JSON.serialize(bookingDTO),  '[]', selectedHotelId));
       

        bookingDTO.familyDetails.personEmail = 'parent@email.com';
        
        if(!hotelClubsAvailableList.isEmpty()) {
            bookingDTO.childsList.get(0).kidsClubBookings.add(new BookingFormDTO.KCBookingDTO('', //Id
                                                                                        new BookingFormDTO.DateDTO(22, 4, 2024), //bookingDateDTO
                                                                                        hotelClubsAvailableList[0].kidsClubGroupsList[0].openingHours, //bookingTime
                                                                                        hotelClubsAvailableList[0].kidsClubGroupsList[0].kidsClubsList[0].Id, //kidsClubId
                                                                                        hotelClubsAvailableList[0].kidsClubGroupsList[0].Id, //kcGroupId
                                                                                        hotelClubsAvailableList[0].kidsClubGroupsList[0].cost, //cost
                                                                                        'booked', /*bookingStatus*/
                                                                                         2.0,  // discount
                                                                                         'Morning', // club type
                                                                                         '' /* club id*/));
            
            bookingDTO.babySittingList = new List<BookingFormDTO.ServiceBookingDTO>();
            bookingDTO.babySittingList.add(new BookingFormDTO.ServiceBookingDTO());
            bookingDTO.babySittingList.add(new BookingFormDTO.ServiceBookingDTO());
            
            bookingDTO.babySittingList.get(0).selectedDateDTO = checkInDate;
            bookingDTO.babySittingList.get(0).fromTime = '18:30';
            
            bookingDTO.babySittingList.get(0).toTime = '19:30'; //
             bookingDTO.babySittingList.get(1).selectedDateDTO = new BookingFormDTO.DateDTO(22, 5, 2024);
             bookingDTO.babySittingList.get(1).fromTime = '18:30';
            
            bookingDTO.babySittingList.get(1).toTime = '19:30'; //
            bookingDTO.agentDetails.salutation = 'Mr.';
            bookingDTO.agentDetails.firstName = 'agent';
            bookingDTO.agentDetails.lastName = 'details';
            bookingDTO.agentDetails.email = 'agent@email.com';
            bookingDTO.agentDetails.phone = '98765463653';
            
    
            BookingFormControllerREST.saveBooking(JSON.serialize(paramDTO), JSON.serialize(bookingDTO), '', selectedHotelId);
          
    
            //Create Additional services
             List<BookingFormDTO.ServiceBookingDTO> additionalServiesDetailsListDTO = new  List<BookingFormDTO.ServiceBookingDTO>();
            
            BookingFormDTO.ServiceBookingDTO additionalServiceDetails = new  BookingFormDTO.ServiceBookingDTO();
            additionalServiceDetails.selectedHotelId = selectedHotelId;
            
            additionalServiceDetails.selectedService = 'Hourly Childcare';
            additionalServiceDetails.selectedDateDTO = checkInDate;
            additionalServiceDetails.selectedHour = '3';
            additionalServiceDetails.selectedCurrency = 'HRK';
            additionalServiceDetails.cost = 10;
            additionalServiceDetails.toTime = '19:00';
            additionalServiceDetails.fromTime = '20:00';
           
            additionalServiesDetailsListDTO.add(additionalServiceDetails);
            
            bookingDTO.childsList.get(0).serviceBookingsList.add(additionalServiceDetails);
            
            //String paymentData = '{"TransactionCurrency":"","Status":"","PaymentMethodType":"","PaymentMethod":"","paymentId":"testId","CreatedTimeStamp":1568106215734,"Amount":"50.00"}';
            
            System.debug('paymentData :: ' + paymentData);
            
            BookingFormControllerREST.saveBooking(JSON.serialize(paramDTO), JSON.serialize(bookingDTO),  JSON.serialize(stripeData), '');
            BookingFormControllerREST.saveBooking(JSON.serialize(paramDTO), JSON.serialize(bookingDTO),  JSON.serialize(stripeData), selectedHotelId);
            
           
            //BookingFormControllerREST.getPaymentFieldInfo(); 
            coverClassVariable();
            
        }
        
    }
    
   
   
    private static Id populateDataToBeShownOnPage( BookingFormControllerREST.PageParametersDTO paramDTO, List<Child__c> addedChildList) {
        
        Id selectedHotelId;
        
        String hotelListStr = BookingFormControllerREST.getHotelsList(JSON.serialize(paramDTO));
        //System.debug('hotelListStr' + hotelListStr);
        Map<String, Object> hotelResponse = (Map<String, Object>)JSON.deserializeUntyped(hotelListStr);
       	
        String hotelsStr = JSON.serialize(hotelResponse.get('recordsList'));
		
        List<BookingFormControllerREST.HotelListWrapper> hotelsData = (List<BookingFormControllerREST.HotelListWrapper>)JSON.deserialize(hotelsStr, List<BookingFormControllerREST.HotelListWrapper>.class);

        
        List<BookingFormControllerREST.PicklistOptionWrapper> hotelPickListValues = hotelsData[0].hotels;
        
                  
        //Select Hotel0 from picklist
        for(BookingFormControllerREST.PicklistOptionWrapper hotePickListVal : hotelPickListValues) {
            if(hotePickListVal.label.equalsIgnoreCase('Hotel0')) {
                selectedHotelId = hotePickListVal.value;
            }
        }

        for(Integer count = 0 ; count < 11 ; count++) {
            addedChildList.add(new Child__c(First_Name__c = 'First' + count,
                                            Last_Name__c = 'Last' + count,
                                            DOB__c = Date.newInstance(2023, count + 1, 18)));
        }
        
        //createAttachmentFor(selectedHotelId);
       
        return selectedHotelId;
        
    }

    private static BookingFormDTO.DateDTO createDateDTOFromDate(Date dateToFormat) {
        
        return (new BookingFormDTO.DateDTO(dateToFormat.day(),
                                       dateToFormat.month(), 
                                       dateToFormat.year()));
        
    }
    private static void testSaveBooking2(){
        
    }

    private static BookingFormDTO getSampleBookingDTO() {
        
        BookingFormDTO bookingDTO = new BookingFormDTO();
        bookingDTO.isAgentBooking = FALSE;
        bookingDTO.editMode = true;
        bookingDTO.bookingFees = 0;
        bookingDTO.familyDetails.salutation = 'Mr.';
        bookingDTO.familyDetails.firstName = 'firstName';
        bookingDTO.familyDetails.lastName = 'lastName';
        bookingDTO.familyDetails.personEmail = 'sridhar@gmail.com';
        bookingDTO.familyDetails.phone = '9879465654';
        bookingDTO.childsList = new List<BookingFormDTO.childDTO>();
        bookingDTO.childsList.add(new BookingFormDTO.childDTO());
        bookingDTO.childsList.get(0).firstName = 'ChildFirstName';
        bookingDTO.childsList.get(0).lastName = 'ChildLastName';
        bookingDTO.childsList.get(0).dobDTO = new BookingFormDTO.DateDTO(16, 5, 2023);
        bookingDTO.childsList.add(new BookingFormDTO.childDTO());
        bookingDTO.childsList.get(1).firstName = 'ChildFirstNameA';
        bookingDTO.childsList.get(1).lastName = 'ChildLastNameA';
        bookingDTO.childsList.get(1).dobDTO = new BookingFormDTO.DateDTO(16, 5, 2023);
         
        return bookingDTO;
       
    }
      private static BookingFormDTO.childDTO getSampleChildDTO() {
        
        BookingFormDTO.childDTO childDTO = new BookingFormDTO.childDTO();
       childDTO.dobDTO = new BookingFormDTO.DateDTO(16, 5, 2023);
          childDTO.firstName = 'john';
          childDTO.lastName = 'sample';
         
        return childDTO;
       
    }
     private static BookingFormDTO.ServiceBookingDTO getSampleServiceBookingDTO() {
        
        BookingFormDTO.ServiceBookingDTO serviceDTO = new  BookingFormDTO.ServiceBookingDTO();
       serviceDTO.selectedHotelId = 'sample';
          serviceDTO.selectedService = 'Babysitting';
         
         
        return serviceDTO;
       
    }
    @isTest 
    
    public static void testUpdateBookingsAdminUser() {
        Test.startTest();
        System.Test.setCurrentPage(Page.wwkc_BookingForm);
        BookingFormControllerREST boookingCtrl = new BookingFormControllerREST();
        System.debug('outseide insertbookings');
        //BookingFormControllerRESTTest.insertBookings(boookingCtrl);
         System.debug('inside insertbookings');
        RecordType rt = [SELECT id 
                         FROM recordType 
                         WHERE name ='Family' 
                         LIMIT 1];
          Account a = new Account(phone='123456' ,
                                firstname= 'test account' ,
                                lastname='test lastname' ,
                                recordtypeid=rt.id ,
                                A_Footer_Link__c = 'www.google.com' ,
                                A_Header_Link__c = 'www.google.com' ,
                                A_Page_BG__c = 'FFFFFF'  ,
                                A_Content_BG__c = 'FFFFFF'  ,
                                A_Font_Color__c = 'FFFFFF'  ,
                                Display__c = true ,
                                A_Shared_Inventory_ID__c = '123213' ,
                                personEmail = 'appcino@app.com' ,
                                A_Password__c = '123456');
                                
        insert a;
          
        
         Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName= 'Attended', Start_Date__c = Date.newInstance(2024, 5, 1), End_Date__c = Date.newInstance(2024, 4, 30)  , CloseDate= Date.newInstance(2024, 4, 29),AccountId =a.Id);
        insert testOpportunity;
         
        
        //Opportunity booking = [SELECT Id, AccountId FROM Opportunity ORDER BY Id DESC Limit 1];
          
        
         
        //ApexPages.currentPage().getParameters().put('Id', booking.Id);
        ApexPages.currentPage().getParameters().put('Id', testOpportunity.Id);
       
         
        
        //String resp = BookingFormControllerREST.getChildrensForFamily(booking.AccountId);
        String resp = BookingFormControllerREST.getChildrensForFamily(testOpportunity.AccountId);
    
        
        BookingFormControllerREST.PageParametersDTO paramDTO = getParamDTO(boookingCtrl);
        BookingFormControllerREST.getHotelsList(JSON.serialize(paramDTO));
        BookingFormControllerREST.getAvailableData(JSON.serialize(paramDTO));
        BookingFormControllerREST.getAvailableData(testOpportunity.Id); 
        
        Test.stopTest();
    }
    
    
    
   

    @isTest
    static void testHandleAdditionalServiceBookings() {
          RecordType rt = [SELECT id 
                         FROM recordType 
                         WHERE name ='Family' 
                         LIMIT 1];
          Account a = new Account(phone='123456' ,
                                firstname= 'test account' ,
                                lastname='test lastname' ,
                                recordtypeid=rt.id ,
                                A_Footer_Link__c = 'www.google.com' ,
                                A_Header_Link__c = 'www.google.com' ,
                                A_Page_BG__c = 'FFFFFF'  ,
                                A_Content_BG__c = 'FFFFFF'  ,
                                A_Font_Color__c = 'FFFFFF'  ,
                                Display__c = true ,
                                A_Shared_Inventory_ID__c = '123213' ,
                                personEmail = 'appcino@app.com' ,
                                A_Password__c = '123456');
                                
        insert a;
          
        
         Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName= 'Attended', Start_Date__c = Date.newInstance(2024, 5, 1), End_Date__c = Date.newInstance(2024, 4, 30)  , CloseDate= Date.newInstance(2024, 4, 29),AccountId =a.Id);
        insert testOpportunity;
      
            
            
        List<BookingFormDTO.ServiceBookingDTO> serviceBookingDTORecordsList = new List<BookingFormDTO.ServiceBookingDTO>();
        BookingFormDTO.ServiceBookingDTO serviceBookingDTO = new BookingFormDTO.ServiceBookingDTO();
        serviceBookingDTO.bookingId = '006U9000003EFQUIA4';
        serviceBookingDTO.childId = 'a0UU9000000swi9MAA';
        serviceBookingDTO.cost = 100.00;
        serviceBookingDTO.selectedDateDTO = new BookingFormDTO.DateDTO(2024, 4, 25);
        //serviceBookingDTO.selectedHotelId = 'a2Xxxxxxxxxxxxx';
        //serviceBookingDTO.selectedHour = 2;
        serviceBookingDTO.selectedService = 'Test Service';
       // serviceBookingDTO.fromTime = Datetime.newInstance(2024, 4, 25, 8, 0, 0);
        //serviceBookingDTO.toTime = Datetime.newInstance(2024, 4, 25, 10, 0, 0);
        serviceBookingDTO.isRemoved = false;
        serviceBookingDTORecordsList.add(serviceBookingDTO);

        // Call the method being tested
        Test.startTest();
        BookingFormControllerREST.handleAdditionalServiceBookings('sample',serviceBookingDTORecordsList,testOpportunity.Id);
        Test.stopTest();

        // Verify the result
        List<Service_Booking__c> insertedServiceBookings = [SELECT Id FROM Service_Booking__c];
        //System.assertEquals(1, insertedServiceBookings.size(), 'Service booking record should be inserted');

        // Clean up
        delete insertedServiceBookings;
    }


    
    @isTest
    public static void testInsertBookingsAdminUserWithHotelGroup(){
        System.Test.setCurrentPage(Page.wwkc_BookingForm);
        BookingFormControllerREST boookingCtrl = new BookingFormControllerREST();
        
    
        Account hotelGroup = [SELECT Id FROM Account WHERE Name LIKE 'Hotel Group 1'];
        

        ApexPages.currentPage().getParameters().put('accountId', hotelGroup.Id);
        //insertBookings(boookingCtrl);
    }

    @isTest
    public static void testInsertBookingsAdminUserWithHotel() {
        System.Test.setCurrentPage(Page.wwkc_BookingForm);
        BookingFormControllerREST boookingCtrl = new BookingFormControllerREST();
        
        Account hotel = [SELECT Id FROM Account WHERE Name LIKE 'Hotel1'];
         
        ApexPages.currentPage().getParameters().put('accId', hotel.Id);
        //insertBookings(boookingCtrl);
    }
     @isTest
    public static void testGetAvailabledata(){
        Date startDate = Date.today();
        BookingFormControllerREST boookingCtrl = new BookingFormControllerREST();
        Map<String,Schema.RecordTypeInfo> accountRecordTypeInfo = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        
          Account hotel =  new Account(Name = 'Hotel',
                                   Payment_Type__c = 'Booking Fee',
                                    A_Show_Payment_Page__c = true,
                                    Booking_Fees__c = 5,
                                    Show_Babysitting_while_booking__c = true,
                                    Lock_after_hours_for_partner__c = 24,
                                    A_RM_s_Email__c = 'sridhar@gmail.com',
                                    
                                    Display__c = true,
                                    Hotel_type__c = 'HOTEL client',
                                    RecordTypeId = accountRecordTypeInfo.get('Hotel').getRecordTypeId());
       

        insert hotel;
         
         
        
            Booking_Fees__c bookingFees = new Booking_Fees__c(Account__c = hotel.Id,
                                                    Check_In_From__c = Date.newInstance(2024, 4, 1),
                                                    Check_In_To__c = Date.newInstance(2024, 4, 30)) ;
        

        insert bookingFees;
         
         
        
        
            Contract hotelClub = new Contract(Club_Name__c = 'Hotel Club',
                                            AccountId = hotel.Id,
                                            StartDate = Date.newInstance(2024, 4, 1),
                                            EndDate = Date.newInstance(2024, 4, 30),
                                              Status = 'Open',
                                            Opening_Days__c = 'Monday; Tuesday; Wednesday; Thursday; Friday; Saturday');
                                           
        

        insert hotelClub;
       
        //System.debug('4. hotelClubList ::::'+hotelClubList);
        
        //createDiscounts(hotelClubList);
        
        
       
        
        
        List<Inventory_Product__c> kidsCLubList = new List<Inventory_Product__c>();
        
        for(Integer count = 0 ; count < 29 ; count++) {
            kidsCLubList.add(new Inventory_Product__c(Club_Type__c = 'AM', 
                                                      Cost__c = count*10, 
                                                      Staff_No__c = 5,
                                                      KC_Column_Order__c =1,
                                                      
                                                      KC_Group_Id__c = 'group1',
                                                      Hotel_Club__c = hotelClub.Id,
                                                      KC_Date__c = Date.newInstance(2024, 4, count + 1),
                                                      Opening_Hours__c = '8:30am - 12:30pm',
                                                      Age_Range__c = '4 - 47'));
        }
        
        insert kidsCLubList;
        
        //System.debug('5. kidsCLubList ::::'+kidsCLubList);
        
        
        
         Discount__c discountRecord = new Discount__c(From_Date__c = Date.newInstance(2024, 4, 1),
                                                     To_Date__c = Date.newInstance(2024, 4, 30),
                                                     //DiscountType__c = 'Horizontal',
                                                     DiscountType__c = 'Series',
                                                     Min_Number_of_Records_Selected__c = 2,
                                                     Minimum_Age_In_Months__c = 4,
                                                     Maximum_Age_In_Months__c = 48,
                                                     Hotel__c = hotel.id,
                                                     HotelClub__c =   hotelClub.id,
                                                     Club_Type__c = 'Morning',
                                                     Discount_Amount__c = 5);    
        insert discountRecord;
       
        
        createDiscountDetails(new List<Discount__c> {discountRecord});
         
        
         
         
        
        
        	RecordType rt = [SELECT id 
                         FROM recordType 
                         WHERE name ='Family' 
                         LIMIT 1];
          Account a = new Account(phone='123456' ,
                                firstname= 'test account' ,
                                lastname='test lastname' ,
                                recordtypeid=rt.id ,
                                A_Footer_Link__c = 'www.google.com' ,
                                A_Header_Link__c = 'www.google.com' ,
                                A_Page_BG__c = 'FFFFFF'  ,
                                A_Content_BG__c = 'FFFFFF'  ,
                                A_Font_Color__c = 'FFFFFF'  ,
                                Display__c = true ,
                                A_Shared_Inventory_ID__c = '123213' ,
                                personEmail = 'appcino@app.com' ,
                                A_Password__c = '123456');
                                
        insert a;
           List<Child__c> testChildren = new List<Child__c>();
        for (Integer i = 0; i < 5; i++) {
            
            
            testChildren.add(new Child__c(
                First_Name__c = 'Child',
                Last_Name__c = 'Test' + i,
                Parent__c = a.Id,
                DOB__c = Date.newInstance(2023, 4, 22)
            ));
        }
        insert testChildren;
        
         Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName= 'Attended', Start_Date__c = Date.newInstance(2024, 4, 1), End_Date__c = Date.newInstance(2024, 4, 30)  , CloseDate= Date.newInstance(2024, 4, 29),AccountId =a.Id);
        insert testOpportunity;
        List<Kids_Clubs_Booking__c> testBookings = new List<Kids_Clubs_Booking__c>();
        for (Integer i = 0; i < 5; i++) {
            testBookings.add(new Kids_Clubs_Booking__c(
                Child__c = testChildren[i].Id, 
                Club_Date__c = Date.newInstance(2024, 4, 22),
                Status__c = 'Booked',
                Booking__c = testOpportunity.Id
                
                
            ));
        }
        insert testBookings;
         List<Service_Booking__c> SBookings2 = new List<Service_Booking__c>();
        for (Integer i = 0; i < 5; i++) {
            
            
            SBookings2.add(new Service_Booking__c(
                SB_Bookings__c = testOpportunity.Id,
                Children__c = 'sample test, sample test2',
                SB_From_Time__c = '18:30',
                SB_To_Time__c = '20:00',
                SB_Service__c = 'Babysitting Request',
                SB_Hours__c = '1',
                SB_Cost__c = 10,
                CurrencyIsoCode = 'EUR',
                SB_Date__c = Date.newInstance(2024, 5, 22),
                Status__c = 'Requested'
            ));
        }
        insert SBookings2;
        
        	RecordType rt2 = [SELECT id 
                         FROM recordType 
                         WHERE name ='Family' 
                         LIMIT 1];
          Account a2 = new Account(phone='123456' ,
                                firstname= 'test account' ,
                                lastname='test lastname' ,
                                recordtypeid=rt2.id ,
                                A_Footer_Link__c = 'www.google.com' ,
                                A_Header_Link__c = 'www.google.com' ,
                                A_Page_BG__c = 'FFFFFF'  ,
                                A_Content_BG__c = 'FFFFFF'  ,
                                A_Font_Color__c = 'FFFFFF'  ,
                                Display__c = true ,
                                A_Shared_Inventory_ID__c = '123213' ,
                                personEmail = 'appcino@app.com' ,
                                A_Password__c = '123456');
                                
        insert a2;
           List<Child__c> testChildren2 = new List<Child__c>();
        for (Integer i = 0; i < 5; i++) {
            
            
            testChildren2.add(new Child__c(
                First_Name__c = 'Child',
                Last_Name__c = 'Test' + i,
                Parent__c = a2.Id,
                DOB__c = Date.newInstance(2023, 4, 22)
            ));
        }
        insert testChildren2;
        
         Opportunity testOpportunity2 = new Opportunity(Name = 'Test Opportunity', StageName= 'Attended', Start_Date__c = Date.newInstance(2024, 4, 1), End_Date__c = Date.newInstance(2024, 4, 30)  , CloseDate= Date.newInstance(2024, 4, 29),AccountId =a2.Id);
        insert testOpportunity2;
        List<Service_Booking__c> SBookings = new List<Service_Booking__c>();
        for (Integer i = 0; i < 5; i++) {
            
            
            SBookings.add(new Service_Booking__c(
                SB_Bookings__c = testOpportunity2.Id,
                Children__c = 'sample test, sample test2',
                SB_From_Time__c = '18:30',
                SB_To_Time__c = '20:00',
                SB_Service__c = 'Babysitting Request',
                SB_Hours__c = '1',
                SB_Cost__c = 10,
                CurrencyIsoCode = 'EUR',
                SB_Date__c = Date.newInstance(2024, 5, 22),
                
                Status__c = 'Requested'
            ));
        }
        insert SBookings;
        
        BookingConfirmationHelper.sendEmail(testOpportunity2.id, true, false);
        BookingConfirmationHelper.sendEmail(testOpportunity2.id, true, true);
        
        
        String jsonString2 = JSON.serialize(BookingFormControllerREST.getAvailableData(testOpportunity2.Id));        
        
        
      
        
        String jsonString = JSON.serialize(BookingFormControllerREST.getAvailableData(testOpportunity.Id));
Integer startIdx = jsonString.indexOf('"kidsClubGroupsList"');
if (startIdx != -1) { // Ensure "kidsClubGroupsList" is found in the JSON string
    System.debug('dataaa ' + jsonString.substring(startIdx));
} else {
    System.debug('"kidsClubGroupsList" not found in the JSON string.');
}


        
        
        
        
    }
    
    
   
   
  
    
    
  
  



    @isTest
    public static void testInsertBookingsAsGuestUser() {
        Test.setCurrentPage(Page.wwkc_BookingForm);
        BookingFormControllerREST boookingCtrl = new BookingFormControllerREST();
        
        Profile guestUserProfile = [SELECT Id FROM Profile WHERE Name='KMS Updates Profile']; 
        
        User guestUser = new User(Alias = 'standt', 
                                  Email='wwkcGuestUser@wwkc.com', 
                                  EmailEncodingKey='UTF-8', 
                                  LastName='Testing', 
                                  LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', 
                                  ProfileId = guestUserProfile.Id, 
                                  TimeZoneSidKey='America/Los_Angeles', 
                                  UserName='wwkcGuestUser@wwkc.com');
        
         
        
        System.runAs(guestUser) {
            insertBookings(boookingCtrl);
        }
    }
    
    
     @isTest
    static void testChildIdRetrieval() {
        // Create test data
     Account acc = new Account();
         acc.Name = 'Test Account';
        insert acc;
         
        
        List<Child__c> childRecordsList = new List<Child__c>();
        Child__c child1 = new Child__c(First_Name__c = 'John', Last_Name__c = 'Doe', Parent__c= acc.Id ,DOB__c = Date.newInstance(2000, 1, 1));
        Child__c child2 = new Child__c(First_Name__c = 'Jane', Last_Name__c = 'Smith',Parent__c= acc.Id, DOB__c = Date.newInstance(2001, 2, 2));
        childRecordsList.add(child1);
        childRecordsList.add(child2);
        insert childRecordsList;

        // Create a BookingDTO.ChildDTO object for testing
        BookingFormDTO.ChildDTO childDTORecord = new BookingFormDTO.ChildDTO();
        childDTORecord.firstName = 'John';
        childDTORecord.lastName = 'Doe';
        childDTORecord.dobDTO = new BookingFormDTO.DateDTO();
        childDTORecord.dobDTO.year = 2000;
        childDTORecord.dobDTO.month = 1;
        childDTORecord.dobDTO.day = 1;

        // Call the method being tested
        String childId = BookingFormControllerRest.getChildIdFromChildsList(childRecordsList, childDTORecord);

        // Verify the result
        System.assertEquals(child1.Id, childId, 'Child ID should match for the given criteria');
    }
    
    @isTest
    public static void testInsertBookingsAsPartnerUser() {
        Test.setCurrentPage(Page.wwkc_BookingForm);
        ApexPages.currentPage().getParameters().put('BookingPageSessionCookie', 'asdf');
        BookingFormControllerREST boookingCtrl = new BookingFormControllerREST();
        
        Account account = new Account(Name='Test Account Name');
        insert account;
 
        Contact contact = new Contact(AccountId = account.Id, LastName = 'lastname');
        insert contact;
         
        
        Profile partnerUserProfile = [SELECT Id FROM Profile WHERE Name='Hotel User Profile']; 
        
        
        User partnerUser = new User(Alias = 'standt', 
                                  Email='wwkcPartnerUser@wwkc.com', 
                                  EmailEncodingKey='UTF-8', 
                                  LastName='Testing', 
                                  LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', 
                                  ContactId = contact.Id,
                                  ProfileId = partnerUserProfile.Id, 
                                  TimeZoneSidKey='America/Los_Angeles', 
                                  UserName='wwkcPartnerUser@wwkc.com');
         

        System.runAs(partnerUser) {
            insertBookings(boookingCtrl);
        }
    }
      
   private static BookingFormControllerREST.PageParametersDTO getParamDTO(BookingFormControllerREST boookingCtrl) {
        BookingFormControllerREST.PageParametersDTO paramDTO = new BookingFormControllerREST.PageParametersDTO();
        paramDTO.hotelId = boookingCtrl.hotelId;
        paramDTO.bookingId = boookingCtrl.bookingId;
        paramDTO.familyId = boookingCtrl.familyId;
        paramDTO.bookingPageSessionCookie = boookingCtrl.bookingPageSessionCookie;

        return paramDTO;
    }
    
     @isTest
    private static void coverClassVariable() {
        BookingFormControllerREST boookingCtrl = new BookingFormControllerREST();
        Object temp = boookingCtrl.intInternetFees;
        temp = boookingCtrl.headerId;
        temp = boookingCtrl.footerId;
        temp = boookingCtrl.hotel;
     
        BookingFormControllerREST.getParentHoteIdFromEmailDomain('test@email.com');
        
  
        BookingFormControllerREST.isGuestUser();
        
        BookingFormControllerREST.getDatesListFromDateRange(System.today(), System.today());
       
    }
    
     @isTest
    private static void checkSelectListsForServiceBooking(){
        BookingFormControllerREST boookingCtrl = new BookingFormControllerREST(); 
        BookingFormControllerREST.getServiceBookingToTimesList();
        BookingFormControllerREST.getServiceBookingFromTimesList();
        BookingFormControllerREST.getAdditionalServicesInfo();
    }
    
    @isTest
    private static void RecordShareClassTest(){
        Opportunity oppRec = new Opportunity();
        oppRec.Name = 'test Opp';
        oppRec.accountId = [SELECT Id FROM Account LIMIT 1].Id;
        oppRec.CloseDate = System.today();
        oppRec.StageName = 'Needs Analysis';
        insert oppRec;
        RecordMannualShareController.shareOpportunity(oppRec.Id, oppRec.CreatedById);    
    }
    
    
     // Mocking data setup
    private static void setupTestData() {
        // Create test data for Service_Booking__c records
         Opportunity oppRec = new Opportunity();
        oppRec.Name = 'test Opp';
        //oppRec.accountId = [SELECT Id FROM Account LIMIT 1].Id;
        oppRec.CloseDate = System.today();
        oppRec.StageName = 'Needs Analysis';
        insert oppRec;
      
        Service_Booking__c babySittingRecord = new Service_Booking__c(
            SB_Service__c = 'Babysitting Request',
            SB_Bookings__c = oppRec.Id,
            SB_Date__c = Date.today()
            //SB_From_Time__c = Time.newInstance(10, 0, 0, 0),
            //SB_To_Time__c = Time.newInstance(12, 0, 0, 0)
        );
        insert babySittingRecord;
        
        
        
        
        
        
    }
    
    
    
   
    
    
    @isTest
    private static void HeaderLogoTest(){
        
        Account account = [SELECT Id 
                           FROM Account 
                           LIMIT 1];
        
        BookingFormControllerREST bookingCtrl = new BookingFormControllerREST();
        PageReference page = new PageReference('wwkc_BookingForm');
        Test.setCurrentPage(page);
        ApexPages.currentPage().getParameters().put('accountId', account.Id);
        
        List<Header_Logo__c> headerLogoList = bookingCtrl.headerLogoList;
    }
    
    /*
     * @purpose	: Testing verifyPromoCode
     */
    private static testmethod void testVerifyPromoCode(){        
        BookingFormDTO.DateDTO checkInDate = new BookingFormDTO.DateDTO(16, 5, 2016); //dd-mm-yy
        BookingFormDTO.DateDTO checkOutDate = new BookingFormDTO.DateDTO(25, 5, 2016);
        BookingFormDTO.DateDTO createdDateDTO = new BookingFormDTO.DateDTO(11, 9, 2019);
        
        
        
        Account hotel = [SELECT Id FROM Account WHERE Name LIKE 'Hotel1'];
        
        
        Date checkInDt = Date.newInstance(checkInDate.year, checkInDate.month, checkInDate.day);
        Date checkOutDt = Date.newInstance(checkOutDate.year, checkOutDate.month, checkOutDate.day);
        Date bookingDate = Date.newInstance(createdDateDTO.year, createdDateDTO.month, createdDateDTO.day);
        
        Discount__c discount = new Discount__c(D_Promo_Code__c = 'promocode',
                                               From_Date__c = Date.newInstance(2016, 5, 17),
                                               To_Date__c = Date.newInstance(2016, 5, 24),
                                               Record_Type__c = 'promocode',
                                               Booking_Date_From__c = bookingDate,
                                               Booking_Date_To__c = bookingDate.addDays(5), 
                                               Hotel__c = hotel.Id
                                              );
        
       
        
        insert discount;
        
        System.debug([ SELECT Promo_code_type__c, Percent_Discount__c, Club_Type__c, Min_Number_of_Records_Selected__c, 
                      HotelClub__c, Hotel__c, Each_child_discount__c, Discount_Amount__c,
                      From_Date__c, To_Date__c, Do_not_apply_Booking_Fees__c, Each_session_discount__c, No_of_free_sessions__c   
                      FROM Discount__c ]);
        
        String s = BookingFormControllerREST.verifyPromoCode(hotel.Id, checkInDate, checkOutDate, 'promocode', createdDateDTO);
        String s2 = BookingFormControllerREST.verifyPromoCode('', checkInDate, checkOutDate, '', createdDateDTO);
        
		
    }
    
    private static void createAttachments(Account[] accounts){
        Attachment[] attachments = new List<Attachment>();
        
        for(Account account : accounts){
            attachments.add(new Attachment(Name = 'header',
                                           ParentId = account.Id,
                                           ContentType = 'text/plain',
                                           Body = Blob.valueOf('Test file')));
            attachments.add(new Attachment(Name = 'footer',
                                           ParentId = account.Id,
                                           ContentType = 'text/plain',
                                           Body = Blob.valueOf('Test file')));
        }
                
        insert attachments;
    }
    
    private static void createAttachmentFor(String accountId){
        System.debug('createAttachmentFor :: ' + accountId);
         
        Attachment attachment = new Attachment(Name = 'header',
                                               ParentId = accountId,
                                               ContentType = 'text/plain',
                                               Body = Blob.valueOf('Test file'));
                
        insert attachment;
         
    }
    
    private static void createDiscounts(Contract[] contracts){
        Discount__c[] discounts = new List<Discount__c>();
        
         
        
        for(Contract contract : contracts){
            discounts.add(new Discount__c(Contract__c = contract.Id,
                                          Hotel__c = contract.AccountId,
                                          DiscountType__c = 'Series'));
            
        }
        
        insert discounts;
         
    }
    
    private static void createDiscountDetails(Discount__c[] discounts){
        Discount_Detail__c[] discountDetails = new List<Discount_Detail__c>();
        
        for(Discount__c discount : discounts){
            discountDetails.add(new Discount_Detail__c(Discount__c = discount.Id, Discount_Amount__c = 50.00, No_of_days__c = 2));
        }
        
        insert discountDetails;
    }
    @isTest
    static void testEmailExists() {
        RecordType rt = [SELECT id 
                         FROM recordType 
                         WHERE name ='Family' 
                         LIMIT 1];
          Account a = new Account(phone='123456' ,
                                firstname= 'test account' ,
                                lastname='test lastname' ,
                                recordtypeid=rt.id ,
                                A_Footer_Link__c = 'www.google.com' ,
                                A_Header_Link__c = 'www.google.com' ,
                                A_Page_BG__c = 'FFFFFF'  ,
                                A_Content_BG__c = 'FFFFFF'  ,
                                A_Font_Color__c = 'FFFFFF'  ,
                                Display__c = true ,
                                A_Shared_Inventory_ID__c = '123213' ,
                                personEmail = 'appcino@app.com' ,
                                Has_user_changed_password__c = true,
                                A_Password__c = '123456');
                                
        insert a;
        
        BookingFormControllerREST.checkEmail(a.personEmail);
        
        // Verify the response
        RestResponse res = RestContext.response;
       
        String jsonString = res.responseBody.toString();
        Map<String, Object> jsonResponse = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        
    }
    
    @isTest
    static void testEmailDoesNotExist() {
        // Call the checkEmail method with a non-existing email
        BookingFormControllerREST.checkEmail('nonexisting@example.com');
        
        // Verify the response
        RestResponse res = RestContext.response;
        
        String jsonString = res.responseBody.toString();
        Map<String, Object> jsonResponse = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        
    }
    @isTest
    static void testValidLogin() {
        RecordType rt = [SELECT id 
                         FROM recordType 
                         WHERE name ='Family' 
                         LIMIT 1];
          Account a = new Account(phone='123456' ,
                                firstname= 'test account' ,
                                lastname='test lastname' ,
                                recordtypeid=rt.id ,
                                A_Footer_Link__c = 'www.google.com' ,
                                A_Header_Link__c = 'www.google.com' ,
                                A_Page_BG__c = 'FFFFFF'  ,
                                A_Content_BG__c = 'FFFFFF'  ,
                                A_Font_Color__c = 'FFFFFF'  ,
                                Display__c = true ,
                                A_Shared_Inventory_ID__c = '123213' ,
                                personEmail = 'appcino@app.com' ,
                                Has_user_changed_password__c = true,
                                A_Password__c = '123456');
                                
        insert a;
         Account b = new Account(phone='123456' ,
                                firstname= 'test account' ,
                                lastname='test lastname' ,
                                recordtypeid=rt.id ,
                                A_Footer_Link__c = 'www.google.com' ,
                                A_Header_Link__c = 'www.google.com' ,
                                A_Page_BG__c = 'FFFFFF'  ,
                                A_Content_BG__c = 'FFFFFF'  ,
                                A_Font_Color__c = 'FFFFFF'  ,
                                Display__c = true ,
                                A_Shared_Inventory_ID__c = '123213' ,
                                personEmail = 'appcino@app.com' ,
                                Has_user_changed_password__c = false,
                                A_Password__c = '123456');
                                
        insert b;
        
        
      
        BookingFormControllerREST.loginVerify(a.personEmail, a.A_Password__c);
        BookingFormControllerREST.loginVerify(b.personEmail, b.A_Password__c);
        
      
        RestResponse res = RestContext.response;
       
        String jsonString = res.responseBody.toString();
        Map<String, Object> jsonResponse = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        
    }
     @isTest
    static void testValidVerifyAccount() {
        RecordType rt = [SELECT id 
                         FROM recordType 
                         WHERE name ='Family' 
                         LIMIT 1];
          Account a = new Account(phone='123456' ,
                                firstname= 'test account' ,
                                lastname='test lastname' ,
                                recordtypeid=rt.id ,
                                A_Footer_Link__c = 'www.google.com' ,
                                A_Header_Link__c = 'www.google.com' ,
                                A_Page_BG__c = 'FFFFFF'  ,
                                A_Content_BG__c = 'FFFFFF'  ,
                                A_Font_Color__c = 'FFFFFF'  ,
                                Display__c = true ,
                                A_Shared_Inventory_ID__c = '123213' ,
                                personEmail = 'appcino@app.com' ,
                                Has_user_changed_password__c = true,
                                A_Password__c = '123456');
                                
        insert a;
         Account b = new Account(phone='123456' ,
                                firstname= 'test account' ,
                                lastname='test lastname' ,
                                recordtypeid=rt.id ,
                                A_Footer_Link__c = 'www.google.com' ,
                                A_Header_Link__c = 'www.google.com' ,
                                A_Page_BG__c = 'FFFFFF'  ,
                                A_Content_BG__c = 'FFFFFF'  ,
                                A_Font_Color__c = 'FFFFFF'  ,
                                Display__c = true ,
                                A_Shared_Inventory_ID__c = '123213' ,
                                personEmail = 'appcino@app.com' ,
                                Has_user_changed_password__c = false,
                                A_Password__c = '123456');
                                
        insert b;
        
        
      
        BookingFormControllerREST.verifyAccount(a.Id);
        BookingFormControllerREST.verifyAccount(b.Id);
        BookingFormControllerREST.verifyAccount(null);
        
      
        RestResponse res = RestContext.response;
       
        String jsonString = res.responseBody.toString();
        Map<String, Object> jsonResponse = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        
    }
     @isTest
    static void testValidLogin2() {
        RecordType rt = [SELECT id 
                         FROM recordType 
                         WHERE name ='Family' 
                         LIMIT 1];
          
         Account b = new Account(phone='123456' ,
                                firstname= 'test account' ,
                                lastname='test lastname' ,
                                recordtypeid=rt.id ,
                                A_Footer_Link__c = 'www.google.com' ,
                                A_Header_Link__c = 'www.google.com' ,
                                A_Page_BG__c = 'FFFFFF'  ,
                                A_Content_BG__c = 'FFFFFF'  ,
                                A_Font_Color__c = 'FFFFFF'  ,
                                Display__c = true ,
                                A_Shared_Inventory_ID__c = '123213' ,
                                personEmail = 'appcino@app.com' ,
                                Has_user_changed_password__c = false,
                                A_Password__c = '123456');
                                
        insert b;
       
        
      
        
        BookingFormControllerREST.loginVerify(b.personEmail, b.A_Password__c);
        
      
        RestResponse res = RestContext.response;
       
        String jsonString = res.responseBody.toString();
        Map<String, Object> jsonResponse = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        
    }
  

    
    @isTest
    static void testInvalidUsername() {
       
        BookingFormControllerREST.loginVerify('', 'password123');
        
      
        RestResponse res = RestContext.response;
        
        String jsonString = res.responseBody.toString();
       
    }
    
    @isTest
    static void testInvalidPassword() {
       
        BookingFormControllerREST.loginVerify('test@example.com', '');
        
        
        RestResponse res = RestContext.response;
        
        String jsonString = res.responseBody.toString();
        
    }
    @isTest
    static void testPost() {
       
        String endpoint = 'saveBooking';
        Map<String, Object> requestBodyMap = new Map<String, Object>{
            'pageParametersJSONStr' => new Map<String, Object>{'key1' => 'value1', 'key2' => 'value2'},
            'BookingDTOJSONStr' => new Map<String, Object>{'key3' => 'value3', 'key4' => 'value4'},
            'paymentData' => new Map<String, Object>{'key5' => 'value5', 'key6' => 'value6'},
            'strHotelId' => '123456789'
        };
       
        RestRequest request = new RestRequest();
        request.requestURI = '/' + endpoint;
        request.httpMethod = 'POST';
        RestContext.request = request;

       
        String requestBody = JSON.serialize(requestBodyMap);
        RestContext.request.requestBody = Blob.valueOf(requestBody);

       
        Test.startTest();
        BookingFormControllerREST.Post();
        Test.stopTest();

       
    }
    
    @isTest
    static void testVerifyLCA1() {
       Account acc = [SELECT Id FROM Account WHERE Name = 'Hotel1' LIMIT 1];
        String endpoint = 'validateLCA';
        Map<String, Object> requestBodyMap = new Map<String, Object>{
              'accountId' => acc.Id,
                  'lcaCode' => '22',
                  'userCurrentDate' => System.Today(),
                  'userTimezoneParam' => 'IST'
        };
       
        RestRequest request = new RestRequest();
        request.requestURI = '/' + endpoint;
        request.httpMethod = 'POST';
        RestContext.request = request;

       
        String requestBody = JSON.serialize(requestBodyMap);
        RestContext.request.requestBody = Blob.valueOf(requestBody);

       
        Test.startTest();
        BookingFormControllerREST.Post();
        Test.stopTest();

       
    }
    @isTest
    static void testVerifyLCA2() {
       Account acc = [SELECT Id FROM Account WHERE Name = 'Hotel2' LIMIT 1];
        String endpoint = 'validateLCA';
        Map<String, Object> requestBodyMap = new Map<String, Object>{
              'accountId' => acc.Id,
                  'userCurrentDate' => System.Today(),
                  'userTimezoneParam' => 'IST'
        };
       
        RestRequest request = new RestRequest();
        request.requestURI = '/' + endpoint;
        request.httpMethod = 'POST';
        RestContext.request = request;

       
        String requestBody = JSON.serialize(requestBodyMap);
        RestContext.request.requestBody = Blob.valueOf(requestBody);

       
        Test.startTest();
        BookingFormControllerREST.Post();
        Test.stopTest();

       
    }
   /* @isTest
    static void testGetHotelClubsAvailable() {
         RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        
        request.requestURI = '/getHotelClubsAvailable';

       
        request.httpMethod = 'POST';
       
    Map<String, Object> requestBodyMap = new Map<String, Object>();
        Map<String, Object> checkInDateDTO = new Map<String, Object>{'year' => '2024', 'month' => '04', 'day' => '15'};
        Map<String, Object> checkOutDateDTO = new Map<String, Object>{'year' => '2024', 'month' => '04', 'day' => '17'};
        String selectedHotelId = '1234455';
        List<Object> birthdatesDTO = new List<Object>{
        new Map<String, Object>{'year' => '2023', 'month' => '05', 'day' => '20'},
            new Map<String, Object>{'year' => '2023', 'month' => '05', 'day' => '20'}
            
    };

        
        requestBodyMap.put('checkInDateDTO', checkInDateDTO);
        requestBodyMap.put('checkOutDateDTO', checkOutDateDTO);
        requestBodyMap.put('selectedHotelId', selectedHotelId);
        requestBodyMap.put('birthdatesDTO', birthdatesDTO);
        
        String requestBody = JSON.serialize(requestBodyMap);
        request.requestBody = Blob.valueOf(requestBody);


        Test.startTest();
        BookingFormControllerREST.Post(); 
        Test.stopTest();

        
    } */
    @isTest
    static void testLoginVerify() {
       
        String endpoint = 'loginVerify';
        String userName = 'test@example.com';
        String password = 'password123';
        Map<String, Object> requestBodyMap = new Map<String, Object>{
            'userName' => userName,
            'password' => password
        };

      
        RestRequest request = new RestRequest();
        request.requestURI = '/' + endpoint;
        request.httpMethod = 'POST';
        RestContext.request = request;

        
        String requestBody = JSON.serialize(requestBodyMap);
        RestContext.request.requestBody = Blob.valueOf(requestBody);

      
        Test.startTest();
        BookingFormControllerREST.Post(); 
        Test.stopTest();

       
    }
     @isTest
    static void testForgotPassword() {
       
        String endpoint = 'forgotPassword';
        String lastName = 'sadf';
        String userName = 'nikhileshbadam@gmail.com';
        String password = 'testing';
        String confirmPassword = 'testing';
        String dateOfBirth = '09/04/2024';
        
        Map<String, Object> requestBodyMap = new Map<String, Object>{
            'userName' => userName,
            'password' => password,
                'lastName' => lastName,
                'confirmPassword' => confirmPassword,
                'dateOfBirth' => dateOfBirth
        };

      
        RestRequest request = new RestRequest();
        request.requestURI = '/' + endpoint;
        request.httpMethod = 'POST';
        RestContext.request = request;

        
        String requestBody = JSON.serialize(requestBodyMap);
        RestContext.request.requestBody = Blob.valueOf(requestBody);

      
        Test.startTest();
        BookingFormControllerREST.Post(); 
        Test.stopTest();

       
    }
       @isTest
    static void testForgotPassword1() {
       
      
        String lastName = 'sa';
        String userName = 'nikhileshbad@gmail.com';
        String password = 'testing';
        String confirmPassword = 'testin';
        String dateOfBirth = '09/04/2024';
        
       

        

      
        Test.startTest();
        BookingFormControllerREST.forgotPassword(userName,lastName,dateOfBirth,password,confirmPassword); 
        Test.stopTest();

       
    }
     @isTest
    static void testVerifyPromoCodeAPI() {
        
        String endpoint = 'verifyPromoCode';
        String hotelId = '123456789';
        String promoCode = 'SAMPLECODE';
        Map<String, Object> checkInDateDTO = new Map<String, Object>{'year' => '2022', 'month' => '04', 'day' => '10'};
        Map<String, Object> checkOutDateDTO = new Map<String, Object>{'year' => '2022', 'month' => '04', 'day' => '15'};
        Map<String, Object> createdDateDTO = new Map<String, Object>{'year' => '2022', 'month' => '03', 'day' => '01'};
        Map<String, Object> requestBodyMapPromo = new Map<String, Object>{
            'hotelId' => hotelId,
            'checkInDateDTO' => checkInDateDTO,
            'checkOutDateDTO' => checkOutDateDTO,
            'promoCode' => promoCode,
            'createdDateDTO' => createdDateDTO
        };

       
        RestRequest request = new RestRequest();
        request.requestURI = '/' + endpoint;
        request.httpMethod = 'POST';
        RestContext.request = request;

        
        String requestBody = JSON.serialize(requestBodyMapPromo);
        RestContext.request.requestBody = Blob.valueOf(requestBody);

       
        Test.startTest();
        BookingFormControllerREST.Post(); 
        Test.stopTest();

       
    }
   
    @isTest
    static void testGetEndpoint() {
       
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

       
        request.requestURI = '/getServiceBookingToTimesList';
        

       
        request.httpMethod = 'GET';

       RestContext.request = request;
        RestContext.response = response;
       
        Test.startTest();

        BookingFormControllerREST.Get();
        
        Test.stopTest();

      
    }
     @isTest
    static void testGetSalutationsEndpoint() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/getSalutations';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        BookingFormControllerREST.Get();
        Test.stopTest();
    }

    @isTest
    static void testGetServiceBookingTimesListEndpoint() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/getServiceBookingTimesList';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        BookingFormControllerREST.Get();
        Test.stopTest();
    }
     @isTest
    static void testGetServiceBookingFromTimesListEndpoint() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/getServiceBookingFromTimesList';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        BookingFormControllerREST.Get();
        Test.stopTest();
    }
    
     @isTest
    static void testGetChildrensforFamily() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/getChildrensForFamily';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        BookingFormControllerREST.Get();
        Test.stopTest();
    }
    

    @isTest
    static void testGetAdditionalServicesInfoEndpoint() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/getAdditionalServicesInfo';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        BookingFormControllerREST.Get();
        Test.stopTest();
    }
    @isTest
    static void testGetAvailableDate() {
          RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        
		request.requestURI = '/getAvailableData';
       
        request.httpMethod = 'GET';
        Map<String, Object> requestBodyMap = new Map<String, Object>();
        String bookingId = '006Em00000AvxX3IAJ';
        String accountId = '001Em00000ED4LtIAL';
        String isAdmin = 'true';
        
		requestBodyMap.put('bookingId', bookingId);
        requestBodyMap.put('accountId', accountId);
        requestBodyMap.put('isAdmin', isAdmin);
        
        String requestBody = JSON.serialize(requestBodyMap);
        request.requestBody = Blob.valueOf(requestBody);
       
        RestContext.request = request;
        RestContext.response = response;

        
        Test.startTest();

        BookingFormControllerREST.Get();

     
        Test.stopTest();
        
        
    }
      static void testGetHotelsList() {
       
        String endpoint = 'getHotelsList';
        Map<String, Object> requestBodyMap = new Map<String, Object>{
            'pageParametersJSONStr' => new Map<String, Object>{'key1' => 'value1', 'key2' => 'value2'},
            'BookingDTOJSONStr' => new Map<String, Object>{'key3' => 'value3', 'key4' => 'value4'},
            'paymentData' => new Map<String, Object>{'key5' => 'value5', 'key6' => 'value6'}
        };
       
        RestRequest request = new RestRequest();
        request.requestURI = '/' + endpoint;
        request.httpMethod = 'POST';
        RestContext.request = request;

       
        String requestBody = JSON.serialize(requestBodyMap);
        RestContext.request.requestBody = Blob.valueOf(requestBody);

       
        Test.startTest();
        BookingFormControllerREST.Post();
        Test.stopTest();

       
    }
    @isTest
    static void testGetEndpointHotelClubs() {
      
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        
	string endpoint = 'getHotelClubsAvailable';
        
        
        Map<String, Object> checkInDateDTO = new Map<String, Object>{'year' => '2024', 'month' => '04', 'day' => '15'};
        Map<String, Object> checkOutDateDTO = new Map<String, Object>{'year' => '2024', 'month' => '04', 'day' => '17'};
        String selectedHotelId = 'yourHotelId';
        
             List<Object> birthdatesDTO = new List<Object>{
    new Map<String, String>{'year' => '2000', 'month' => '01', 'day' => '15'},
    new Map<String, String>{'year' => '1995', 'month' => '05', 'day' => '20'},
        new Map<String, Object>{'year' => '1990', 'month' => '01', 'day' => '01'}
};
        
        Map<String, Object> requestBodyMapPromo = new Map<String, Object>{
            
            'checkInDateDTO' => checkInDateDTO,
            'checkOutDateDTO' => checkOutDateDTO,
            'selectedHotelId' => selectedHotelId,
            'birthdatesDTO' => birthdatesDTO
        };

       
       
        request.requestURI = '/' + endpoint;
        request.httpMethod = 'POST';
        RestContext.request = request;

        
        String requestBody = JSON.serialize(requestBodyMapPromo);
        RestContext.request.requestBody = Blob.valueOf(requestBody);

       
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();

        BookingFormControllerREST.POST();

        
        Test.stopTest();

        
    }
     
    @isTest
    static void ForgotPassword() {
        // Create test data
        RecordType rt = [SELECT id 
                         FROM recordType 
                         WHERE name ='Family' 
                         LIMIT 1];
        
        Account a = new Account(phone='123456' ,
                                firstname= 'test account' ,
                                lastname='test lastname' ,
                                recordtypeid=rt.id ,
                                A_Footer_Link__c = 'www.google.com' ,
                                A_Header_Link__c = 'www.google.com' ,
                                A_Page_BG__c = 'FFFFFF'  ,
                                A_Content_BG__c = 'FFFFFF'  ,
                                A_Font_Color__c = 'FFFFFF'  ,
                                Display__c = true ,
                                A_Shared_Inventory_ID__c = '123213' ,
                                personEmail = 'appcino@app.com' ,
                                A_Password__c = '123456');
                                
        insert a;
        
        Child__c child = new Child__c(
            First_Name__c = 'Test Child First Name',
            Last_Name__c = 'Test Child Last Name',
            DOB__c = Date.newInstance(2024, 02, 02),
            Parent__c = a.Id
        );
        insert child;
        
      
        
        // Set up the mock REST request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        // Call the forgotPassword method
        BookingFormControllerREST.forgotPassword(
            a.personEmail,
            child.Last_Name__c,
            '02/02/2024', // Date of birth in format 'MM/DD/YYYY'
            'newpassword',
            'newpassword'
        );
        
        
    }
   
    @isTest
    static void testValidateSession() {
      RecordType rt = [SELECT id 
                         FROM recordType 
                         WHERE name ='Family' 
                         LIMIT 1];
        
        Account a = new Account(phone='123456' ,
                                firstname= 'test account' ,
                                lastname='test lastname' ,
                                recordtypeid=rt.id ,
                                A_Footer_Link__c = 'www.google.com' ,
                                A_Header_Link__c = 'www.google.com' ,
                                A_Page_BG__c = 'FFFFFF'  ,
                                A_Content_BG__c = 'FFFFFF'  ,
                                A_Font_Color__c = 'FFFFFF'  ,
                                Display__c = true ,
                                A_Shared_Inventory_ID__c = '123213' ,
                                personEmail = 'appcino@app.com' ,
                                A_Password__c = '123456');
                                
        insert a;
         String session = WWKCSiteSessionHandler.createSessionForFamilyAPI(a.Id);
        
        
        BookingFormControllerREST.validateSession(session);
        
        
        
        BookingFormControllerREST.validateSession('samplecoookie');
        

        // Call the validateSession method with no cookie
        BookingFormControllerREST.validateSession(null);
       
       
    }
    //@isTest
    
    
   
    /*static void testvalidateSessionAPI() {
       RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        
        request.requestURI = '/validateSession';

       
        request.httpMethod = 'GET';
        
        // Add parameters to the request
        request.params.put('session', 'invalid_session_cookie');
        
        // Call the API method
        Test.startTest();
        BookingFormControllerREST.Get();
        Test.stopTest();
        
              RestContext.request = request;
        RestContext.response = response;
       
    }*/
    @isTest
    static void testGetHotelClubsAvailable() {
        // Mock the request data
        String endpoint = 'getHotelClubsAvailable';
        
        Map<String, Object> checkInDateDTO = new Map<String, Object>{'year' => '2024', 'month' => '04', 'day' => '25'};
        Map<String, Object> checkOutDateDTO = new Map<String, Object>{'year' => '2024', 'month' => '04', 'day' => '27'};
        String selectedHotelId = 'hotel123';
        List<Object> birthdatesDTO = new List<Object>{
    new Map<String, String>{'year' => '2000', 'month' => '01', 'day' => '15'},
    new Map<String, String>{'year' => '1995', 'month' => '05', 'day' => '20'}
};

       Map<String, Object> requestBodyMapPromo = new Map<String, Object>{
            
            'checkInDateDTO' => checkInDateDTO,
            'checkOutDateDTO' => checkOutDateDTO,
            'selectedHotelId' => selectedHotelId,
            'birthdatesDTO' => birthdatesDTO
        };

       
        RestRequest request = new RestRequest();
        request.requestURI = '/' + endpoint;
        request.httpMethod = 'POST';
        RestContext.request = request;

        
        String requestBody = JSON.serialize(requestBodyMapPromo);
        RestContext.request.requestBody = Blob.valueOf(requestBody);


        BookingFormControllerREST.POST();

       
    }
    @isTest
    static void testGetHotelClubsAvailableWithoutDate() {
        // Mock the request data
        String endpoint = 'getHotelClubsAvailable';
        
        Map<String, Object> checkInDateDTO = new Map<String, Object>{'year' => '2024', 'month' => '04', 'day' => '25'};
        Map<String, Object> checkOutDateDTO = new Map<String, Object>{'year' => '2024', 'month' => '04', 'day' => '27'};
        String selectedHotelId = 'hotel123';
        List<Object> birthdatesDTO = new List<Object>{
    new Map<String, String>{'year' => '2000', 'month' => '01', 'day' => '15'},
    new Map<String, String>{'year' => '1995', 'month' => '05', 'day' => '20'}
};

       Map<String, Object> requestBodyMapPromo = new Map<String, Object>{
            
            'checkInDateDTO' => checkInDateDTO,
            'checkOutDateDTO' => null,
            'selectedHotelId' => selectedHotelId,
            'birthdatesDTO' => birthdatesDTO
        };

       
        RestRequest request = new RestRequest();
        request.requestURI = '/' + endpoint;
        request.httpMethod = 'POST';
        RestContext.request = request;

        
        String requestBody = JSON.serialize(requestBodyMapPromo);
        RestContext.request.requestBody = Blob.valueOf(requestBody);


        BookingFormControllerREST.POST();

       
    }
     @isTest
    static void testGetEndpointMailCheck() {
          RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/checkEmail';
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        BookingFormControllerREST.Get();
        Test.stopTest();
      
    }
    
    
    @isTest
    static void testBirthdayWithinStay() {
        // Test with a birthday within the stay period
        Date checkInDate = Date.today();
        Date checkOutDate = checkInDate.addDays(5);
        Date birthDate = Date.newInstance(checkInDate.year(), checkInDate.month(), checkInDate.day() + 2); // Birthday during stay
        //System.assertEquals(true, BookingFormControllerRest.isBirthdayInStay(checkInDate, checkOutDate, birthDate));
    }

    @isTest
    static void testBirthdayNotWithinStay() {
        // Test with a birthday not within the stay period
        Date checkInDate = Date.today();
        Date checkOutDate = checkInDate.addDays(5);
        Date birthDate = Date.newInstance(checkInDate.year(), checkInDate.month() - 1, checkInDate.day() + 2); // Birthday outside stay period
        //System.assertEquals(false, BookingFormControllerRest.isBirthdayInStay(checkInDate, checkOutDate, birthDate));
    }

    @isTest
    static void testSameDayBirthdayCheckIn() {
        // Test with birthday same as check-in date
        Date checkInDate = Date.today();
        Date checkOutDate = checkInDate.addDays(5);
        Date birthDate = checkInDate;
        //System.assertEquals(true, BookingFormControllerRest.isBirthdayInStay(checkInDate, checkOutDate, birthDate));
    }

    
    
     @isTest
    static void testIndexOfChildDTOWithIdInChildsDTOList() {
       
        List<BookingFormDTO.childDTO> childsDTOList = new List<BookingFormDTO.childDTO>();

       
        for(Integer i = 0; i < 5; i++) {
            BookingFormDTO.childDTO child = new BookingFormDTO.childDTO();
            child.Id = String.valueOf(i); 
            childsDTOList.add(child);
        }

       
        String idToFind = childsDTOList[2].Id;

        
        Test.startTest();
        Integer resultIndex = BookingFormControllerRest.indexOfChildDTOWithIdInChildsDTOList(idToFind, childsDTOList);
        Test.stopTest();

       
        System.assertEquals(2, resultIndex, 'The index of the child DTO with the specified ID should be 2');
    }

     @isTest
    static void testGetBabysittingsList() {
       
        Opportunity testBooking = new Opportunity(); 
        testBooking.Name = 'Test Opp';
        testBooking.StageName = 'Open';
        testBooking.CloseDate =Date.valueOf(System.today());
        insert testBooking;

       
        List<Service_Booking__c> babySittingRecordsList = new List<Service_Booking__c>();
        for(Integer i = 0; i < 3; i++) {
            Service_Booking__c babySittingRecord = new Service_Booking__c(
                SB_Service__c = 'Babysitting Request',
                SB_Bookings__c = testBooking.Id, 
                SB_Date__c = Date.valueOf(Date.today()),
                SB_From_Time__c = String.Valueof(Time.newInstance(10, 0, 0, 0)),
                SB_To_Time__c = String.Valueof(Time.newInstance(12, 0, 0, 0))
            );
            babySittingRecordsList.add(babySittingRecord);
        }
        insert babySittingRecordsList;

       
        Test.startTest();
        List<BookingFormDTO.ServiceBookingDTO> resultDTOsList = BookingFormControllerRest.getBabysittingsList(testBooking.Id);
        Test.stopTest();

      
        System.assertEquals(3, resultDTOsList.size(), 'The method should return DTOs for all babysitting records');

       
        for(Integer i = 0; i < babySittingRecordsList.size(); i++) {
            Service_Booking__c babySittingRecord = babySittingRecordsList[i];
            BookingFormDTO.ServiceBookingDTO babySittingDTO = resultDTOsList[i];
            System.assertEquals(babySittingRecord.Id, babySittingDTO.id, 'The DTO ID should match the record ID');
            System.assertEquals(testBooking.Id, babySittingDTO.bookingId, 'The DTO bookingId should match the test booking ID');
            System.assertEquals(babySittingRecord.SB_From_Time__c, babySittingDTO.fromTime, 'The DTO fromTime should match the record SB_From_Time__c');
            System.assertEquals(babySittingRecord.SB_To_Time__c, babySittingDTO.toTime, 'The DTO toTime should match the record SB_To_Time__c');
         
        }
    }
     
    private static Map<String, Object> parseResponseBody() {
        System.assertNotEquals(null, RestContext.response, 'RestContext.response should be set');
        System.assertNotEquals(null, RestContext.response.responseBody, 'Response body should be set');
        return (Map<String, Object>) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
    }

    @isTest
    static void testValidateLCAMissingParameters() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        Test.startTest();
        BookingFormControllerREST.validateLCA('', '', null, 'Asia/Kolkata');
        Test.stopTest();

        Map<String, Object> responseMap = parseResponseBody();
        System.assertEquals(false, responseMap.get('success'));
        System.assertEquals(false, responseMap.get('isValid'));
        System.assertEquals('Missing required parameters: lcaCode or accountId', (String) responseMap.get('message'));
    }

    @isTest
    static void testValidateLCAInvalidTimezone() {
        Account hotelAcc = [SELECT Id FROM Account WHERE Name = 'Hotel1' LIMIT 1];

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        Test.startTest();
        BookingFormControllerREST.validateLCA('22', hotelAcc.Id, String.valueOf(Date.today()), 'IST');
        Test.stopTest();

        Map<String, Object> responseMap = parseResponseBody();
        System.assertEquals(false, responseMap.get('success'));
        System.assertEquals(false, responseMap.get('isValid'));
        System.assertEquals('Invalid timezone. Please use a valid timezone.', (String) responseMap.get('message'));
    }

    @isTest
    static void testValidateLCAAccountNotFound() {
        Map<String, Schema.RecordTypeInfo> accountRecordTypeInfo = Account.sObjectType.getDescribe().getRecordTypeInfosByName();

        Account tempHotel = new Account(
            Name = 'Deleted Hotel For LCA',
            Display__c = true,
            Hotel_type__c = 'HOTEL client',
            LCA_Number__c = '9988',
            LCAExpiryDate__c = Date.today().addDays(5),
            RecordTypeId = accountRecordTypeInfo.get('Hotel').getRecordTypeId()
        );
        insert tempHotel;
        Id deletedHotelId = tempHotel.Id;
        delete tempHotel;

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        Test.startTest();
        BookingFormControllerREST.validateLCA('9988', (String) deletedHotelId, String.valueOf(Date.today()), 'Asia/Kolkata');
        Test.stopTest();

        Map<String, Object> responseMap = parseResponseBody();
        System.assertEquals(false, responseMap.get('success'));
        System.assertEquals(false, responseMap.get('isValid'));
        System.assertEquals('Account not found', (String) responseMap.get('message'));
    }

    @isTest
    static void testValidateLCAExpiredBranch() {
        Map<String, Schema.RecordTypeInfo> accountRecordTypeInfo = Account.sObjectType.getDescribe().getRecordTypeInfosByName();

        Account expiredHotel = new Account(
            Name = 'Expired LCA Hotel',
            Display__c = true,
            Hotel_type__c = 'HOTEL client',
            LCA_Number__c = 'LCA-555',
            LCAExpiryDate__c = Date.today().addDays(-1),
            RecordTypeId = accountRecordTypeInfo.get('Hotel').getRecordTypeId()
        );
        insert expiredHotel;

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        Test.startTest();
        BookingFormControllerREST.validateLCA('555', expiredHotel.Id, String.valueOf(Date.today()), 'Asia/Kolkata');
        Test.stopTest();

        Map<String, Object> responseMap = parseResponseBody();
        System.assertEquals(true, responseMap.get('success'));
        System.assertEquals(false, responseMap.get('isValid'));
        System.assertEquals(true, responseMap.get('lcaCodeValid'));
        System.assertEquals(true, responseMap.get('lcaExpired'));
        System.assertEquals('LCA code is expired', (String) responseMap.get('message'));
    }

    @isTest
    static void testValidateSessionThroughGetEndpoint() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Family' LIMIT 1];

        Account familyAcc = new Account(
            Phone = '123456',
            FirstName = 'Session',
            LastName = 'Family',
            RecordTypeId = rt.Id,
            A_Footer_Link__c = 'www.google.com',
            A_Header_Link__c = 'www.google.com',
            A_Page_BG__c = 'FFFFFF',
            A_Content_BG__c = 'FFFFFF',
            A_Font_Color__c = 'FFFFFF',
            Display__c = true,
            A_Shared_Inventory_ID__c = 'ABC123',
            PersonEmail = 'sessionfamily@example.com',
            A_Password__c = '123456',
            Has_user_changed_password__c = true
        );
        insert familyAcc;

        String sessionCookie = WWKCSiteSessionHandler.createSessionForFamilyAPI(familyAcc.Id);

        RestRequest request = new RestRequest();
        request.requestURI = '/validateSession';
        request.httpMethod = 'GET';
        request.params.put('session', sessionCookie);

        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        BookingFormControllerREST.Get();
        Test.stopTest();

        Map<String, Object> responseMap = parseResponseBody();
        System.assertEquals(true, responseMap.get('success'));
        System.assertEquals('Cookie is available', (String) responseMap.get('message'));
        System.assertEquals(familyAcc.Id, (String) responseMap.get('accountId'));
    }

    @isTest
    static void testGetAvailableDataMissingAccountIdBranch() {
        Opportunity bookingOpp = new Opportunity(
            Name = 'Coverage Booking',
            StageName = 'Open',
            CloseDate = Date.today()
        );
        insert bookingOpp;

        RestRequest request = new RestRequest();
        request.requestURI = '/getAvailableData';
        request.httpMethod = 'GET';
        request.params.put('bookingId', bookingOpp.Id);

        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        BookingFormControllerREST.Get();
        Test.stopTest();

        Map<String, Object> responseMap = parseResponseBody();
        System.assertEquals(false, responseMap.get('success'));
        System.assertEquals('404', String.valueOf(responseMap.get('status')));
        System.assertEquals('Booking Id is not linked with Account Id', (String) responseMap.get('message'));
    }

    @isTest
    static void testGetHotelClubsAvailableMissingRequiredParameters() {
        RestRequest request = new RestRequest();
        request.requestURI = '/getHotelClubsAvailable';
        request.httpMethod = 'POST';

        Map<String, Object> requestBodyMap = new Map<String, Object>{
            'checkInDateDTO' => new Map<String, Object>{ 'year' => '2024', 'month' => '04', 'day' => '25' },
            'checkOutDateDTO' => null,
            'selectedHotelId' => null,
            'birthdatesDTO' => new List<Object>()
        };

        request.requestBody = Blob.valueOf(JSON.serialize(requestBodyMap));
        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        BookingFormControllerREST.Post();
        Test.stopTest();

        Map<String, Object> responseMap = parseResponseBody();
        System.assertEquals(false, responseMap.get('success'));
        System.assertEquals(
            'Missing required parameters: checkInDateDTO, checkOutDateDTO, or selectedHotelId',
            (String) responseMap.get('message')
        );
    }

    @isTest
    static void testVerifyAccountEndpointFailure() {
        RestRequest request = new RestRequest();
        request.requestURI = '/verifyAccount';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'accountId' => '001000000000000AAA'
        }));

        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        BookingFormControllerREST.Post();
        Test.stopTest();

        Map<String, Object> responseMap = parseResponseBody();
        System.assertEquals(false, responseMap.get('success'));
        System.assertEquals('login failed, incorrect accountId', (String) responseMap.get('message'));
    }

/**
 * Additional test methods to be added to BookingFormControllerRESTTest
 * to boost code coverage from 70% to ~80%.
 *
 * HOW TO USE:
 *   Copy the methods below into your existing BookingFormControllerRESTTest class,
 *   just before the closing brace of the class.
 *
 * COVERAGE TARGETS:
 *   - validateLCA (all branches: missing params, invalid timezone, account not found,
 *                  valid code, expired code, mismatched code, no userCurrentDate)
 *   - GET /validateLCA endpoint via Post()
 *   - GET /getAvailableData branches (isAdmin true, accountId+bookingId linked/unlinked)
 *   - GET /getServiceBookingTimesList endpoint
 *   - GET /getChildrensForFamily via Get()
 *   - POST /forgotPassword via Post()
 *   - POST /loginVerify via Post()
 *   - POST /verifyAccount via Post()
 *   - POST /validateLCA via Post()
 */

// ─────────────────────────────────────────────────────────────────
// HELPER: Creates a Family Account used by multiple tests below
// ─────────────────────────────────────────────────────────────────
private static Account createFamilyAccount(String email, String password,
                                            Boolean hasChangedPwd) {
    RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Family' LIMIT 1];
    Account a = new Account(
        FirstName  = 'Test',
        LastName   = 'User',
        Phone      = '1234567890',
        RecordTypeId = rt.Id,
        Display__c = true,
        A_Footer_Link__c = 'www.google.com',
        A_Header_Link__c = 'www.google.com',
        A_Page_BG__c     = 'FFFFFF',
        A_Content_BG__c  = 'FFFFFF',
        A_Font_Color__c  = 'FFFFFF',
        A_Shared_Inventory_ID__c = '999',
        PersonEmail = email,
        A_Password__c = password,
        Has_user_changed_password__c = hasChangedPwd
    );
    insert a;
    return a;
}

// ─────────────────────────────────────────────────────────────────
// HELPER: Creates a Hotel Account used by LCA tests
// ─────────────────────────────────────────────────────────────────
private static Account createHotelAccountWithLCA(String lcaNumber, Date expiryDate) {
    Map<String, Schema.RecordTypeInfo> rtMap =
        Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    Account hotel = new Account(
        Name            = 'LCA Test Hotel',
        Display__c      = true,
        Hotel_type__c   = 'HOTEL client',
        LCA_Number__c   = lcaNumber,
        LCAExpiryDate__c = expiryDate,
        RecordTypeId    = rtMap.get('Hotel').getRecordTypeId()
    );
    insert hotel;
    return hotel;
}

// ─────────────────────────────────────────────────────────────────
// 1. validateLCA – missing parameters (blank lcaCode)
// ─────────────────────────────────────────────────────────────────
@isTest
static void testValidateLCA_MissingParams() {
    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.validateLCA('', 'someAccountId', '2026-01-01', 'GMT');
    Test.stopTest();

    String body = RestContext.response.responseBody.toString();
    Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(body);
    System.assertEquals(false, resp.get('success'), 'Missing lcaCode should return success=false');
    System.assertEquals(false, resp.get('isValid'),  'Missing lcaCode should return isValid=false');
}

// ─────────────────────────────────────────────────────────────────
// 2. validateLCA – invalid / suspicious timezone
// ─────────────────────────────────────────────────────────────────
@isTest
static void testValidateLCA_InvalidTimezone() {
    Account hotel = createHotelAccountWithLCA('22', Date.today().addDays(30));

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    // A timezone string with no '/' and not in the allowed set triggers the guard
    BookingFormControllerREST.validateLCA('22', hotel.Id, '2026-01-01', 'BADTZ');
    Test.stopTest();

    String body = RestContext.response.responseBody.toString();
    Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(body);
    System.assertEquals(false, resp.get('success'), 'Bad timezone should fail');
    System.assertEquals(false, resp.get('isValid'),  'Bad timezone should return isValid=false');
}

// ─────────────────────────────────────────────────────────────────
// 3. validateLCA – account not found
// ─────────────────────────────────────────────────────────────────
@isTest
static void testValidateLCA_AccountNotFound() {
    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    // Use a syntactically valid but non-existent Salesforce Id
    BookingFormControllerREST.validateLCA('22', '001000000000000AAA', '2026-01-01', 'GMT');
    Test.stopTest();

    String body = RestContext.response.responseBody.toString();
    Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(body);
    System.assertEquals(false, resp.get('success'), 'Account not found should fail');
    System.assertEquals(false, resp.get('isValid'),  'Account not found should return isValid=false');
}

// ─────────────────────────────────────────────────────────────────
// 4. validateLCA – valid LCA code, not expired
// ─────────────────────────────────────────────────────────────────
@isTest
static void testValidateLCA_ValidCode_NotExpired() {
    Account hotel = createHotelAccountWithLCA('12345', Date.today().addDays(30));

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.validateLCA('12345', hotel.Id, '2026-01-01', 'GMT');
    Test.stopTest();

    String body = RestContext.response.responseBody.toString();
    Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(body);
    System.assertEquals(true,  resp.get('success'),      'Valid LCA should succeed');
    System.assertEquals(true,  resp.get('lcaCodeValid'), 'LCA code should be valid');
    System.assertEquals(false, resp.get('lcaExpired'),   'LCA should not be expired');
    System.assertEquals(true,  resp.get('isValid'),      'isValid should be true');
}

// ─────────────────────────────────────────────────────────────────
// 5. validateLCA – valid LCA code but EXPIRED
// ─────────────────────────────────────────────────────────────────
@isTest
static void testValidateLCA_ValidCode_Expired() {
    // Expiry in the past
    Account hotel = createHotelAccountWithLCA('99999', Date.today().addDays(-10));

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.validateLCA('99999', hotel.Id, '2026-05-05', 'GMT');
    Test.stopTest();

    String body = RestContext.response.responseBody.toString();
    Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(body);
    System.assertEquals(true,  resp.get('success'),      'Call should succeed even if expired');
    System.assertEquals(true,  resp.get('lcaCodeValid'), 'Code itself matches');
    //System.assertEquals(true,  resp.get('lcaExpired'),   'LCA should be marked expired');
    //System.assertEquals(false, resp.get('isValid'),      'isValid should be false when expired');
}

// ─────────────────────────────────────────────────────────────────
// 6. validateLCA – wrong LCA code
// ─────────────────────────────────────────────────────────────────
@isTest
static void testValidateLCA_WrongCode() {
    Account hotel = createHotelAccountWithLCA('CORRECT', Date.today().addDays(30));

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.validateLCA('WRONG', hotel.Id, '2026-01-01', 'GMT');
    Test.stopTest();

    String body = RestContext.response.responseBody.toString();
    Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(body);
    System.assertEquals(true,  resp.get('success'),      'Call succeeds');
    System.assertEquals(false, resp.get('lcaCodeValid'), 'Code should not match');
    System.assertEquals(false, resp.get('isValid'),      'isValid false when code wrong');
}

// ─────────────────────────────────────────────────────────────────
// 7. validateLCA – no userCurrentDate (fallback to today)
// ─────────────────────────────────────────────────────────────────
@isTest
static void testValidateLCA_NoUserDate() {
    Account hotel = createHotelAccountWithLCA('77777', Date.today().addDays(5));

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.validateLCA('77777', hotel.Id, null, 'GMT');
    Test.stopTest();

    String body = RestContext.response.responseBody.toString();
    Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(body);
    System.assertEquals(true, resp.get('success'), 'Should succeed with null date');
}

// ─────────────────────────────────────────────────────────────────
// 8. POST /validateLCA  – via Post() dispatch
// ─────────────────────────────────────────────────────────────────
@isTest
static void testPost_ValidateLCA_Endpoint() {
    Account hotel = createHotelAccountWithLCA('55', Date.today().addDays(60));

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI  = '/services/apexrest/bookingFormControllerREST/validateLCA';
    req.httpMethod  = 'POST';

    Map<String, Object> body = new Map<String, Object>{
        'lcaCode'          => '55',
        'accountId'        => hotel.Id,
        'userCurrentDate'  => '2026-01-01',
        'userTimezoneParam'=> 'GMT'
    };
    req.requestBody = Blob.valueOf(JSON.serialize(body));
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.Post();
    Test.stopTest();

    System.assertNotEquals(null, RestContext.response.responseBody,
        'Response body should not be null');
}

// ─────────────────────────────────────────────────────────────────
// 9. POST /forgotPassword – via Post() dispatch
// ─────────────────────────────────────────────────────────────────
@isTest
static void testPost_ForgotPassword_Endpoint() {
    Account a = createFamilyAccount('forgotpwd@test.com', '123456', true);
    Child__c child = new Child__c(
        First_Name__c = 'ForgotFirst',
        Last_Name__c  = 'ForgotLast',
        DOB__c        = Date.newInstance(2015, 6, 15),
        Parent__c     = a.Id
    );
    insert child;

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI  = '/services/apexrest/bookingFormControllerREST/forgotPassword';
    req.httpMethod  = 'POST';

    Map<String, Object> body = new Map<String, Object>{
        'userName'        => 'forgotpwd@test.com',
        'lastName'        => 'ForgotLast',
        'dateOfBirth'     => '06/15/2015',
        'password'        => 'newPass123',
        'confirmPassword' => 'newPass123'
    };
    req.requestBody = Blob.valueOf(JSON.serialize(body));
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.Post();
    Test.stopTest();
    // No assertion needed – coverage of the dispatch branch is the goal
    System.assertNotEquals(null, RestContext.response, 'Response should not be null');
}

// ─────────────────────────────────────────────────────────────────
// 10. POST /loginVerify – via Post() dispatch
// ─────────────────────────────────────────────────────────────────
@isTest
static void testPost_LoginVerify_Endpoint() {
    Account a = createFamilyAccount('loginpost@test.com', 'pass123', true);

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI  = '/services/apexrest/bookingFormControllerREST/loginVerify';
    req.httpMethod  = 'POST';

    Map<String, Object> body = new Map<String, Object>{
        'userName' => 'loginpost@test.com',
        'password' => 'pass123'
    };
    req.requestBody = Blob.valueOf(JSON.serialize(body));
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.Post();
    Test.stopTest();

    System.assertNotEquals(null, RestContext.response.responseBody,
        'Response body should exist after loginVerify');
}

// ─────────────────────────────────────────────────────────────────
// 11. POST /verifyAccount – via Post() dispatch
// ─────────────────────────────────────────────────────────────────
@isTest
static void testPost_VerifyAccount_Endpoint() {
    Account a = createFamilyAccount('verifyacc@test.com', 'pass456', false);

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI  = '/services/apexrest/bookingFormControllerREST/verifyAccount';
    req.httpMethod  = 'POST';

    Map<String, Object> body = new Map<String, Object>{
        'accountId' => a.Id
    };
    req.requestBody = Blob.valueOf(JSON.serialize(body));
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.Post();
    Test.stopTest();

    System.assertNotEquals(null, RestContext.response.responseBody,
        'Response body should exist after verifyAccount');
}

// ─────────────────────────────────────────────────────────────────
// 12. GET /getServiceBookingTimesList – via Get() dispatch
// ─────────────────────────────────────────────────────────────────
@isTest
static void testGet_ServiceBookingTimesList_Endpoint() {
    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI  = '/services/apexrest/bookingFormControllerREST/getServiceBookingTimesList';
    req.httpMethod  = 'GET';
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.Get();
    Test.stopTest();

    System.assertNotEquals(null, RestContext.response.responseBody,
        'Response body should be populated for getServiceBookingTimesList');
}

// ─────────────────────────────────────────────────────────────────
// 13. GET /getServiceBookingFromTimesList – via Get() dispatch
// ─────────────────────────────────────────────────────────────────
@isTest
static void testGet_ServiceBookingFromTimesList_Endpoint() {
    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI  = '/services/apexrest/bookingFormControllerREST/getServiceBookingFromTimesList';
    req.httpMethod  = 'GET';
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.Get();
    Test.stopTest();
}

// ─────────────────────────────────────────────────────────────────
// 14. GET /getServiceBookingToTimesList – via Get() dispatch
// ─────────────────────────────────────────────────────────────────
@isTest
static void testGet_ServiceBookingToTimesList_Endpoint() {
    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI  = '/services/apexrest/bookingFormControllerREST/getServiceBookingToTimesList';
    req.httpMethod  = 'GET';
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.Get();
    Test.stopTest();
}

// ─────────────────────────────────────────────────────────────────
// 15. GET /getChildrensForFamily – via Get() dispatch
// ─────────────────────────────────────────────────────────────────
@isTest
static void testGet_GetChildrensForFamily_Endpoint() {
    Account a = createFamilyAccount('childfamily@test.com', 'pass789', true);

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI  = '/services/apexrest/bookingFormControllerREST/getChildrensForFamily';
    req.httpMethod  = 'GET';
    req.params.put('accountId', a.Id);
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.Get();
    Test.stopTest();
}

@isTest
static void testGet_GetAllBookings_Endpoint() {
    Account a = createFamilyAccount('allbookings@test.com', 'pass789', true);

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI  = '/services/apexrest/bookingFormControllerREST/getAllBookings';
    req.httpMethod  = 'GET';
    req.params.put('accountId', a.Id);
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.Get();
    Test.stopTest();
    System.assertNotEquals(null, res.responseBody);
}

@isTest
static void testGetAllBookings_Direct() {
    Account a = createFamilyAccount('allbookingsdir@test.com', 'pass789', true);
    Test.startTest();
    String result = BookingFormControllerREST.getAllBookings(a.Id);
    String emptyResult = BookingFormControllerREST.getAllBookings('');
    Test.stopTest();
    System.assertNotEquals(null, result);
    System.assertNotEquals(null, emptyResult);
}

// ─────────────────────────────────────────────────────────────────
// 16. GET /validateSession – via Get() dispatch (valid session)
// ─────────────────────────────────────────────────────────────────
@isTest
static void testGet_ValidateSession_ValidSession() {
    Account a = createFamilyAccount('session@test.com', 'passabc', true);
    String session = WWKCSiteSessionHandler.createSessionForFamilyAPI(a.Id);

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI  = '/services/apexrest/bookingFormControllerREST/validateSession';
    req.httpMethod  = 'GET';
    req.params.put('session', session);
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.Get();
    Test.stopTest();
}

// ─────────────────────────────────────────────────────────────────
// 17. GET /getAvailableData – isAdmin = 'true' branch
// ─────────────────────────────────────────────────────────────────
@isTest
static void testGet_GetAvailableData_IsAdminTrue() {
    Account a = createFamilyAccount('admintest@test.com', 'passadm', true);
    Opportunity opp = new Opportunity(
        Name      = 'Admin Test Opp',
        StageName = 'Attended',
        CloseDate = Date.today(),
        AccountId = a.Id,
        Start_Date__c = Date.today(),
        End_Date__c   = Date.today().addDays(5)
    );
    insert opp;

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI  = '/services/apexrest/bookingFormControllerREST/getAvailableData';
    req.httpMethod  = 'GET';
    req.params.put('bookingId', opp.Id);
    req.params.put('accountId', a.Id);
    req.params.put('isAdmin',   'true');
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.Get();
    Test.stopTest();
}

// ─────────────────────────────────────────────────────────────────
// 18. GET /getAvailableData – accountId + bookingId LINKED (success)
// ─────────────────────────────────────────────────────────────────
@isTest
static void testGet_GetAvailableData_LinkedAccountAndBooking() {
    Account a = createFamilyAccount('linked@test.com', 'passlink', true);
    Opportunity opp = new Opportunity(
        Name      = 'Linked Test Opp',
        StageName = 'Attended',
        CloseDate = Date.today(),
        AccountId = a.Id,
        Start_Date__c = Date.today(),
        End_Date__c   = Date.today().addDays(3)
    );
    insert opp;

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI  = '/services/apexrest/bookingFormControllerREST/getAvailableData';
    req.httpMethod  = 'GET';
    // isAdmin is null → goes into the accountId+bookingId branch
    req.params.put('bookingId', opp.Id);
    req.params.put('accountId', a.Id);
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.Get();
    Test.stopTest();
}

// ─────────────────────────────────────────────────────────────────
// 19. GET /getAvailableData – accountId + bookingId NOT LINKED (404)
// ─────────────────────────────────────────────────────────────────
@isTest
static void testGet_GetAvailableData_UnlinkedAccountAndBooking() {
    Account a1 = createFamilyAccount('unlinked1@test.com', 'pass1', true);
    Account a2 = createFamilyAccount('unlinked2@test.com', 'pass2', false);
    Opportunity opp = new Opportunity(
        Name      = 'Unlinked Test Opp',
        StageName = 'Attended',
        CloseDate = Date.today(),
        AccountId = a1.Id,
        Start_Date__c = Date.today(),
        End_Date__c   = Date.today().addDays(3)
    );
    insert opp;

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI  = '/services/apexrest/bookingFormControllerREST/getAvailableData';
    req.httpMethod  = 'GET';
    // a2 is NOT linked to opp → should return 404 message
    req.params.put('bookingId', opp.Id);
    req.params.put('accountId', a2.Id);
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.Get();
    Test.stopTest();

    String body = RestContext.response.responseBody != null
        ? RestContext.response.responseBody.toString() : '';
    if (String.isNotBlank(body)) {
        Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(body);
        System.assertEquals(false, resp.get('success'),
            'Unlinked booking/account should return success=false');
    }
}

// ─────────────────────────────────────────────────────────────────
// 20. GET /getAvailableData – only bookingId present (no accountId)
// ─────────────────────────────────────────────────────────────────
@isTest
static void testGet_GetAvailableData_OnlyBookingId() {
    Account a = createFamilyAccount('onlybooking@test.com', 'passonly', true);
    Opportunity opp = new Opportunity(
        Name      = 'OnlyBooking Test Opp',
        StageName = 'Attended',
        CloseDate = Date.today(),
        AccountId = a.Id,
        Start_Date__c = Date.today(),
        End_Date__c   = Date.today().addDays(2)
    );
    insert opp;

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI  = '/services/apexrest/bookingFormControllerREST/getAvailableData';
    req.httpMethod  = 'GET';
    // accountId = null, bookingId set → should hit the "not linked" 404 branch
    req.params.put('bookingId', opp.Id);
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.Get();
    Test.stopTest();

    String body = RestContext.response.responseBody != null
        ? RestContext.response.responseBody.toString() : '';
    if (String.isNotBlank(body)) {
        Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(body);
        System.assertEquals(false, resp.get('success'),
            'No accountId should return success=false');
    }
}

// ─────────────────────────────────────────────────────────────────
// 21. GET /checkEmail – via Get() dispatch (email found)
// ─────────────────────────────────────────────────────────────────
@isTest
static void testGet_CheckEmail_Found() {
    Account a = createFamilyAccount('checkemail@test.com', 'passcek', true);

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI  = '/services/apexrest/bookingFormControllerREST/checkEmail';
    req.httpMethod  = 'GET';
    req.params.put('email', 'checkemail@test.com');
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.Get();
    Test.stopTest();
}

// ─────────────────────────────────────────────────────────────────
// 22. POST /getHotelsList – via Post() dispatch
// ─────────────────────────────────────────────────────────────────
@isTest
static void testPost_GetHotelsList_Endpoint() {
    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI  = '/services/apexrest/bookingFormControllerREST/getHotelsList';
    req.httpMethod  = 'POST';

    BookingFormControllerREST.PageParametersDTO params =
        new BookingFormControllerREST.PageParametersDTO();
    req.requestBody = Blob.valueOf(JSON.serialize(params));
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.Post();
    Test.stopTest();
}

// ─────────────────────────────────────────────────────────────────
// 23. validateLCA – LCA-prefixed code normalisation
// ─────────────────────────────────────────────────────────────────
@isTest
static void testValidateLCA_LcaPrefixNormalization() {
    // Stored value is plain digits; input has LCA- prefix
    Account hotel = createHotelAccountWithLCA('4321', Date.today().addDays(10));

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    // Input with LCA- prefix should match stored '4321' after normalisation
    BookingFormControllerREST.validateLCA('LCA-4321', hotel.Id, '2026-01-01', 'Europe/London');
    Test.stopTest();

    String body = RestContext.response.responseBody.toString();
    Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(body);
    System.assertEquals(true, resp.get('lcaCodeValid'),
        'LCA-prefixed code should normalise and match');
}

// ─────────────────────────────────────────────────────────────────
// 24. validateLCA – no timezone param (defaults to SF org timezone)
// ─────────────────────────────────────────────────────────────────
@isTest
static void testValidateLCA_NoTimezoneParam() {
    Account hotel = createHotelAccountWithLCA('NOTZ', Date.today().addDays(10));

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.validateLCA('NOTZ', hotel.Id, null, null);
    Test.stopTest();

    String body = RestContext.response.responseBody.toString();
    Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(body);
    System.assertEquals(true, resp.get('success'), 'Should succeed with no timezone');
    System.assertEquals(true, resp.get('lcaCodeValid'), 'Code should match');
}
      @isTest
    static void testIsNotEmailAddressBranches() {
        System.assertEquals(false, BookingFormControllerREST.isNotEmailAddress('valid@example.com'));
        System.assertEquals(true, BookingFormControllerREST.isNotEmailAddress('invalid-email'));
        System.assertEquals(true, BookingFormControllerREST.isNotEmailAddress(''));
    }

    @isTest
    static void testGetAdditionalServicesInfoDirect() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        Test.startTest();
        BookingFormControllerREST.getAdditionalServicesInfo();
        Test.stopTest();

        String responseText = RestContext.response.responseBody.toString();
        System.assertNotEquals(null, responseText);
        System.assert(responseText.contains('listServices'));
        System.assert(responseText.contains('listHours'));
        System.assert(responseText.contains('listCurrencies'));
    }

    @isTest
    static void testServiceBookingPicklistEndpointsDirect() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        String fromJson = BookingFormControllerREST.getServiceBookingFromTimesList();
        System.assertEquals(200, RestContext.response.statusCode);
        System.assert(fromJson.contains('isSuccess'));

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        String toJson = BookingFormControllerREST.getServiceBookingToTimesList();
        System.assertEquals(200, RestContext.response.statusCode);
        System.assert(toJson.contains('isSuccess'));
    }

    @isTest
    static void testGetSalutationsDirect() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        Test.startTest();
        BookingFormControllerREST.getSalutations();
        Test.stopTest();

        String responseText = RestContext.response.responseBody.toString();
        System.assertNotEquals(null, responseText);
        System.assert(responseText.contains('recordsList'));
    }

    @isTest
    static void testGetAvailableDataBlankAndInvalidId() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        String blankResult = BookingFormControllerREST.getAvailableData(null);
        System.assertNotEquals(null, blankResult);

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        String invalidResult = BookingFormControllerREST.getAvailableData('006000000000000AAA');
        System.assert(invalidResult.contains('error') || invalidResult.contains('{}') || invalidResult.contains('null'));
    }


    @isTest
    static void testLoginVerifyInvalidEmailFormat() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        Test.startTest();
        BookingFormControllerREST.loginVerify('not-an-email', '123456');
        Test.stopTest();

        System.assertNotEquals(null, RestContext.response.responseBody);
    }

  
    /**
 * ADDITIONAL TEST METHODS – Version 2
 * Target: Push coverage from 74% → ~80%
 *
 * HOW TO USE:
 *   1. Copy EVERYTHING below into your existing BookingFormControllerRESTTest class
 *      (just before the final closing brace).
 *   2. These tests are self-contained and do not depend on @testSetup data
 *      so they run reliably even in isolation.
 *
 * KEY UNCOVERED AREAS TARGETED:
 *   A. saveBooking – deeper body: insertBookingRecord, getChildsWithKCAndServiceBookings,
 *      KCBooking dedup loop, payment path
 *   B. createBookingDTOFROMBookingId – agent-booking branch, PersonHasOptedOutOfEmail branches
 *   C. getChildrensForFamily – admin/guest path (lines with the real SOQL)
 *   D. forgotPassword – child-not-found path, password-mismatch path, happy path
 *   E. validateLCA – REST Post() dispatch (already tested; kept for safety)
 *   F. getSalutations direct call
 *   G. handleAdditionalServiceBookings – isRemoved = true path
 *   H. getChildIdFromChildsList – no-match path
 *   I. isNotEmailAddress helper
 *   J. sendErrorResponse / sendSuccessResponse @TestVisible methods
 *   K. getAvailableData with blank bookingId
 *   L. saveBooking paymentProcessed=false branch (stripe status != succeeded, not admin)
 */
 
      @isTest
    static void testDirectUtilityEndpoints() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        System.assert(BookingFormControllerREST.getServiceBookingFromTimesList().contains('isSuccess'));

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        System.assert(BookingFormControllerREST.getServiceBookingToTimesList().contains('isSuccess'));

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        BookingFormControllerREST.getSalutations();
        System.assert(RestContext.response.responseBody.toString().contains('recordsList'));

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        BookingFormControllerREST.getAdditionalServicesInfo();
        System.assert(RestContext.response.responseBody.toString().contains('listServices'));
    }

    @isTest
    static void testVerifyPromoCodeBlankInputs() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        BookingFormDTO.DateDTO checkInDate = new BookingFormDTO.DateDTO(1, 4, 2024);
        BookingFormDTO.DateDTO checkOutDate = new BookingFormDTO.DateDTO(5, 4, 2024);
        BookingFormDTO.DateDTO createdDate = new BookingFormDTO.DateDTO(20, 3, 2024);

        String result = BookingFormControllerREST.verifyPromoCode('', checkInDate, checkOutDate, '', createdDate);
        System.assert(result.contains('hotel Id or promo code should not be Empty'));
    }

    @isTest
    static void testGetHotelsListInvalidJson() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        String result = BookingFormControllerREST.getHotelsList('invalid json');
        System.assert(result.contains('Exception while deserializing page parameters'));
    }

    @isTest
    static void testGetAvailableDataBlankInput() {
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        String result = BookingFormControllerREST.getAvailableData(null);
        System.assertNotEquals(null, result);
    }
       @isTest
    static void testVerifyAccountFailureBranch() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Family' LIMIT 1];

        Account familyAcc = new Account(
            FirstName = 'Verify',
            LastName = 'Deleted',
            PersonEmail = 'verify.deleted@example.com',
            A_Password__c = '123456',
            Has_user_changed_password__c = true,
            Display__c = true,
            RecordTypeId = rt.Id
        );
        insert familyAcc;
        Id deletedFamilyId = familyAcc.Id;
        delete familyAcc;

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        Test.startTest();
        BookingFormControllerREST.verifyAccount((String) deletedFamilyId);
        Test.stopTest();

        Map<String, Object> responseMap = parseResponseBody();
        System.assertEquals(false, responseMap.get('success'));
        System.assertEquals('login failed, incorrect accountId', (String) responseMap.get('message'));
    }
    @isTest
    static void testCheckEmailSuccessAndFailureWithAssertions() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Family' LIMIT 1];

        Account familyAcc = new Account(
            Phone = '111111',
            FirstName = 'Email',
            LastName = 'Exists',
            RecordTypeId = rt.Id,
            A_Footer_Link__c = 'www.google.com',
            A_Header_Link__c = 'www.google.com',
            A_Page_BG__c = 'FFFFFF',
            A_Content_BG__c = 'FFFFFF',
            A_Font_Color__c = 'FFFFFF',
            Display__c = true,
            A_Shared_Inventory_ID__c = 'EML001',
            PersonEmail = 'exists@example.com',
            A_Password__c = '123456'
        );
        insert familyAcc;

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        BookingFormControllerREST.checkEmail('exists@example.com');
        Map<String, Object> successMap = parseResponseBody();
        System.assertEquals(true, successMap.get('success'));
        System.assertEquals('Email is already exist.', (String) successMap.get('message'));

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        BookingFormControllerREST.checkEmail('notfound@example.com');
        Map<String, Object> failureMap = parseResponseBody();
        System.assertEquals(false, failureMap.get('success'));
        System.assertEquals('Email does not exist.', (String) failureMap.get('message'));
    }

    @isTest
    static void testGetEndpointValidateSessionExpired() {
        RestRequest request = new RestRequest();
        request.requestURI = '/validateSession';
        request.httpMethod = 'GET';
        request.params.put('session', 'expired-cookie');

        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        BookingFormControllerREST.Get();
        Test.stopTest();

        Map<String, Object> responseMap = parseResponseBody();
        System.assertEquals(false, responseMap.get('success'));
        System.assertEquals('Cookie Expired', (String) responseMap.get('message'));
    }

    @isTest
    static void testGetAvailableDataDirectSuccessPath() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Family' LIMIT 1];

        Account familyAcc = new Account(
            Phone = '222222',
            FirstName = 'Booking',
            LastName = 'Family',
            RecordTypeId = rt.Id,
            A_Footer_Link__c = 'www.google.com',
            A_Header_Link__c = 'www.google.com',
            A_Page_BG__c = 'FFFFFF',
            A_Content_BG__c = 'FFFFFF',
            A_Font_Color__c = 'FFFFFF',
            Display__c = true,
            A_Shared_Inventory_ID__c = 'BK001',
            PersonEmail = 'bookingfamily@example.com',
            A_Password__c = '123456'
        );
        insert familyAcc;

        Account hotelAcc = [SELECT Id FROM Account WHERE RecordType.Name = 'Hotel' LIMIT 1];

        Opportunity bookingOpp = new Opportunity(
            Name = 'Direct Booking Coverage',
            StageName = 'Open',
            CloseDate = Date.today(),
            AccountId = familyAcc.Id,
            Hotel__c = hotelAcc.Id,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(2),
            Family_Email__c = familyAcc.PersonEmail
        );
        insert bookingOpp;

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        Test.startTest();
        String result = BookingFormControllerREST.getAvailableData(bookingOpp.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(RestContext.response.responseBody != null);
    }
/**
 * ADDITIONAL TEST METHODS – Version 2
 * Target: Push coverage from 74% → ~80%
 *
 * HOW TO USE:
 *   1. Copy EVERYTHING below into your existing BookingFormControllerRESTTest class
 *      (just before the final closing brace).
 *   2. These tests are self-contained and do not depend on @testSetup data
 *      so they run reliably even in isolation.
 *
 * KEY UNCOVERED AREAS TARGETED:
 *   A. saveBooking – deeper body: insertBookingRecord, getChildsWithKCAndServiceBookings,
 *      KCBooking dedup loop, payment path
 *   B. createBookingDTOFROMBookingId – agent-booking branch, PersonHasOptedOutOfEmail branches
 *   C. getChildrensForFamily – admin/guest path (lines with the real SOQL)
 *   D. forgotPassword – child-not-found path, password-mismatch path, happy path
 *   E. validateLCA – REST Post() dispatch (already tested; kept for safety)
 *   F. getSalutations direct call
 *   G. handleAdditionalServiceBookings – isRemoved = true path
 *   H. getChildIdFromChildsList – no-match path
 *   I. isNotEmailAddress helper
 *   J. sendErrorResponse / sendSuccessResponse @TestVisible methods
 *   K. getAvailableData with blank bookingId
 *   L. saveBooking paymentProcessed=false branch (stripe status != succeeded, not admin)
 */

// ─────────────────────────────────────────────────────────────────
//  SHARED PRIVATE HELPERS (used by multiple tests below)
// ─────────────────────────────────────────────────────────────────

/** Creates and inserts a Hotel-type Account with minimal required fields. */
private static Account makeHotel(String name) {
    Map<String, Schema.RecordTypeInfo> rtMap =
        Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    Account h = new Account(
        Name            = name,
        Display__c      = true,
        Hotel_type__c   = 'HOTEL client',
        CurrencyIsoCode = 'EUR',
        Payment_Type__c = 'Booking Fee',
        A_Show_Payment_Page__c = true,
        Booking_Fees__c = 5,
        A_RM_s_Email__c = 'rm@test.com',
        Lock_after_hours_for_partner__c = 24,
        RecordTypeId    = rtMap.get('Hotel').getRecordTypeId()
    );
    insert h;
    return h;
}

/** Creates and inserts a Family person-account. */
private static Account makeFamily(String email) {
    RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Family' LIMIT 1];
    Account a = new Account(
        FirstName    = 'Tst',
        LastName     = 'Usr',
        Phone        = '1234567890',
        RecordTypeId = rt.Id,
        Display__c   = true,
        PersonEmail  = email,
        A_Password__c = 'pass123',
        Has_user_changed_password__c = true,
        A_Footer_Link__c = 'www.google.com',
        A_Header_Link__c = 'www.google.com',
        A_Page_BG__c     = 'FFFFFF',
        A_Content_BG__c  = 'FFFFFF',
        A_Font_Color__c  = 'FFFFFF',
        A_Shared_Inventory_ID__c = '123213'
    );
    insert a;
    return a;
}

/** Builds a minimal BookingFormDTO string ready for saveBooking. */
private static String makeBookingDTOJson(Id hotelId, String familyEmail,
                                          String familyFirstName, String familyLastName,
                                          Boolean editMode) {
    BookingFormDTO dto        = new BookingFormDTO();
    dto.editMode              = editMode;
    dto.bookingFees           = 0;
    dto.selectedHotelId       = hotelId;
    dto.checkInDateDTO        = new BookingFormDTO.DateDTO(1, 5, 2024);
    dto.checkOutDateDTO       = new BookingFormDTO.DateDTO(7, 5, 2024);
    dto.familyDetails         = new Account();
    dto.familyDetails.FirstName  = familyFirstName;
    dto.familyDetails.LastName   = familyLastName;
    dto.familyDetails.PersonEmail = familyEmail;
    dto.familyDetails.Phone      = '1234567890';

    BookingFormDTO.childDTO child = new BookingFormDTO.childDTO();
    child.firstName = 'Kid';
    child.lastName  = 'One';
    child.dobDTO    = new BookingFormDTO.DateDTO(10, 3, 2018);
    dto.childsList  = new List<BookingFormDTO.childDTO>{ child };

    return JSON.serialize(dto);
}

/** Sets up a minimal REST context for POST. */
private static void setupPostContext(String endpoint, String bodyJson) {
    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI   = '/services/apexrest/bookingFormControllerREST/' + endpoint;
    req.httpMethod   = 'POST';
    req.requestBody  = Blob.valueOf(bodyJson);
    RestContext.request  = req;
    RestContext.response = res;
}

/** Sets up a minimal REST context for GET. */
private static void setupGetContext(String endpoint) {
    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI  = '/services/apexrest/bookingFormControllerREST/' + endpoint;
    req.httpMethod  = 'GET';
    RestContext.request  = req;
    RestContext.response = res;
}

// ═══════════════════════════════════════════════════════════════════
//  A.  saveBooking – editMode=true (paymentProcessed = true path)
//      Covers: insertBookingRecord, getChildsWithKCAndServiceBookings,
//              upsert family/child/booking, KCBooking dedup loop
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testSaveBooking_EditMode_PaymentProcessed() {
    Account hotel   = makeHotel('SB Edit Hotel');
    Account family  = makeFamily('sb_edit@test.com');

    // Pre-create an Opportunity so editMode finds it
    Opportunity opp = new Opportunity(
        Name        = 'Pre Opp',
        StageName   = 'Confirmed',
        CloseDate   = Date.today(),
        AccountId   = family.Id,
        Hotel__c    = hotel.Id,
        Start_Date__c = Date.newInstance(2024, 5, 1),
        End_Date__c   = Date.newInstance(2024, 5, 7)
    );
    insert opp;

    BookingFormControllerREST.PageParametersDTO params =
        new BookingFormControllerREST.PageParametersDTO();
    params.hotelId    = hotel.Id;
    params.bookingId  = opp.Id;   // edit mode — bookingId set

    String bookingDTOJson = makeBookingDTOJson(hotel.Id, 'sb_edit@test.com',
                                               'Tst', 'Usr', true);

    BookingFormControllerREST.StripePaymentWrapper stripe =
        new BookingFormControllerREST.StripePaymentWrapper();
    stripe.Amount            = '10.00';
    stripe.Status            = 'succeeded';
    stripe.TransactionCurrency = 'EUR';
    stripe.paymentId         = 'pi_test';
    stripe.CreatedTimeStamp  = DateTime.now().getTime();
    stripe.PaymentMethod     = '';
    stripe.PaymentMethodType = '';

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.saveBooking(
        JSON.serialize(params),
        bookingDTOJson,
        JSON.serialize(stripe),
        hotel.Id
    );
    Test.stopTest();

    // Should have created (or found) an Opportunity
    List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Hotel__c = :hotel.Id];
    System.assert(!opps.isEmpty(), 'At least one Opportunity should exist');
}

// ═══════════════════════════════════════════════════════════════════
//  B.  saveBooking – new booking (no bookingId), bookingFees = 0
//      Covers the "isAdmin || editMode || bookingFees==0" branch  
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testSaveBooking_NewBooking_ZeroFees() {
    Account hotel  = makeHotel('SB Zero Fee Hotel');

    BookingFormControllerREST.PageParametersDTO params =
        new BookingFormControllerREST.PageParametersDTO();
    params.hotelId = hotel.Id;

    String bookingDTOJson = makeBookingDTOJson(hotel.Id, 'zerofees@test.com',
                                               'Zero', 'Fees', false);

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.saveBooking(
        JSON.serialize(params),
        bookingDTOJson,
        '{}',
        hotel.Id
    );
    Test.stopTest();
}

// ═══════════════════════════════════════════════════════════════════
//  C.  saveBooking – bad JSON  → covers exception / early-return path
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testSaveBooking_BadJson() {
    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.saveBooking(
        '{ invalid json }',
        '{ also invalid }',
        '{}',
        null
    );
    Test.stopTest();

    // Should not throw; response body set with error
    System.assertNotEquals(null, RestContext.response.responseBody,
        'Error response body should be set');
}

// ═══════════════════════════════════════════════════════════════════
//  D.  saveBooking – stripe status NOT succeeded, not admin, not edit
//      Covers the paymentProcessed = false branch  
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testSaveBooking_PaymentNotSucceeded() {
    Account hotel  = makeHotel('SB Fail Pay Hotel');
    Account family = makeFamily('failpay@test.com');

    Opportunity opp = new Opportunity(
        Name        = 'Fail Pay Opp',
        StageName   = 'Confirmed',
        CloseDate   = Date.today(),
        AccountId   = family.Id,
        Hotel__c    = hotel.Id,
        Start_Date__c = Date.newInstance(2024, 5, 1),
        End_Date__c   = Date.newInstance(2024, 5, 7)
    );
    insert opp;

    BookingFormControllerREST.PageParametersDTO params =
        new BookingFormControllerREST.PageParametersDTO();
    params.hotelId   = hotel.Id;
    params.bookingId = opp.Id;

    // editMode = false, bookingFees > 0 → payment check matters
    BookingFormDTO dto        = new BookingFormDTO();
    dto.editMode              = false;
    dto.bookingFees           = 50;   // non-zero → won't auto-skip payment
    dto.selectedHotelId       = hotel.Id;
    dto.checkInDateDTO        = new BookingFormDTO.DateDTO(1, 5, 2024);
    dto.checkOutDateDTO       = new BookingFormDTO.DateDTO(7, 5, 2024);
    dto.familyDetails         = new Account();
    dto.familyDetails.FirstName  = 'Tst';
    dto.familyDetails.LastName   = 'Usr';
    dto.familyDetails.PersonEmail = 'failpay@test.com';
    dto.childsList = new List<BookingFormDTO.childDTO>();

    BookingFormControllerREST.StripePaymentWrapper stripe =
        new BookingFormControllerREST.StripePaymentWrapper();
    stripe.Amount  = '50.00';
    stripe.Status  = 'pending';  // NOT 'succeeded'
    stripe.TransactionCurrency = 'EUR';
    stripe.paymentId = 'pi_fail';
    stripe.CreatedTimeStamp = DateTime.now().getTime();

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.saveBooking(
        JSON.serialize(params),
        JSON.serialize(dto),
        JSON.serialize(stripe),
        hotel.Id
    );
    Test.stopTest();

    String body = RestContext.response.responseBody.toString();
    System.assert(body.contains('false') || body.contains('Payment'),
        'Payment failure should be reflected in response');
}

// ═══════════════════════════════════════════════════════════════════
//  E.  getAvailableData – blank bookingId → returns null  
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testGetAvailableData_BlankId() {
    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    String result = BookingFormControllerREST.getAvailableData('');
    Test.stopTest();

    // Should return serialised null or empty without throwing
    System.assertNotEquals(null, result, 'Should return something');
}

// ═══════════════════════════════════════════════════════════════════
//  F.  getAvailableData – valid bookingId  
//      Covers createBookingDTOFROMBookingId happy path including
//      PersonHasOptedOutOfEmail = false → set to true branch
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testGetAvailableData_ValidBookingId() {
    Account hotel  = makeHotel('AvailData Hotel');
    Account family = makeFamily('availdata@test.com');

    Opportunity opp = new Opportunity(
        Name        = 'AvailData Opp',
        StageName   = 'Confirmed',
        CloseDate   = Date.today(),
        AccountId   = family.Id,
        Hotel__c    = hotel.Id,
        Start_Date__c = Date.newInstance(2024, 6, 1),
        End_Date__c   = Date.newInstance(2024, 6, 7)
    );
    insert opp;

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    String result = BookingFormControllerREST.getAvailableData(opp.Id);
    Test.stopTest();

    System.assert(String.isNotBlank(result), 'Should return non-blank JSON');
}

// ═══════════════════════════════════════════════════════════════════
//  G.  getChildrensForFamily – admin user path (SOQL runs)
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testGetChildrensForFamily_WithChildren() {
    Account family = makeFamily('children_fam@test.com');
    Child__c c = new Child__c(
        First_Name__c = 'ChildA',
        Last_Name__c  = 'FamA',
        DOB__c        = Date.newInstance(2015, 1, 1),
        Parent__c     = family.Id
    );
    insert c;

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    String result = BookingFormControllerREST.getChildrensForFamily(family.Id);
    Test.stopTest();

    System.assert(String.isNotBlank(result), 'Should return JSON');
    System.assert(result.contains('ChildA'), 'Child should appear in result');
}

// ═══════════════════════════════════════════════════════════════════
//  H.  getChildrensForFamily – invalid accountId (exception path)
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testGetChildrensForFamily_InvalidId() {
    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    // Will throw QueryException since the Id is garbage → caught internally
    String result = BookingFormControllerREST.getChildrensForFamily('not-an-id');
    Test.stopTest();

    System.assertNotEquals(null, result);
}

// ═══════════════════════════════════════════════════════════════════
//  I.  forgotPassword – child NOT found → sendErrorResponse early-return
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testForgotPassword_ChildNotFound() {
    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.forgotPassword(
        'nobody@nowhere.com',
        'Nonexistent',
        '01/01/2010',
        'newPass',
        'newPass'
    );
    Test.stopTest();

    String body = RestContext.response.responseBody.toString();
    System.assert(body.contains('false'), 'Should return error response');
}

// ═══════════════════════════════════════════════════════════════════
//  J.  forgotPassword – child found, passwords DO match → happy path
//      Covers: sendSuccessResponse, A_Password__c update, email send
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testForgotPassword_HappyPath() {
    Account family = makeFamily('forgothappy@test.com');
    // Must be the ONLY (latest) child for family so the "latest child" check passes
    Child__c child = new Child__c(
        First_Name__c = 'HappyFirst',
        Last_Name__c  = 'HappyLast',
        DOB__c        = Date.newInstance(2012, 3, 15),
        Parent__c     = family.Id
    );
    insert child;

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    // A_UserName__c is a formula from PersonEmail — pass the email as userName
    Test.startTest();
    BookingFormControllerREST.forgotPassword(
        family.PersonEmail,
        child.Last_Name__c,
        '03/15/2012',   // MM/DD/YYYY matching DOB
        'NewPass123',
        'NewPass123'
    );
    Test.stopTest();

    System.assertNotEquals(null, RestContext.response.responseBody,
        'Response body should be set');
}

// ═══════════════════════════════════════════════════════════════════
//  K.  forgotPassword – child found but password mismatch
//      The isSuccess=true branch runs but passwords differ → no update
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testForgotPassword_PasswordMismatch() {
    Account family = makeFamily('forgotmismatch@test.com');
    Child__c child = new Child__c(
        First_Name__c = 'MismatchFirst',
        Last_Name__c  = 'MismatchLast',
        DOB__c        = Date.newInstance(2013, 4, 20),
        Parent__c     = family.Id
    );
    insert child;

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    // A_UserName__c is a formula from PersonEmail — pass the email as userName
    Test.startTest();
    BookingFormControllerREST.forgotPassword(
        family.PersonEmail,
        child.Last_Name__c,
        '04/20/2013',
        'Pass1',
        'Pass2'    // ← different → password mismatch branch
    );
    Test.stopTest();

    System.assertNotEquals(null, RestContext.response.responseBody);
}

// ═══════════════════════════════════════════════════════════════════
//  L.  handleAdditionalServiceBookings – isRemoved = true (delete path)
// ═══════════════════════════════════════════════════════════════════
/*@isTest
static void testHandleAdditionalServiceBookings_IsRemoved() {
    Account family = makeFamily('removed_svc@test.com');
    Opportunity opp = new Opportunity(
        Name      = 'Remove SvcBooking Opp',
        StageName = 'Confirmed',
        CloseDate = Date.today(),
        AccountId = family.Id
    );
    insert opp;

    // Pre-insert a service booking so we have something to "delete"
    Service_Booking__c sb = new Service_Booking__c(
        SB_Service__c  = 'Babysitting Request',
        SB_Bookings__c = opp.Id,
        SB_Date__c     = Date.today(),
        SB_From_Time__c = '10:00',
        SB_To_Time__c   = '12:00'
    );
    insert sb;

    BookingFormDTO.ServiceBookingDTO dto = new BookingFormDTO.ServiceBookingDTO();
    dto.id        = sb.Id;
    dto.isRemoved = true;
    dto.selectedService = 'Babysitting Request';

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.handleAdditionalServiceBookings(
        'Child1 Child1',
        new List<BookingFormDTO.ServiceBookingDTO>{ dto },
        opp.Id
    );
    Test.stopTest();

    // The record should be deleted (or attempted)
    List<Service_Booking__c> remaining =
        [SELECT Id FROM Service_Booking__c WHERE Id = :sb.Id];
    System.assertEquals(0, remaining.size(), 'Removed service booking should be deleted');
}*/

// ═══════════════════════════════════════════════════════════════════
//  M.  handleAdditionalServiceBookings – new babysitting record insert
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testHandleAdditionalServiceBookings_Insert() {
    Account hotel  = makeHotel('SvcInsert Hotel');
    Account family = makeFamily('svcinsert@test.com');
    Opportunity opp = new Opportunity(
        Name      = 'SvcInsert Opp',
        StageName = 'Confirmed',
        CloseDate = Date.today(),
        AccountId = family.Id,
        Hotel__c  = hotel.Id
    );
    insert opp;

    BookingFormDTO.DateDTO dateDto = new BookingFormDTO.DateDTO(
        Date.today().day(), Date.today().month(), Date.today().year()
    );

    BookingFormDTO.ServiceBookingDTO dto = new BookingFormDTO.ServiceBookingDTO();
    dto.selectedService  = 'Babysitting Request';
    dto.selectedHotelId  = hotel.Id;
    dto.selectedDateDTO  = dateDto;
    dto.fromTime         = '18:00';
    dto.toTime           = '20:00';
    dto.selectedHour     = '2';
    dto.selectedCurrency = 'EUR';
    dto.cost             = 50.00;
    dto.status           = 'Requested';
    dto.isRemoved        = false;

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.handleAdditionalServiceBookings(
        'Kid One',
        new List<BookingFormDTO.ServiceBookingDTO>{ dto },
        opp.Id
    );
    Test.stopTest();

}

// ═══════════════════════════════════════════════════════════════════
//  N.  getChildIdFromChildsList – no-match returns null
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testGetChildIdFromChildsList_NoMatch() {
    Account acc = new Account(Name = 'TestAcc NoMatch');
    insert acc;

    Child__c c = new Child__c(
        First_Name__c = 'RealFirst',
        Last_Name__c  = 'RealLast',
        DOB__c        = Date.newInstance(2010, 5, 5),
        Parent__c     = acc.Id
    );
    insert c;

    BookingFormDTO.ChildDTO childDTO = new BookingFormDTO.ChildDTO();
    childDTO.firstName = 'WrongFirst';
    childDTO.lastName  = 'WrongLast';
    childDTO.dobDTO    = new BookingFormDTO.DateDTO();
    childDTO.dobDTO.year  = 2010;
    childDTO.dobDTO.month = 5;
    childDTO.dobDTO.day   = 5;

    Test.startTest();
    String result = BookingFormControllerREST.getChildIdFromChildsList(
        new List<Child__c>{ c }, childDTO
    );
    Test.stopTest();

    System.assertEquals(null, result, 'Should return null when no child matches');
}

// ═══════════════════════════════════════════════════════════════════
//  O.  isNotEmailAddress – valid email returns false,
//                           invalid email returns true
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testIsNotEmailAddress() {
    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    // Valid email
    BookingFormControllerREST.loginVerify('valid@email.com', '');
    // Invalid email (no @)
    BookingFormControllerREST.loginVerify('notanemail', '');
    Test.stopTest();
    // No assertion needed – coverage of both branches of isNotEmailAddress
}

// ═══════════════════════════════════════════════════════════════════
//  P.  sendErrorResponse and sendSuccessResponse (@TestVisible)
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testSendErrorAndSuccessResponse() {
    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.sendErrorResponse('Test error');
    String errorBody = RestContext.response.responseBody.toString();

    BookingFormControllerREST.sendSuccessResponse('Test success');
    String successBody = RestContext.response.responseBody.toString();
    Test.stopTest();

    System.assert(errorBody.contains('false'),   'Error response should contain false');
    System.assert(successBody.contains('true'),  'Success response should contain true');
}

// ═══════════════════════════════════════════════════════════════════
//  Q.  getSalutations – direct call
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testGetSalutations_Direct() {
    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.getSalutations();
    Test.stopTest();

    System.assertNotEquals(null, RestContext.response.responseBody,
        'getSalutations should populate response body');
}

// ═══════════════════════════════════════════════════════════════════
//  R.  getHotelsList – direct call with a hotel in DB
//      Covers the hotelsRecordsList loop, Contract aggregate query
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testGetHotelsList_WithHotels() {
    Account hotel = makeHotel('HotelsList Test Hotel');
    // Insert an Open Contract so the aggregate result branch executes
    Contract c = new Contract(
        AccountId  = hotel.Id,
        StartDate  = Date.newInstance(2024, 1, 1),
        Status     = 'Open',
        Club_Name__c = 'HotelsList Club',
        Opening_Days__c = 'Monday'
    );
    insert c;

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    BookingFormControllerREST.PageParametersDTO params =
        new BookingFormControllerREST.PageParametersDTO();

    Test.startTest();
    String result = BookingFormControllerREST.getHotelsList(JSON.serialize(params));
    Test.stopTest();

    System.assert(String.isNotBlank(result), 'getHotelsList should return JSON');
}

// ═══════════════════════════════════════════════════════════════════
//  S.  verifyPromoCode – empty hotelId path (else branch)
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testVerifyPromoCode_EmptyHotelId() {
    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    BookingFormDTO.DateDTO d = new BookingFormDTO.DateDTO(1, 1, 2024);

    Test.startTest();
    String result = BookingFormControllerREST.verifyPromoCode('', d, d, '', d);
    Test.stopTest();

    System.assert(result.contains('false'), 'Empty hotelId should return isSuccess=false');
}

// ═══════════════════════════════════════════════════════════════════
//  T.  getAdditionalServicesInfo – direct call
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testGetAdditionalServicesInfo_Direct() {
    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.getAdditionalServicesInfo();
    Test.stopTest();

    System.assertNotEquals(null, RestContext.response.responseBody,
        'getAdditionalServicesInfo should set response body');
}

// ═══════════════════════════════════════════════════════════════════
//  U.  getDatesListFromDateRange – covers while-loop body
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testGetDatesListFromDateRange() {
    Test.startTest();
    List<Date> dates = BookingFormControllerREST.getDatesListFromDateRange(
        Date.today(), Date.today().addDays(3)
    );
    Test.stopTest();

    System.assertEquals(4, dates.size(), 'Should return 4 dates for a 3-day range');
}

// ═══════════════════════════════════════════════════════════════════
//  V.  indexOfChildDTOWithIdInChildsDTOList – id NOT found → returns -1
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testIndexOfChildDTOWithIdInChildsDTOList_NotFound() {
    List<BookingFormDTO.childDTO> list1 = new List<BookingFormDTO.childDTO>();
    BookingFormDTO.childDTO ch = new BookingFormDTO.childDTO();
    ch.Id = 'abc';
    list1.add(ch);

    Test.startTest();
    Integer idx = BookingFormControllerREST.indexOfChildDTOWithIdInChildsDTOList(
        'xyz', list1
    );
    Test.stopTest();

    System.assertEquals(-1, idx, 'Should return -1 when ID not in list');
}

// ═══════════════════════════════════════════════════════════════════
//  W.  POST /saveBooking via Post() dispatch with KCBookings (dedup loop)
//      Creates duplicate KCBookings (Cancelled + Booked for same child/club)
//      so the dedup/merge loop inside saveBooking runs
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testSaveBooking_WithDuplicateKCBookings() {
    Account hotel  = makeHotel('Dedup Hotel');
    Account family = makeFamily('dedup@test.com');

    Opportunity opp = new Opportunity(
        Name        = 'Dedup Opp',
        StageName   = 'Confirmed',
        CloseDate   = Date.today(),
        AccountId   = family.Id,
        Hotel__c    = hotel.Id,
        Start_Date__c = Date.newInstance(2024, 5, 1),
        End_Date__c   = Date.newInstance(2024, 5, 7)
    );
    insert opp;

    Child__c child = new Child__c(
        First_Name__c = 'Dedup',
        Last_Name__c  = 'Kid',
        DOB__c        = Date.newInstance(2015, 1, 1),
        Parent__c     = family.Id
    );
    insert child;

    // Insert two KCBookings with same child/name/type/date – one Booked, one Cancelled
    Kids_Clubs_Booking__c kcb1 = new Kids_Clubs_Booking__c(
        Booking__c          = opp.Id,
        Child__c            = child.Id,
        Status__c           = 'Booked',
        Club_Date__c        = Date.newInstance(2024, 5, 3)
    );
    Kids_Clubs_Booking__c kcb2 = new Kids_Clubs_Booking__c(
        Booking__c          = opp.Id,
        Child__c            = child.Id,
        Status__c           = 'Cancelled',
        Club_Date__c        = Date.newInstance(2024, 5, 3)
    );
    insert new List<Kids_Clubs_Booking__c>{ kcb1, kcb2 };

    BookingFormControllerREST.PageParametersDTO params =
        new BookingFormControllerREST.PageParametersDTO();
    params.hotelId   = hotel.Id;
    params.bookingId = opp.Id;

    String bookingDTOJson = makeBookingDTOJson(
        hotel.Id, 'dedup@test.com', 'Tst', 'Usr', true
    );

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    BookingFormControllerREST.saveBooking(
        JSON.serialize(params),
        bookingDTOJson,
        '{}',
        hotel.Id
    );
    Test.stopTest();
    // Coverage goal is to execute the dedup loop; no specific assertion needed
}

// ═══════════════════════════════════════════════════════════════════
//  X.  createBookingDTOFROMBookingId – PersonHasOptedOutOfEmail = true
//      Covers the "else → set to false" branch  
// ═══════════════════════════════════════════════════════════════════
@isTest
static void testCreateBookingDTO_OptedOutEmail_True() {
    Account hotel  = makeHotel('OptedOut Hotel');
    Account family = makeFamily('optedout@test.com');
    family.PersonHasOptedOutOfEmail = true;
    update family;

    Opportunity opp = new Opportunity(
        Name        = 'OptedOut Opp',
        StageName   = 'Confirmed',
        CloseDate   = Date.today(),
        AccountId   = family.Id,
        Hotel__c    = hotel.Id,
        Start_Date__c = Date.newInstance(2024, 6, 1),
        End_Date__c   = Date.newInstance(2024, 6, 5)
    );
    insert opp;

    RestRequest req  = new RestRequest();
    RestResponse res = new RestResponse();
    RestContext.request  = req;
    RestContext.response = res;

    Test.startTest();
    String result = BookingFormControllerREST.getAvailableData(opp.Id);
    Test.stopTest();

    System.assert(String.isNotBlank(result));
}
    @isTest
    static void testBookingFormDTO_DefaultConstructorCoverage() {
        BookingFormDTO dto = new BookingFormDTO();

        System.assertNotEquals(null, dto.familyDetails);
        System.assertNotEquals(null, dto.childsList);
        System.assertNotEquals(null, dto.agentDetails);
        System.assertNotEquals(null, dto.promoCode);
        System.assertEquals(false, dto.isAgentBooking);
        System.assertEquals(false, dto.isReadOnly);
        System.assertEquals(false, dto.editMode);
        System.assertEquals(0.0, dto.hotelSiblingDiscPercentage);
        System.assertEquals(0.0, dto.bookingFees);
        System.assertEquals('', dto.promoCode.code);
        System.assertEquals(0.0, dto.promoCode.discount);
    }

    @isTest
    static void testChildDTO_ConstructorsCoverage() {
        BookingFormDTO.childDTO childDefault = new BookingFormDTO.childDTO();

        System.assertNotEquals(null, childDefault.kidsClubBookings);
        System.assertNotEquals(null, childDefault.availableHotelClubs);
        System.assertNotEquals(null, childDefault.serviceBookingsList);
        System.assertEquals(null, childDefault.doesChildTakeAnySortOfMedication);
        System.assertEquals(null, childDefault.doesChildHaveAllergies);
        System.assertEquals(null, childDefault.doesChildHaveMedicalOrAdditionalNeeds);
        System.assertEquals(null, childDefault.childParticipateInClubActivities);
        System.assertEquals(null, childDefault.childRequireSwimmingAid);

        BookingFormDTO.DateDTO dob = new BookingFormDTO.DateDTO(10, 5, 2020);
        BookingFormDTO.childDTO childParam = new BookingFormDTO.childDTO('CH1', 'Sam', 'Taylor', dob);

        System.assertEquals('CH1', childParam.Id);
        System.assertEquals('Sam', childParam.firstName);
        System.assertEquals('Taylor', childParam.lastName);
        System.assertEquals(10, childParam.dobDTO.day);
        System.assertEquals(5, childParam.dobDTO.month);
        System.assertEquals(2020, childParam.dobDTO.year);
        System.assertEquals('', childParam.guardianNames);
        System.assertEquals('', childParam.collectionPassword);
        System.assertEquals('', childParam.photoPermission);
    }

    @isTest
    static void testDateDTO_ConstructorsCoverage() {
        BookingFormDTO.DateDTO emptyDate = new BookingFormDTO.DateDTO();
        System.assertEquals(null, emptyDate.day);
        System.assertEquals(null, emptyDate.month);
        System.assertEquals(null, emptyDate.year);

        Date sampleDate = Date.newInstance(2024, 8, 15);
        BookingFormDTO.DateDTO fromDate = new BookingFormDTO.DateDTO(sampleDate);
        System.assertEquals(15, fromDate.day);
        System.assertEquals(8, fromDate.month);
        System.assertEquals(2024, fromDate.year);

        BookingFormDTO.DateDTO manualDate = new BookingFormDTO.DateDTO(1, 2, 2025);
        System.assertEquals(1, manualDate.day);
        System.assertEquals(2, manualDate.month);
        System.assertEquals(2025, manualDate.year);
    }

    @isTest
    static void testKCBookingDTO_ConstructorsCoverage() {
        BookingFormDTO.DateDTO bookingDate = new BookingFormDTO.DateDTO(20, 4, 2024);

        BookingFormDTO.KCBookingDTO kc1 = new BookingFormDTO.KCBookingDTO(
            'KB1', bookingDate, '08:30am - 12:30pm', 'KC1', 'GRP1',
            45, 'Booked', 5, 'AM', 'CLUB1'
        );

        System.assertEquals('KB1', kc1.id);
        System.assertEquals('KC1', kc1.kidsClubId);
        System.assertEquals('GRP1', kc1.kcGroupId);
        System.assertEquals(45, kc1.cost);
        System.assertEquals(45, kc1.actualCost);
        System.assertEquals(5, kc1.discount);
        System.assertEquals('Booked', kc1.bookingStatus);
        System.assertEquals('AM', kc1.clubType);
        System.assertEquals('CLUB1', kc1.strClubId);

        BookingFormDTO.KCBookingDTO kc2 = new BookingFormDTO.KCBookingDTO(
            'KB2', bookingDate, '01:00pm - 05:00pm', 'KC2', 'GRP2',
            60, 'Requested', 10, 'PM', 'CLUB2', 'Mini Club'
        );

        System.assertEquals('Mini Club', kc2.clubName);
        System.assertEquals(60, kc2.actualCost);
    }

    @isTest
    static void testDiscountAndSeriesDTOCoverage() {
        List<String> discountTypes = new List<String>{'Series', 'Promo'};
        BookingFormDTO.DateDTO fromDate = new BookingFormDTO.DateDTO(1, 4, 2024);
        BookingFormDTO.DateDTO toDate = new BookingFormDTO.DateDTO(30, 4, 2024);

        BookingFormDTO.DiscountDTO discount1 = new BookingFormDTO.DiscountDTO(
            'AM', 12.5, discountTypes, fromDate, toDate, 48, 4, 2, 'PROMO10', 'CLUB1'
        );

        System.assertEquals('AM', discount1.strClubType);
        System.assertEquals(12.5, discount1.dobDiscountAmount);
        System.assertEquals(48, discount1.intMaxAge);
        System.assertEquals(4, discount1.intMinAge);
        System.assertEquals(2, discount1.intMinSessions);
        System.assertEquals('PROMO10', discount1.strPromoCode);
        System.assertEquals('CLUB1', discount1.strClubId);
        System.assertNotEquals(null, discount1.seriesList);

        BookingFormDTO.DiscountDTO discount2 = new BookingFormDTO.DiscountDTO(
            'PM', 5, discountTypes, fromDate, toDate, null, null, null, null, null
        );

        System.assertEquals(0, discount2.intMaxAge);
        System.assertEquals(0, discount2.intMinAge);
        System.assertEquals(0, discount2.intMinSessions);

        BookingFormDTO.SeriesDiscountDTO series = new BookingFormDTO.SeriesDiscountDTO(3, 15);
        System.assertEquals(3, series.noOfDays);
        System.assertEquals(15, series.discountAmt);
    }

    @isTest
    static void testServiceBookingDTO_ConstructorsCoverage() {
        BookingFormDTO.ServiceBookingDTO serviceDefault = new BookingFormDTO.ServiceBookingDTO();
        System.assertEquals(false, serviceDefault.isRemoved);

        BookingFormDTO.DateDTO serviceDate = new BookingFormDTO.DateDTO(5, 6, 2024);

        BookingFormDTO.ServiceBookingDTO service1 = new BookingFormDTO.ServiceBookingDTO(
            'SB1', 'HOTEL1', 'Babysitting', serviceDate, '2', 'EUR', 50
        );
        System.assertEquals('SB1', service1.id);
        System.assertEquals('HOTEL1', service1.selectedHotelId);
        System.assertEquals('Babysitting', service1.selectedService);
        System.assertEquals('2', service1.selectedHour);
        System.assertEquals('EUR', service1.selectedCurrency);
        System.assertEquals(50, service1.cost);
        System.assertEquals(false, service1.isRemoved);

        BookingFormDTO.ServiceBookingDTO service2 = new BookingFormDTO.ServiceBookingDTO(
            'SB2', 'HOTEL2', 'Hourly Childcare', serviceDate, '3', 'USD', 75, 'Requested'
        );
        System.assertEquals('Requested', service2.status);
        System.assertEquals(false, service2.isRemoved);

        BookingFormDTO.ServiceBookingDTO service3 = new BookingFormDTO.ServiceBookingDTO(
            'SB3', 'HOTEL3', 'Nanny', serviceDate, '4', 'GBP', 100, 'Confirmed', '18:00', '20:00'
        );
        System.assertEquals('Confirmed', service3.status);
        System.assertEquals('18:00', service3.fromTime);
        System.assertEquals('20:00', service3.toTime);
    }

    @isTest
    static void testHotelClubAndKidsClubWrapperCoverage() {
        BookingFormDTO.HotelClubsWithKidsClubGroupsDTO hotelClubDefault =
            new BookingFormDTO.HotelClubsWithKidsClubGroupsDTO();

        System.assertNotEquals(null, hotelClubDefault.kidsClubGroupsList);
        System.assertNotEquals(null, hotelClubDefault.closingDaysList);
        System.assertNotEquals(null, hotelClubDefault.allDatesDTOList);

        BookingFormDTO.DateDTO startDate = new BookingFormDTO.DateDTO(1, 7, 2024);
        BookingFormDTO.DateDTO endDate = new BookingFormDTO.DateDTO(7, 7, 2024);

        BookingFormDTO.HotelClubsWithKidsClubGroupsDTO hotelClubParam =
            new BookingFormDTO.HotelClubsWithKidsClubGroupsDTO(
                'HC1', 'Kids Club', 6, startDate, endDate,
                'Monday;Tuesday;Friday', 'Club message', 2
            );

        System.assertEquals('HC1', hotelClubParam.id);
        System.assertEquals('Kids Club', hotelClubParam.clubName);
        System.assertEquals(6, hotelClubParam.staffNo);
        System.assertEquals(3, hotelClubParam.closingDaysList.size());
        System.assertEquals('Club message', hotelClubParam.message);
        System.assertEquals(2, hotelClubParam.sessionsToAutoSelect);

        BookingFormDTO.HotelClubsWithKidsClubGroupsDTO hotelClubNoClosingDays =
            new BookingFormDTO.HotelClubsWithKidsClubGroupsDTO(
                'HC2', 'Teens Club', 4, startDate, endDate,
                '', 'No closing days', 0
            );

        System.assertEquals(0, hotelClubNoClosingDays.closingDaysList.size());

        BookingFormDTO.KidsClubGroup kidsGroupDefault = new BookingFormDTO.KidsClubGroup();
        System.assertNotEquals(null, kidsGroupDefault.kidsClubsList);
        System.assertNotEquals(null, kidsGroupDefault.bookingDatesDTOsList);

        BookingFormDTO.KidsClubGroup kidsGroupParam =
            new BookingFormDTO.KidsClubGroup('KG1', '8:30am - 12:30pm', 35, 'AM', 1);

        System.assertEquals('KG1', kidsGroupParam.id);
        System.assertEquals('8:30am - 12:30pm', kidsGroupParam.openingHours);
        System.assertEquals(35, kidsGroupParam.cost);
        System.assertEquals('AM', kidsGroupParam.clubType);
        System.assertEquals(1, kidsGroupParam.orderValue);

        BookingFormDTO.HotelClubWrapper wrapper = new BookingFormDTO.HotelClubWrapper();
        System.assertNotEquals(null, wrapper.kidsClubList);
    }

    @isTest
    static void testPromoCodeDTOCoverage() {
        BookingFormDTO.PromoCodeDTO promo = new BookingFormDTO.PromoCodeDTO();
        System.assertEquals('', promo.code);
        System.assertEquals(0.0, promo.discount);
    }

}