import { LightningElement, api, track, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createInventoryProducts from '@salesforce/apex/InventorySetupController.createInventoryProducts';
import createHotelClubRecord from '@salesforce/apex/InventorySetupController.createHotelClubRecord';
import createDiscountRecords from '@salesforce/apex/InventorySetupController.createDiscountRecords';
 import deleteHotelClubRecord from '@salesforce/apex/InventorySetupController.deleteHotelClubRecord';
 import checkPartner from '@salesforce/apex/InventorySetupController.checkPartner';
import updateCheckbox from '@salesforce/apex/InventorySetupController.updateCheckbox';
import {loadStyle} from 'lightning/platformResourceLoader'; 
import override from '@salesforce/resourceUrl/override';
import {
    getObjectInfo
} from 'lightning/uiObjectInfoApi';
import {
    getPicklistValues
} from 'lightning/uiObjectInfoApi';
import KCObject from '@salesforce/schema/Inventory_Product__c';
import statfield from '@salesforce/schema/Inventory_Product__c.Club_Type__c';
import ageRangeField from '@salesforce/schema/Inventory_Product__c.Age_Range__c';
import openingHoursField from '@salesforce/schema/Inventory_Product__c.Opening_Hours__c';
export default class inventorySetup extends LightningElement {
    @api recordId;
    @track isLoading = true;
    @track ageStaffRecords= [];
    @track sessionRecords = [];
    @track discountRecords = [];
    wiredRecords;
    error;
    @track selectedOptions = [];

    @track options = [
        
    ];
    @track typeOptions = [
        { label: 'Vertical', value: 'Vertical' },
        { label: 'Horizontal', value: 'Horizontal' }
    ];
    @track deleteConatctIds = '';
    @track startDate;
    @track endDate;
    @track clubName;
    @track records = [];
    @track openingDays = [];
    @track openHours = [];
    @track sessions = [];
    @track columnOrder = 0;
    @track ageRangeFieldValues = [];
    @track closingDays = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
    accountId;
    handleStartDateChange(event) {
        this.startDate = event.target.value;
    }
    renderedCallback(){
        this.accountId = this.recordId;
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
    }

    handleClubNameChange(event) {
        this.clubName = event.target.value;
    }


    @wire(getObjectInfo, {
        objectApiName: KCObject
    })
    kcobjectmetadata;

    @wire(getPicklistValues, {
        recordTypeId: '$kcobjectmetadata.data.defaultRecordTypeId',
        fieldApiName: ageRangeField
    })
    statpicklist({
        data,
        error
    }) {
        if (data) {
            this.ageRangeFieldValues = data.values;
            console.log(JSON.stringify(this.ageRangeFieldValues));
        } else if (error) {
           
        }
    }
    @wire(getObjectInfo, {
        objectApiName: KCObject
    })
    kcobjectmetadata;

    @wire(getPicklistValues, {
        recordTypeId: '$kcobjectmetadata.data.defaultRecordTypeId',
        fieldApiName: statfield
    })
    agePicklist({
        data,
        error
    }) {
        if (data) {
            this.sessions = data.values;
            console.log(JSON.stringify(this.sessions));
        } else if (error) {
           
        }
    }
    @wire(getObjectInfo, {
        objectApiName: KCObject
    })
    kcobjectmetadata;

    @wire(getPicklistValues, {
        recordTypeId: '$kcobjectmetadata.data.defaultRecordTypeId',
        fieldApiName: openingHoursField
    })
    hourPicklist({
        data,
        error
    }) {
        if (data) {
            this.openHours = data.values;
            console.log(JSON.stringify(this.openHours));
        } else if (error) {
           
        }
    }
    @track showDropdown = false;
    @track labelsSet = new Set(); // Set to store unique labels
 
    toggleDropdown() {
        this.showDropdown = !this.showDropdown;
       
        
       



    }

    handleCheckboxChange(event) {
        this.selectedOptions = event.detail.value;
        console.log(JSON.stringify(this.selectedOptions));
    }




    updateOpeningDaysValues(event) {
        const dayName = event.target.name;
        const isChecked = event.target.checked;
    
        if (isChecked) {
           
            const index = this.closingDays.indexOf(dayName);
            if (index !== -1) {
                this.closingDays.splice(index, 1);
            }
           
            this.openingDays.push(dayName);
        } else {
           
            if (!this.closingDays.includes(dayName)) {
                this.closingDays.push(dayName);
            }
           
            const index = this.openingDays.indexOf(dayName);
            if (index !== -1) {
                this.openingDays.splice(index, 1);
            }
        }
    }
    
   
    


    
    isAgeRangeValid(ageRange) {
       
        let ageRangeValues = this.ageRangeFieldValues.map(ageRange => ageRange.value);
    
        
        return ageRangeValues.includes(ageRange);
    }
    isOpeningHourValid(openingHour) {
       
        let openHoursValues = this.openHours.map(hour => hour.value);
    
        
        return openHoursValues.includes(openingHour);
    }
    isSessionValid(currentSession){
        let sessions = this.sessions.map(session => session.value);
    
        
        return sessions.includes(currentSession);
    }
    handleSaveAction() {
        console.log(this.openingDays);
        console.log(this.closingDays);
        console.log(JSON.stringify(this.sessions));
        let ageRanges = this.ageStaffRecords.map(record => record.ageRange);
        let sessionsEntered = this.sessionRecords.map(record => record.Session_Name);
       
        let sessionsEnteredForDiscount = this.discountRecords.map(record => record.Session_Types);
        let openingHoursEntered = this.sessionRecords.map(record => record.openingHours);
        let openingHoursEntered2 = this.sessionRecords.map(record => record.openingHours2);




      
        /*for (let ageRange of ageRanges) {
            if (!this.isAgeRangeValid(ageRange)) {
                this.showToast('Error', 'Invalid age range: ' + ageRange, 'error', 'dismissable');
                return;
            }
        }
        for (let i = 0; i < openingHoursEntered.length || i < openingHoursEntered2.length; i++) {
            if (i < openingHoursEntered.length && !this.isOpeningHourValid(openingHoursEntered[i]) && !this.isOpeningHourValid(openingHoursEntered2[i])) {
                this.showToast('Error', 'Invalid opening hours: ' + openingHoursEntered[i], 'error', 'dismissable');
                return;
            }
           
        } */
        
       

        for (let currentSession of sessionsEntered) {
            if (!this.isSessionValid(currentSession)) {
                this.showToast('Error', 'Invalid session: ' + currentSession, 'error', 'dismissable');
                return;
            }
        }

        // for (let currentSession of sessionsEnteredForDiscount) {
        //     if (!this.isSessionValid(currentSession)) {
        //         this.showToast('Error', 'Invalid session: ' + currentSession, 'error', 'dismissable');
        //         return;
        //     }
        // }

        for (let i = 1; i < this.ageStaffRecords.length; i++) {
            const currentRecord = this.ageStaffRecords[i];
            const previousRecord = this.ageStaffRecords[i - 1];
            
           
            if (parseInt(previousRecord.To_Age) > parseInt(currentRecord.From_Age)) {
               
                this.showToast('Error', 'Age range should not overlap', 'error', 'dismissable');
                return; 
            }
        }
        for (let i = 0; i < this.ageStaffRecords.length; i++) {
            const currentRecord = this.ageStaffRecords[i];
           
            
           
            if (parseInt(currentRecord.To_Age) < parseInt(currentRecord.From_Age)) {
               
                this.showToast('Error', 'From Age should be less than To Age ', 'error', 'dismissable');
                return; 
            }
            else if(parseInt(currentRecord.To_Age) === parseInt(currentRecord.From_Age)){
                this.showToast('Error', 'From Age should not be equal to To Age ', 'error', 'dismissable');
                return; 
            }
        }
        for (let i = 0; i < this.sessionRecords.length - 1; i++) {
            const endTimeCurrent = this.sessionRecords[i].End_Time;
            const startTimeNext = this.sessionRecords[i + 1].Start_Time;
        
           
            const endTimeCurrentMillis = this.getTimeInMillis(endTimeCurrent);
            const startTimeNextMillis = this.getTimeInMillis(startTimeNext);
        
            
            if (endTimeCurrentMillis > startTimeNextMillis) {
                this.showToast('Error', 'Session times should not overlap.', 'error', 'dismissable');
                return;
            }
        }
      
        for (let i = 0; i < this.sessionRecords.length; i++) {
            const startTime = this.sessionRecords[i].Start_Time;
            const endTime = this.sessionRecords[i].End_Time;
            const startTimeMillis = this.getTimeInMillis(startTime);
            const endTimeMillis = this.getTimeInMillis(endTime);
            if(startTimeMillis>endTimeMillis){
                this.showToast('Error', 'Start time should be less than end time', 'error', 'dismissable');
                return; 
            }
            else if(endTimeMillis === startTimeMillis ){
                this.showToast('Error', 'Start time should not be equal to end time for session records', 'error', 'dismissable');
                return; 
            }

        }
        if (new Date(this.startDate) > new Date(this.endDate)) {
            this.showToast('Error', 'Start date should not be greater than end date for hotel club records', 'error', 'dismissable');
                return; 
        }
      
        for (let i = 0; i < this.discountRecords.length; i++) {
            const startDate = this.discountRecords[i].From_Date;
            const endDate = this.discountRecords[i].To_Date;
            if (new Date(startDate) > new Date(endDate)) {
                this.showToast('Error', 'Start date should not be greater than end date for discount records', 'error', 'dismissable');
                return; 
            }
            if (new Date(startDate).getTime() === new Date(endDate).getTime()) {
                this.showToast('Error', 'Start date should not be equal to end date for discount records', 'error', 'dismissable');
                return; 
            }
            if (startDate < new Date()) {
                this.showToast('Error', 'Start date should not be less than today\'s date for discount records', 'error', 'dismissable');
                return;
            }
            if (endDate < new Date()) {
                this.showToast('Error', 'End date should not be less than today\'s date for discount records', 'error', 'dismissable');
                return;
            }

            

        }
       
        // for (let i = 0; i < this.discountRecords.length; i++) {
        //     let type = this.discountRecords[i].Type;
          
        //     if (type!='Vertical' && type!='Horizontal') {
        //         this.showToast('Error', 'Type should be Horizantal or Vertical', 'error', 'dismissable');
        //         console.log(type);
        //         return ;
        //     }
        
           
            

        // }
        for (let i = 0; i < this.discountRecords.length - 1; i++) {
            const endDateCurrent = this.discountRecords[i].To_Date;
            const startdateNext = this.discountRecords[i + 1].From_Date;
        
           
            const endDateCurrentMillis = new Date(endDateCurrent);
            const startDateNextMillis = new Date(startdateNext);
        
            
            if (endDateCurrentMillis > startDateNextMillis) {
                this.showToast('Error', 'Dates should not overlap for discount records.', 'error', 'dismissable');
                return;
            }
        }

        if(this.sessionRecords.length==0 || this.ageStaffRecords.length==0){
            this.showToast('Error', 'Please enter all the details properly', 'error', 'dismissable');
            return;
        }
       
       
        


    
       
    
    
 
   
    
       
        // const sessionOpeningHours = this.sessionRecords.map(session => session.openingHours);
        // const ageRanges = this.ageStaffRecords.map(ageStaff => ageStaff.ageRange);
        
    
        
        // const invalidSessions = sessionOpeningHours.filter(openingHour => !this.openHours.find(hour => hour.value === openingHour));
        // const invalidSessionsForAgeRange = ageRanges.filter(ageRange => !this.ageRangeFieldValues.find(range => range.value === ageRange));
        // if (new Date(this.startDate) >= new Date(this.endDate)) {
            
        //     this.showToast('Error', 'Start date should be less than end date', 'error', 'dismissable');
        //     return; 
        // }
        // else if(this.clubName=== null){
        //     this.showToast('Error', 'Club Name is Mandatory', 'error', 'dismissable');
        //     return; 

        // }
    
        /*if (invalidSessions.length > 0) {
            
            this.showToast('Error', 'Some session records have invalid opening hours Please edit.', 'error', 'dismissable');
            return; 
        }
        if (invalidSessionsForAgeRange.length > 0) {
            
            this.showToast('Error', 'Some age staff records have invalid age ranges Please edit.', 'error', 'dismissable');
            return; 
        }*/


        
    
        this.createInventoryProducts();
       
        
    }
    handlePublishAction() {
        console.log(this.openingDays);
        console.log(this.closingDays);
        console.log(JSON.stringify(this.sessions));
        let ageRanges = this.ageStaffRecords.map(record => record.ageRange);
        let sessionsEntered = this.sessionRecords.map(record => record.Session_Name);
       
        let sessionsEnteredForDiscount = this.discountRecords.map(record => record.Session_Types);
        let openingHoursEntered = this.sessionRecords.map(record => record.openingHours);
        let openingHoursEntered2 = this.sessionRecords.map(record => record.openingHours2);




      
        /*for (let ageRange of ageRanges) {
            if (!this.isAgeRangeValid(ageRange)) {
                this.showToast('Error', 'Invalid age range: ' + ageRange, 'error', 'dismissable');
                return;
            }
        }
        for (let i = 0; i < openingHoursEntered.length || i < openingHoursEntered2.length; i++) {
            if (i < openingHoursEntered.length && !this.isOpeningHourValid(openingHoursEntered[i]) && !this.isOpeningHourValid(openingHoursEntered2[i])) {
                this.showToast('Error', 'Invalid opening hours: ' + openingHoursEntered[i], 'error', 'dismissable');
                return;
            }
           
        } */
        
       

        for (let currentSession of sessionsEntered) {
            if (!this.isSessionValid(currentSession)) {
                this.showToast('Error', 'Invalid session: ' + currentSession, 'error', 'dismissable');
                return;
            }
        }

        // for (let currentSession of sessionsEnteredForDiscount) {
        //     if (!this.isSessionValid(currentSession)) {
        //         this.showToast('Error', 'Invalid session: ' + currentSession, 'error', 'dismissable');
        //         return;
        //     }
        // }

        for (let i = 1; i < this.ageStaffRecords.length; i++) {
            const currentRecord = this.ageStaffRecords[i];
            const previousRecord = this.ageStaffRecords[i - 1];
            
           
            if (parseInt(previousRecord.To_Age) > parseInt(currentRecord.From_Age)) {
               
                this.showToast('Error', 'Age range should not overlap', 'error', 'dismissable');
                return; 
            }
        }
        for (let i = 0; i < this.ageStaffRecords.length; i++) {
            const currentRecord = this.ageStaffRecords[i];
           
            
           
            if (parseInt(currentRecord.To_Age) < parseInt(currentRecord.From_Age)) {
               
                this.showToast('Error', 'From Age should be less than To Age ', 'error', 'dismissable');
                return; 
            }
            else if(parseInt(currentRecord.To_Age) === parseInt(currentRecord.From_Age)){
                this.showToast('Error', 'From Age should not be equal to To Age ', 'error', 'dismissable');
                return; 
            }
        }
        for (let i = 0; i < this.sessionRecords.length - 1; i++) {
            const endTimeCurrent = this.sessionRecords[i].End_Time;
            const startTimeNext = this.sessionRecords[i + 1].Start_Time;
        
           
            const endTimeCurrentMillis = this.getTimeInMillis(endTimeCurrent);
            const startTimeNextMillis = this.getTimeInMillis(startTimeNext);
        
            
            if (endTimeCurrentMillis > startTimeNextMillis) {
                this.showToast('Error', 'Session times should not overlap.', 'error', 'dismissable');
                return;
            }
        }
      
        for (let i = 0; i < this.sessionRecords.length; i++) {
            const startTime = this.sessionRecords[i].Start_Time;
            const endTime = this.sessionRecords[i].End_Time;
            const startTimeMillis = this.getTimeInMillis(startTime);
            const endTimeMillis = this.getTimeInMillis(endTime);
            if(startTimeMillis>endTimeMillis){
                this.showToast('Error', 'Start time should be less than end time', 'error', 'dismissable');
                return; 
            }
            else if(endTimeMillis === startTimeMillis ){
                this.showToast('Error', 'Start time should not be equal to end time for session records', 'error', 'dismissable');
                return; 
            }

        }
        if (new Date(this.startDate) > new Date(this.endDate)) {
            this.showToast('Error', 'Start date should not be greater than end date for hotel club records', 'error', 'dismissable');
                return; 
        }
      
        for (let i = 0; i < this.discountRecords.length; i++) {
            const startDate = this.discountRecords[i].From_Date;
            const endDate = this.discountRecords[i].To_Date;
            if (new Date(startDate) > new Date(endDate)) {
                this.showToast('Error', 'Start date should not be greater than end date for discount records', 'error', 'dismissable');
                return; 
            }
            if (new Date(startDate).getTime() === new Date(endDate).getTime()) {
                this.showToast('Error', 'Start date should not be equal to end date for discount records', 'error', 'dismissable');
                return; 
            }
            if (startDate < new Date()) {
                this.showToast('Error', 'Start date should not be less than today\'s date for discount records', 'error', 'dismissable');
                return;
            }
            if (endDate < new Date()) {
                this.showToast('Error', 'End date should not be less than today\'s date for discount records', 'error', 'dismissable');
                return;
            }

            

        }
       
        // for (let i = 0; i < this.discountRecords.length; i++) {
        //     let type = this.discountRecords[i].Type;
          
        //     if (type!='Vertical' && type!='Horizontal') {
        //         this.showToast('Error', 'Type should be Horizantal or Vertical', 'error', 'dismissable');
        //         console.log(type);
        //         return ;
        //     }
        
           
            

        // }
        for (let i = 0; i < this.discountRecords.length - 1; i++) {
            const endDateCurrent = this.discountRecords[i].To_Date;
            const startdateNext = this.discountRecords[i + 1].From_Date;
        
           
            const endDateCurrentMillis = new Date(endDateCurrent);
            const startDateNextMillis = new Date(startdateNext);
        
            
            if (endDateCurrentMillis > startDateNextMillis) {
                this.showToast('Error', 'Dates should not overlap for discount records.', 'error', 'dismissable');
                return;
            }
        }

        if(this.sessionRecords.length==0 || this.ageStaffRecords.length==0){
            this.showToast('Error', 'Please enter all the details properly', 'error', 'dismissable');
            return;
        }

        this.checkValidUser();

       
        
         

   
        
        
        
    }
    checkValidUser(){
        checkPartner({hotelId: this.recordId})
        .then(result=>{
            if(result=='true'){
                this.createInventoryProducts();
                this.updateDisplayCheckbox();

            }
            else{
                this.showToast('Error', 'Error No valid partner user present for this hotel', 'error', 'sticky');
            }
        })

    }
    getTimeInMillis(timeString) {
        const [hours, minutes, seconds] = timeString.split(':').map(Number);
        return (hours * 60 * 60 + minutes * 60 + seconds) * 1000;
    }

    closeAction(){
        console.log(JSON.stringify(this.openingDays));
        console.log(JSON.stringify(this.closingDays));
        console.log(JSON.stringify(this.openHours));
        console.log(JSON.stringify(this.ageRangeFieldValues));
        
        this.dispatchEvent(new CloseActionScreenEvent());
    }
 
    
    addRowForAge() {
      
        
       // let randomId = Math.floor(Math.random() * 16);
        // FIXED CODE:
        // Use timestamp + random for unique IDs to prevent jumbling with many sessions
         // jumbleness resolve tayib:16march 2026 at 5:50pm
        let randomId = String(Date.now() + Math.floor(Math.random() * 1000));
        

        let myNewElement = {From_Age: "", To_Age: "",Staff:"", Ratio: "",Id: randomId,ageRange:""};
        this.ageStaffRecords = [...this.ageStaffRecords, myNewElement];

    }
    addRowForSession() {

        
        // let randomId = Math.floor(Math.random() * 16);
        // FIXED CODE:
        // Use timestamp + random for unique IDs to prevent jumbling with many sessions
        // jumbleness resolve tayib:16march 2026 at 5:50pm
        let randomId = String(Date.now() + Math.floor(Math.random() * 1000));
        

        let myNewElement = {Session_Name: "", Start_Time: "",  End_Time: "",Ratio:"",Staff:"",Cost:"",Id: randomId, openingHours:"", openingHours2:""};
        this.sessionRecords = [...this.sessionRecords, myNewElement];
        
    }
    addRowForDiscount() {
  
        
        // let randomId = Math.floor(Math.random() * 16);
        // FIXED CODE:
        // Use timestamp + random for unique IDs to prevent jumbling with many sessions
        // jumbleness resolve tayib:16march 2026 at 5:50pm
        let randomId = String(Date.now() + Math.floor(Math.random() * 1000));


        let myNewElement = {From_Date: "", To_Date: "",  Type: "",Min_No:"",Id: randomId, Session_Types:""};
        this.discountRecords = [...this.discountRecords, myNewElement];
        
    }

    updateDisplayCheckbox(){
        updateCheckbox({ hotelId: this.recordId })
            .then(result => {
               
                console.log('Display__c checkbox updated successfully.');
            })
            .catch(error => {
                
                console.error('Error updating Display__c checkbox: ', error);
            });
    }

    
 
   
 

 

    updateValuesForAgeData(event){
         // jumbleness resolve type coercion num to string Use Strict Equality : tayib:16march 2026 at 5:50pm
        // var foundelement = this.ageStaffRecords.find(ele => ele.Id == event.target.dataset.id);
        var foundelement = this.ageStaffRecords.find(ele => ele.Id === event.target.dataset.id);
        
        if(event.target.name === 'From_Age'){
            foundelement.From_Age = event.target.value;
            foundelement.ageRange = foundelement.From_Age+" "+"-"+" "+foundelement.To_Age;
        } else if(event.target.name === 'To_Age'){
            foundelement.To_Age = event.target.value;
            foundelement.ageRange = foundelement.From_Age+" "+"-"+" "+foundelement.To_Age;
        // } else if(event.target.name === 'Ratio'){
        //     foundelement.Ratio = event.target.value;
        //
     }
        //   else if(event.target.name === 'Staff'){
        //     foundelement.Staff = event.target.value;
        // }

        console.log(this.ageStaffRecords[0].ageRange);
        
       
      
       
    }
    @track updatedLabelsSet=[];
    updateValuesForSessionData(event){
        // jumbleness resolve type coercion num to string Use Strict Equality : tayib:16march 2026 at 5:50pm 
        // var foundelement = this.sessionRecords.find(ele => ele.Id == event.target.dataset.id);
        var foundelement = this.sessionRecords.find(ele => ele.Id === event.target.dataset.id);
        if (event.target.name === 'Session_Name') {
            foundelement.Session_Name = event.target.value;
            for (let i = 0; i < this.sessionRecords.length; i++) {
                if (!this.labelsSet.has(this.sessionRecords[i].Session_Name)) { 
                    this.options.push({ label: this.sessionRecords[i].Session_Name, value: this.sessionRecords[i].Session_Name });
                    this.labelsSet.add(this.sessionRecords[i].Session_Name); 
                }
            }
           
        } else if (event.target.name === 'Start_Time') {
            foundelement.Start_Time = event.detail.value;
            foundelement.openingHours = formatTimeTo12Hour(foundelement.Start_Time) + " - " + formatTimeTo12Hour(foundelement.End_Time);
            foundelement.openingHours2 = formatTimeTo12Hour2(foundelement.Start_Time) + " - " + formatTimeTo12Hour2(foundelement.End_Time);

        } else if (event.target.name === 'End_Time') {
            foundelement.End_Time = event.detail.value;
            foundelement.openingHours = formatTimeTo12Hour(foundelement.Start_Time) + " - " + formatTimeTo12Hour(foundelement.End_Time);
            foundelement.openingHours2 = formatTimeTo12Hour2(foundelement.Start_Time) + " - " + formatTimeTo12Hour2(foundelement.End_Time);
        } else if (event.target.name === 'Cost') {
            foundelement.Cost = event.target.value;
        }
        else if (event.target.name === 'Ratio') {
            foundelement.Ratio = event.target.value;
        }
        else if (event.target.name === 'Staff') {
            foundelement.Staff = event.target.value;
        }

      
        console.log(JSON.stringify(this.options));     
        
        function formatTimeTo12Hour(time) {
            let timeArray = time.split(':');
            let hours = parseInt(timeArray[0]);
            let minutes = timeArray[1];
            let ampm = hours >= 12 ? 'pm' : 'am';
            hours = hours % 12;
            hours = hours ? hours : 12; 
            if(timeArray[1]==='00'){
                return hours + ampm;
            }

            return hours + ':' + minutes + ampm;
        }
        function formatTimeTo12Hour2(time) {
            let timeArray = time.split(':');
            let hours = parseInt(timeArray[0]);
            let minutes = timeArray[1];
            let ampm = hours >= 12 ? 'pm' : 'am';
            hours = hours % 12;
            hours = hours ? hours : 12; 
            

            return hours + ':' + minutes + ampm;
        }
        

        console.log(this.sessionRecords[0].openingHours);   
      
        
    }

    @track isVertical = true;
    @track isHorizontal = false;

    updateValuesForDiscountData(event){
        // jumbleness resolve type coercion num to string Use Strict Equality : tayib:16march 2026 at 5:50pm
        // var foundelement = this.discountRecords.find(ele => ele.Id == event.target.dataset.id);
       var foundelement = this.discountRecords.find(ele => ele.Id === event.target.dataset.id);
        if(event.target.name === 'From_Date'){
            foundelement.From_Date = event.target.value;
        } else if(event.target.name === 'To_Date'){
            foundelement.To_Date = event.detail.value;
          
        } else if(event.target.name === 'Type'){
            foundelement.Type = event.detail.value;
            if(foundelement.Type==='Horizontal'){
                this.isHorizontal = true;
                this.isVertical = false;
            }
            else{
                this.isVertical = true;
                this.isHorizontal = false;
            }
            
          
        }
          else if(event.target.name === 'Min_No'){
            foundelement.Min_No = event.target.value;
        }
      
        else if(event.target.name === 'Session_Types'){
            foundelement.Session_Types = event.target.value;
            
          
        }
         else if(event.target.name === 'Amount'){
            foundelement.Amount = event.target.value;
        }

       
    }
 
   
 

   

    
 

  
 
    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }
 
    updateRecordView() {
       setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
       }, 3000); 
    }
 


      

// createInventoryProducts() {
//     console.log(JSON.stringify(this.ageStaffRecords));
//     console.log(JSON.stringify(this.sessionRecords));

   
//     createHotelClubRecord({
//             startDate: this.startDate,
//             endDate: this.endDate,
//             clubName: this.clubName,
//             openingDays: this.openingDays,
//             closingDays: this.closingDays
//         })
//         .then(hotelClubId => { 
//             createInventoryProducts({
//                     hotelClubId: hotelClubId, 
//                     ageStaffRecordsJSON: JSON.stringify(this.ageStaffRecords),
//                     sessionRecordsJSON: JSON.stringify(this.sessionRecords)
//                 })
//                 .then(result => {
                   
//                     this.showToast('Success', 'Inventory products created successfully', 'success', 'dismissable');
                    
//                 })
//                 .catch(error => {
                   
//                     this.showToast('Error', 'Error creating inventory products', 'error', 'sticky');
//                     console.error('Error creating inventory products', error);
//                 });

//             this.showToast('Success', 'Hotel club record created successfully', 'success', 'dismissable');
//         })
//         .catch(error => {
//             this.showToast('Error', 'Error creating hotel club record', 'error', 'sticky');
//             console.error('Error creating hotel club record', error);
//         });
// }

@track hotelClubRecordId;
createInventoryProducts(currentDate) {
    console.log(JSON.stringify(this.ageStaffRecords));
    console.log(JSON.stringify(this.sessionRecords));
    this.columnOrder = this.sessionRecords.length;
    console.log(this.columnOrder);



    let hotelClubId;

    createHotelClubRecord({
        hotelId: this.recordId,
        startDate: this.startDate,
        endDate: this.endDate,
        clubName: this.clubName,
        openingDays: this.openingDays,
        closingDays: this.closingDays,
        
    })
    .then(newHotelClubId => {
        this.showToast('Success', 'Hotel club created successfully', 'success', 'dismissable');
        hotelClubId = newHotelClubId;
        return createInventoryProducts({
            startDate: this.startDate,
            endDate: this.endDate,
            hotelClubId: hotelClubId,
            columnOrder: this.columnOrder,
            ageStaffRecordsJSON: JSON.stringify(this.ageStaffRecords),
            sessionRecordsJSON: JSON.stringify(this.sessionRecords)
        });
    })
    .then(newHotelClubId => {
        this.showToast('Success', 'Inventory products created successfully', 'success', 'dismissable');
        hotelClubId = newHotelClubId;
        
       
        return createDiscountRecords({
            hotelId: this.recordId,
            selectedOptions: this.selectedOptions,
           
            hotelClubId: hotelClubId,
            discountRecordsJSON: JSON.stringify(this.discountRecords),
          
        });
        
    })
    .then(result=>{
       
        if(this.discountRecords.length>0){

        
        this.showToast('Success', 'Discount records created successfully', 'success', 'dismissable');
        let url = 'https://wwkc.lightning.force.com/lightning/r/Contract/' +hotelClubId+ '/view'; 
 

   
        window.location.href = url;
        }
        else{
            let url = 'https://wwkc.lightning.force.com/lightning/r/Contract/' +hotelClubId+ '/view'; 
 

   
        window.location.href = url;

        }
        this.closeAction();
        
    })
    .catch(error=>{
        this.showToast('Error', 'Error creating in records. Please enter Hotel club details properly', 'error', 'dismissable');
        console.log('error'+error);
        if (hotelClubId) {
           
            deleteHotelClubRecord({ hotelClubId: hotelClubId })
            .then(result =>{
                this.showToast('Error', 'Deleted Hotel Club created ', 'error', 'dismissable');
            })
            .catch(deleteError => {
                console.error('Error deleting hotel club record after inventory product creation failure', deleteError);
            });
        }

        console.error('error',error);
    })
    .catch(error => {
       
        this.showToast('Error', 'Error creating in records. Please enter details properly', 'error', 'sticky');
        console.error('Error creating inventory products', error);
    });
   
   
  
    
}
get todaysDate() {
    const today = new Date();
        const year = today.getFullYear();
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const day = String(today.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
}
isCssLoaded = false;
renderedCallback(){ 
 
   
    if(this.isCssLoaded) return
    this.isCssLoaded = true
   
    loadStyle(this, override).then(()=>{
       
    }).catch(error=>{ 
       
    })
}
    
}