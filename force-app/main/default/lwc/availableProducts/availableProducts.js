import { LightningElement, wire, track } from 'lwc';
import getProductWithPriceList from '@salesforce/apex/AvailableProductsController.getProductWithPriceList';
import dispatchPlatformEvent from '@salesforce/apex/AvailableProductsController.dispatchPlatformEvent';

const data = [];
const columns = [
    {
        label: 'Add',
        type: 'button-icon',
        initialWidth: 60,
        typeAttributes: {
            iconName: 'utility:add',
            variant: 'border-filled',
            alternativeText: 'Add Product to current Order'
        }
    },
    { 
        label: 'Product Name', 
        fieldName: 'name',
        sortable: true,
    },
    {
        label: 'List Price',
        fieldName: 'unitPrice',
        type: 'currency',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
];

export default class AvailableProducts extends LightningElement {
	data = data;
    columns = columns;
	@track products;
	@wire(getProductWithPriceList)
    products({error,data}) {
        console.log('Data : ' + JSON.stringify(data));
        if(data){
            this.products = data;
        } else if(error){
            console.log('Product Error');
            console.log(error);
        } else{
            console.log('Sorry Nothing Happened');
        }
    }
    handleRowAction(event){
        console.log('Entered handleRowAction');
        console.log(JSON.stringify(event.detail.row));

        dispatchPlatformEvent({
            productId : event.detail.row.id,
            name : event.detail.row.name,
            unitPrice : event.detail.row.unitPrice,
        });
        let tempProducts = [...this.products];
        let index = tempProducts.findIndex(element => element.id == event.detail.row.id);
        let addedProduct = tempProducts.splice(index, 1)[0];
        this.products = [addedProduct, ...tempProducts];
   }
}