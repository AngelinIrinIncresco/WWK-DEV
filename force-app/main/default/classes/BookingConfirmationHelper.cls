/**
*@Author: Dreamwares
*
*@Updates
* 16/06/16 Last modified by Dreamwares? 
* 30/06/17 CM adding condition to only show password details when Has_user_changed_password__c is False
*/


public class BookingConfirmationHelper {
    
    public static String sendEmail(String opportunityId, Boolean isFirstTime, Boolean isGuestUser) { 
        system.debug('opportunityId::'+opportunityId);

        // Fast-exit: Do not send confirmation email when an existing booking is edited via booking engine
        if (isFirstTime != null && !isFirstTime && isGuestUser) {
            System.debug('Confirmation email skipped: existing booking edit. OpportunityId: ' + opportunityId);
            return 'Email skipped: Booking edit does not require guest notification.';
        }

        String response;
        try {
            
            SiteUrl__c siteurl = SiteUrl__c.getInstance();
            if(String.isNotBlank(opportunityId)) {
                List<Opportunity> bookingRecord = [SELECT Id, Name, Childcare_Manager_Email__c, Auto_Booking_Ref__c,Account.Name, Account.PersonEmail, Hotel__r.Name, Account.Password__c, Account.A_Password__c, Account.Has_user_changed_password__c, O_Booking_Type__c, O_Contact__r.Email, CreatedDate 
                                                    FROM Opportunity 
                                                    WHERE Id = :opportunityId
                                                    LIMIT 1];
                
                if(bookingRecord.size() > 0) {
                    System.debug('bookingRecord.get(0).Id::' + bookingRecord.get(0).Id);

                    // Secondary fail-safe: Check database record. If the Opportunity was created in the past, it is an existing booking edit.
                    Boolean isPreExistingBooking = bookingRecord.get(0).CreatedDate != null 
                        && bookingRecord.get(0).CreatedDate < Datetime.now().addMinutes(-1);
                    if (isPreExistingBooking && isGuestUser) {
                        System.debug('Confirmation email skipped: pre-existing booking record created ' + bookingRecord.get(0).CreatedDate + '. OpportunityId: ' + opportunityId);
                        return 'Email skipped: Booking edit does not require guest notification.';
                    }
                    if(String.isNotBlank(bookingRecord.get(0).Account.PersonEmail)) {
                        if(String.isNotBlank(bookingRecord.get(0).Account.A_Password__c)) {
                            String subject = 'Your Childcare Booking ' + bookingRecord.get(0).Auto_Booking_Ref__c;
                        String body = 'Dear ' + bookingRecord.get(0).Account.Name + ',<br/><br/>' +
    'Thank you for your childcare booking at ' + bookingRecord.get(0).Hotel__r.Name + '. Your booking number is ' + bookingRecord.get(0).Auto_Booking_Ref__c + '.<br/><br/>' +
    'Please visit <a href="https://wwkc.my.salesforce-sites.com/KMSNew/wwkc_LoginPage#' + bookingRecord.get(0).Id + '" target="_blank">MyWK Guest</a> to view your confirmation and manage your booking. For security, you are advised to change your temporary password upon your first login.<br/><br/>';

// Add username and password if the user has not changed the password
if (!bookingRecord.get(0).Account.Has_user_changed_password__c) {
    body += 'Username: ' + bookingRecord.get(0).Account.PersonEmail + '<br/>' +
            'Temporary Password: ' + bookingRecord.get(0).Account.A_Password__c + '<br/><br/>';
}

body += '<b>Next Steps:</b><br/><br/>' +
    '<ul>' +
        '<li><b>Waiting List:</b><br/>If you have any sessions on a waiting list, we will inform you by email when the session becomes available and we have allocated the session to you. You can always check the status by <a href="https://wwkc.my.salesforce-sites.com/KMSNew/wwkc_LoginPage#' + bookingRecord.get(0).Id + '" target="_blank">logging in to MyWK Guest</a>.' +
        '<br/>If you remain on the waiting list, please be advised we have a 15-minute policy: if a pre-booked child has not arrived or called within the 15 minutes bracket, the position becomes available first come first serve.</li>' +
        '<br/>' +
        '<br/><li><b>Changes and Cancellations:</b><br/>To adjust or cancel sessions, <a href="https://wwkc.my.salesforce-sites.com/KMSNew/wwkc_LoginPage#' + bookingRecord.get(0).Id + '" target="_blank">log in to MyWK Guest</a>. Cancellations are free up to 24 hours before the session begins.' +
        '<br/>When in resort, if your schedule changes, please cancel any sessions or let the Childcare Manager know, as this helps sessions become available for other guests.</li>' +
    '</ul><br/>' +
    'Need Assistance? For further inquiries, contact our Childcare Manager at ' + bookingRecord.get(0).Childcare_Manager_Email__c + ', quoting your name and reference number '+ bookingRecord.get(0).Auto_Booking_Ref__c +'.<br/><br/>' +
    'We look forward to welcoming your family soon.<br/><br/>' +
    'Kind regards,<br/>' +
    bookingRecord.get(0).Hotel__r.Name + ' Childcare Manager';

Messaging.SingleEmailMessage confirmationMail = new Messaging.SingleEmailMessage();
confirmationMail.setSubject(subject);
confirmationMail.setHtmlBody(body);


                                List<String> toAddressesList = new List<String>();
                                toAddressesList.add(bookingRecord.get(0).Account.PersonEmail);
                                confirmationMail.setToAddresses(toAddressesList);
                                
                                if(!isGuestUser) {
                                    Messaging.EmailFileAttachment PDFEmailAttachment = new Messaging.EmailFileAttachment();
                                    PDFEmailAttachment.setFileName(bookingRecord.get(0).Auto_Booking_Ref__c + ' - Booking Confirmation.pdf');
                                    
                                    if(!Test.isRunningTest()) {
                                        PageReference pdf = Page.WWKC_Booking_PDF_BookingForm;
                                        pdf.getParameters().put('id', bookingRecord.get(0).Id);
                                        pdf.setRedirect(true);
                                        Blob pdfContent = pdf.getContentAsPDF();                                        
                                        PDFEmailAttachment.setBody(pdfContent);
                                        confirmationMail.setFileAttachments(new Messaging.EmailFileAttachment[] {PDFEmailAttachment});
                                    } else {
                                        PDFEmailAttachment.setBody(Blob.valueof('myString'));
                                    }
                                } else {
                                    if(bookingRecord.get(0).O_Booking_Type__c == 'Agent Booking') {
                                        toAddressesList.add(bookingRecord.get(0).O_Contact__r.Email);
                                    }
                                }
                                
                                if(String.isNotBlank(bookingRecord.get(0).Childcare_Manager_Email__c)) {
                                    List<OrgWideEmailAddress> listChildCareManagerAddress = [SELECT Id, Address, DisplayName 
                                                                                                  FROM OrgWideEmailAddress 
                                                                                                  WHERE Address = :bookingRecord.get(0).Childcare_Manager_Email__c];
                                    if(listChildCareManagerAddress.size() > 0) {                                            
                                        confirmationMail.setOrgWideEmailAddressId(listChildCareManagerAddress.get(0).Id);      
                                    }
                                }
                                
                                Messaging.sendEmail(new Messaging.Singleemailmessage[] {confirmationMail});  
                                response = 'Confirmation Message sent Successfully!';
                                
                                return response;   
                        } else {
                            response = 'You have not set Password for this account.';
                            return response;   
                        }
                    } else {
                        response = 'Email Id is not present for Family record. We cannot send an email to the Family.';
                        return response;   
                    }
                } else {
                    response = 'Booking Id is missing.';
                    return response;               
                }
            } else {
                response = 'Booking Id is corrupted.';
                return response;      
            }
        } catch (Exception ex) {
            System.debug('Exception in sending mail:' + ex.getMessage() + ' @ line number: ' + ex.getLineNumber());
            response = ex.getMessage();
        }
        return response;   
    }
}