@isTest(seealldata=false)
private class AvailableProductsControllerTest{
    @testSetup 
    static void setup(){
        Product2 prod = new Product2(Name = 'TestProd', Family = 'Fam', IsActive = TRUE);
        insert prod;

        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
   
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
    }

    @isTest
    static void validateGetProductList() {
        Test.startTest();
        List<AvailableProductsController.ProductWithPrice> prodList = AvailableProductsController.getProductWithPriceList();
        Test.stopTest();
        System.assertEquals(1, prodList.size());
    }

    @isTest
    static void validateDispatchPlatformEvent() {
        Test.startTest();
        AvailableProductsController.dispatchPlatformEvent('productId', 'name', 10);
        Test.stopTest();
        //System.assertEquals(1, prodList.size());
    }
}