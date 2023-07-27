/**********************************************************
Apex Class Name    : AvailableProductsController
Created Date       : July 24, 2023
@description       : Created to handle the OrderProducts component
@author            : Leandro Magallanes
Modification Log:
Ver   Date         Author                               Modification
1.0   24-07-2023   Leandro Magallanes                  Initial Version
**********************************************************/
public with sharing class AvailableProductsController {
    /**********************************************************
    @Method Name    : getProductWithPriceList
    @author         : Leandro Magallanes
    @description    : Gets the Product with the Pricelist, and sets them in a list of the ProductWithPrice wrapper
    @return         : List<ProductWithPrice>
    *********************************************************/
    @auraEnabled(cacheable=true)
    public static List<ProductWithPrice> getProductWithPriceList(){
        List<Pricebookentry> pbeList = [SELECT id, unitPrice, Product2.name, pricebook2.isstandard FROM Pricebookentry WHERE Product2.isActive = TRUE AND pricebook2.isstandard = TRUE AND isActive = TRUE ORDER BY Product2.name ASC];
        List<ProductWithPrice> productsWithPriceToReturn = new List<ProductWithPrice>();
        for(Pricebookentry p : pbeList){
            ProductWithPrice pwp = new ProductWithPrice();
            pwp.id = p.Product2Id;
            pwp.name = p.product2.name;
            pwp.unitPrice = p.unitPrice;

            productsWithPriceToReturn.add(pwp);
        }
        return productsWithPriceToReturn;
    }    
    
    /**********************************************************
    @Method Name    : dispatchPlatformEvent
    @author         : Leandro Magallanes
    @description    : Creates and publishes an instance of the "Added_Product__e" event
    @param          : String productId, String name, Decimal unitPrice
    @return         : Boolean
    *********************************************************/
    @auraEnabled(cacheable=false)
    public static void dispatchPlatformEvent(String productId, String name, Decimal unitPrice){
        Added_Product__e ap = new Added_Product__e();
        ap.ProductId__c = productId;
        ap.Name__c = name;
        ap.Unit_Price__c = unitPrice;
        EventBus.publish(ap);
    }

    /**********************************************************
    Apex Class Name    : ProductWithPrice
    Created Date       : July 24, 2023
    @description       : Inner Wrapper class to set the product with the unitprice from the standard pricebook
    @author            : Leandro Magallanes
    Modification Log:
    Ver   Date         Author                               Modification
    1.0   24-07-2023   Leandro Magallanes                  Initial Version
    **********************************************************/
    public with sharing class ProductWithPrice {
        @auraenabled public String id {get; set;}
        @auraenabled public String name {get; set;}
        @auraenabled public Decimal unitPrice {get; set;}
        @auraenabled public Decimal totalPrice {get; set;}
        @auraenabled public Integer quantity {get; set;}
    }
}