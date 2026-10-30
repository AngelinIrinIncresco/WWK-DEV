@RestResource(urlMapping='/bookingFormControllerREST/*')
global with sharing class BookingFormControllerREST {
    public static Map<String, String> profileInfoMap = new Map<String, String>();
    
    @HttpPost
    global static void Post(){
        String endpoint = RestContext.request.requestURI.substringAfterLast('/');
        String requestBody = RestContext.request.requestBody.toString();
        Map<String, Object> requestBodyMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        
        switch on endpoint{
            /*     when 'verifyPromoCode' {
Map<String, Object> requestBodyMapPromo = (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());

// Extract DTO parameters from the request body map
String hotelId = (String) requestBodyMapPromo.get('hotelId');
Map<String, Object> checkInDateDTO = (Map<String, Object>) requestBodyMapPromo.get('checkInDateDTO');
Map<String, Object> checkOutDateDTO = (Map<String, Object>) requestBodyMapPromo.get('checkOutDateDTO');
String promoCode = (String) requestBodyMapPromo.get('promoCode');
Map<String, Object> createdDateDTO = (Map<String, Object>) requestBodyMapPromo.get('createdDateDTO');

// Create DateDTO instances from the extracted data
Integer checkInYear = Integer.valueOf((String) checkInDateDTO.get('year'));
Integer checkInMonth = Integer.valueOf((String) checkInDateDTO.get('month'));
Integer checkInDay = Integer.valueOf((String) checkInDateDTO.get('day'));

Integer checkOutYear = Integer.valueOf((String) checkOutDateDTO.get('year'));
Integer checkOutMonth = Integer.valueOf((String) checkOutDateDTO.get('month'));
Integer checkOutDay = Integer.valueOf((String) checkOutDateDTO.get('day'));

Integer createdYear = Integer.valueOf((String) createdDateDTO.get('year'));
Integer createdMonth = Integer.valueOf((String) createdDateDTO.get('month'));
Integer createdDay = Integer.valueOf((String) createdDateDTO.get('day'));

// Create DateDTO instances from the parsed integers
BookingDTO.DateDTO checkInDate = new BookingDTO.DateDTO(checkInDay, checkInMonth, checkInYear);
BookingDTO.DateDTO checkOutDate = new BookingDTO.DateDTO(checkOutDay, checkOutMonth, checkOutYear);
BookingDTO.DateDTO createdDate = new BookingDTO.DateDTO(createdDay, createdMonth, createdYear);

// Call verifyPromoCode method with DTO parameters
verifyPromoCode(hotelId, checkInDate, checkOutDate, promoCode, createdDate);
}  */
            when 'saveBooking' {
                
                
                
                Map<String, Object> pageParametersJSON = (Map<String, Object>)requestBodyMap.get('pageParametersJSONStr');
                String pageParametersJSONStr = JSON.serialize(pageParametersJSON);
                Map<String, Object> BookingDTOJSON = (Map<String, Object>)requestBodyMap.get('BookingDTOJSONStr');
                String BookingDTOJSONStr = JSON.serialize(BookingDTOJSON);
                Map<String, Object> paymentDataJSON = (Map<String, Object>)requestBodyMap.get('paymentData');
                String paymentData = JSON.serialize(paymentDataJSON);
                
                String strHotelId = String.valueOf(requestBodyMap.get('strHotelId'));
                System.debug('hello'+ pageParametersJSONStr);
                saveBooking(pageParametersJSONStr,BookingDTOJSONStr,paymentData,strHotelId);
            }
            
            /*when 'createPaymentIntent'{
Decimal amount = (Decimal) requestBodyMap.get('amount');
String transactionCurrency = (String) requestBodyMap.get('transactionCurrency');
createPaymentIntent(amount,transactionCurrency);

}*/
            
            when 'getHotelClubsAvailable'{
                
                
                Map<String, Object> requestBodyMapHotel = (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());
                Map<String, Object> checkInDateDTO = (Map<String, Object>) requestBodyMapHotel.get('checkInDateDTO');
                Map<String, Object> checkOutDateDTO = (Map<String, Object>) requestBodyMapHotel.get('checkOutDateDTO');
                String selectedHotelId = (String) requestBodyMapHotel.get('selectedHotelId');
                //String guestUser = (String) requestBodyMapHotel.get('guestUser');
                List<Object> birthdatesDTO = (List<Object>) requestBodyMapHotel.get('birthdatesDTO');

                // start:fix for NullPointerException at 9th march 2026-11:25am - tayib
                RestResponse res = RestContext.response;
                if(res == null) {
                    res = new RestResponse();
                    RestContext.response = res;
                }
                
                // Return error if required data is missing
                if(checkInDateDTO == null || checkOutDateDTO == null || selectedHotelId == null) {
                    Map<String, Object> errorResponse = new Map<String, Object>{
                        'success' => false,
                        'message' => 'Missing required parameters: checkInDateDTO, checkOutDateDTO, or selectedHotelId'
                    };
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
                    return;
                }
                // end:fix for NullPointerException at 9th march 2026-11:25am - tayib
                
                // Create DateDTO instances from the extracted data
                Integer checkInYear = Integer.valueOf((String) checkInDateDTO.get('year'));
                Integer checkInMonth = Integer.valueOf((String) checkInDateDTO.get('month'));
                Integer checkInDay = Integer.valueOf((String) checkInDateDTO.get('day'));
                
                Integer checkOutYear = Integer.valueOf((String) checkOutDateDTO.get('year'));
                Integer checkOutMonth = Integer.valueOf((String) checkOutDateDTO.get('month'));
                Integer checkOutDay = Integer.valueOf((String) checkOutDateDTO.get('day'));
                 
                List<BookingFormDTO.DateDTO> birthDateList = new List<BookingFormDTO.DateDTO>();
                List<Object> birthdateDTOs = (List<Object>) requestBodyMapHotel.get('birthdatesDTO');
                // Create DateDTO instances from the parsed integers
                BookingFormDTO.DateDTO checkInDate = new BookingFormDTO.DateDTO(checkInDay, checkInMonth, checkInYear);
                BookingFormDTO.DateDTO checkOutDate = new BookingFormDTO.DateDTO(checkOutDay, checkOutMonth, checkOutYear);
                List<Object> results = new List<Object>();
                for (Object birthdateDTO : birthdateDTOs) {
                    Map<String, Object> birthdateMap = (Map<String, Object>)birthdateDTO;
                    Integer birthYear = Integer.valueOf((String) birthdateMap.get('year'));
                    Integer birthMonth = Integer.valueOf((String) birthdateMap.get('month'));
                    Integer birthDay = Integer.valueOf((String) birthdateMap.get('day'));
                    
                    // Create DateDTO instances from the parsed integers
                    BookingFormDTO.DateDTO birthDate = new BookingFormDTO.DateDTO(birthDay, birthMonth, birthYear);
                    birthDateList.add(birthDate);
                    
                    // Call the method for each birthdateDTO
                    String serializedResult = getHotelClubsAvailable(selectedHotelId, checkInDate, checkOutDate, birthDate);
                    Map<String, Object> deserializedResult = (Map<String, Object>) JSON.deserializeUntyped(serializedResult);
                    
                    // Add the new key-value pair
                    deserializedResult.put('dateOfBirth', birthDate);
                    
                    results.add(deserializedResult);
                }
                
                
                Map<String, Object> responseMap = new Map<String, Object>();
                responseMap.put('results', results);
                res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                
            }
            when 'getHotelsList' {
                
                getHotelsList(requestBody);
            }               
            when 'loginVerify' {
                
                String userName = (String) requestBodyMap.get('userName');
                String password = (String) requestBodyMap.get('password');
                
                
                
                loginVerify(userName , password);
            }
              when 'verifyAccount'{
                 Map<String, Object> requestBodyMapVerifyAccount = (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());
                String accountId = (String) requestBodyMapVerifyAccount.get('accountId');
                System.debug('accountId'+accountId);
                verifyAccount(accountId);
            }
             //  tayib:19 march 2026- adding LCA validation START
              when 'validateLCA'{
                Map<String, Object> requestBodyMapLCA = (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());
                String lcaCode = (String) requestBodyMapLCA.get('lcaCode');
                String accountId = (String) requestBodyMapLCA.get('accountId');
                String userCurrentDate = (String) requestBodyMapLCA.get('userCurrentDate');
                String userTimezoneParam = (String) requestBodyMapLCA.get('userTimezoneParam');
                
                validateLCA(lcaCode, accountId, userCurrentDate, userTimezoneParam);
            }
            // when 'validateLCA'{
            //     Map<String, Object> requestBodyMapLCA = (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());
            //     String lcaCode = (String) requestBodyMapLCA.get('lcaCode');
            //     String accountId = (String) requestBodyMapLCA.get('accountId');
                
            //     validateLCA(lcaCode, accountId);
            // }
            //  tayib:19 march 2026- adding LCA validation END

            
            when 'forgotPassword'{
                Map<String, Object> requestBodyMapForgotPassword = (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());
                
                String dateOfBirth = (String) requestBodyMapForgotPassword.get('dateOfBirth');
                String lastName = (String) requestBodyMapForgotPassword.get('lastName');
                String userName = (String) requestBodyMapForgotPassword.get('userName');
                String password = (String) requestBodyMapForgotPassword.get('password');
                String confirmPassword = (String) requestBodyMapForgotPassword.get('confirmPassword');
                forgotPassword(userName,lastName,dateOfBirth,password,confirmPassword);
            }
            
            
            
            
            
            
            
            
        }
        
    }
    
    @HttpGet
    global static void Get() {
        
        String endpoint = RestContext.request.requestURI.substringAfterLast('/');
        
        
        System.debug(' RestContext Variable value: ' + endpoint );
        System.debug(' request Variable value: ' +RestContext.request );
        System.debug('requestBody Variable value: ' +RestContext.request.params );
        //String requestBody = RestContext.request.requestBody.toString();
        
        
        
        
        
        switch on endpoint {
            when 'getServiceBookingFromTimesList'{
                getServiceBookingFromTimesList();
            }
            
            when 'getServiceBookingToTimesList' {
                getServiceBookingToTimesList();
            }
            
            
            
            
            
            when 'getServiceBookingTimesList' {
                RestResponse res = RestContext.response;
                if(res == null) {
                    res = new RestResponse();
                    RestContext.response = res;
                    
                }
                
                
                String fromTimes = getServiceBookingFromTimesList(); // Assuming this is the correct variable name
                String toTimes = getServiceBookingToTimesList(); // Assuming this is the correct variable name
                
                Map<String, Object> deserializedResultFromTimes = (Map<String, Object>) JSON.deserializeUntyped(fromTimes);
                Map<String, Object> deserializedResultToTimes = (Map<String, Object>) JSON.deserializeUntyped(toTimes);
                
                Map<String, Object> results = new Map<String, Object>();
                results.put('fromTimes', deserializedResultFromTimes);
                results.put('toTimes', deserializedResultToTimes);
                
                
                
                Map<String, Object> responseMap = new Map<String, Object>();
                responseMap.put('results', results);
                res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            }
            
            when 'validateSession'{
                RestRequest req = RestContext.request;
                Map<String, String> queryParams = req.params;
                String session = req.params.get('session');
                
                validateSession(session);
            }
            
            
            
            
            
            
            when 'getChildrensForFamily'{
                /*  Map<String, Object> requestBodyMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
String accountId = (String) requestBodyMap.get('accountId'); */
                RestRequest req = RestContext.request;
                Map<String, String> queryParams = req.params;
                String accountId = req.params.get('accountId');
                
                getChildrensForFamily(accountId);
            }
            when 'getAllBookings'{
                RestRequest req = RestContext.request;
                Map<String, String> queryParams = req != null ? req.params : new Map<String, String>();
                String accountId = queryParams != null ? queryParams.get('accountId') : null;
                
                getAllBookings(accountId);
            }
           
            when 'getAvailableData' {
                
                RestResponse res = RestContext.response;
                if(res == null) {
                    res = new RestResponse();
                    RestContext.response = res;
                    
                }
                RestRequest req = RestContext.request;
                Map<String, String> queryParams = req.params;
                String bookingId = req.params.get('bookingId');
                String accountId = req.params.get('accountId');
                String isAdmin = req.params.get('isAdmin');
                System.debug('isAdmin'+isAdmin);
                if(isAdmin=='true' || isAdmin =='false'){
                    getAvailableData(bookingId);
                    System.debug('inside isAdmin');
                }
                else if(accountId==null && bookingId!=null){
                    Map<String, Object> jsonResponse = new Map<String, Object>{
                        'success' => false,
                            'status' => '404',
                            'message' => 'Booking Id is not linked with Account Id'
                            };
                                String jsonString = JSON.serialize(jsonResponse);
                    RestResponse resi = RestContext.response;
                    res.responseBody = Blob.valueOf(jsonString);
                }
                
                
                else if(isAdmin==null && accountId!=null && bookingId!=null){
                    List<Opportunity> oppList = [SELECT Id, AccountId FROM Opportunity WHERE AccountId = :accountId AND Id = :bookingId];
                    
                    
                    if (!oppList.isEmpty()) {
                        getAvailableData(bookingId);
                    } else {
                        Map<String, Object> jsonResponse = new Map<String, Object>{
                            'success' => false,
                                'status' => '404',
                                'message' => 'Booking Id is not linked with Account Id'
                                };
                                    String jsonString = JSON.serialize(jsonResponse);
                        RestResponse resi = RestContext.response;
                        res.responseBody = Blob.valueOf(jsonString);
                    }
                    
                }
                
                
            }
            
            /*when 'getAvailableData'{





getAvailableData(requestBody);
}*/
            
            
            /*   when 'getHotelClubsAvailable'{


Map<String, Object> requestBodyMapHotel = (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());
Map<String, Object> checkInDateDTO = (Map<String, Object>) requestBodyMapHotel.get('checkInDateDTO');
Map<String, Object> checkOutDateDTO = (Map<String, Object>) requestBodyMapHotel.get('checkOutDateDTO');
String selectedHotelId = (String) requestBodyMapHotel.get('selectedHotelId');
Map<String, Object> birthdateDTO = (Map<String, Object>) requestBodyMapHotel.get('birthdateDTO');

// Create DateDTO instances from the extracted data
Integer checkInYear = Integer.valueOf((String) checkInDateDTO.get('year'));
Integer checkInMonth = Integer.valueOf((String) checkInDateDTO.get('month'));
Integer checkInDay = Integer.valueOf((String) checkInDateDTO.get('day'));

Integer checkOutYear = Integer.valueOf((String) checkOutDateDTO.get('year'));
Integer checkOutMonth = Integer.valueOf((String) checkOutDateDTO.get('month'));
Integer checkOutDay = Integer.valueOf((String) checkOutDateDTO.get('day'));

Integer birthYear = Integer.valueOf((String) birthdateDTO.get('year'));
Integer birthMonth = Integer.valueOf((String) birthdateDTO.get('month'));
Integer birthDay = Integer.valueOf((String) birthdateDTO.get('day'));

// Create DateDTO instances from the parsed integers
BookingDTO.DateDTO checkInDate = new BookingDTO.DateDTO(checkInDay, checkInMonth, checkInYear);
BookingDTO.DateDTO checkOutDate = new BookingDTO.DateDTO(checkOutDay, checkOutMonth, checkOutYear);
BookingDTO.DateDTO birthDate = new BookingDTO.DateDTO(birthDay, birthMonth, birthYear); 




/* RestRequest req = RestContext.request;
Map<String, String> queryParams = req.params; // Changed to Map<String, String> as parameters are strings

// Extracting query parameters as strings
String checkInDateDTOString = queryParams.get('checkInDateDTO');
String checkOutDateDTOString = queryParams.get('checkOutDateDTO');
String selectedHotelId = queryParams.get('selectedHotelId');
String birthdateDTOString = queryParams.get('birthdateDTO');

// Parsing JSON strings into maps
Map<String, Object> checkInDateDTO = (Map<String, Object>) JSON.deserializeUntyped(checkInDateDTOString);
Map<String, Object> checkOutDateDTO = (Map<String, Object>) JSON.deserializeUntyped(checkOutDateDTOString);
Map<String, Object> birthdateDTO = (Map<String, Object>) JSON.deserializeUntyped(birthdateDTOString);

// Parse individual date components
Integer checkInYear = Integer.valueOf((String) checkInDateDTO.get('year'));
Integer checkInMonth = Integer.valueOf((String) checkInDateDTO.get('month'));
Integer checkInDay = Integer.valueOf((String) checkInDateDTO.get('day'));

Integer checkOutYear = Integer.valueOf((String) checkOutDateDTO.get('year'));
Integer checkOutMonth = Integer.valueOf((String) checkOutDateDTO.get('month'));
Integer checkOutDay = Integer.valueOf((String) checkOutDateDTO.get('day'));

Integer birthYear = Integer.valueOf((String) birthdateDTO.get('year'));
Integer birthMonth = Integer.valueOf((String) birthdateDTO.get('month'));
Integer birthDay = Integer.valueOf((String) birthdateDTO.get('day'));

// Create DateDTO instances from the parsed integers
BookingDTO.DateDTO checkInDate = new BookingDTO.DateDTO(checkInDay, checkInMonth, checkInYear);
BookingDTO.DateDTO checkOutDate = new BookingDTO.DateDTO(checkOutDay, checkOutMonth, checkOutYear);
BookingDTO.DateDTO birthDate = new BookingDTO.DateDTO(birthDay, birthMonth, birthYear); 





getHotelClubsAvailable(selectedHotelId,checkInDate,checkOutDate,birthDate);
} */
            when 'checkEmail'{
                RestRequest req = RestContext.request;
                Map<String, String> queryParams = req.params;
                String email = req.params.get('email');
                /* Map<String, Object> requestBodyMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
String email = (String) requestBodyMap.get('email'); */
                checkEmail(email);
            }
            when else {
                RestResponse res = RestContext.response;
                if(res == null) {
                    res = new RestResponse();
                    RestContext.response = res;
                }
                res.statusCode = 404;
                Map<String, Object> notFoundResponse = new Map<String, Object>{
                    'isSuccess' => false,
                    'success' => false,
                    'message' => 'Endpoint not found: ' + endpoint
                };
                res.responseBody = Blob.valueOf(JSON.serialize(notFoundResponse));
            }
        }
    }
    
     public static void verifyAccount(String accountId){
        RestResponse res = RestContext.response;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        List<Account> personAccList = [SELECT Id, Has_user_changed_password__c,First_Name__c, Last_Name__c, Phone, A_UserName__c, A_Password__c
                                       FROM Account
                                       WHERE Id = :  accountId                                 
                                       AND IsPersonAccount = true
                                       ORDER BY CreatedDate DESC
                                       LIMIT 1];
        
        if(!personAccList.isEmpty()) {
            Account personAcc = personAccList[0];
            String session = WWKCSiteSessionHandler.createSessionForFamilyAPI(personAcc.Id);
            
           
                Map<String, Object> jsonResponse = new Map<String, Object>{
                    'success' => true,
                        'message' => 'login success',
                        'accountId' => personAcc.Id,
                        'session' => session,
                        'firstName' => personAcc.First_Name__c,
                        'lastName' => personAcc.Last_Name__c,
                        'phone' => personAcc.Phone,
                        'userName' => personAcc.A_UserName__c
                        };
                            String jsonString = JSON.serialize(jsonResponse);
                res.responseBody = Blob.valueOf(jsonString);
           
        
    }
        else{
            Map<String, Object> jsonResponse = new Map<String, Object>{
                    'success' => false,
                        'message' => 'login failed, incorrect accountId'
                      
                        };
                            String jsonString = JSON.serialize(jsonResponse);
                res.responseBody = Blob.valueOf(jsonString);
        }
    }
    
  
    //  tayib:19 march 2026- adding LCA validation START

        public static void validateLCA(String lcaCode, String accountId, String userCurrentDate, String userTimezoneParam) {
        RestResponse res = RestContext.response;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        
        if (String.isBlank(lcaCode) || String.isBlank(accountId)) {
            Map<String, Object> jsonResponse = new Map<String, Object>{
                'success' => false,
                'isValid' => false,
                'message' => 'Missing required parameters: lcaCode or accountId'
            };
            res.responseBody = Blob.valueOf(JSON.serialize(jsonResponse));
            return;
        }
        
        List<Account> accountList = [
            SELECT Id, LCA_Number__c, LCAExpiryDate__c
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];
        
        // Get Salesforce organization's timezone
        Organization org = [SELECT TimeZoneSidKey FROM Organization LIMIT 1];
        String salesforceTimezone = org.TimeZoneSidKey;
        System.debug('validateLCA - Salesforce timezone: ' + salesforceTimezone);
        
        // Get user's timezone from the request or default to Salesforce timezone
        String userTimezone = String.isNotBlank(userTimezoneParam) ? userTimezoneParam : salesforceTimezone;
        System.debug('validateLCA - User timezone: ' + userTimezone);
        
        // Security check: Validate that the timezone is not manipulated
        // Block if timezone is radically different (potential abuse)
        // Allow common timezone variations (e.g., +5:30 vs +5:00 within reasonable range)
        Boolean isTimezoneValid = true;
        if (String.isNotBlank(userTimezoneParam)) {
            // List of common valid timezone patterns
            Set<String> validTimezones = new Set<String>{
                'GMT', 'UTC', 'Europe/London', 'Europe/Paris', 'Europe/Berlin',
                'Asia/Kolkata', 'Asia/Dubai', 'Asia/Singapore', 'Asia/Tokyo',
                'America/New_York', 'America/Los_Angeles', 'America/Chicago',
                'Australia/Sydney', 'Pacific/Auckland'
            };
            
            // Check if timezone is in valid list or matches common patterns
            if (!validTimezones.contains(userTimezoneParam) && !userTimezoneParam.contains('/')) {
                isTimezoneValid = false;
                System.debug('validateLCA - Invalid timezone format: ' + userTimezoneParam);
            }
        }
        
        if (!isTimezoneValid) {
            Map<String, Object> jsonResponse = new Map<String, Object>{
                'success' => false,
                'isValid' => false,
                'message' => 'Invalid timezone. Please use a valid timezone.'
            };
            res.responseBody = Blob.valueOf(JSON.serialize(jsonResponse));
            return;
        }
        
        if (accountList.isEmpty()) {
            Map<String, Object> jsonResponse = new Map<String, Object>{
                'success' => false,
                'isValid' => false,
                'message' => 'Account not found'
            };
            res.responseBody = Blob.valueOf(JSON.serialize(jsonResponse));
            return;
        }
        
        Account acc = accountList[0];
        String storedLcaNumber = acc.LCA_Number__c != null ? String.valueOf(acc.LCA_Number__c) : '';
        Date lcaExpiryDate = acc.LCAExpiryDate__c;
        
        // Debug: log the values
        System.debug('validateLCA - Input LCA: ' + lcaCode);
        System.debug('validateLCA - Stored LCA: ' + storedLcaNumber);
        
        
        // Normalize both: remove 'LCA-' prefix and all dashes for comparison
        String lcaCodeInput = lcaCode.replaceAll('LCA-', '').replaceAll('-', '');
        String storedLcaNumberClean = storedLcaNumber.replaceAll('LCA-', '').replaceAll('-', '');
        
        
        System.debug('validateLCA - Input LCA normalized: ' + lcaCodeInput);
        System.debug('validateLCA - Stored LCA normalized: ' + storedLcaNumberClean);
        
        Boolean isLcaCodeValid = lcaCodeInput == storedLcaNumberClean;
        Boolean isLcaExpired = false;
        
        // Determine today's date in user's timezone
        Date todayDate;
        if (String.isNotBlank(userCurrentDate)) {
            // Parse user-provided date (format: YYYY-MM-DD)
            List<String> dateParts = userCurrentDate.split('-');
            todayDate = Date.newInstance(
                Integer.valueOf(dateParts[0]),
                Integer.valueOf(dateParts[1]),
                Integer.valueOf(dateParts[2])
            );
        } else {
            // Fallback to Salesforce org's today date
            todayDate = Date.today();
        }
        
        System.debug('validateLCA - Today date in user timezone: ' + todayDate);
        System.debug('validateLCA - LCA expiry date: ' + lcaExpiryDate);
        
        if (lcaExpiryDate != null) {
            // Compare dates: if expiry date is before user's today date, it's expired
            isLcaExpired = lcaExpiryDate < todayDate;
        }
        
        Map<String, Object> jsonResponse = new Map<String, Object>{
            'success' => true,
            'isValid' => isLcaCodeValid && !isLcaExpired,
            'lcaCodeValid' => isLcaCodeValid,
            'lcaExpired' => isLcaExpired,
            'expiryDate' => lcaExpiryDate != null ? String.valueOf(lcaExpiryDate) : null,
            'salesforceTimezone' => salesforceTimezone,
            'userTimezone' => userTimezone,
            'inputLca' => lcaCode,
            'storedLca' => storedLcaNumber,
            'message' => isLcaCodeValid ? (isLcaExpired ? 'LCA code is expired' : 'LCA code is valid') : 'LCA code does not match'
        };
        res.responseBody = Blob.valueOf(JSON.serialize(jsonResponse));
    }
//    public static void validateLCA(String lcaCode, String accountId) {
//         RestResponse res = RestContext.response;
//         if (res == null) {
//             res = new RestResponse();
//             RestContext.response = res;
//         }
        
//         if (String.isBlank(lcaCode) || String.isBlank(accountId)) {
//             Map<String, Object> jsonResponse = new Map<String, Object>{
//                 'success' => false,
//                 'isValid' => false,
//                 'message' => 'Missing required parameters: lcaCode or accountId'
//             };
//             res.responseBody = Blob.valueOf(JSON.serialize(jsonResponse));
//             return;
//         }
        
        
//         List<Account> accountList = [
//             SELECT Id, LCA_Number__c, LCAExpiryDate__c
//             FROM Account
//             WHERE Id = :accountId
//             LIMIT 1
//         ];
        
//         if (accountList.isEmpty()) {
//             Map<String, Object> jsonResponse = new Map<String, Object>{
//                 'success' => false,
//                 'isValid' => false,
//                 'message' => 'Account not found'
//             };
//             res.responseBody = Blob.valueOf(JSON.serialize(jsonResponse));
//             return;
//         }
        
//         Account acc = accountList[0];
//         String storedLcaNumber = acc.LCA_Number__c != null ? String.valueOf(acc.LCA_Number__c) : '';
//         Date lcaExpiryDate = acc.LCAExpiryDate__c;
        
//         // Debug: log the values
//         System.debug('validateLCA - Input LCA: ' + lcaCode);
//         System.debug('validateLCA - Stored LCA: ' + storedLcaNumber);
        
//         // Normalize both: remove 'LCA-' prefix and all dashes for comparison
//         String lcaCodeInput = lcaCode.replaceAll('LCA-', '').replaceAll('-', '');
//         String storedLcaNumberClean = storedLcaNumber.replaceAll('LCA-', '').replaceAll('-', '');
        
//         System.debug('validateLCA - Input LCA normalized: ' + lcaCodeInput);
//         System.debug('validateLCA - Stored LCA normalized: ' + storedLcaNumberClean);
        
//         Boolean isLcaCodeValid = lcaCodeInput == storedLcaNumberClean;
//         Boolean isLcaExpired = false;
//         if (lcaExpiryDate != null) {
//             isLcaExpired = lcaExpiryDate < Date.today();
//         }
        
//         Map<String, Object> jsonResponse = new Map<String, Object>{
//             'success' => true,
//             'isValid' => isLcaCodeValid && !isLcaExpired,
//             'lcaCodeValid' => isLcaCodeValid,
//             'lcaExpired' => isLcaExpired,
//             'expiryDate' => lcaExpiryDate != null ? String.valueOf(lcaExpiryDate) : null,
//             'inputLca' => lcaCode,
//             'storedLca' => storedLcaNumber,
//             'message' => isLcaCodeValid ? (isLcaExpired ? 'LCA code is expired' : 'LCA code is valid') : 'LCA code does not match'
//         };
//         res.responseBody = Blob.valueOf(JSON.serialize(jsonResponse));
//     }

   //  tayib:19 march 2026- adding LCA validation END

    public static void forgotPassword(String userName, String lastName, String dateOfBirth, String password, String confirmPassword) {
        RestResponse res = RestContext.response;
        Boolean isSuccess = false;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        
        List<String> childDobSplit =  dateOfBirth.split('/');  
        Date enteredChildDob = Date.newInstance(Integer.valueOf(childDobSplit[2]),
                                                Integer.valueOf(childDobSplit[1]),
                                                Integer.valueOf(childDobSplit[0]));
        
        List<Child__c> childWithMatchingCriteria = [
            SELECT Id, First_Name__c, Last_Name__c, Parent__c, DOB__c
            FROM Child__c
            WHERE Parent__r.A_UserName__c = :userName
            AND DOB__c = :enteredChildDob
            AND Last_Name__c = :lastName
            LIMIT 1
        ];
        
        if (childWithMatchingCriteria.isEmpty()) {
            sendErrorResponse('Please enter child details properly');
            return;
        }
        
        Child__c matchingChild = childWithMatchingCriteria[0];
        
        List<Account> parentWithLatestChild = [
            SELECT Id, Name, (SELECT First_Name__c, Last_Name__c, DOB__c
                              FROM Children__r
                              ORDER BY DOB__c DESC
                              LIMIT 1)
            FROM Account
            WHERE Id = :matchingChild.Parent__c
        ];
        
        if (parentWithLatestChild.isEmpty() || parentWithLatestChild[0].Children__r.isEmpty()) {
            sendErrorResponse('Please enter child details properly');
            return;
        }
        
        Child__c latestChild = parentWithLatestChild[0].Children__r[0];
        
        if (!matchingChild.First_Name__c.equalsIgnoreCase(latestChild.First_Name__c)
            || !matchingChild.Last_Name__c.equalsIgnoreCase(latestChild.Last_Name__c)
            || matchingChild.DOB__c != latestChild.DOB__c) {
                sendErrorResponse('Please enter child details properly');
                return;
            }
        else{
            sendSuccessResponse('details matched');
            isSuccess = true;
            
        }
        if(isSuccess){
            
            if (password == confirmPassword && password != null && password.trim() != '' && confirmPassword != null && confirmPassword.trim() != '') {
                Account personAcc = new Account(Id = parentWithLatestChild[0].Id);
                personAcc.A_Password__c = password;
                personAcc.Has_user_changed_password__c = true;
                upsert personAcc;
                
                SendconfirmationEmail(userName, password);
                
                sendSuccessResponse('Password Changed Successfully');
            } 
        }else {
            sendErrorResponse('Please enter child details properly');
        }
    }
    
    
    public static String verifyPromoCode(String hotelId, BookingFormDTO.DateDTO checkInDateDTO, BookingFormDTO.DateDTO checkOutDateDTO, String promoCode,  BookingFormDTO.DateDTO createdDateDTO){
        System.debug('Created Date DTO' + createdDateDTO);
        ResponseWithRecord response = new ResponseWithRecord();
        Response resp;
        RestResponse res = RestContext.response;
        if(res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        
        Date checkInDate = Date.newInstance(checkInDateDTO.year, checkInDateDTO.month, checkInDateDTO.day);
        Date checkOutDate = Date.newInstance(checkOutDateDTO.year, checkOutDateDTO.month, checkOutDateDTO.day);
        Date bookingDate = Date.newInstance(createdDateDTO.year, createdDateDTO.month, createdDateDTO.day);
        if(String.isNotBlank(hotelId) && String.isNotBlank(promoCode)){
            Discount__c promoCodeRecord = [ SELECT Promo_code_type__c, Percent_Discount__c, Club_Type__c, Min_Number_of_Records_Selected__c, 
                                           HotelClub__c, Hotel__c, Each_child_discount__c, Discount_Amount__c,
                                           From_Date__c, To_Date__c, Do_not_apply_Booking_Fees__c, Each_session_discount__c, No_of_free_sessions__c   
                                           FROM Discount__c 
                                           WHERE D_Promo_Code__c = :promoCode AND
                                           (( From_Date__c >= :checkIndate AND  From_Date__c <= :checkOutDate )OR 
                                            (From_Date__c <= :checkInDate AND To_Date__c >= :checkInDate)) AND
                                           ( Booking_Date_From__c <= :bookingDate AND Booking_Date_To__c >= :bookingDate) AND
                                           Record_Type__c = 'promocode' AND 
                                           Hotel__c =: hotelId
                                          ];
            response.isSuccess = true;
            response.record = promoCodeRecord;
        }
        else{
            response.isSuccess = false;
            response.message = 'hotel Id or promo code should not be Empty';
        }
        
        
        
        res.responseBody = Blob.valueOf(JSON.serialize(response));
        return JSON.serialize(response);
        
        
    }
    @Testvisible
    private static void sendErrorResponse(String message) {
        Map<String, Object> jsonResponse = new Map<String, Object>{
            'success' => false,
                'message' => message
                };
                    String jsonString = JSON.serialize(jsonResponse);
        RestContext.response.responseBody = Blob.valueOf(jsonString);
    }
    @TestVisible
    private static void sendSuccessResponse(String message) {
        Map<String, Object> jsonResponse = new Map<String, Object>{
            'success' => true,
                'message' => message
                };
                    String jsonString = JSON.serialize(jsonResponse);
        RestContext.response.responseBody = Blob.valueOf(jsonString);
    }
    
    
    public static void SendconfirmationEmail(String UserName,String Password){
        //send new password mail confirmation
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //wwkc__c wwkc_link =wwkc__c.getInstance();
        SiteUrl__c siteurl =SiteUrl__c.getInstance();
        List<String> sendTo = new List<String>();
        sendTo.add(UserName);
        OrgWideEmailAddress[] owea = [
        SELECT Id 
        FROM OrgWideEmailAddress  LIMIT 1
    ];
    if (!owea.isEmpty()) {
        mail.setOrgWideEmailAddressId(owea[0].Id);
    }
        
        mail.setToAddresses(sendTo);
        
        //Set email contents
        mail.setSubject('New Password Confirmation') ;
        //mail.setSenderDisplayName('Worldwide Kids') ;
        String  body =  '<b>WORLDWIDE KIDS NEW PASSWORD CONFIRMATION</b><br/><br/>';            
        body += 'Your Worldwide Kids password has been changed successfully. <br/><br/>';
        body += 'If this was not you that reset your password then please contact Worldwide Kids on +44 208 246 5340.<br/><br/>';
        // body += 'If this was you then please ignore this email. Please click <a href="'+siteurl.Url__c+'WWKC_LoginPage?lid='+languageId+'">here</a> to login.<br/><br/>';
        body += 'Kind Regards, <br/>';
        body += 'Worldwide Kids';
        
        
        mail.setHtmlBody(body);
        mails.add(mail);
        if(mails.size()>0){
            Messaging.sendEmail(mails);
        }
    }
    
    
    
    
    
    
    
    
    /* public static void createPaymentIntent(Decimal amount, String transactionCurrency){

    RestResponse res = RestContext.response;
if(res == null) {
res = new RestResponse();
RestContext.response = res;
}

res.responseBody = Blob.valueOf(JSON.serialize(StripePaymentHelper.createPaymentIntent(amount, transactionCurrency)));



} */
    
    
    public static void validateSession(String cookie) {
        RestResponse res = RestContext.response;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        
        if (cookie != null || cookie =='') {
            System.debug('cookie'+cookie);
            try {
                Account acc = [SELECT Id, Site_Session_Cookie__c FROM Account WHERE Site_Session_Cookie__c = :cookie LIMIT 1];
                Map<String, Object> jsonResponse = new Map<String, Object>{
                    'success' => true,
                        'message' => 'Cookie is available',
                        'accountId' => acc.Id
                        
                        };
                            String jsonString = JSON.serialize(jsonResponse);
                res.responseBody = Blob.valueOf(jsonString);
                
            } catch (QueryException e) {
                System.debug('QueryException for api'+e);
                Map<String, Object> jsonResponse = new Map<String, Object>{
                    'success' => false,
                        'message' => 'Cookie Expired'   
                        };
                            String jsonString = JSON.serialize(jsonResponse);
                res.responseBody = Blob.valueOf(jsonString);
                
                
            } 
        } else {
            Map<String, Object> jsonResponse = new Map<String, Object>{
                'success' => false,
                    'message' => 'Cookie Not available'   
                    };
                        
                        }
    }
    public static void loginVerify(String userName, String password) {
        RestResponse res = RestContext.response;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        
        String displayMessage = '';
        String languageId = ''; // You need to define how you're obtaining langId
        
        if(String.isBlank(userName) || isNotEmailAddress(userName)) {
            displayMessage = Label.Error_UserName;
            res.responseBody = Blob.valueOf(displayMessage);
        }
        
        if(String.isBlank(password)) {
            displayMessage = Label.Error_Password;
            res.responseBody = Blob.valueOf(displayMessage);
        }
        // tayib:19 march 2026- added LCA_Number__c, LCAExpiryDate__c
        List<Account> personAccList = [SELECT Id, Has_user_changed_password__c,First_Name__c, Last_Name__c, Phone,LCA_Number__c, LCAExpiryDate__c
                                       FROM Account
                                       WHERE A_UserName__c = :userName 
                                       AND A_Password__c = :password
                                       AND IsPersonAccount = true
                                       ORDER BY CreatedDate DESC
                                       LIMIT 1];
        
        if(!personAccList.isEmpty()) {
            Account personAcc = personAccList[0];
            String session = WWKCSiteSessionHandler.createSessionForFamilyAPI(personAcc.Id);
            
            if(personAcc.Has_user_changed_password__c) {
                Map<String, Object> jsonResponse = new Map<String, Object>{
                    'success' => true,
                        'message' => 'login success',
                        'accountId' => personAcc.Id,
                        'session' => session,
                        'firstName' => personAcc.First_Name__c,
                        'lastName' => personAcc.Last_Name__c,
                        'phone' => personAcc.Phone,
                        'lcaNumber' => personAcc.LCA_Number__c,
                        'lcaExpiryDate' => personAcc.LCAExpiryDate__c
                        };
                        // tayib:19 march 2026- added LCA_Number__c, LCAExpiryDate__c
                            String jsonString = JSON.serialize(jsonResponse);
                res.responseBody = Blob.valueOf(jsonString);
            } else {
                Map<String, Object> jsonResponse = new Map<String, Object>{
                    'success' => false,
                        'message' => 'Password not changed'
                        };
                            String jsonString = JSON.serialize(jsonResponse);
                res.responseBody = Blob.valueOf(jsonString);
            }
        } else {               
            Map<String, Object> jsonResponse = new Map<String, Object>{
                'success' => false,
                    'message' => 'Incorrect Username or password'
                    };
                        String jsonString = JSON.serialize(jsonResponse);
            res.responseBody = Blob.valueOf(jsonString);
        }
    }
    public static Boolean isNotEmailAddress(String strEmail){
        Boolean isError = true;
        if( String.isNotEmpty(strEmail)){
            String regex = '^[a-zA-Z0-9_\\+-]+(\\.[a-zA-Z0-9_\\+-]+)*@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*\\.([a-zA-Z]{2,7})$';
            //  Pattern webFormat = Pattern.compile('[0-9a-zA-z]+\\.[0-9a-zA-z]+\\.[0-9a-zA-z]+.*');
            Pattern webFormat = Pattern.compile(regex);
            matcher myMatch = webFormat.matcher(strEmail);
            boolean b = myMatch.matches();
            if(b){
                isError = false;
            }
        }
        return isError;
    }
    
    
    
    public static String getAvailableData(String bookingId) {
        String strBookingDTO = '';
        RestResponse res = RestContext.response;
        if(res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        
        try {
            // if (!String.isBlank(strBookingReq)) {
            
            
            //PageParametersDTO pageParams = (PageParametersDTO) JSON.deserialize(strBookingReq, PageParametersDTO.class);
            
            
            strBookingDTO = JSON.serialize(createBookingDTOFROMBookingId(bookingId));
            
            // }
        } catch(Exception e) {
            
            System.debug('Error: ' + e.getMessage());
            
            strBookingDTO = '{"error": "' + e.getMessage() + '"}';
        }
        
        res.responseBody = Blob.valueOf(strBookingDTO);
        return strBookingDTO;
        
        
    }
    public static void checkEmail(String email) {
        RestResponse res = RestContext.response;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        
        List<Account> bookingRecords = [SELECT Id, PersonEmail,Name FROM Account WHERE PersonEmail = :email];
        
        if (!bookingRecords.isEmpty()) {
            Map<String, Object> jsonResponse = new Map<String, Object>{
                'success' => true,
                    'message' => 'Email is already exist.',
                    'name' => bookingRecords[0].Name
                    };
                        String jsonString = JSON.serialize(jsonResponse);
            res.responseBody = Blob.valueOf(jsonString);
        } else {
            // If the list is empty, it means there are no booking records with the provided email
            Map<String, Object> jsonResponse = new Map<String, Object>{
                'success' => false,
                    'message' => 'Email does not exist.'
                    };
                        String jsonString = JSON.serialize(jsonResponse);
            res.responseBody = Blob.valueOf(jsonString);
        }
    }
    @TestVisible
    private static BookingFormDTO createBookingDTOFROMBookingId(String bookingId){
        if(String.isNotBlank(bookingId)){
            // fetch booking record from id with kids club bookings -Tayib@4march12:13pm
            Opportunity bookingRecord;
            List<Opportunity> bookingRecords = [ SELECT Id, AccountId, O_Agent__c, Start_Date__c, End_Date__c, Hotel__c, Hotel_Property__c, Hotel__r.Show_Babysitting_while_booking__c, Booking_Fee__c,
                                                Hotel__r.Booking_Info__c ,Family_Email__c, Promotion_Code__c, CreatedDate,  Sibling_Discount__c,  Hotel__r.Sibling_Discount__c,
                                                
                                                ( SELECT Id, Child__c, Child__r.First_Name__c, Child__r.Last_Name__c, Child__r.DOB__c,
                                                 Child__r.doesChildTakeAnySortOfMedication__c, Child__r.DoesChildHaveAllergies__c,
                                                 Child__r.Signs_Symptoms__c,Child__r.Treatment__c,Child__r.Time_to_be_administered__c,
                                                 Child__r.DetailChildAllergies__c,Child__r.DetailChildAdditionalNeeds__c,Child__r.C_DetailChildMedication__c,
                                                 Child__r.Medication_Required__c,Child__r.Dose__c,Child__r.How_can_the_team_support_your_child__c,
                                                 Child__r.DoesChildHaveMedicalOrAdditionalNeeds__c, Child__r.childParticipateInClubActivities__c,
                                                 Child__r.ChildRequireSwimmingAid__c,Child__r.childCollectPersonName__c, Child__r.childCollectPersonPassword__c, Child__r.agreeForPhotographAndFilmingForPublicity__c,
                                                Discount_Amount__c,cost__c, Status__c, Club_Date__c, Kids_Club__c, Club_Time__c, Kids_Club__r.KC_Group_Id__c, Club_Type__c,
                                                 Kids_Club__r.Hotel_Club__c, Kids_Club__r.KC_Club_Name__c,Booking__c
                                                 FROM Booking_Line_Items__r WHERE Status__c!='Cancelled'),
                                                ( SELECT Id, CurrencyIsoCode, Name, SB_Bookings__c, SB_Child__c, SB_Date__c, SB_Service__c, SB_Hotel__c, SB_From_Time__c, SB_To_Time__c, SB_Hours__c,
                                                 SB_Child__r.First_Name__c, SB_Child__r.Last_Name__c, SB_Child__r.DOB__c,
                                                 SB_Child__r.doesChildTakeAnySortOfMedication__c, SB_Child__r.DoesChildHaveAllergies__c,
                                                 SB_Child__r.DoesChildHaveMedicalOrAdditionalNeeds__c, SB_Child__r.childParticipateInClubActivities__c,
                                                 SB_Child__r.ChildRequireSwimmingAid__c,
                                                 SB_Child__r.childCollectPersonName__c,
                                                 SB_Child__r.childCollectPersonPassword__c,
                                                 SB_Child__r.agreeForPhotographAndFilmingForPublicity__c,
                                                 SB_Cost__c, Children__c, Status__c
                                                 FROM Service_Bookings__r
                                                 //WHERE SB_Service__c NOT IN ('Babysitting Request', 'Babysitting Confirmed')) 
                                                 WHERE Status__c != 'Cancelled')                                                
                                                FROM Opportunity 
                                                WHERE Id =: bookingId];
            // Booking DTO
            BookingFormDTO bookingDTORecord = new BookingFormDTO();
            
            if(bookingRecords != null && !bookingRecords.isEmpty()) {
                bookingRecord = bookingRecords.get(0);
            }
            
            if(bookingRecord != null){
                bookingDTORecord.id = bookingRecord.Id;
                
                if(String.isNotBlank((String)bookingRecord.Id)){
                    bookingDTORecord.editMode = true;
                }
                
                bookingDTORecord.hotelSiblingDiscPercentage = bookingRecord.Hotel__r.Sibling_Discount__c;
                // fetch family details
                bookingDTORecord.familyDetails = [ SELECT id, salutation, firstName, lastName, personEmail, phone, PersonHasOptedOutOfEmail 
                                                  FROM Account 
                                                  WHERE Id =: bookingRecord.AccountId];
                // this field is opposite in client side
                if(bookingDTORecord.familyDetails.PersonHasOptedOutOfEmail == null ||
                   bookingDTORecord.familyDetails.PersonHasOptedOutOfEmail == false){
                       bookingDTORecord.familyDetails.PersonHasOptedOutOfEmail = true;
                   }
                else{
                    bookingDTORecord.familyDetails.PersonHasOptedOutOfEmail = false;
                }
                // check for Agent booking                                 
                if(!String.isEmpty(bookingRecord.O_Agent__c)){
                    bookingDTORecord.isAgentBooking = true;
                    // fetch and assign agent record
                    bookingDTORecord.agentDetails = [ SELECT Id, Salutation, FirstName, LastName, Email, Phone 
                                                     FROM Contact 
                                                     WHERE id =: bookingRecord.O_Agent__c];
                }
                else{
                    bookingDTORecord.isAgentBooking = false;    
                }
                bookingDTORecord.createdDateDTO = createDateDTOFromDate(Date.newInstance(bookingRecord.CreatedDate.year(),
                                                                                         bookingRecord.CreatedDate.month(),
                                                                                         bookingRecord.CreatedDate.day()
                                                                                        ));
                bookingDTORecord.selectedHotelId = bookingRecord.Hotel__c;
                bookingDTORecord.hotelProperty = bookingRecord.Hotel_property__c;
                bookingDTORecord.checkInDateDTO = createDateDTOFromDate(bookingRecord.Start_Date__c);
                bookingDTORecord.checkOutDateDTO = createDateDTOFromDate(bookingRecord.End_Date__c);
                bookingDTORecord.promoCode.code = bookingRecord.Promotion_Code__c;
                bookingDTORecord.siblingDiscount = bookingRecord.Sibling_Discount__c;
                bookingDTORecord.showBabysittingSection = bookingRecord.Hotel__r.Show_Babysitting_while_booking__c;
                bookingDTORecord.bookingInfoFromHotel = bookingRecord.Hotel__r.Booking_Info__c;
                
                if(bookingRecord.Booking_Fee__c != null){
                    bookingDTORecord.bookingFees = bookingRecord.Booking_Fee__c;
                }
                System.debug('booking record --> service boooking r'+bookingRecord.Service_Bookings__r);
                
                // get child DTO's list with related kidsclub booking DTO's and Service booking
                bookingDTORecord.childsList = createChildDTOListWithRelatedKCBookings(bookingRecord.Booking_Line_Items__r,
                                                                                      bookingDTORecord.selectedHotelId,
                                                                                      bookingDTORecord.checkInDateDTO,
                                                                                      bookingDTORecord.checkOutDateDTO,bookingRecord.Service_Bookings__r, bookingId );
                
                bookingDTORecord.babySittingList = getBabysittingsList(bookingDTORecord.id);
            }
            Map<Id, Boolean> bookingIsReadOnlyMap = WWKCBookingHelper.areReadOnlyBookings(new List<Opportunity>{bookingRecord});
            if(bookingIsReadOnlyMap == NULL || bookingIsReadOnlyMap.get(bookingRecord.Id)){
                bookingDTORecord.isReadOnly = true;
            }
            else bookingDTORecord.isReadOnly = false;
            return bookingDTORecord;
        }
        else return null;
    }
    private static BookingFormDTO.DateDTO createDateDTOFromDate(Date dateRecord){
        return new BookingFormDTO.DateDTO(dateRecord.day(), dateRecord.month(), dateRecord.year());
    }
  private static List<BookingFormDTO.childDTO> createChildDTOListWithRelatedKCBookings( 
                                                     List<Kids_Clubs_Booking__c> kcBookingsList,
                                                     String selectedHotelId, 
                                                     BookingFormDTO.DateDTO checkInDateDTO, 
                                                     BookingFormDTO.DateDTO checkOutDateDTO,
                                                     List<Service_Booking__c> serviceBookingsList, String bookingId ){
                                                         
                                                     
        List<BookingFormDTO.childDTO> childsDTOList = new List<BookingFormDTO.childDTO>();
                                                         if(kcBookingsList.size()==0){
                                                              for(Service_Booking__c serviceBooking : serviceBookingsList){
                
                // create kids club booking DTO record
                BookingFormDTO.ServiceBookingDTO serviceBookingDTORecord = new BookingFormDTO.ServiceBookingDTO(serviceBooking.id,              
                                                                                                        serviceBooking.SB_Hotel__c,
                                                                                                        serviceBooking.SB_Service__c,
                                                                                                        createDateDTOFromDate(serviceBooking.SB_Date__c),
                                                                                                        serviceBooking.SB_Hours__c,
                                                                                                        serviceBooking.CurrencyIsoCode,
                                                                                                        serviceBooking.SB_Cost__c,
                                                                                                        serviceBooking.Status__c,
                                                                                                        serviceBooking.SB_From_Time__c,
                                                                                                         serviceBooking.SB_To_Time__c
                                                                                                        
                                                                                                       );
                                                                  
                                                                  
                                                                  
                String Name = serviceBooking.Children__c;
                                                                  System.debug('Name'+Name);
                                                    

                                                                  if(Name!=null){
List<String> names = Name.split(',');
                                                                  System.debug('names'+names);


List<List<Child__c>> childRecords = new List<List<Child__c>>();


for (String sample : names) {
    System.debug('sample'+sample);
    List<String> parts = sample.split(' ');
String firstName = parts[0];
String lastName = parts.size() > 1 ? parts[1] : '';
   
  
    
// tayib:5:49pm 3 march   adding childCollectPersonName__c, childCollectPersonPassword__c, agreeForPhotographAndFilmingForPublicity__c on line 955
    List<Child__c> childRecord = [SELECT Id, First_Name__c, Last_Name__c, DOB__c,
                                  doesChildTakeAnySortOfMedication__c, DoesChildHaveAllergies__c,Signs_Symptoms__c,DetailChildAllergies__c,DetailChildAdditionalNeeds__c,C_DetailChildMedication__c,Treatment__c,Time_to_be_administered__c,
                                                 Medication_Required__c,Dose__c,How_can_the_team_support_your_child__c,
                                  DoesChildHaveMedicalOrAdditionalNeeds__c, childParticipateInClubActivities__c,
                                  ChildRequireSwimmingAid__c,childCollectPersonName__c, childCollectPersonPassword__c, agreeForPhotographAndFilmingForPublicity__c
                                  FROM Child__c WHERE First_Name__c = :firstName AND Last_Name__c=:lastName LIMIT 1];
     
 
    
    if (!childRecord.isEmpty()) {
        childRecords.add(childRecord);
       
    }
}       
                                                                  for(List<Child__c> child : childRecords){
                                                                     
                                                                      
                Integer indexOfChildDTOInList = indexOfChildDTOWithIdInChildsDTOList(child[0].Id, childsDTOList);
                BookingFormDTO.childDTO childDTORecord;
                // check that child with id exists in child dto list
                if(indexOfChildDTOInList > -1){
                    childDTORecord = childsDTOList[indexOfChildDTOInList];
                    
                    // child DTO exists so add kc booking dto in kids club bookings list
                    childDTORecord.serviceBookingsList.add(serviceBookingDTORecord);
                }
                else{
                    // create new child dto record
                    childDTORecord = new BookingFormDTO.childDTO(child[0].Id,
                                                                                 child[0].First_Name__c,
                                                                                 child[0].Last_Name__c,
                                                                                 createDateDTOFromDate(child[0].DOB__c)
                                                                                );
                    // Populate medical/allergy fields (direct assignment from Salesforce picklist)
                    childDTORecord.doesChildTakeAnySortOfMedication = child[0].doesChildTakeAnySortOfMedication__c;
                    childDTORecord.signsSymptoms = child[0].Signs_Symptoms__c;
                   childDTORecord.allergen = child[0].DetailChildAllergies__c;
                    childDTORecord.additionalNeedsReason = child[0].DetailChildAdditionalNeeds__c;
                    childDTORecord.medicalConditionDetails = child[0].C_DetailChildMedication__c;
                    childDTORecord.treatment = child[0].Treatment__c;
                    childDTORecord.medicationTime = child[0].Time_to_be_administered__c;
                    childDTORecord.medicationRequired = child[0].Medication_Required__c;
                    childDTORecord.medicationDose = child[0].Dose__c;
                    childDTORecord.additionalNeedsSupport = child[0].How_can_the_team_support_your_child__c;
                    //Child__r.Signs_Symptoms__c,Child__r.Treatment__c,Child__r.Time_to_be_administered__c, Child__r.Medication_Required__c,Child__r.Dose__c,Child__r.How_can_the_team_support_your_child__c,
                    childDTORecord.doesChildHaveAllergies = child[0].DoesChildHaveAllergies__c;
                    childDTORecord.doesChildHaveMedicalOrAdditionalNeeds = child[0].DoesChildHaveMedicalOrAdditionalNeeds__c;
                    childDTORecord.childParticipateInClubActivities = child[0].childParticipateInClubActivities__c;
                    childDTORecord.childRequireSwimmingAid = child[0].ChildRequireSwimmingAid__c;

                    // Tayib-code changes start @3-Mar-2026 : 5:30pm
                    childDTORecord.guardianNames = child[0].childCollectPersonName__c;
                    childDTORecord.collectionPassword = child[0].childCollectPersonPassword__c;
                    childDTORecord.photoPermission = child[0].agreeForPhotographAndFilmingForPublicity__c;
                    // Tayib-code changes end @3-Mar-2026 : 5:30pm
                    /**
                     *@Description  : get all hotel available for child with kids club groups list
                    */
                   
                        ResponseWithRecordsList hotelClubsAvailableResponse = new ResponseWithRecordsList();
                        hotelClubsAvailableResponse = getHotelClubsAvailableHelper(selectedHotelId, checkInDateDTO, checkOutDateDTO, childDTORecord.dobDTO);
                        if(hotelClubsAvailableResponse.isSuccess){
                            // add available hotel club groups to child
                            childDTORecord.availableHotelClubs = (List<BookingFormDTO.HotelClubsWithKidsClubGroupsDTO>)hotelClubsAvailableResponse.recordsList;
                        }
                        else{
                            return null;
                        }
                    
                    childDTORecord.serviceBookingsList.add(serviceBookingDTORecord);
                    // add child DTO record to list
                    childsDTOList.add(childDTORecord);
                }
                                                                  }
                
            }
                                                         }
                                                         }
        if(!kcBookingsList.isEmpty()){
            for(Kids_Clubs_Booking__c kcBookingRecord : kcBookingsList){
                // create kids club booking DTO record
                BookingFormDTO.KCBookingDTO kcBookingDTORecord = new BookingFormDTO.KCBookingDTO( kcBookingRecord.Id, 
                                                                        createDateDTOFromDate(kcBookingRecord.Club_Date__c),
                                                                        kcBookingRecord.Club_Time__c,
                                                                        kcBookingRecord.Kids_Club__c,
                                                                        kcBookingRecord.Kids_Club__r.KC_Group_Id__c,
                                                                        kcBookingRecord.cost__c,
                                                                        kcBookingRecord.Status__c,
                                                                        kcBookingRecord.Discount_Amount__c,
                                                                        kcBookingRecord.Club_Type__c,
                                                                        kcBookingRecord.Kids_Club__r.Hotel_Club__c,
                                                                                         kcBookingRecord.Kids_Club__r.KC_Club_Name__c
                                                                                         
                                                                      );
               
                
                Integer indexOfChildDTOInList = indexOfChildDTOWithIdInChildsDTOList(kcBookingRecord.Child__c, childsDTOList);
                BookingFormDTO.childDTO childDTORecord;
                // check that child with id exists in child dto list
                if(indexOfChildDTOInList > -1){
                    childDTORecord = childsDTOList[indexOfChildDTOInList];
                    
                    // child DTO exists so add kc booking dto in kids club bookings list
                    // childDTORecord.kidsClubBookings.add(kcBookingDTORecord);
                }
                else{
                    // create new child dto record
                    childDTORecord = new BookingFormDTO.childDTO(kcBookingRecord.Child__c,
                                                                                 kcBookingRecord.Child__r.First_Name__c,
                                                                                 kcBookingRecord.Child__r.Last_Name__c,
                                                                                 createDateDTOFromDate(kcBookingRecord.Child__r.DOB__c)
                                                                                );
                    // Populate medical/allergy fields (direct assignment from Salesforce picklist)
                    childDTORecord.doesChildTakeAnySortOfMedication = kcBookingRecord.Child__r.doesChildTakeAnySortOfMedication__c;
                    /*childDTORecord.signsSymptoms = kcBookingRecord.Signs_Symptoms__c;
                    childDTORecord.allergen = kcBookingRecord.DetailChildAllergies__c;
                    childDTORecord.additionalNeedsReason = kcBookingRecord.DetailChildAdditionalNeeds__c;
                    childDTORecord.medicalConditionDetails = kcBookingRecord.C_DetailChildMedication__c;
                    childDTORecord.treatment = kcBookingRecord.Treatment__c;
                    childDTORecord.medicationTime = kcBookingRecord.Time_to_be_administered__c;
                    childDTORecord.medicationRequired = kcBookingRecord.Medication_Required__c;
                    childDTORecord.medicationDose = kcBookingRecord.Dose__c;
                    childDTORecord.additionalNeedsSupport = kcBookingRecord.How_can_the_team_support_your_child__c;*/
                    childDTORecord.doesChildHaveAllergies = kcBookingRecord.Child__r.DoesChildHaveAllergies__c;
                    childDTORecord.doesChildHaveMedicalOrAdditionalNeeds = kcBookingRecord.Child__r.DoesChildHaveMedicalOrAdditionalNeeds__c;
                    childDTORecord.childParticipateInClubActivities = kcBookingRecord.Child__r.childParticipateInClubActivities__c;
                    childDTORecord.childRequireSwimmingAid = kcBookingRecord.Child__r.ChildRequireSwimmingAid__c;
                    // tayib-4march-12:13pm
                    childDTORecord.guardianNames = kcBookingRecord.Child__r.childCollectPersonName__c;
                    childDTORecord.collectionPassword = kcBookingRecord.Child__r.childCollectPersonPassword__c;
                    childDTORecord.photoPermission = kcBookingRecord.Child__r.agreeForPhotographAndFilmingForPublicity__c;
                    /**
                     *@Description  : get all hotel available for child with kids club groups list
                    */
                    try{
                        ResponseWithRecordsList hotelClubsAvailableResponse = new ResponseWithRecordsList();
                        hotelClubsAvailableResponse = getHotelClubsAvailableHelper(selectedHotelId, checkInDateDTO, checkOutDateDTO, childDTORecord.dobDTO);
                        if(hotelClubsAvailableResponse.isSuccess){
                            // add available hotel club groups to child
                            childDTORecord.availableHotelClubs = (List<BookingFormDTO.HotelClubsWithKidsClubGroupsDTO>)hotelClubsAvailableResponse.recordsList;
                        }
                        else{
                            return null;
                        }
                    } catch(Exception e){
                        System.debug('Exception ::: '+ e);
                        return null;
                    }
                    
                    // add child DTO record to list
                    childsDTOList.add(childDTORecord);
                }
                
                // add booking date on respective kids club group
                // for each hotel club DTO record
                for(BookingFormDTO.HotelClubsWithKidsClubGroupsDTO hotelClubDTORecord : childDTORecord.availableHotelClubs){
                    // for each kids club group
                    for(BookingFormDTO.KidsClubGroup kcGroupRecord :hotelClubDTORecord.kidsClubGroupsList){
                        System.debug(kcGroupRecord.id + ' ::: ' + kcBookingDTORecord.kcGroupId);
                        if(kcGroupRecord.id == kcBookingDTORecord.kcGroupId 
                            && !kcBookingDTORecord.bookingStatus.equalsIgnoreCase('cancelled')){
                            System.debug('kcGroupRecord ::: '+kcGroupRecord);
                            System.debug('kcBookingDTORecord ::: '+kcBookingDTORecord);
                            kcGroupRecord.bookingDatesDTOsList.add(kcBookingDTORecord.bookingDateDTO);
                        }
                    }
                }                
                childDTORecord.kidsClubBookings.add(kcBookingDTORecord);
            }
            
            /// Modified by Sagar
             for(Service_Booking__c serviceBooking : serviceBookingsList){
                 
                
                // create kids club booking DTO record
                BookingFormDTO.ServiceBookingDTO serviceBookingDTORecord = new BookingFormDTO.ServiceBookingDTO(serviceBooking.id,              
                                                                                                        serviceBooking.SB_Hotel__c,
                                                                                                        serviceBooking.SB_Service__c,
                                                                                                        createDateDTOFromDate(serviceBooking.SB_Date__c),
                                                                                                        serviceBooking.SB_Hours__c,
                                                                                                        serviceBooking.CurrencyIsoCode,
                                                                                                        serviceBooking.SB_Cost__c,
                                                                                                         serviceBooking.Status__c,
                                                                                                        serviceBooking.SB_From_Time__c,
                                                                                                         serviceBooking.SB_To_Time__c
                                                                                                       
                                                                                                       );
                 
                                                                  
                String Name = serviceBooking.Children__c;
                                                                  System.debug('Name inside kcb'+Name);
                 if(Name!=null){
                                                    


List<String> names = Name.split(',');
                                                                  System.debug('names for kids club bookings'+names);


List<List<Child__c>> childRecords = new List<List<Child__c>>();


for (String sample : names) {
    System.debug('sample'+sample);
    List<String> parts = sample.split(' ');
String firstName = parts[0];
String lastName = parts.size() > 1 ? parts[1] : '';
    System.debug('lastname'+lastname);
   
  
    
   // tayib:5:49pm 3 march   adding childCollectPersonName__c, childCollectPersonPassword__c, agreeForPhotographAndFilmingForPublicity__c on line 955
 
    List<Child__c> childRecord = [SELECT Id, First_Name__c, Last_Name__c, DOB__c,
                                  doesChildTakeAnySortOfMedication__c, DoesChildHaveAllergies__c,Signs_Symptoms__c,DetailChildAllergies__c,DetailChildAdditionalNeeds__c,C_DetailChildMedication__c,Treatment__c,Time_to_be_administered__c,Medication_Required__c,Dose__c,How_can_the_team_support_your_child__c,
                                  DoesChildHaveMedicalOrAdditionalNeeds__c, childParticipateInClubActivities__c,
                                  ChildRequireSwimmingAid__c,childCollectPersonName__c, childCollectPersonPassword__c, agreeForPhotographAndFilmingForPublicity__c
                                  FROM Child__c WHERE First_Name__c = :firstName AND Last_Name__c=:lastName LIMIT 1];
     
   
    
    if (!childRecord.isEmpty()) {
        childRecords.add(childRecord);
       
    }
}       
                                                                  for(List<Child__c> child : childRecords){
                                                                     
                                                                      
                Integer indexOfChildDTOInList = indexOfChildDTOWithIdInChildsDTOList(child[0].Id, childsDTOList);
                BookingFormDTO.childDTO childDTORecord;
                // check that child with id exists in child dto list
                if(indexOfChildDTOInList > -1){
                    childDTORecord = childsDTOList[indexOfChildDTOInList];
                    
                    // child DTO exists so add kc booking dto in kids club bookings list
                    childDTORecord.serviceBookingsList.add(serviceBookingDTORecord);
                }
                else{
                    // create new child dto record
                    childDTORecord = new BookingFormDTO.childDTO(child[0].Id,
                                                                                 child[0].First_Name__c,
                                                                                 child[0].Last_Name__c,
                                                                                 createDateDTOFromDate(child[0].DOB__c)
                                                                                );
                    // Populate medical/allergy fields (direct assignment from Salesforce picklist)
                    childDTORecord.doesChildTakeAnySortOfMedication = child[0].doesChildTakeAnySortOfMedication__c;
                     childDTORecord.signsSymptoms = child[0].Signs_Symptoms__c;
                     childDTORecord.allergen = child[0].DetailChildAllergies__c;
                    childDTORecord.additionalNeedsReason = child[0].DetailChildAdditionalNeeds__c;
                    childDTORecord.medicalConditionDetails = child[0].C_DetailChildMedication__c;
                    childDTORecord.treatment = child[0].Treatment__c;
                    childDTORecord.medicationTime = child[0].Time_to_be_administered__c;
                    childDTORecord.medicationRequired = child[0].Medication_Required__c;
                    childDTORecord.medicationDose = child[0].Dose__c;
                    childDTORecord.additionalNeedsSupport = child[0].How_can_the_team_support_your_child__c;
                    childDTORecord.doesChildHaveAllergies = child[0].DoesChildHaveAllergies__c;
                    childDTORecord.doesChildHaveMedicalOrAdditionalNeeds = child[0].DoesChildHaveMedicalOrAdditionalNeeds__c;
                    childDTORecord.childParticipateInClubActivities = child[0].childParticipateInClubActivities__c;
                    childDTORecord.childRequireSwimmingAid = child[0].ChildRequireSwimmingAid__c;

                    // Tayib-code changes start @3-Mar-2026 : 5:30pm
                    childDTORecord.guardianNames = child[0].childCollectPersonName__c;
                    childDTORecord.collectionPassword = child[0].childCollectPersonPassword__c;
                    childDTORecord.photoPermission = child[0].agreeForPhotographAndFilmingForPublicity__c;
                    // Tayib-code changes end @3-Mar-2026 : 5:30pm

                    /**
                     *@Description  : get all hotel available for child with kids club groups list
                    */
                   
                        ResponseWithRecordsList hotelClubsAvailableResponse = new ResponseWithRecordsList();
                        hotelClubsAvailableResponse = getHotelClubsAvailableHelper(selectedHotelId, checkInDateDTO, checkOutDateDTO, childDTORecord.dobDTO);
                        if(hotelClubsAvailableResponse.isSuccess){
                            // add available hotel club groups to child
                            childDTORecord.availableHotelClubs = (List<BookingFormDTO.HotelClubsWithKidsClubGroupsDTO>)hotelClubsAvailableResponse.recordsList;
                        }
                        else{
                            return null;
                        }
                    
                    childDTORecord.serviceBookingsList.add(serviceBookingDTORecord);
                    // add child DTO record to list
                    childsDTOList.add(childDTORecord);
                }
                                                                  }
             }
                
            }
        }
                                                         
        
        
        System.debug('childsDTOList nikhil '+childsDTOList);
                                                        
Set<Id> addedParentIds = new Set<Id>();
                                                         Opportunity oppRecord = [SELECT Id, AccountId FROM Opportunity WHERE Id = :bookingId];
        
        // Query the child record based on the parent ID (AccountId)
        // tayib:5:49pm 3 march   adding childCollectPersonName__c, childCollectPersonPassword__c, agreeForPhotographAndFilmingForPublicity__c on line 955
        List<Child__c> childRecord = [SELECT Id, Parent__c, First_Name__c, Last_Name__c, DOB__c,
                                      doesChildTakeAnySortOfMedication__c, DoesChildHaveAllergies__c,Signs_Symptoms__c,DetailChildAllergies__c,DetailChildAdditionalNeeds__c,C_DetailChildMedication__c,Treatment__c,Time_to_be_administered__c,Medication_Required__c,Dose__c,How_can_the_team_support_your_child__c,
                                      DoesChildHaveMedicalOrAdditionalNeeds__c, childParticipateInClubActivities__c,
                                      ChildRequireSwimmingAid__c,childCollectPersonName__c, childCollectPersonPassword__c, agreeForPhotographAndFilmingForPublicity__c
                                      FROM Child__c WHERE Parent__c=:oppRecord.AccountId];
        
       System.debug('childRecord nikhil'+childRecord);
                                                        List<Child__c> recordsToAdd = new List<Child__c>();
Set<Id> addedChildIds = new Set<Id>();
                                                         
                                                         if(childRecord.size()>0){
Set<Id> remainingChildIds = new Set<Id>();

// Iterate through childRecord

for (Child__c child : childRecord) {
    boolean found = false;
    
    // Iterate through childDTORecord to check if the child exists
    for (BookingFormDTO.ChildDTO childDTORecord : childsDTOList) {
        if (child.Id == childDTORecord.Id) {
            found = true;
            break;
        }
    }
    
    // If the child is not found in childDTORecord, add its ID to the set
    if (!found) {
        remainingChildIds.add(child.Id);
        recordsToAdd.add(child);
    }
}
                                                             System.debug('record to add'+remainingChildIds);
                                                             for(Child__c child: recordsToAdd){
                                                             BookingFormDTO.ChildDTO childDTORecord = new BookingFormDTO.ChildDTO(); 
                                                              childDTORecord = new BookingFormDTO.childDTO(child.Id, 
                                                                                 child.First_Name__c,
                                                                                 child.Last_Name__c,
                                                                                 createDateDTOFromDate(child.DOB__c)
                                                                                );
                    // Populate medical/allergy fields (direct assignment from Salesforce picklist) tayib-new-2pm-4march
                    childDTORecord.doesChildTakeAnySortOfMedication = child.doesChildTakeAnySortOfMedication__c;
                     childDTORecord.signsSymptoms = child.Signs_Symptoms__c;
                     childDTORecord.allergen = child.DetailChildAllergies__c;
                    childDTORecord.additionalNeedsReason = child.DetailChildAdditionalNeeds__c;
                    childDTORecord.medicalConditionDetails = child.C_DetailChildMedication__c;
                    childDTORecord.treatment = child.Treatment__c;
                    childDTORecord.medicationTime = child.Time_to_be_administered__c;
                    childDTORecord.medicationRequired = child.Medication_Required__c;
                    childDTORecord.medicationDose = child.Dose__c;
                    childDTORecord.additionalNeedsSupport = child.How_can_the_team_support_your_child__c;
                    childDTORecord.doesChildHaveAllergies = child.DoesChildHaveAllergies__c;
                    childDTORecord.doesChildHaveMedicalOrAdditionalNeeds = child.DoesChildHaveMedicalOrAdditionalNeeds__c;
                    childDTORecord.childParticipateInClubActivities = child.childParticipateInClubActivities__c;
                    childDTORecord.childRequireSwimmingAid = child.ChildRequireSwimmingAid__c;
                    childDTORecord.guardianNames = child.childCollectPersonName__c;
                    childDTORecord.collectionPassword = child.childCollectPersonPassword__c;
                    childDTORecord.photoPermission = child.agreeForPhotographAndFilmingForPublicity__c;
    childsDTOList.add(childDTORecord);
                                                             
                                                         }
                                                             
                                                         }
                                                  
        
        return childsDTOList;
    }
    public String hotelId {
        get {
            if(String.isBlank(hotelId)) {
                hotelId = ApexPages.currentPage().getParameters().get('accountId');
            }
            
            return hotelId;
        }
        
        set;
    }
    public List<Header_Logo__c> headerLogoList {
        get{
            if(headerLogoList == null || headerLogoList.isEmpty()){
                if(hotelId != null){
                    headerLogoList = [SELECT Id, 
                                      Site_URL__c, 
                                      Image_URL__c 
                                      FROM Header_Logo__c 
                                      WHERE Account__c = :hotelId];
                }
            }
            return headerLogoList;
        }
        set;
    }
    private static Integer getAgeInMonths(Date birthDate, Date onDate){
        Integer ageInMonths = birthDate.monthsBetween(onDate);
        if(birthDate.day() > onDate.day() ){
            ageInMonths--;
        }
        return ageInMonths;
    }
    @TestVisible
    private static Integer indexOfChildDTOWithIdInChildsDTOList(String id, List<BookingFormDTO.childDTO> childsDTOList){
        if(!childsDTOList.isEmpty()){
            Integer childsDTOListCount = childsDTOList.size();
            for(Integer index = 0; index < childsDTOListCount; index++){
                if(childsDTOList[index].Id == id) return index;
            }
        }
        return -1;
    }
    
    @TestVisible
    private static List<BookingFormDTO.serviceBookingDTO> getBabysittingsList(String bookingId){
        List<Service_Booking__c> babySittingRecordsList =  [ SELECT Id, SB_Date__c, SB_Service__c, SB_Hotel__c, Status__c,                                                            SB_From_Time__c, SB_To_Time__c 
                                                            FROM Service_Booking__c  
                                                            WHERE ( SB_Service__c = 'Babysitting Request' 
                                                                   AND SB_Bookings__c = :bookingId AND Status__c != 'Cancelled')
                                                           ];
        
        List<BookingFormDTO.serviceBookingDTO> babySittingRecordsDTOsList = new List<BookingFormDTO.serviceBookingDTO>();
        
        if(babySittingRecordsList.size() > 0){
            for(Service_Booking__c babySittingRecord : babySittingRecordsList){
                BookingFormDTO.ServiceBookingDTO babySittingDTO = new BookingFormDTO.ServiceBookingDTO();
                babySittingDTO.id = babySittingRecord.id;
                babySittingDTO.bookingId = bookingId;
                babySittingDTO.fromTime = babySittingRecord.SB_From_Time__c;
                babySittingDTO.toTime = babySittingRecord.SB_To_Time__c;
                babySittingDTO.selectedDateDTO =  createDateDTOFromDate(babySittingRecord.SB_Date__c);
                babySittingDTO.isRemoved = false;
                babySittingDTO.Status = babySittingRecord.Status__c;
                babySittingRecordsDTOsList.add(babySittingDTO);
            }
        }
        return babySittingRecordsDTOsList;
    }
    @TestVisible
    private static ResponseWithRecordsList getHotelClubsAvailableHelper(String selectedHotelId, BookingFormDTO.DateDTO checkInDateDTO, 
                                                                        BookingFormDTO.DateDTO checkOutDateDTO, BookingFormDTO.DateDTO birthdateDTO){
                                                                            
                                                                            ResponseWithRecordsList childClubsAvailableResponse = new ResponseWithRecordsList();
                                                                            List<Contract> hotelClubsAvilableList = new List<Contract>();
                                                                            try{
                                                                                Date checkInDate = Date.newInstance(checkInDateDTO.year, checkInDateDTO.month, checkInDateDTO.day);
                                                                                Date checkOutDate = Date.newInstance(checkOutDateDTO.year, checkOutDateDTO.month, checkOutDateDTO.day);
                                                                                Date birthDate = Date.newInstance(birthdateDTO.year, birthdateDTO.month, birthdateDTO.day);
                                                                                // wrappers list to store hotel clubs and its reated kids clubs
                                                                                List<BookingFormDTO.HotelClubWrapper> hotelClubWrapperList = new List<BookingFormDTO.HotelClubWrapper>();
                                                                                Account record = [SELECT Id,A_RM_s_Email__c FROM Account WHERE Id=:selectedHotelId limit 1];
                                                                                childClubsAvailableResponse.cmEmail = record.A_RM_s_Email__c;
                                                                                
                                                                                
                                                                                List<BookingFormDTO.HotelClubsWithKidsClubGroupsDTO> hotelClubsAvailableDTOList = new List<BookingFormDTO.HotelClubsWithKidsClubGroupsDTO>();
                                                                                
                                                                                
                                                                                
                                                                                // get hotel clubs available
                                                                                hotelClubsAvilableList = getHotelClubsAvailableForAge(selectedHotelId, checkInDate, checkOutDate, 
                                                                                                                                      getAgeInMonths(birthdate, checkInDate));
                                                                                hotelClubWrapperList = createHCWrapperListFromHCList(hotelClubsAvilableList);
                                                                                
                                                                                /* create kids club groups according to same kids club  group Id
* Kids club will be childs of kids club group 
*/
                                                                                hotelClubsAvailableDTOList = createHotelClubsWithKidsClubGroupsDTOList(hotelClubWrapperList);
                                                                                
                                                                                
                                                                                System.debug('hotelClubWrapperList : ' + JSON.serialize(hotelClubWrapperList));
                                                                                
                                                                                
                                                                                Account hotel = [SELECT Id, CurrencyIsoCode, Name, A_Show_Payment_Page__c, Payment_Type__c, Percentage_Take__c, Sibling_Discount__c, 
                                                                                                 Show_Babysitting_while_booking__c, Booking_Info__c, Booking_Fees__c,
                                                                                                 (SELECT Id, Booking_From__c, Booking_To__c, Check_In_From__c, Check_In_To__c 
                                                                                                  FROM Booking_Fees__r)
                                                                                                 FROM Account
                                                                                                 WHERE Id =: selectedHotelId];
                                                                                
                                                                                childClubsAvailableResponse.currencyIsoCode = hotel.CurrencyIsoCode;
                                                                                
                                                                                // if(isAdminUser()){
                                                                                // childClubsAvailableResponse.skipBookingFees = true;
                                                                                
                                                                                
                                                                                
                                                                                //  }
                                                                                //else{
                                                                                childClubsAvailableResponse.skipBookingFees = !hotel.A_Show_Payment_Page__c;
                                                                                if(hotel.A_Show_Payment_Page__c){
                                                                                    //[Pritam June 22] Added to handle percentage booking fees
                                                                                    childClubsAvailableResponse.paymentType = hotel.Payment_Type__c;
                                                                                    childClubsAvailableResponse.bookingFees = hotel.Booking_Fees__c; 
                                                                                    childClubsAvailableResponse.percentageTake = hotel.Percentage_Take__c;
                                                                                }
                                                                                
                                                                                
                                                                                // }
                                                                                
                                                                                childClubsAvailableResponse.siblingDiscount = hotel.Sibling_Discount__c;
                                                                                childClubsAvailableResponse.showBabysittingSection = hotel.Show_Babysitting_while_booking__c;
                                                                                childClubsAvailableResponse.bookingInfoFromHotel = hotel.Booking_Info__c;
                                                                                /*   
if(hotel.Booking_Fees__r != null && hotel.Booking_Fees__r.size() > 0) {
Date currentDate = System.today();

for(Booking_Fees__c bookingFee : hotel.Booking_Fees__r) {
if((bookingFee.Booking_From__c < currentDate && bookingFee.Booking_To__c > currentDate)
|| (bookingFee.Check_In_From__c < checkInDate && bookingFee.Check_In_To__c > checkInDate)) {
childClubsAvailableResponse.skipBookingFees = true;
break;
}
}

}
*/
                                                                                
                                                                                System.debug('hotelClubsAvailableDTOList :: ' + JSON.serialize(hotelClubsAvailableDTOList));
                                                                                childClubsAvailableResponse.isSuccess = true;
                                                                                childClubsAvailableResponse.recordsList = hotelClubsAvailableDTOList;
                                                                                
                                                                            }
                                                                            catch(Exception e){
                                                                                childClubsAvailableResponse.isSuccess = false;
                                                                                childClubsAvailableResponse.message = 'Error While retrieving Kids clubs :: ' + e.getMessage() + ' Line Number : ' + e.getLineNumber();
                                                                            }
                                                                            return childClubsAvailableResponse;
                                                                        }
    public static List<Contract> getHotelClubsAvailableForAge(String selectedHotelId, Date checkInDate, Date checkOutDate, Integer kidsAge){
        System.debug('Kids Age :: ' + kidsAge);
        ResponseWithRecordsList childClubsAvailableResponse = new ResponseWithRecordsList();
        List<Contract> availableHotelClubsWithKidsClubList = new List<Contract>();
        try{
            // kids age is completed age we want running age
            //kidsAge++;
            List<Contract> availableSharedHotelClubsIdList = [ SELECT Id 
                                                              FROM Contract 
                                                              WHERE Id 
                                                              IN (  SELECT LKU_Hotel_club__c 
                                                                  FROM Shared_Inventory__c 
                                                                  WHERE Hotel__c = :selectedHotelId )
                                                             ];
            availableHotelClubsWithKidsClubList = [ SELECT Id, Staff_No__c, StartDate, EndDate, Opening_Days__c, 
                                                   Description, SpecialTerms, H_Age_Range__c, Club_Name__c, Closing_Days__c, H_Message__c, No_next_of_autoselect__c, 
                                                   ( SELECT Id, KC_Club_Name__c, Opening_Hours__c, Cost__c, KC_Spaces_Left__c, 
                                                    Minimum_Age__c, Maximum_Age__c ,KC_Hotel_Name__c,  
                                                    Age_Range__c, KC_Date__c, KC_Group_Id__c, Club_Type__c,Club_Type_Session_Order__c, Status__c
                                                    FROM Hotel_Club__r
                                                    WHERE  (Minimum_Age__c <= :kidsAge AND Maximum_Age__c >= :kidsAge )
                                                    AND (KC_Date__c >= :checkIndate AND  KC_Date__c <= :checkOutDate)
                                                    ORDER BY Club_Type_Session_Order__c ASC
                                                   ),
                                                   (SELECT Id, Club_Type__c, HotelClub__c, Discount_Amount__c, DiscountType__c, From_Date__c,
                                                    Hotel_Club_Name__c, Maximum_Age_In_Months__c, Minimum_Age_In_Months__c,
                                                    Min_Number_of_Records_Selected__c, D_Promo_Code__c, To_Date__c
                                                    FROM Discounts1__r
                                                    WHERE Hotel__c =: selectedHotelId AND Maximum_Age_In_Months__c >=: kidsAge
                                                    AND Minimum_Age_In_Months__c <=: kidsAge AND
                                                    (( From_Date__c >= :checkIndate AND  From_Date__c <= :checkOutDate ) 
                                                     OR (From_Date__c <= :checkInDate AND To_Date__c >= :checkInDate))
                                                    ORDER BY LastModifiedDate DESC)
                                                   FROM Contract 
                                                   WHERE (AccountId = :selectedHotelId  OR Id IN :availableSharedHotelClubsIdList) 
                                                   AND (( StartDate >= :checkIndate AND  StartDate <= :checkOutDate ) 
                                                        OR (StartDate <= :checkInDate AND EndDate >= :checkInDate))
                                                  ];
            // Remove Hotel clubs that donot have Kids club
            Integer hotelClubsCount = availableHotelClubsWithKidsClubList.size();
            System.debug('availableHotelClubsWithKidsClubList :: ' + availableHotelClubsWithKidsClubList);
            for(Integer i = 0; i < hotelClubsCount; i++){
                if(availableHotelClubsWithKidsClubList[i].Hotel_Club__r.size() == 0){
                    availableHotelClubsWithKidsClubList.remove(i);
                    i--;
                    hotelClubsCount--;
                }
                else {
                    // Set start date and end date 
                    if(checkInDate > availableHotelClubsWithKidsClubList[i].StartDate){
                        availableHotelClubsWithKidsClubList[i].StartDate = checkInDate;
                    }
                    if(checkOutDate < availableHotelClubsWithKidsClubList[i].EndDate){
                        availableHotelClubsWithKidsClubList[i].EndDate = checkOutDate;
                    }
                }
            }
            
            System.debug('Available hotel clubs count :: ' + availableHotelClubsWithKidsClubList.size());
        }
        catch(Exception e){
            System.debug('Error While retrieving Kids clubs :: ' + e.getMessage());
        }
        
        return availableHotelClubsWithKidsClubList;
    }
    public static List<BookingFormDTO.HotelClubsWithKidsClubGroupsDTO> createHotelClubsWithKidsClubGroupsDTOList(
        List<BookingFormDTO.HotelClubWrapper> hotelClubWrapperList){
            List<BookingFormDTO.HotelClubsWithKidsClubGroupsDTO> hotelClubsAvailableDTOList = new List<BookingFormDTO.HotelClubsWithKidsClubGroupsDTO>();
            try{
                Map<Id, List<BookingFormDTO.SeriesDiscountDTO>> dIdToseriesListMap = new Map<Id, List<BookingFormDTO.SeriesDiscountDTO>>();
                
                Set<Id> seriesDiscountIdSet = new Set<Id>();
                // create set of discount record ids having series discount
                for(BookingFormDTO.HotelClubWrapper hcWrapperRec : hotelClubWrapperList){
                    if(hcWrapperRec.hotelClub.Discounts1__r.size() > 0 && 
                       hcWrapperRec.hotelClub.Discounts1__r != null) {
                           System.debug('**** hcWrapperRec.hotelClub.Discounts1__r.get(0).DiscountType__c ' + hcWrapperRec.hotelClub.Discounts1__r.get(0).DiscountType__c);
                           if(hcWrapperRec.hotelClub.Discounts1__r.get(0).DiscountType__c.equalsIgnoreCase('Series')){
                               seriesDiscountIdSet.add(hcWrapperRec.hotelClub.Discounts1__r.get(0).Id);
                           }
                       }
                }    
                // get discounts detail series records 
                
                
                // for each hotel club record create Hotel Clubs With Kids Club Groups DTO Record
                for(BookingFormDTO.HotelClubWrapper hcWrapperRec : hotelClubWrapperList){
                    System.debug('Start Date DTO :: ' + createDateDTOFromDate(hcWrapperRec.hotelClub.StartDate));
                    BookingFormDTO.HotelClubsWithKidsClubGroupsDTO hotelClubsWithKidsClubGroupsDTORecord = 
                        new BookingFormDTO.HotelClubsWithKidsClubGroupsDTO( 
                            hcWrapperRec.hotelClub.Id,
                            hcWrapperRec.hotelClub.Club_Name__c,
                            hcWrapperRec.hotelClub.Staff_No__c,
                            createDateDTOFromDate(hcWrapperRec.hotelClub.StartDate),
                            createDateDTOFromDate(hcWrapperRec.hotelClub.EndDate),
                            hcWrapperRec.hotelClub.Closing_Days__c,
                            hcWrapperRec.hotelClub.H_Message__c,
                            Integer.valueOf(hcWrapperRec.hotelClub.No_next_of_autoselect__c)
                        );
                    // Create kids club groups of kids clubs whose group ids are same
                    // For each kids club record
                    for(Inventory_Product__c kidsClubRecord : hcWrapperRec.kidsClubList){  Integer indexOfKCGroup = indexOfKCGroupWithOrder(hotelClubsWithKidsClubGroupsDTORecord.kidsClubGroupsList, 
                                                                            kidsClubRecord.Club_Type_Session_Order__c);
                        if(indexOfKCGroup > -1){
                            hotelClubsWithKidsClubGroupsDTORecord.kidsClubGroupsList[indexOfKCGroup].kidsClubsList.add(kidsClubRecord);
                        }
                        else{
                            BookingFormDTO.KidsClubGroup tempKCGroupRecord = new BookingFormDTO.KidsClubGroup(
                                kidsClubRecord.KC_Group_Id__c,
                                kidsClubRecord.Opening_Hours__c,
                                kidsClubRecord.Cost__c,
                                kidsClubRecord.Club_Type__c,
                                kidsClubRecord.Club_Type_Session_Order__c
                            );
                            tempKCGroupRecord.kidsClubsList.add(kidsClubRecord);
                            hotelClubsWithKidsClubGroupsDTORecord.kidsClubGroupsList.add(tempKCGroupRecord);
                        }
                    }
                    
                    // Code by Tushar K.
                    if(hcWrapperRec.hotelClub.Discounts1__r.size() > 0 && hcWrapperRec.hotelClub.Discounts1__r != null) {
                        hotelClubsWithKidsClubGroupsDTORecord.discountDTO = new BookingFormDTO.DiscountDTO(
                            hcWrapperRec.hotelClub.Discounts1__r.get(0).Club_Type__c,
                            hcWrapperRec.hotelClub.Discounts1__r.get(0).Discount_Amount__c,
                            !String.isBlank(hcWrapperRec.hotelClub.Discounts1__r.get(0).DiscountType__c) ? hcWrapperRec.hotelClub.Discounts1__r.get(0).DiscountType__c.split(';') : new List<String>(),
                            new BookingFormDTO.DateDTO(hcWrapperRec.hotelClub.Discounts1__r.get(0).From_Date__c),
                            new BookingFormDTO.DateDTO(hcWrapperRec.hotelClub.Discounts1__r.get(0).To_Date__c),
                            hcWrapperRec.hotelClub.Discounts1__r.get(0).Maximum_Age_In_Months__c,
                            hcWrapperRec.hotelClub.Discounts1__r.get(0).Minimum_Age_In_Months__c,
                            hcWrapperRec.hotelClub.Discounts1__r.get(0).Min_Number_of_Records_Selected__c,
                            hcWrapperRec.hotelClub.Discounts1__r.get(0).D_Promo_Code__c,
                            hcWrapperRec.hotelClub.Discounts1__r.get(0).HotelClub__c
                        );
                        if(hcWrapperRec.hotelClub.Discounts1__r.get(0).DiscountType__c.equalsIgnoreCase('Series')){
                            if(dIdToseriesListMap.containsKey(hcWrapperRec.hotelClub.Discounts1__r.get(0).Id)){
                                hotelClubsWithKidsClubGroupsDTORecord.discountDTO.seriesList = dIdToseriesListMap.get(hcWrapperRec.hotelClub.Discounts1__r.get(0).Id);
                            }
                        }
                    }
                    /*
for(Discount__c discount : ) {
hotelClubsWithKidsClubGroupsDTORecord.listDiscountDTO.add(
new BookingFormDTO.DiscountDTO(
discount.Club_Type__c,
discount.Discount_Amount__c,
discount.DiscountType__c,
new BookingFormDTO.DateDTO(discount.From_Date__c),
new BookingFormDTO.DateDTO(discount.To_Date__c),
discount.Maximum_Age_In_Months__c,
discount.Minimum_Age_In_Months__c,
discount.Min_Number_of_Records_Selected__c,
discount.D_Promo_Code__c,
discount.HotelClub__c
)
);
}
*/

                hotelClubsAvailableDTOList.add(hotelClubsWithKidsClubGroupsDTORecord);
                }
            }catch(Exception e){
                System.debug('Error in createHotelClubsWithKidsClubGroupsDTOList : ' + e.getMessage() + ' ' + e.getLineNumber());
            }
            return hotelClubsAvailableDTOList;
        }
    private static List<BookingFormDTO.HotelClubWrapper> createHCWrapperListFromHCList(List<Contract> hotelClubsList){
        List<BookingFormDTO.HotelClubWrapper> hotelClubWrapperList = new List<BookingFormDTO.HotelClubWrapper>();
        for(Contract hotelClubRecord : hotelClubsList){
            BookingFormDTO.HotelClubWrapper hotelClubWrapperRec = new BookingFormDTO.HotelClubWrapper();
            hotelClubWrapperRec.hotelClub = hotelClubRecord;
            hotelClubWrapperRec.kidsClubList = hotelClubRecord.Hotel_Club__r;
            hotelClubWrapperList.add(hotelClubWrapperRec);
        }
        return hotelClubWrapperList;
    }
    
    private static Boolean isBirthdayInStay(Date checkInDate, Date checkOutDate, Date birthDate) {
        // check if day is same
        while(checkInDate.daysBetween(checkOutDate) >= 0){
            if(checkInDate.day() == birthDate.day() && checkInDate.month() == birthDate.month()) {
                return true;
            }
            
            checkInDate = checkInDate.addDays(1);
        }
        return false;
    }
    private static Integer indexOfKCGroupWithIdInList(List<BookingFormDTO.KidsClubGroup> kidsClubGroupsList, String id){
        Integer recordsCount = kidsClubGroupsList.size();
        
        for(Integer index = 0; index < recordsCount; index++){
            if(kidsClubGroupsList[index].id == id)
                return index;
        }
        return -1;

    }
    private static Integer indexOfKCGroupWithOrder(List<BookingFormDTO.KidsClubGroup> kidsClubGroupsList, Decimal orderValue){
        Integer recordsCount = kidsClubGroupsList.size();
    
        for(Integer index = 0; index < recordsCount; index++){
            
            if(kidsClubGroupsList[index].orderValue == orderValue){
                return index;
            }
        }
        return -1;
    }
    
    public static string getHotelClubsAvailable(String selectedHotelId, BookingFormDTO.DateDTO checkInDateDTO, 
                                                BookingFormDTO.DateDTO checkOutDateDTO, BookingFormDTO.DateDTO birthdateDTO){
                                                    RestResponse res = RestContext.response;
                                                    if(res == null) {
                                                        res = new RestResponse();
                                                        RestContext.response = res;
                                                        
                                                        
                                                    }
                                                    //res.responseBody = Blob.valueOf(JSON.serialize(getHotelClubsAvailableHelper(selectedHotelId, checkInDateDTO, checkOutDateDTO, birthdateDTO)));
                                                    return JSON.serialize(getHotelClubsAvailableHelper(selectedHotelId, checkInDateDTO, checkOutDateDTO, birthdateDTO));
                                                    
                                                }
    
    
    public static void saveBooking(String pageParametersJSONStr, String BookingDTOJSONStr, String paymentData, String strHotelId) {
        PageParametersDTO pageParameters = new PageParametersDTO();
        
        
        Response resp;
        RestResponse res = RestContext.response;
        if(res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        
        Boolean paymentProcessed = false;
        ResponseWithRecord saveBookingResponse = new ResponseWithRecord();
        BookingFormDTO bookingDTORecord = new BookingFormDTO();
        StripePaymentWrapper stripePaymentInfo = new StripePaymentWrapper();
        
        Boolean isAdmin = isAdminUser();
        
        try {
            
            pageParameters = (PageParametersDTO)JSON.deserialize(pageParametersJSONStr, PageParametersDTO.class);
            
            
            bookingDTORecord = (BookingFormDTO)JSON.deserialize(BookingDTOJSONStr, BookingFormDTO.class);
            System.debug('==>'+bookingDTORecord);
            List<Id> kcBookingIds = new List<Id>();
            List<Id> kcBookingIdsNotPresent = new List<Id>();
            if(pageParameters.bookingId!='' || pageParameters.bookingId!=null){
                for (Kids_Clubs_Booking__c kcBooking : [SELECT Id FROM Kids_Clubs_Booking__c WHERE Booking__c = :pageParameters.bookingId]) {
                    kcBookingIds.add(kcBooking.Id);
                }
                
                for (BookingFormDTO.childDTO child : bookingDTORecord.childsList) {
                    
                    for (BookingFormDTO.KCBookingDTO kcBooking : child.kidsClubBookings) {
                        if (kcBookingIds.contains(kcBooking.Id)) {
                            kcBookingIdsNotPresent.add(kcBooking.Id);
                        }
                        
                    }
                }	/*List<Kids_Clubs_Booking__c> recordsToUpdate = new List<Kids_Clubs_Booking__c>();
for(String bookId : kcBookingIds){
if(kcBookingIdsNotPresent.contains(bookId)){
continue;
}
else{
List<Kids_Clubs_Booking__c> updateRecord = [SELECT Id,Status__c From Kids_Clubs_Booking__c WHERE Id=:bookId];
updateRecord[0].Status__c = 'Cancelled';
//Upsert updateRecord;
recordsToUpdate.add(updateRecord[0]);
}
}
Update recordsToUpdate;
}*/
                
                List<Kids_Clubs_Booking__c> recordsToUpdate = new List<Kids_Clubs_Booking__c>();
                
                // Query all records outside the loop
                Map<Id, Kids_Clubs_Booking__c> bookingMap = new Map<Id, Kids_Clubs_Booking__c>([SELECT Id, Status__c FROM Kids_Clubs_Booking__c WHERE Id IN :kcBookingIds]);
                
                for(String bookId : kcBookingIds) {
                    // Check if the booking ID is present
                    if(kcBookingIdsNotPresent.contains(bookId)) {
                        continue;
                    } else {
                        // Get the record from the map
                        Kids_Clubs_Booking__c updateRecord = bookingMap.get(bookId);
                        if(updateRecord != null) {
                            updateRecord.Status__c = 'Cancelled';
                            recordsToUpdate.add(updateRecord);
                        }
                    }
                }
                
                // Update outside the loop
                if(!recordsToUpdate.isEmpty()) {
                    update recordsToUpdate;
                }
                
                
                
                
                if(String.isNotBlank(paymentData)){
                    
                    stripePaymentInfo = (StripePaymentWrapper)JSON.deserialize(paymentData, StripePaymentWrapper.class);
                    
                }
                
                // If admin or booking is edited
                if(isAdmin || bookingDTORecord.editMode || bookingDTORecord.bookingFees == 0) {
                    paymentProcessed = true;
                } else if(stripePaymentInfo.status == 'succeeded') {
                    paymentProcessed = true;
                } else {
                    paymentProcessed = false;
                    saveBookingResponse.isSuccess = false;
                    saveBookingResponse.message = 'Please process payment before saving booking.';
                    res.responseBody = Blob.valueOf(JSON.serialize(saveBookingResponse));
                    return;
                }
            }        } catch(Exception e) {
                System.debug('Error while deserializing Booking Data ' + e.getMessage() + ' line :: ' + e.getLineNumber());
                saveBookingResponse.isSuccess = false;
                saveBookingResponse.message ='Error while deserializing Booking Data' + e.getMessage();
                res.responseBody = Blob.valueOf(JSON.serialize(saveBookingResponse));
                return;
            } 
        
        // Save point so that we can roll back DML operation if further operations failed
        if(paymentProcessed) {
            SavePoint savePointBeforeDML = Database.setSavePoint();
            String strConfirmationText;
            Boolean isInsert = false;
            
            try {
                if(!String.isBlank(bookingDTORecord.familyDetails.personEmail)) {
                    if(!String.isBlank(pageParameters.bookingId) && !String.isBlank(bookingDTORecord.id)){
                        isInsert = true;
                    }
                    
                    saveBookingResponse = insertBookingRecord(pageParameters, bookingDTORecord, strHotelId, stripePaymentInfo, resp);
                    saveBookingResponse.wwkNo = [SELECT Id,Name FROM Opportunity WHERE Id=:saveBookingResponse.recordId].Name;
                } else {
                    saveBookingResponse.isSuccess = false;
                    saveBookingResponse.message = 'Invalid Booking Data';
                }
            } catch(Exception e) {
                System.debug('Error While saving Booking ' + e.getMessage() + ' Line no: ' + e.getLineNumber() + ' ::: '+ bookingDTORecord.id);
                Database.rollback(savePointBeforeDML);
                saveBookingResponse.isSuccess = false;
                saveBookingResponse.message = 'Error while Saving Booking Data : ' + e.getMessage() + ' ' + e.getStackTraceString() + ' ::: '+ saveBookingResponse.recordId;
            }
            
            //if(!isAdmin && !String.isBlank(saveBookingResponse.recordId)) {
            System.debug('saveBookingResponse.recordId'+saveBookingResponse.recordId);
            if(!String.isBlank(saveBookingResponse.recordId)) {
                System.debug('inside mail');
                strConfirmationText = BookingConfirmationHelper.sendEmail(saveBookingResponse.recordId, !isInsert, true);
                System.debug('strConfirmationText'+strConfirmationText);
                
                if(!String.isBlank(strConfirmationText) && strConfirmationText.equalsIgnoreCase('Confirmation Message sent Successfully!')) {  
                    System.debug('inside mail');
                    Opportunity opptyBooking = new Opportunity();
                    opptyBooking.Id = saveBookingResponse.recordId;
                    
                    opptyBooking.Invoice__c = true;
                    upsert opptyBooking;
                }
            }
        } else {
            saveBookingResponse.isSuccess = false;
            saveBookingResponse.message = 'Payment Processing Error: ' + resp.Message;
        }
        // Query all Kids_Clubs_Booking__c records related to the booking
        List<Kids_Clubs_Booking__c> kcBookings = [SELECT Id, Child__c, Club_Name_Report__c, Club_Type_and_Time__c, Club_Date_and_Time__c, Booking__c, Status__c FROM Kids_Clubs_Booking__c WHERE Booking__c = :pageParameters.bookingId];
        List<Kids_Clubs_Booking__c> deleteRecords = new List<Kids_Clubs_Booking__c>();
        List<Kids_Clubs_Booking__c> updateRecords = new List<Kids_Clubs_Booking__c>();
        
        for (Integer i = 0; i < kcBookings.size(); i++) {
            for (Integer j = i + 1; j < kcBookings.size(); j++) {
                Kids_Clubs_Booking__c booking1 = kcBookings[i];
                Kids_Clubs_Booking__c booking2 = kcBookings[j];
                
                
                if (booking1.Child__c == booking2.Child__c &&
                    booking1.Club_Name_Report__c == booking2.Club_Name_Report__c &&
                    booking1.Club_Type_and_Time__c == booking2.Club_Type_and_Time__c &&
                    booking1.Club_Date_and_Time__c == booking2.Club_Date_and_Time__c) {
                        if (booking1.Status__c == 'Cancelled' && booking2.Status__c == 'Booked') {
                            booking1.Status__c = 'Booked';
                            updateRecords.add(booking1);
                            deleteRecords.add(booking2);
                            break;
                            
                        } else if (booking2.Status__c == 'Cancelled' && booking1.Status__c == 'Booked') {
                            booking2.Status__c = 'Booked';
                            updateRecords.add(booking2);
                            deleteRecords.add(booking1);
                            break;
                        } else if(booking1.Status__c == 'Cancelled' && booking2.Status__c == 'On Waiting List'){
                            booking1.Status__c = 'On Waiting List';
                            updateRecords.add(booking1);
                            deleteRecords.add(booking2);
                            break;
                        }
                        else if (booking2.Status__c == 'Cancelled' && booking1.Status__c == 'On Waiting List') {
                            booking2.Status__c = 'On Waiting List';
                            updateRecords.add(booking2);
                            deleteRecords.add(booking1);
                            break;
                        }
                    }
            }
            
        }
        // Perform DML operations
        try {
            if (!updateRecords.isEmpty()) {
                update updateRecords;
                System.debug('Records updated successfully: ' + updateRecords);
            }
            
            if (!deleteRecords.isEmpty()) {
                delete deleteRecords;
                System.debug('Records deleted successfully: ' + deleteRecords);
            }
        } catch (Exception e) {
            System.debug('Error occurred during DML operation: ' + e.getMessage());
            
        }
        
        
        
        
        res.responseBody = Blob.valueOf(JSON.serialize(saveBookingResponse));
    }
   

    
     private static ResponseWithRecord insertBookingRecord(PageParametersDTO pageParameters, BookingFormDTO bookingDTORecord, String strHotelId, StripePaymentWrapper stripePaymentInfo, Response res){
        ResponseWithRecord saveBookingResponse = new ResponseWithRecord();
         String Name;
        
        
        Boolean isFromEmail = false;
        
        Account hotel = [SELECT Id, CurrencyIsoCode
                         FROM Account
                         WHERE Id =: strHotelId];
        
        if(String.isBlank(bookingDTORecord.familyDetails.Id)) {
            String strFamilyId = isFamilyWithEmailAlreadyExists(bookingDTORecord.familyDetails.personEmail);
            
            if(!String.isBlank(strFamilyId)) {
                bookingDTORecord.familyDetails.Id = strFamilyId;
            }
            else{
                bookingDTORecord.familyDetails.Id = null;
            }
            
            isFromEmail = !String.isBlank(bookingDTORecord.familyDetails.Id);
        }
        
        bookingDTORecord.familyDetails.recordTypeId = getRecordTypeIdFromName('Account', 'family');
        
        // create family Record if family (with email does not exists)
        if(String.isBlank(bookingDTORecord.familyDetails.Id) || bookingDTORecord.familyDetails.Id==null) {
            Integer len = 10;
            Blob blobKey = crypto.generateAesKey(128);
            String key = EncodingUtil.convertToHex(blobKey);
            String pwd = key.substring(0,len);
            bookingDTORecord.familyDetails.A_Password__c = pwd;
        }
        
        if(bookingDTORecord.familyDetails.PersonHasOptedOutOfEmail == true){
            bookingDTORecord.familyDetails.PersonHasOptedOutOfEmail = false;
        }
        else{
            bookingDTORecord.familyDetails.PersonHasOptedOutOfEmail = true;   
        }
        bookingDTORecord.familyDetails.CurrencyIsoCode = hotel.CurrencyIsoCode;
        // System.debug('bookingDTORecord.familyDetails' + bookingDTORecord.familyDetails);
        upsert bookingDTORecord.familyDetails;
        
        // check for agent booking
        if(bookingDTORecord.isAgentBooking){
            // Insert Agent record
            // BookingFormDTO.agentDetails.accountId = getParentHoteIdFromEmailDomain(BookingFormDTO.agentDetails.Email);
            upsert bookingDTORecord.agentDetails;
        }
        
        // create booking record
        Opportunity bookingRecord = new Opportunity();
        bookingRecord = getBookingRecordFromBookingDTO(bookingDTORecord);
        bookingRecord.CurrencyIsoCode = hotel.CurrencyIsoCode;
        
        if(!String.isBlank(pageParameters.bookingId)) {
            bookingRecord.Id = pageParameters.bookingId;
        }
        
        
        
        upsert bookingRecord;
        
        /* Sharing Account and Opportunity */
        Opportunity oppRec = new Opportunity();
        
        oppRec = [SELECT Id, OwnerId, CreatedById
                  FROM Opportunity
                  WHERE Id =: bookingRecord.Id];
        // check owner and created by
        String guestUserId = getGuestUserId();
        if(!Test.isRunningTest()){
            
            if(oppRec.OwnerId != oppRec.CreatedById && oppRec.CreatedById != guestUserId){
                RecordMannualShareController.shareOpportunity(oppRec.Id, oppRec.CreatedById);
            }
        }
        System.debug('Opportunity Owner Id : ' + oppRec.OwnerId);
        
        
        // share account record
        // RecordMannualShareController.shareAccount(bookingDTORecord.familyDetails.Id, bookingRecord.ownerId);
        bookingDTORecord.familyDetails.OwnerId = oppRec.ownerId;
        
        update bookingDTORecord.familyDetails;
        
        
        if(oppRec.CreatedById != guestUserId){
           
            RecordMannualShareController.shareAccount(bookingDTORecord.familyDetails.Id, oppRec.CreatedById);
        }
        
        if(stripePaymentInfo != null && stripePaymentInfo.Amount != null){    
            // If currency is not listed it should be CHF
            if(stripePaymentInfo.TransactionCurrency == 'other'){
                stripePaymentInfo.TransactionCurrency = 'CHF';
            }
            
            Client_Payment__c clientPayment = new Client_Payment__c(
                CP_Account__c = bookingDTORecord.familyDetails.Id,
                CP_Amount__c = Double.valueOf(stripePaymentInfo.Amount),
                CP_Card_Type__c = stripePaymentInfo.PaymentMethodType,
                CP_Message__c = 'Created Timestamp ' + String.valueOf(stripePaymentInfo.CreatedTimeStamp) + ', Status: ' + stripePaymentInfo.Status,
                CP_Opportunity__c = bookingRecord.Id,
                CP_Transaction_Id__c = stripePaymentInfo.paymentId,
                CP_Transaction_Status__c = stripePaymentInfo.Status,
                CurrencyIsoCode = stripePaymentInfo.TransactionCurrency.toUpperCase(),
                CP_Payment_Type__c = bookingDTORecord.paymentType
            );
            
            insert clientPayment;
        }    
        
        saveBookingResponse.record = bookingRecord;
        saveBookingResponse.recordId = bookingRecord.Id;
        
        // assign id to booking DTO record
        bookingDTORecord.Id = bookingRecord.Id;
        
        // get all childs with kids club booking map
        ChildKCBookingResonseWrapper childKCBookingResponse = getChildsWithKCAndServiceBookings(bookingDTORecord);
         System.debug('childKCBookingResponse nikhil'+childKCBookingResponse);
        
        
        if(childKCBookingResponse.isSuccess){
            if(!childKCBookingResponse.indexChildMap.values().isEmpty()) {
                // upsert childs
                upsert childKCBookingResponse.indexChildMap.values();

                List<Booking_Child__c> bookingChildList = new List<Booking_Child__c>();

                for (Integer index : childKCBookingResponse.indexChildMap.keySet()) {
                    Child__c childRecord = childKCBookingResponse.indexChildMap.get(index);

                    bookingChildList.add(new Booking_Child__c(
                        Existing_Bookings__c = bookingDTORecord.Id,
                        Child__c = childRecord.Id,
                        Is_Active__c =true
                    ));
                }

                if (!bookingChildList.isEmpty()) {
                    upsert bookingChildList;
                }
                
                // list to stote all childs kids club booking records
                List<Kids_Clubs_Booking__c> kidsClubBookingList = new List<Kids_Clubs_Booking__c>();
               
                
                // for each child
                for(Integer index : childKCBookingResponse.indexChildMap.keySet()){
                    Child__c childRecord = childKCBookingResponse.indexChildMap.get(index);
                    
                    
                    
                    
                    // for each KC booking for a child
                    for(Kids_Clubs_Booking__c kcBookingRecord : childKCBookingResponse.indexKCBookingsListMap.get(index)){
                        // set Child to parent child
                        kcBookingRecord.Child__c = childRecord.Id;
                        kcBookingRecord.CurrencyIsoCode = hotel.CurrencyIsoCode;
                        kidsClubBookingList.add(kcBookingRecord);
                    }
                }
                if(!kidsClubBookingList.isEmpty()){
                    upsert kidsClubBookingList;
                }
                
               
                List<BookingFormDTO.ServiceBookingDTO> allServiceBookingsDTOsList = new List<BookingFormDTO.ServiceBookingDTO>();
                   String FinalName='';
                
                
                for(Integer index : childKCBookingResponse.indexChildMap.keySet()){
                    
               
                    Child__c childRecord = childKCBookingResponse.indexChildMap.get(index);
                    
                   
                     if (childKCBookingResponse.indexServiceBookingDTOsListMap.containsKey(index)) {

        List<BookingFormDTO.ServiceBookingDTO> serviceBookingDTOList = childKCBookingResponse.indexServiceBookingDTOsListMap.get(index);

       
        if (serviceBookingDTOList != null) {
            
           
            Set<String> unique = new Set<String>();
            
            
           
            for (BookingFormDTO.ServiceBookingDTO serviceBookingDTORecord : serviceBookingDTOList) {
                if (serviceBookingDTORecord != null) {
                  
                    string unique2;
                  unique2 = childRecord.First_Name__c+' '+childRecord.Last_Name__c;
                    unique.add(unique2);
                    
                   
                   
                    serviceBookingDTORecord.childId = childRecord.Id;
                    serviceBookingDTORecord.bookingId = bookingDTORecord.Id;

                    allServiceBookingsDTOsList.add(serviceBookingDTORecord);
                }
            }
            if(unique.size()>0){
              for(String value : unique){
                             FinalName = FinalName +','+ value  ;
                  System.debug('FinalName'+FinalName);
                         } 
            }
           
                     
        }
                       
                     }
                }
                
                
                if(FinalName.length()>0){
							 FinalName = FinalName.substring(1,FinalName.length());  
                System.debug('FinalName'+FinalName);
                    String bookingId ='';
                    if(!String.isBlank(pageParameters.bookingId)) {
             bookingId = pageParameters.bookingId;
        }
                    System.debug('bookingIdd'+bookingId);
                    
                handleAdditionalServiceBookings(FinalName,allServiceBookingsDTOsList,bookingId);
                }
                
                if(isFromEmail) {
                    saveBookingResponse.isSuccess = true;
                    saveBookingResponse.message = 'Email address already exists';
                }
                else {
                    saveBookingResponse.isSuccess = true;
                    saveBookingResponse.message = 'Booking created Successfully';
                }
            }
            
            if(bookingDTORecord.babySittingList != null) {
                List<Service_Booking__c> listServiceBookings = new List<Service_Booking__c>();
                
                List<Service_Booking__c> listServiceBookingsToDelete = new List<Service_Booking__c>();
                
                for(BookingFormDTO.ServiceBookingDTO additionalService : bookingDTORecord.babySittingList) {
                    Service_Booking__c serviceBooking = new Service_Booking__c();
                  
                    
                    if(String.isNotBlank(additionalService.fromTime) && String.isNotBlank(additionalService.toTime) &&
                       !additionalService.fromTime.containsIgnoreCase('NONE') && 
                       !additionalService.toTime.containsIgnoreCase('NONE') ) {
                           serviceBooking.id = additionalService.id;
                           serviceBooking.SB_Bookings__c = bookingDTORecord.Id;
                       
                           serviceBooking.SB_Date__c = Date.newInstance(additionalService.selectedDateDTO.year, additionalService.selectedDateDTO.month, additionalService.selectedDateDTO.day);
                           serviceBooking.SB_Hotel__c = bookingRecord.Hotel__c;
                           serviceBooking.SB_From_Time__c = additionalService.fromTime;
                           serviceBooking.SB_To_Time__c = additionalService.toTime;
                           serviceBooking.SB_Service__c = 'Babysitting Request';
                           listServiceBookings.add(serviceBooking);
                       }
                    else{
                        System.debug('Baby sitting Id : ' + additionalService.id );
                        if(String.isNotBlank(additionalService.id)) {
                            
                            serviceBooking.id = additionalService.id; 
                            listServiceBookingsToDelete.add(serviceBooking);
                        }
                    }
                }
                
                if(listServiceBookings.size() > 0) {
                    upsert listServiceBookings;
                }
                
                if(listServiceBookingsToDelete.size() > 0) {
                    delete listServiceBookingsToDelete;
                }
            }
        }
        else{
            saveBookingResponse.isSuccess = false;
            saveBookingResponse.messagesList = childKCBookingResponse.messagesList;
        }
        return saveBookingResponse;
    }
    
    
    
    
    
    public static string getChildrensForFamily(String accountId) {
        RestResponse res = RestContext.response;
        if(res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        FamilyWithChildrens childrenRecordsForFamilyResponse = new FamilyWithChildrens();
        childrenRecordsForFamilyResponse.childrenResponse = new ResponseWithRecordsList();
        
        if (isGuestUser() || isAdminUser()) {
            // tayib:19 march 2026-START
            // try {
            //     childrenRecordsForFamilyResponse.familyDetails = [
            //         SELECT id, salutation, firstName, lastName, personEmail, phone, PersonHasOptedOutOfEmail
            //         FROM Account 
            //         WHERE Id = :accountId
            //     ];
               
            try {
                childrenRecordsForFamilyResponse.familyDetails = [
                    SELECT id, salutation, firstName, lastName, personEmail, phone, PersonHasOptedOutOfEmail,
                           Has_user_changed_password__c, First_Name__c, Last_Name__c, A_UserName__c, 
                           A_Password__c, LCA_Number__c, LCAExpiryDate__c
                    FROM Account 
                    WHERE Id = :accountId
                ];
                // tayib:19 march 2026-END
                
                // this field is rendered opposite in client side
                
                
                if (childrenRecordsForFamilyResponse.familyDetails.PersonHasOptedOutOfEmail == null || !childrenRecordsForFamilyResponse.familyDetails.PersonHasOptedOutOfEmail) {
                    childrenRecordsForFamilyResponse.familyDetails.PersonHasOptedOutOfEmail = true;
                } else {
                    childrenRecordsForFamilyResponse.familyDetails.PersonHasOptedOutOfEmail = false;
                }
                
                // tayib:5:49pm 3 march   adding childCollectPersonName__c, childCollectPersonPassword__c, agreeForPhotographAndFilmingForPublicity__c on line 955
 
                childrenRecordsForFamilyResponse.childrenResponse.recordsList = [
                    SELECT First_Name__c, Last_Name__c, DOB__c, Age__c,
                           doesChildTakeAnySortOfMedication__c, DoesChildHaveAllergies__c,Signs_Symptoms__c,DetailChildAllergies__c,DetailChildAdditionalNeeds__c,C_DetailChildMedication__c,Treatment__c,Time_to_be_administered__c,Medication_Required__c,Dose__c,How_can_the_team_support_your_child__c,
                           DoesChildHaveMedicalOrAdditionalNeeds__c, childParticipateInClubActivities__c,
                           ChildRequireSwimmingAid__c,childCollectPersonName__c, childCollectPersonPassword__c, agreeForPhotographAndFilmingForPublicity__c
                    FROM Child__c
                    WHERE Parent__c = :accountId
                ];
                
                childrenRecordsForFamilyResponse.childrenResponse.isSuccess = true;
            } catch(Exception e) {
                childrenRecordsForFamilyResponse.childrenResponse.isSuccess = false;
                childrenRecordsForFamilyResponse.childrenResponse.message = 'Error While Retrieving Childrens for Family :: ' + e.getMessage();
                System.debug('Error While Retrieving Childrens for Family :: ' + e.getMessage());
            }
        } else {
            childrenRecordsForFamilyResponse.childrenResponse.isSuccess = false;
            childrenRecordsForFamilyResponse.childrenResponse.message = 'User is not a valid User';
        }
        
        res.responseBody = Blob.valueOf(JSON.serialize(childrenRecordsForFamilyResponse));
        return JSON.serialize(childrenRecordsForFamilyResponse);
        
    }

    public static String getAllBookings(String accountId) {
        RestResponse res = RestContext.response;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }

        if (String.isBlank(accountId)) {
            Map<String, Object> errorMap = new Map<String, Object>{
                'isSuccess' => false,
                'success' => false,
                'message' => 'Account ID parameter is required.'
            };
            res.statusCode = 400;
            String errorJson = JSON.serialize(errorMap);
            res.responseBody = Blob.valueOf(errorJson);
            return errorJson;
        }

        try {
            List<Opportunity> bookings = [
                SELECT Id, Name, Auto_Booking_Ref__c, StageName, Start_Date__c, End_Date__c,
                       Hotel__c, Hotel_Name__c, Amount, Total_Club_Cost__c, Booking_Fee__c,
                       CurrencyIsoCode, CreatedDate,
                       (SELECT Id, Status__c, Cost__c, Club_Date__c, Kids_Club__c, Club_Time__c, Club_Type__c 
                        FROM Booking_Line_Items__r WHERE Status__c != 'Cancelled'),
                       (SELECT Id, Name, Status__c, SB_Cost__c, SB_Date__c, SB_Service__c, SB_From_Time__c, SB_To_Time__c, SB_Hours__c 
                        FROM Service_Bookings__r WHERE Status__c != 'Cancelled')
                FROM Opportunity
                WHERE AccountId = :accountId
                ORDER BY CreatedDate DESC
            ];

            Map<String, Object> responseMap = new Map<String, Object>{
                'isSuccess' => true,
                'success' => true,
                'message' => bookings.isEmpty() ? 'No bookings found' : 'Bookings retrieved successfully',
                'recordsList' => bookings,
                'bookings' => bookings,
                'Data' => bookings
            };
            res.statusCode = 200;
            String jsonResult = JSON.serialize(responseMap);
            res.responseBody = Blob.valueOf(jsonResult);
            return jsonResult;
        } catch (Exception e) {
            Map<String, Object> errorMap = new Map<String, Object>{
                'isSuccess' => false,
                'success' => false,
                'message' => 'Error retrieving bookings: ' + e.getMessage()
            };
            res.statusCode = 500;
            String errorJson = JSON.serialize(errorMap);
            res.responseBody = Blob.valueOf(errorJson);
            return errorJson;
        }
    }

    public static Response getCustomLabels() {
        RestResponse res = RestContext.response;
        Response result; 
        try {
            Map<String, Map<String, String>> checkAvailability = new Map<String, Map<String, String>>{'checkingAvailability'=>new Map<String, String>{'child'=>Label.I_am_checking_availability_or_booking_for_my_children,
                'adult'=> Label.I_am_checking_availability_or_my_booking},
                    'pageSectionTitle'=>new Map<String, String>{'child'=>Label.Please_Add_Children,
                        'adult'=>Label.Please_Add_Person},
                            'firstName'=>new Map<String, String>{'child'=>Label.Child_First_Name,
                                'adult'=>Label.Adult_First_Name},
                                    'lastName'=>new Map<String, String>{'child'=>Label.Child_Last_Name,
                                        'adult'=>Label.Adult_Last_Name},
                                            'addButtonName'=>new Map<String, String>{'child'=>Label.Add_Child_Button,
                                                'adult'=>Label.Add_Person_Button}};
                                                    
                                                    Map<String, Map<String, String>> selectSession = new Map<String, Map<String, String>>{'tickTheSession'=>new Map<String, String>{'child'=>Label.Please_tick_the_session,
                                                        'adult'=>Label.Please_tick_the_session_adult},
                                                            'cost'=>new Map<String, String>{'child'=>Label.CHILDCARE_COST,
                                                                'adult'=>Label.Cost}};
                                                                    
                                                                    Map<String, Map<String, String>> contactDetails = new Map<String, Map<String, String>>{'pageSectionTitle1'=>new Map<String, String>{'child'=>Label.Parent_Guardian_Contact_Details,
                                                                        'adult'=>Label.Contact_Details},
                                                                            'pageSectionTitle2'=>new Map<String, String>{'child'=>Label.Please_Select_Child,
                                                                                'adult'=>Label.Please_Select_Person},
                                                                                    'firstName'=>new Map<String, String>{'child'=>Label.Child_First_Name,
                                                                                        'adult'=>Label.Adult_First_Name},
                                                                                            'lastName'=>new Map<String, String>{'child'=>Label.Child_Last_Name,
                                                                                                'adult'=>Label.Adult_Last_Name},
                                                                                                    'name'=>new Map<String, String>{'child'=>Label.Child_Name,
                                                                                                        'adult'=>Label.Name}}; 
                                                                                                            
                                                                                                            Map<String, Map<String, String>> bookingSummary = new Map<String, Map<String, String>>{'header'=>new Map<String, String>{'child'=>Label.Application_Details,
                                                                                                                'adult'=>Label.Booking_Summary},
                                                                                                                    'pageSectionTitle1'=>new Map<String, String>{'child'=>Label.Childcare_Booking_Summary,
                                                                                                                        'adult'=>Label.Adult_Booking_Summary},
                                                                                                                            'pageSectionTitle2'=>new Map<String, String>{'child'=>Label.Parent_Guardian_Contact_Details,
                                                                                                                                'adult'=>Label.Adult_Contact_Details},
                                                                                                                                    'cost'=>new Map<String, String>{'child'=>Label.CHILDCARE_COST,
                                                                                                                                        'adult'=>Label.Adult_Cost}}; 
                                                                                                                                            
                                                                                                                                            // Define other label maps similarly...
                                                                                                                                            
                                                                                                                                            CustomLabels labels = new CustomLabels(checkAvailability, selectSession, contactDetails, bookingSummary);
            result = new Response(true, labels, '');
            String jsonResponse = JSON.serialize(labels);
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(jsonResponse);
            
        } catch(Exception e) {
            
            
            result = new Response(false, null, e.getMessage());
        }
        return result;
    }
    
    global static void getAdditionalServicesInfo() {
        RestResponse res = RestContext.response;
        if(res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        AdditionalServicesInfo additionalServiceInfo = new AdditionalServicesInfo();
        
        try {
            additionalServiceInfo.listServices = new List<PicklistOptionWrapper>();
            
            for(Schema.PicklistEntry picklistEntry : Service_Booking__c.SB_Service__c.getDescribe().getPicklistValues()) {
                if(!picklistEntry.getValue().equalsIgnoreCase('Babysitting Request') && !picklistEntry.getValue().equalsIgnoreCase('Babysitting Confirmed')){
                    additionalServiceInfo.listServices.add(new PicklistOptionWrapper(picklistEntry.getLabel(), picklistEntry.getValue()));
                }
            }
            
            additionalServiceInfo.listHours = new List<PicklistOptionWrapper>();
            
            for(Schema.PicklistEntry picklistEntry : Service_Booking__c.SB_Hours__c.getDescribe().getPicklistValues()) {
                additionalServiceInfo.listHours.add(new PicklistOptionWrapper(picklistEntry.getLabel(), picklistEntry.getValue()));
            }
            
            additionalServiceInfo.listCurrencies = new List<PicklistOptionWrapper>();
            
            for(Schema.PicklistEntry picklistEntry : Service_Booking__c.CurrencyIsoCode.getDescribe().getPicklistValues()) {
                additionalServiceInfo.listCurrencies.add(new PicklistOptionWrapper(picklistEntry.getLabel(), picklistEntry.getValue()));
            }
        }
        catch(Exception ex) {
            additionalServiceInfo.isSuccess = false;
            additionalServiceInfo.message = ex.getMessage();
        }
        
        res.responseBody = Blob.valueOf(JSON.serialize(additionalServiceInfo));
        
        
    }
    
    
    global static string getServiceBookingToTimesList() {
        RestResponse res = RestContext.response;
        if(res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        
        ResponseWithRecordsList serviceBookingToTimesResponse = new ResponseWithRecordsList();
        List<PicklistOptionWrapper> serviceBookingToTimesList = getPicklistValues('Service_Booking__c', 'SB_To_Time__c');
        
        if(serviceBookingToTimesList != null) {
            serviceBookingToTimesResponse.isSuccess = true;
            serviceBookingToTimesResponse.recordsList = new List<PicklistOptionWrapper>(serviceBookingToTimesList);
            res.statusCode = 200; // OK
        } else {
            serviceBookingToTimesResponse.isSuccess = false;
            serviceBookingToTimesResponse.message = 'Error While Fetching Service booking From Times  List';
            res.statusCode = 400; // Bad Request
        }
        
        res.responseBody = Blob.valueOf(JSON.serialize(serviceBookingToTimesResponse));
        return JSON.serialize(serviceBookingToTimesResponse);
    }
    
    
    global static string getServiceBookingFromTimesList() {
        RestResponse res = RestContext.response;
        if(res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        
        ResponseWithRecordsList serviceBookingFromTimesResponse = new ResponseWithRecordsList();
        List<PicklistOptionWrapper> serviceBookingFromTimesList = getPicklistValues('Service_Booking__c', 'SB_From_Time__c');
        
        if(serviceBookingFromTimesList != null) {
            serviceBookingFromTimesResponse.isSuccess = true;
            serviceBookingFromTimesResponse.recordsList = new List<PicklistOptionWrapper>(serviceBookingFromTimesList);
            res.statusCode = 200; // OK
        } else {
            serviceBookingFromTimesResponse.isSuccess = false;
            serviceBookingFromTimesResponse.message = 'Error While Fetching Service booking From Times  List';
            res.statusCode = 400; // Bad Request
        }
        
        res.responseBody = Blob.valueOf(JSON.serialize(serviceBookingFromTimesResponse));
        return JSON.serialize(serviceBookingFromTimesResponse);
    }
    global static void getSalutations() {
        RestResponse res = RestContext.response;
        if(res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        
        ResponseWithRecordsList salutationOptionsListResponse = new ResponseWithRecordsList();
        List<PicklistOptionWrapper> salutationOptionsList = getPicklistValues('Account', 'Salutation');
        
        if(salutationOptionsListResponse != null) {
            salutationOptionsListResponse.isSuccess = true;
            salutationOptionsListResponse.recordsList = new List<PicklistOptionWrapper>(salutationOptionsList);
            res.statusCode = 200; // OK
        } else {
           
        }
        
        res.responseBody = Blob.valueOf(JSON.serialize(salutationOptionsListResponse));
    }
     public static String getHotelsList(String pageParametersJSONStr) {
        RestResponse res = RestContext.response;
        if(res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        // Response
        ResponseWithRecordsList hotelsListResponse = new ResponseWithRecordsList();
        
        try {
            PageParametersDTO pageParameters = (PageParametersDTO)JSON.deserialize(pageParametersJSONStr, PageParametersDTO.class);
            // Get user Details
            UsersAvailableInfoDTO userDetails = getUserDetails(pageParameters);
            hotelsListResponse.userInfo = userDetails;
            
            String queryStr = 'SELECT Id, Name, A_Past_Bookings_Search_Days__c, Is_Adult_Hotel__c,(Select Id,Image_URL__c From Header_Logos__r) FROM Account WHERE Display__c = true AND RecordType.Name = \'Hotel\' ';
            
            if(userDetails.isHotelGroupBrandedPage){
                // Hotel Group branded page
                queryStr += 'AND ParentId = \'' + userDetails.hotelId + '\'';
            } else if(userDetails.isHotelBrandedPage){
                // Hotel branded Page
                queryStr += 'AND Id =\'' + userDetails.hotelId + '\''; 
            }
            
            queryStr += ' ORDER By Name ASC';
            
            List<PicklistOptionWrapper> hotelOptionsList = new List<PicklistOptionWrapper>();
            List<PicklistOptionWrapper> hotelPropertiesList = new List<PicklistOptionWrapper>();
            
            Map<String, Hotel_Property__c> hotelProperties = Hotel_Property__c.getAll();
            
            if(hotelProperties != null){
                for(Hotel_Property__c property : hotelProperties.values()){
                    hotelPropertiesList.add(new PicklistOptionWrapper(property.Name, property.Name, property.Hotel_Name__c));
                }
            }
            
            HotelListWrapper hotelOptions = new HotelListWrapper();
            
            try{
                List<Account> hotelsRecordsList = Database.query(queryStr);
                for(Account hotelRecord : hotelsRecordsList){
                     List<Header_Logo__c> headerLogos = hotelRecord.Header_Logos__r;
                    String imageUrl = null; 
    if (!headerLogos.isEmpty()) {
        imageUrl = headerLogos[0].Image_URL__c;
    }
                    
                    List<AggregateResult> results = [
                        SELECT 
                        MIN(StartDate) earliestStartDate, 
                        MAX(EndDate) latestEndDate
                        FROM 
                        Contract
                        WHERE 
                        AccountId = :hotelRecord.Id
                        AND Status = 'Open'
                        GROUP BY 
                        AccountId
                    ];
                    System.debug('results'+results);
                    
                    if(!results.isEmpty()) {
                        Date earliestStartDate = (Date)results[0].get('earliestStartDate');
                        
                        Date latestEndDate = (Date)results[0].get('latestEndDate');
                        
                        PicklistOptionWrapper picklistOption = new PicklistOptionWrapper(
                            hotelRecord.Name, 
                            hotelRecord.Id,
                            hotelRecord.A_Past_Bookings_Search_Days__c,
                            hotelRecord.Is_Adult_Hotel__c,
                            (Date)earliestStartDate,
                            (Date)latestEndDate,
                             imageUrl
                        );
                        
                        hotelOptionsList.add(picklistOption);
                        System.debug('picklistOption'+picklistOption);
                    }
                }
                
                hotelOptions.hotels = hotelOptionsList;
                hotelOptions.hotelProperties = hotelPropertiesList;
                
                hotelsListResponse.isSuccess = true;
                hotelsListResponse.recordsList = new List<HotelListWrapper>{ hotelOptions };
                    } catch(Exception e){
                        hotelsListResponse.isSuccess = false;
                        hotelsListResponse.message = 'Error in fetching Hotel records :: ' + e.getMessage();
                    }
        } catch(Exception e){
            hotelsListResponse.isSuccess = false;
            hotelsListResponse.message = 'Exception while deserializing page parameters : ' + e.getMessage();
        }
        
        
        res.responseBody = Blob.valueOf(JSON.serialize(hotelsListResponse, true));
        return JSON.serialize(hotelsListResponse, true);
        
    }

    
    
 public class PicklistOptionWrapper {
        public String value;
        public String label;
        public String additionalInfo;
        public Boolean isAdultHotel;
        public Date endDate;
        public Date startDate;
        public string imageUrl;
        
        public PicklistOptionWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
        
        public PicklistOptionWrapper(String label, String value, String additionalInfo){
            this.label = label;
            this.value = value;
            this.additionalInfo = additionalInfo;
        }
        
        
        public PicklistOptionWrapper(String label, String value, String additionalInfo, Boolean isAdultHotel, string  imageUrl){
            this.label = label;
            this.value = value;
            this.additionalInfo = additionalInfo;
            this.isAdultHotel = isAdultHotel;
            this.imageUrl = imageUrl;
        }
        public PicklistOptionWrapper(String label, String value, String additionalInfo, Boolean isAdultHotel,Date startDate, Date endDate,string imageUrl ){
            this.label = label;
            this.value = value;
            this.additionalInfo = additionalInfo;
            this.isAdultHotel = isAdultHotel;
            this.endDate = endDate;
            this.startDate = startDate;
            this.imageUrl = imageUrl;
        }
    }

    
    // Define the ResponseWithRecordsList class here
    public class ResponseWithRecordsList extends Response {
        public List<Object> recordsList;
        UsersAvailableInfoDTO userInfo;
        Boolean skipBookingFees;
        String currencyIsoCode;
        Decimal siblingDiscount;
        public Boolean showBabysittingSection;
        public String bookingInfoFromHotel;
        public String paymentType;
        public Decimal bookingFees;
        public Decimal percentageTake;
        public String cmEmail;
        
        
        public ResponseWithRecordsList(){
            recordsList = new List<Object>();
            skipBookingFees = false;
            bookingFees = 0.0;
            paymentType = '';
            percentageTake = 0.0;
        }
    }
    
    private static List<PicklistOptionWrapper> getPicklistValues(String objectName, String fieldName){
        objectName = objectName.toLowerCase();
        fieldName = fieldName.toLowerCase();
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        // Check if picklist values exist
        if (!objFieldMap.containsKey(fieldName)){
            System.debug('FIELD NOT FOUND :: ' + fieldName);
            return null;     
        }
        
        List<Schema.PicklistEntry> picklistEntriesList = objFieldMap.get(fieldName).getDescribe().getPicklistValues();
        
        List<PicklistOptionWrapper> picklistOptionsList = new List<PicklistOptionWrapper>();
        for(Schema.PicklistEntry option : picklistEntriesList){
            PicklistOptionWrapper picklistEntry = new PicklistOptionWrapper(option.getLabel(), option.getValue());
            picklistOptionsList.add(picklistEntry);
        }
        return picklistOptionsList;
    }
    
    private class UsersAvailableInfoDTO{
        String profileName;
        String userName;
        // 0 New 1 edit
        Boolean isEditMode;
        Boolean isAdmin;
        Boolean isSiteLogin;
        // to use in case of Branded booking Page
        String hotelId;
        // to use while updating booking
        String bookingId;
        // to use while geting family
        String familyId;
        // for cookies
        String bookingPageSessionCookie;
        Boolean isHotelGroupBrandedPage;
        Boolean isHotelBrandedPage;
        
        public UsersAvailableInfoDTO(){
            this.isSiteLogin = false;
            this.isEditMode = false;
            this.isHotelGroupBrandedPage = false;
            this.isHotelBrandedPage = false;
        }
    }
    
    // Define the Response class here
    public virtual class Response {
        public Boolean isSuccess;
        public Object Data;
        public String message;
        List<String> messagesList;
        PaymentCreated paymentDetails;
        Public String wwkNo;
        
        public Response(){
            messagesList = new List<String>();
        }
        
        public Response(Boolean isSuccess, Object Data, String message){
            this.isSuccess = isSuccess;
            this.Data = Data;
            this.message = message;
        }
    }
    
    public class PaymentCreated {
        public string id;
        public string create_time;
        public string update_time;
        public string state;
        public string intent;
        public List<Links> links;
    }
    @testvisible
    private static String getParentHoteIdFromEmailDomain(String email){
        // Account Id
        String hotelId;
        if (email != null && email.trim() != '') {
            string domain = email.substring(email.indexOf('@'));
            if (domain != null) {
                List<Account> accounts = [ select id, A_Agent_Email_Group__c 
                                          FROM Account 
                                          WHERE A_Agent_Email_Group__c =: domain];
                if (accounts.size() > 0) {
                    hotelId = accounts[0].id;
                }
            }   
        }
        return hotelId; 
    }
    
    public class Links {
        public string href;  
        public string rel;
        public string method;
    }
    public class PageParametersDTO{
        // to use in case of Branded booking Page
        public String hotelId;
        // to use while updating booking
        public String bookingId;
        // to use while geting family
        public String familyId;
        // for cookies
        public String bookingPageSessionCookie;
    }
    public class HotelListWrapper{
        public List<PicklistOptionWrapper> hotels;
        // Parent Hotel in additioanal property
        public List<PicklistOptionWrapper> hotelProperties;
        
        public HotelListWrapper(){
            hotels = new List<PicklistOptionWrapper>();
            hotelProperties = new List<PicklistOptionWrapper>();
        }
    }
    public class AdditionalServicesInfo extends Response {
        List<PicklistOptionWrapper> listServices;
        List<PicklistOptionWrapper> listHours;
        List<PicklistOptionWrapper> listCurrencies;
    }
    private static UsersAvailableInfoDTO getUserDetails(PageParametersDTO pageParameters){
        UsersAvailableInfoDTO userDetails = new UsersAvailableInfoDTO();
        userDetails.profileName = WWKCSiteSessionHandler.getUserProfileName();
        userDetails.userName = UserInfo.getName();
        // check if hotel group i.e. branded page for hotel group
        if(!String.isBlank(pageParameters.hotelId)){
            String hotelIdRecordType;
            try{
               
                
            } catch(Exception e){
                System.debug('Error fetching hotelId Record Type Name :: ' + e.getMessage());
            }
            
        }
        
        userDetails.isAdmin = isAdminUser();
        
        // check for guest user
        if(userDetails.profileName.equalsIgnoreCase('KMS Updates Profile')) { // 'Guest License User'
            // check for cookies
            
        }
        // Other users
        else{
            // get family Id from page parameters
            userDetails.familyId = pageParameters.familyId;
            // get bookingId from page parameters i.e. Edit mode
            userDetails.bookingId = pageParameters.bookingId;
            // check for Edit Mode
            // if(!String.isEmpty(pageParameters.bookingId)){
            userDetails.isEditMode = true;
            // }
        }
        
        return userDetails;
    }
    private static Boolean isAdminUser() {
        Boolean isAdmin = false;
        
        try {
            Profile currProfile = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
            
            if(currProfile.Name.EqualsIgnoreCase('System Administrator') || currProfile.Name.EqualsIgnoreCase('Hotel User Profile') ) {
                isAdmin = true;
            }
        }
        catch(Exception e){
            System.debug('Error While getting Users Profiles Liscence Id :: ' + e.getMessage());
            return null;
        }
        
        return isAdmin;
    }
    public class FamilyWithChildrens {
        public ResponseWithRecordsList childrenResponse;
        public Account familyDetails;
    }
    
    
    public static Boolean isGuestUser(){
        
            String userProfileId = UserInfo.getProfileId();
            String userProfilesLicenseId = [ Select Id,Name,UserLicenseId FROM Profile where Id =: userProfileId ].UserLicenseId;
            //String guestUsersLicenseId = [ SELECT Id,UserLicenseId,name FROM Profile where name = 'KMS Updates Profile' ].UserLicenseId ;
            String guestUsersLicenseId = [ SELECT Id,UserLicenseId,name FROM Profile where name = 'Minimum Access - API Only Integrations' ].UserLicenseId ;
            System.debug(userProfilesLicenseId + ' ::: ' + guestUsersLicenseId);
            if(userProfilesLicenseId.contains(guestUsersLicenseId)){
                return true;
            }
            return false;
        
        
    }
    @testvisible
    private static List<Date> getDatesListFromDateRange(Date startDate, Date endDate){
        List<Date> datesList = new List<Date>();
        for(Date tempDate = startDate; tempDate<= endDate; tempDate = tempDate.addDays(1)){
            datesList.add(tempDate);
        }
        return datesList;
    }
    public class CustomLabels{
        Map<String, Map<String, String>> checkAvailability;
        Map<String, Map<String, String>> selectSession;
        Map<String, Map<String, String>> contactDetails;
        Map<String, Map<String, String>> bookingSummary;
        public CustomLabels(Map<String, Map<String, String>> checkAvailability, Map<String, Map<String, String>> selectSession, 
                            Map<String, Map<String, String>> contactDetails, Map<String, Map<String, String>> bookingSummary){
                                this.checkAvailability = checkAvailability;
                                this.selectSession = selectSession;
                                this.contactDetails = contactDetails;
                                this.bookingSummary = bookingSummary;
                            }
    }
    public class StripePaymentWrapper{
        public String paymentId;
        public Long CreatedTimeStamp;
        public String PaymentMethod;
        public String PaymentMethodType;
        public String Amount;
        public String TransactionCurrency;
        public String Status;
    }
    public class ResponseWithRecord extends Response{
        Object record;
        String recordId;
    }
    private class ChildKCBookingResonseWrapper extends Response{
        Map<Integer, Child__c> indexChildMap;
        Map<Integer, List<BookingFormDTO.ServiceBookingDTO>> indexServiceBookingDTOsListMap;
        Map<Integer, List<Kids_Clubs_Booking__c>> indexKCBookingsListMap;
    }
    private static String isFamilyWithEmailAlreadyExists(String email) {
        List<Account> listAccount = [SELECT Id FROM Account
                                     WHERE PersonEmail =:email 
                                     AND RecordType.Name = 'Family'
                                     LIMIT 1];
        
        if(!listAccount.isEmpty()) {
            return listAccount.get(0).Id;
        }
        
        return '';
    }
    
    public static String getRecordTypeIdFromName(String objectName, String recordTypeName){
        try{
            return [ SELECT Id FROM RecordType WHERE SobjectType =: objectName AND Name =:recordTypeName LIMIT 1 ][0].Id;
        }
        catch(Exception e){
            System.debug('Error while getting Record Type Id for ' + recordTypeName + ' Record Type :: ' + e.getMessage());
            return null;
        }
    }
    private static Opportunity getBookingRecordFromBookingDTO(BookingFormDTO bookingDTO){
        ResponseWithRecord getBookingRecordFromBookingDTOResponse = new ResponseWithRecord();
        Opportunity bookingRecord = new Opportunity();
        if(!String.isEmpty(bookingDTO.selectedHotelId) && !String.isEmpty(bookingDTO.familyDetails.id)){
            // check if Agent booking
            if(bookingDTO.isAgentBooking != null && bookingDTO.isAgentBooking){
                bookingRecord.O_Booking_Type__c = 'Agent Booking';
                // Contact Lookup (Agent)
                bookingRecord.O_Contact__c = bookingDTO.agentDetails.Id;
            }
            else{
                bookingRecord.O_Booking_Type__c = 'Client Direct';
            }
            
            try{
                
                //tayib: 11 march - 1:40pm line 6111 to 6115 replaced with line: 6100 to 6109
                // check in date - add null validation to prevent NullPointerException
                if(bookingDTO.checkInDateDTO != null && bookingDTO.checkInDateDTO.year != null && bookingDTO.checkInDateDTO.month != null && bookingDTO.checkInDateDTO.day != null){
                bookingRecord.Start_Date__c = Date.newInstance(bookingDTO.checkInDateDTO.year, bookingDTO.checkInDateDTO.month, bookingDTO.checkInDateDTO.day);
                    bookingRecord.Start_Date__c = Date.newInstance(Integer.valueOf(bookingDTO.checkInDateDTO.year), Integer.valueOf(bookingDTO.checkInDateDTO.month), Integer.valueOf(bookingDTO.checkInDateDTO.day));
                // check out date
                }
                // check out date - add null validation to prevent NullPointerException
                if(bookingDTO.checkOutDateDTO != null && bookingDTO.checkOutDateDTO.year != null && bookingDTO.checkOutDateDTO.month != null && bookingDTO.checkOutDateDTO.day != null){
                bookingRecord.End_Date__c = Date.newInstance(bookingDTO.checkOutDateDTO.year, bookingDTO.checkOutDateDTO.month, bookingDTO.checkOutDateDTO.day);
                    bookingRecord.End_Date__c = Date.newInstance(Integer.valueOf(bookingDTO.checkOutDateDTO.year), Integer.valueOf(bookingDTO.checkOutDateDTO.month), Integer.valueOf(bookingDTO.checkOutDateDTO.day));
                }

                // // check in date
                // bookingRecord.Start_Date__c = Date.newInstance(bookingDTO.checkInDateDTO.year, bookingDTO.checkInDateDTO.month, bookingDTO.checkInDateDTO.day);
                // // check out date
                // bookingRecord.End_Date__c = Date.newInstance(bookingDTO.checkOutDateDTO.year, bookingDTO.checkOutDateDTO.month, bookingDTO.checkOutDateDTO.day);
                bookingRecord.Name = 'WWKC_Test'; 
                bookingRecord.CloseDate = Date.today();
                bookingRecord.Hotel__c = bookingDTO.selectedHotelId;
                bookingRecord.Hotel_Property__c = bookingDTO.hotelProperty;
                
                
                
                bookingRecord.AccountID = bookingDTO.familyDetails.id;
                bookingRecord.StageName = 'Confirmed';
                if(bookingDTO.promoCode != null){
                    bookingRecord.Promotion_Code__c = bookingDTO.promoCode.code;
                    bookingRecord.Promo_Code_discount__c = bookingDTO.promoCode.discount;
                }
                
                System.debug('bookingRecord');
                
                bookingRecord.Sibling_Discount__c = bookingDTO.siblingDiscount;
                getBookingRecordFromBookingDTOResponse.isSuccess = true;
                getBookingRecordFromBookingDTOResponse.record = bookingRecord;
            }
            catch(Exception e){
                System.debug('Error while creating Opportunity Record : ' + e.getMessage() + ' Line : ' + e.getLineNumber());
                getBookingRecordFromBookingDTOResponse.isSuccess = false;
                getBookingRecordFromBookingDTOResponse.message = 'Invalid booking data in Booking DTO';
            }
        }
        else{
            System.debug('Hotel Id or Family Id missing in booking DTO');
        }
        return bookingRecord;
    }
    private static ChildKCBookingResonseWrapper getChildsWithKCAndServiceBookings(BookingFormDTO bookingDTORecord){
        // DTO for response
        ChildKCBookingResonseWrapper childKCBookingResponse = new ChildKCBookingResonseWrapper();
        
        childKCBookingResponse.isSuccess = true;
        
        Map<Integer, Child__c> indexChildMap = new Map<Integer, Child__c>(); 
        Map<Integer, List<Kids_Clubs_Booking__c>> indexKCBookingsListMap = new Map<Integer, List<Kids_Clubs_Booking__c>>();
        Map<Integer, List<BookingFormDTO.ServiceBookingDTO>> indexServiceBookingDTOsListMap = new Map<Integer, List<BookingFormDTO.ServiceBookingDTO>>();
        
        
        Integer childsCount = bookingDTORecord.childsList.size();
        List<Child__c> existingChildRecordsForFamilyList = new List<Child__c>();
        
        if(childsCount > 0){
            // get existing childs for a family in database
            if(String.isNotBlank(bookingDTORecord.familyDetails.id)){
                existingChildRecordsForFamilyList = [ SELECT Id, First_Name__c, Last_Name__c, DOB__C 
                                                     FROM Child__c
                                                     WHERE Parent__c =: bookingDTORecord.familyDetails.id];
            }
            // for each child DTO record create child record
            for(Integer index = 0;  index < childsCount; index++){
                BookingFormDTO.ChildDTO childDTORecord = new BookingFormDTO.ChildDTO();                     // create new child DTO record
                // for each child
                childDTORecord = bookingDTORecord.childsList[index];                                
                
                Child__c childRecord = new Child__c();                                             // create new child record
                
                // check if child DTO record have id
                if(String.isNotBlank(childDTORecord.id)){
                    childRecord.Id = childDTORecord.id;
                }
                else{
                    // get id of child if exist in database
                    String childRecordId = getChildIdFromChildsList(existingChildRecordsForFamilyList, childDTORecord);
                    // check if same child is already in list
                    if(String.isNotBlank(childRecordId)){
                        // assign id to child record
                        childRecord.Id = childRecordId;
                    }
                }
                
                // assign values from childDTO to Child
                childRecord.Parent__c = bookingDTORecord.familyDetails.Id;
                
                
                
                // check if first name is not valid
                if(!String.isEmpty(childDTORecord.firstName)){
                    childRecord.First_Name__c = childDTORecord.firstName;
                }
                else{
                    childKCBookingResponse.isSuccess = false;
                    childKCBookingResponse.messagesList.add('FirstName of Child should not be empty for child : ' + 
                                                            childDTORecord.firstName + ' ' + childDTORecord.lastName);
                }
                // check if last name is not valid
                if(!String.isEmpty(childDTORecord.lastName)){
                    childRecord.Last_Name__c = childDTORecord.lastName;
                }
                else{
                    childKCBookingResponse.isSuccess = false;
                    childKCBookingResponse.messagesList.add('LastName of Child should not be empty for child : ' + 
                                                            childDTORecord.firstName + ' ' + childDTORecord.lastName);
                }
                // check if birth date is not valid
                try{
                    childRecord.DOB__C = Date.newInstance(childDTORecord.dobDTO.year, childDTORecord.dobDTO.month, childDTORecord.dobDTO.day);
                } catch(Exception e){
                    System.debug('Invalid Date of birth for child : ' + childDTORecord.firstName + ' ' + childDTORecord.lastName);
                    childKCBookingResponse.isSuccess = false;
                    childKCBookingResponse.messagesList.add('Invalid Date of birth for child : ' + childDTORecord.firstName + ' ' + childDTORecord.lastName);
                }

                // Map medical and allergy fields from DTO to Child record (direct assignment)
                childRecord.doesChildTakeAnySortOfMedication__c = childDTORecord.doesChildTakeAnySortOfMedication;
                 childRecord.Signs_Symptoms__c = childDTORecord.signsSymptoms;
                 childRecord.DetailChildAllergies__c = childDTORecord.allergen;
                    childRecord.DetailChildAdditionalNeeds__c = childDTORecord.additionalNeedsReason;
                    childRecord.C_DetailChildMedication__c = childDTORecord.medicalConditionDetails;
                    childRecord.Treatment__c = childDTORecord.treatment;
                    childRecord.Time_to_be_administered__c = childDTORecord.medicationTime;
                    childRecord.Medication_Required__c  = childDTORecord.medicationRequired ;
                    childRecord.Dose__c = childDTORecord.medicationDose;
                    childRecord.How_can_the_team_support_your_child__c = childDTORecord.additionalNeedsSupport;
                childRecord.DoesChildHaveAllergies__c = childDTORecord.doesChildHaveAllergies;
                childRecord.DoesChildHaveMedicalOrAdditionalNeeds__c = childDTORecord.doesChildHaveMedicalOrAdditionalNeeds;
                childRecord.childParticipateInClubActivities__c = childDTORecord.childParticipateInClubActivities;
                childRecord.ChildRequireSwimmingAid__c = childDTORecord.childRequireSwimmingAid;
                
                                
                // Map the guardian names, collection password, and photo permission fields
                childRecord.childCollectPersonName__c = childDTORecord.guardianNames;
                childRecord.childCollectPersonPassword__c = childDTORecord.collectionPassword;
                childRecord.agreeForPhotographAndFilmingForPublicity__c = childDTORecord.photoPermission;
                
                
                // List to store all KC bookings on a child
                List<Kids_Clubs_Booking__c> kcBookingsList = new List<Kids_Clubs_Booking__c>();
                
                // for each booking on child create kids club booking 
                for(BookingFormDTO.KCBookingDTO kcBookingDTORecord : childDTORecord.kidsClubBookings){
                    
                    
                    Kids_Clubs_Booking__c kcBookingRecord = new Kids_Clubs_Booking__c();
                    try{
                        kcBookingRecord.Club_Date__c = Date.newInstance(kcBookingDTORecord.bookingDateDTO.year, kcBookingDTORecord.bookingDateDTO.month, 
                                                                        kcBookingDTORecord.bookingDateDTO.day);
                    } catch(Exception e){
                        childKCBookingResponse.isSuccess = false;
                        childKCBookingResponse.messagesList.add('Invalid booking date for child : ' + childDTORecord.firstName + ' ' + childDTORecord.lastName);
                    }
                    // assign Kids club id (parent booking (opportunity))
                    if(!String.isEmpty(bookingDTORecord.id)){
                        kcBookingRecord.Booking__c = bookingDTORecord.id;
                    }
                    else{
                        childKCBookingResponse.isSuccess = false;
                        childKCBookingResponse.messagesList.add('Parent Booking can\'t be null : ' + childDTORecord.firstName + ' ' + childDTORecord.lastName);
                    }
                    
                    if(String.isNotBlank(kcBookingDTORecord.id)) {
                        kcBookingRecord.Id = kcBookingDTORecord.id;
                    }
                    
                    
                    kcBookingRecord.Child__c = childDTORecord.id;
                    kcBookingRecord.Discount_Amount__c = kcBookingDTORecord.discount;
                    
                    // assign kids club id for KC booking
                    if(!String.isEmpty(kcBookingDTORecord.kidsClubId)){
                        kcBookingRecord.Kids_Club__c = kcBookingDTORecord.kidsClubId;
                    }
                    else{
                        childKCBookingResponse.isSuccess = false;
                        childKCBookingResponse.messagesList.add('Kids club Id can not be null for KC booking ' + childDTORecord.firstName + ' ' + childDTORecord.lastName);
                    }
                    if(!String.isEmpty(kcBookingDTORecord.bookingStatus)){
                        kcBookingRecord.Status__c = kcBookingDTORecord.bookingStatus;
                    }
                    else{
                        childKCBookingResponse.isSuccess = false;
                        childKCBookingResponse.messagesList.add('Invalid Bookin Status for ' + childDTORecord.firstName + ' ' + childDTORecord.lastName);
                    }
                    kcBookingsList.add(kcBookingRecord);
                }
                
                
                indexChildMap.put(index, childRecord);
                indexKCBookingsListMap.put(index, kcBookingsList);
                indexServiceBookingDTOsListMap.put(index, childDTORecord.serviceBookingsList);
                System.debug('Service Bookings List : ' + JSON.serialize(childDTORecord.serviceBookingsList));
            }
            childKCBookingResponse.indexChildMap = indexChildMap;
            childKCBookingResponse.indexKCBookingsListMap = indexKCBookingsListMap;
            childKCBookingResponse.indexServiceBookingDTOsListMap = indexServiceBookingDTOsListMap;
        }
        else{
            childKCBookingResponse.isSuccess = false;
            childKCBookingResponse.messagesList.add('No child Records Provided');
        }
        return childKCBookingResponse;
    }
    private static String getGuestUserId(){
        return [ SELECT Id FROM User WHERE Name = 'KMS New Site Guest User'].Id;
    }
    @testvisible
    private static void handleAdditionalServiceBookings(String Name,List<BookingFormDTO.ServiceBookingDTO> serviceBookingDTORecordsList, String bookingId) {
        Set<Date> dateList = new Set<Date>();
        If(bookingId!=null || bookingId!=''){
            List<Service_Booking__c> previousBabySitting = [SELECT Id, SB_Bookings__c,SB_From_Time__c,SB_To_Time__c,SB_Date__c,Status__c FROM Service_Booking__c WHERE SB_Bookings__c=:bookingId];
             List <Service_Booking__c> listToCancelAll = new List<Service_Booking__c>();
             if(serviceBookingDTORecordsList.size()==0){
                    for(Service_Booking__c record:previousBabySitting){
                        record.Status__c = 'Cancelled';
                            listToCancelAll.add(record);
                    }
                    upsert listToCancelAll;
                }
        }
        if(serviceBookingDTORecordsList.size() > 0) {
            List<Service_Booking__c> listServiceBookingsToInsert = new List<Service_Booking__c>();
            List<Service_Booking__c> listServiceBookingsToDelete = new List<Service_Booking__c>();
             List<Service_Booking__c> listToInsert = new List<Service_Booking__c>();
           
            
           Set<String> uniqueBookings = new Set<String>();
            If(bookingId!=null || bookingId!=''){
            List<Service_Booking__c> previousBabySitting = [SELECT Id, SB_Bookings__c,SB_From_Time__c,SB_To_Time__c,SB_Date__c,Status__c FROM Service_Booking__c WHERE SB_Bookings__c=:bookingId];
               
                


Map<Date, Service_Booking__c> previousBookingMap = new Map<Date, Service_Booking__c>();
for (Service_Booking__c booking : previousBabySitting) {
    previousBookingMap.put(booking.SB_Date__c, booking);
}
                Map<Date, BookingFormDTO.ServiceBookingDTO> serviceDTOMap = new Map<Date, BookingFormDTO.ServiceBookingDTO>();
for (BookingFormDTO.ServiceBookingDTO booking : serviceBookingDTORecordsList) {
    Date recDate = Date.newInstance(
            booking.selectedDateDTO.year, 
            booking.selectedDateDTO.month, 
            booking.selectedDateDTO.day
        );
    serviceDTOMap.put(recDate, booking);
}


for (BookingFormDTO.ServiceBookingDTO editedBooking : serviceBookingDTORecordsList) {
    Date editedDate = Date.newInstance(
            editedBooking.selectedDateDTO.year, 
            editedBooking.selectedDateDTO.month, 
            editedBooking.selectedDateDTO.day
        );
    
    if (previousBookingMap.containsKey(editedDate)) {
        dateList.add(editedDate);
        
        Service_Booking__c previousBooking = previousBookingMap.get(editedDate);
        previousBooking.SB_From_Time__c = editedBooking.fromTime;
        previousBooking.SB_To_Time__c = editedBooking.toTime;
        previousBooking.Children__c = Name;
        if(previousBooking.Status__c=='Cancelled'){
            previousBooking.Status__c = 'Requested';
        }
        
    }
}
                
                for (Service_Booking__c cancelledBooking : previousBabySitting) {
                    if(serviceDTOMap.containsKey(cancelledBooking.SB_Date__c)){
                        continue;
                    }
                    else{
                        cancelledBooking.Status__c = 'Cancelled';
                        listToInsert.add(cancelledBooking);
                    }
                }
                
                

                if(previousBabySitting.size()>0){
upsert previousBabySitting;
                }
                if(listToInsert.size()>0){
                    upsert listToInsert;
                }
                
            }

            


for (BookingFormDTO.ServiceBookingDTO serviceBookingDTORecord : serviceBookingDTORecordsList) {
    System.debug('serviceBookingDTORecord: ' + serviceBookingDTORecord);
    Date recordDate = Date.newInstance(
            serviceBookingDTORecord.selectedDateDTO.year, 
            serviceBookingDTORecord.selectedDateDTO.month, 
            serviceBookingDTORecord.selectedDateDTO.day
        );
    if(dateList.contains(recordDate)){
        continue;
    }
    else{
    
    
    
    // Create a unique key using fromTime, toTime, and selectedDateDTO
    String uniqueKey = serviceBookingDTORecord.fromTime + '-' + 
                       serviceBookingDTORecord.toTime + '-' + 
                       serviceBookingDTORecord.selectedDateDTO.year + '-' + 
                       serviceBookingDTORecord.selectedDateDTO.month + '-' + 
                       serviceBookingDTORecord.selectedDateDTO.day;
    
    // Check if the uniqueKey is already in the set
    if (!uniqueBookings.contains(uniqueKey)) {
        uniqueBookings.add(uniqueKey);
        
        Service_Booking__c serviceBooking = new Service_Booking__c();
        serviceBooking.SB_Bookings__c = serviceBookingDTORecord.bookingId;
        //START:Tayib - 12 march 2026 12:30 - Uncommented to fix child association for service bookings
        //serviceBooking.SB_Child__c = serviceBookingDTORecord.childId;
        serviceBooking.SB_Child__c = serviceBookingDTORecord.childId;
        //END:Tayib
        serviceBooking.SB_Cost__c = serviceBookingDTORecord.cost;
        serviceBooking.Children__c = Name;
        serviceBooking.SB_Date__c = Date.newInstance(
            serviceBookingDTORecord.selectedDateDTO.year, 
            serviceBookingDTORecord.selectedDateDTO.month, 
            serviceBookingDTORecord.selectedDateDTO.day
        );
        serviceBooking.SB_Hotel__c = serviceBookingDTORecord.selectedHotelId;
        serviceBooking.SB_Hours__c = serviceBookingDTORecord.selectedHour;
        serviceBooking.SB_Service__c = serviceBookingDTORecord.selectedService;
        serviceBooking.SB_From_Time__c = serviceBookingDTORecord.fromTime;
        serviceBooking.SB_To_Time__c = serviceBookingDTORecord.toTime;
        serviceBooking.SB_Service__c = 'Babysitting Request';
        
        listServiceBookingsToInsert.add(serviceBooking);
    }
}
}

            
            // insert service booking records
            if(listServiceBookingsToInsert.size() > 0) {
                try{
                    upsert listServiceBookingsToInsert;
                }catch(Exception e){
                    System.debug('Error while saving service Booking Records ' + e.getLineNumber() + ' ' + e.getMessage());
                }
            }
            
            // Delete service booking records
            if(listServiceBookingsToDelete.size() > 0) {
               
                    delete listServiceBookingsToDelete;
                
            }
        }
    }
    @TestVisible
    private static String getChildIdFromChildsList(List<Child__c> childRecordsList, BookingFormDTO.ChildDTO childDTORecord){
        for(Child__c childRecord : childRecordsList){
            // check if first Name is Same
            if(childRecord.First_Name__c == childDTORecord.firstName){
                // check if lastname is same
                if(childRecord.Last_Name__c == childDTORecord.lastName){
                    // check if date of birth is same
                    if(childRecord.DOB__c == Date.newInstance(childDTORecord.dobDTO.year, childDTORecord.dobDTO.month,
                                                             childDTORecord.dobDTO.day)){
                                                                 return childRecord.id;
                                                             }
                }
            }
        }
        return null;
    }
    public Double intInternetFees {
        get {
            return 2.50;
        }        
        set;
    }
    
    public String headerId {
        get {
            if(String.isBlank(headerId) && hotel != null) {
                for(Attachment currAttach : hotel.Attachments) {
                    if(currAttach.Name.contains('Header')) {
                        headerId = currAttach.Id;
                    }
                }
            }
            
            return headerId;
        }
        
        set;
    }
    
    public String footerId {
        get {
            if(String.isBlank(headerId) && hotel != null) {
                for(Attachment currAttach : hotel.Attachments) {
                    if(currAttach.Name.contains('Footer')) {
                        footerId = currAttach.Id;
                    }
                }
            }
            
            return footerId;
        }
        
        set;
    } 
    
    public Account hotel {
        get {
            if(hotel == null && !String.isBlank(hotelId)) {
                hotel = [SELECT Id, Name, A_Header_Link__c, A_Footer_Link__c,
                         Has_Corona_Message__c, Has_Availability_Message__c, Availability_Message__c,
                         (SELECT Id, Name FROM Attachments WHERE Name LIKE '%header%' OR Name LIKE '%footer%')
                         FROM Account
                         WHERE Id =: hotelId
                         ORDER By Name ASC];
                
                System.debug('hotel attachments : ' + [SELECT Id, Name
                                                       FROM Attachment
                                                       WHERE (Name LIKE '%header%' OR Name LIKE '%footer%')
                                                       AND ParentId = :hotelId]);
            }
            return hotel;
        }
        
        set;
    }
    
    public String bookingId {
        get {
            if(String.isBlank(bookingId)) {
                bookingId = ApexPages.currentPage().getParameters().get('Id');
            }
            
            return bookingId;
        }
        
        set;
    }
    
    public String familyId {
        get {
            if(String.isBlank(familyId)) {
                familyId = ApexPages.currentPage().getParameters().get('accId');
            }
            
            return familyId;
        }
        
        set;
    }
    
    
    
    
    public String stripePublicKey{
        get{
            StripeConfig config = new StripeConfig('active_creds');
            return config.PublishableKey;
        }
        set;
    }
    
    public String bookingPageSessionCookie {
        get {
            if(String.isBlank(bookingPageSessionCookie)) {
                Cookie cookieRec = ApexPages.currentPage().getCookies().get('site_session'); //
                
                if(cookieRec != null){
                    // if(cookieRec.getMaxAge() > 0){
                    bookingPageSessionCookie = cookieRec.getValue();
                    // }
                }
            }
            
            return bookingPageSessionCookie;
        }
        
        set;
    }
    
    
    
    
    
    
}