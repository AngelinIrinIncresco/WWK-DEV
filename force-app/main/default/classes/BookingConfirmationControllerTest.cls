/*
 * @purpose : To test BookingConfirmationController which sends confirmation email and creates a related task.
*/
@isTest
public class BookingConfirmationControllerTest {

    @testsetup//@isTest 
    public static void createData() {
        String recordTypeId  = Schema.getGlobalDescribe()
                                     .get('Account')
                                     .getDescribe()
                                     .getRecordTypeInfosByName()
                                     .get('Person Account')
                                     .getRecordTypeId();
        
        Account family = new Account(FirstName='Test FName',
                                     LastName='Test LName',
                                     RecordTypeId = recordTypeId,
                                     A_RM_s_Email__c = 'enquiries@worldwidekidscompany.com');
        insert family;
        
        insert new Opportunity( Name = 'Product2',
                                CloseDate = System.today(),
                                StageName = 'Closed',
                                AccountId = family.Id,
                                Hotel__c = family.Id); 
        
       
    }
    
    @isTest
    public static void testBookingConfirmation() {
        PageReference pageRef = Page.WWKC_Booking_Confirmation_New;
        Test.setCurrentPage(pageRef);
        
        //When opportunity id is blank
        Opportunity testBooking1 = new Opportunity();
        sendBookingConfirmation(testBooking1);
        
        //If opportunity with provided id does not exist in org
        Opportunity testBooking2 = new Opportunity(Id = '0064B0000035Dfw');
        sendBookingConfirmation(testBooking2);
        
        //If opportunity with provided id is found
        Opportunity testBooking3 = [SELECT Id, AccountId FROM Opportunity];
        sendBookingConfirmation(testBooking3);
        
        Account family = [SELECT Id, PersonEmail, A_Password__c 
                          FROM Account 
                          WHERE Id = :testBooking3.AccountId];
        
        //If family is having person email
        family.PersonEmail = 'abc@test.com';
        update family;
        sendBookingConfirmation(testBooking3);
        
        //If family is having password
        family.A_Password__c = 'password';
        update family;
        sendBookingConfirmation(testBooking3);
        
        //When Email_Template_Translation__c is found
        Email_Template__c emailTemplate = new Email_Template__c(Email_Template_Object__c = 'Opportunity');
        insert emailTemplate;
        
        Email_Template_Translation__c emailTemplateTranslation;
        emailTemplateTranslation = new Email_Template_Translation__c(Name = 'Booking Confirmation New',
                                                                     Email_Template__c = emailTemplate.Id);
        insert emailTemplateTranslation;
        sendBookingConfirmation(testBooking3);
        
        emailTemplateTranslation.Body__c = 'Test Body';
        update emailTemplateTranslation;
        sendBookingConfirmation(testBooking3);
        
    }

    @isTest
    public static void testBookingConfirmationHelperEdgeCases() {
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Id = :opp.AccountId];
        acc.PersonEmail = 'test@example.com';
        acc.A_Password__c = 'password123';
        update acc;

        Test.startTest();
        // 1. Guard check: Existing booking edit from guest/booking engine should be skipped
        String skipResponse = BookingConfirmationHelper.sendEmail(opp.Id, false, true);
        System.assert(skipResponse.contains('Email skipped'), 'Should skip email on edit');

        // 2. Initial creation: Should proceed to send
        String sendResponse = BookingConfirmationHelper.sendEmail(opp.Id, true, true);

        // 3. Manual admin resend: Should proceed even if isFirstTime is false
        String adminResponse = BookingConfirmationHelper.sendEmail(opp.Id, false, false);

        // 4. Missing / null ID check
        String nullResponse = BookingConfirmationHelper.sendEmail(null, true, true);
        System.assertEquals('Booking Id is corrupted.', nullResponse);

        // 5. Corrupted ID check
        String corruptResponse = BookingConfirmationHelper.sendEmail('invalidId123', true, true);
        Test.stopTest();
    }
    
    private static void sendBookingConfirmation(Opportunity booking) {
        ApexPages.currentPage().getParameters().put('id',booking.id);
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(booking);
        BookingConfirmationController bookingConfirmationCtrl = new BookingConfirmationController(stdCtrl); 
        bookingConfirmationCtrl.sendConfrmationMail();
        bookingConfirmationCtrl.cancel();
    }
}