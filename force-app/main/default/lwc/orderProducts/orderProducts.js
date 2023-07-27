import { LightningElement,track,wire,api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { subscribe, unsubscribe } from 'lightning/empApi';
import getActivateOrder from '@salesforce/apex/OrderProductsController.getActivateOrder'
import STATUS_FIELD from '@salesforce/schema/Order.Status';

const data = [];
const columns = [
    { 
        label: 'Product Name', 
        fieldName: 'name',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Unit Price',
        fieldName: 'unitPrice',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Quantity',
        fieldName: 'quantity',
        type: 'number',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    {
        label: 'Total Price',
        fieldName: 'totalPrice',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
];


export default class DemoApp extends LightningElement {
    @track orderProducts = [];
    data = data;
    columns = columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    
    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD]})
    order;

    //Boolean to track if the order status is Activated
    get isOrderActivated() {
        return getFieldValue(this.order.data, STATUS_FIELD) == 'Activated';
    }

	connectedCallback(){
		console.log('Connected Callback');
        this.subscribeToPlatformEvent();
    }


    subscribeToPlatformEvent(){
        const refreshData = (response) => {
            let elem = this.orderProducts.find(element => element.id == response.data.payload.ProductId__c);
            if(elem){
                console.log('Segundo agregado');
                // EXISTING PRODUCT IN THE ORDER - ADDS 1 TO THE QUANTITY AND RECALCULATES THE TOTAL PRICE
                elem.quantity ++;
                elem.totalPrice = elem.quantity * elem.unitPrice;
                this.orderProducts = [...this.orderProducts];
            }else{
                console.log('Primero agregado');
                // FIRST OCCURENCE OF THE PRODUCT IN THE ORDER LIST
                this.orderProducts = [...this.orderProducts, {
                    name: response.data.payload.Name__c,
                    unitPrice: response.data.payload.Unit_Price__c,
                    id: response.data.payload.ProductId__c,
                    quantity: 1,
                    totalPrice: response.data.payload.Unit_Price__c,
                }];
            }
            
        }
        subscribe('/event/Added_Product__e', -1, refreshData).then(response => {
            this.subscription = response;
        });
    }

    //Runs the method with the logic for the change of status to "Activated". If it's activated, it unsubscribes from the platform event
    @wire(getActivateOrder)
    onHandleActivateButton() {
        getActivateOrder({pwpList: this.orderProducts, orderId: this.recordId}).then(result => {
            unsubscribe(this.subscription, (response) => {
                console.log('unsubscribe() response: ', JSON.stringify(response));
            });
            console.log('ACTIVATE - Result : ' + result);
        })
        .catch(error => {
            this.error = error;
        });
    }
}