@isTest(seealldata=false)
private class OrderProductsControllerTest{
    @testSetup 
    static void setup(){
        Product2 prod = new Product2(Name = 'TestProd', Family = 'Fam', IsActive = TRUE);
        insert prod;

        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
   
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPricebook.id, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;

        Account acc = new Account(name = 'Test Acc Name');
        insert acc;

        Contract cont = new Contract(Status = 'Draft', StartDate = Date.today(), ContractTerm = 12, AccountId = acc.id);
        insert cont;
        
        cont.status = 'Activated';
        update cont;
        
        Order ord = new Order(Pricebook2Id = standardPricebook.id ,ContractId = cont.id, AccountId = acc.id, Status = 'Draft', EffectiveDate = Date.today());
        insert ord;
        
        OrderItem oi = new OrderItem(Quantity = 1, UnitPrice = 10, OrderId = ord.id, Product2Id = prod.id, PricebookEntryId = standardPrice.id);
        insert oi;
    }

    @isTest
    static void validateGetProductList() {
        Test.startTest();
        Order ord = [Select id, status from Order];
        ord.Status = 'Activated';
        update ord;
        
        Boolean isOrderActivated = OrderProductsController.getIsOrderActivated(ord.id);
        Test.stopTest();
        System.assertEquals(true, isOrderActivated);
    }
    
    @isTest
    static void validateGetActivateOrder() {
        Test.startTest();
        Order ord = [Select id from Order];
        Product2 prd = [Select id from product2];
        List<AvailableProductsController.ProductWithPrice> pwpList = new List<AvailableProductsController.ProductWithPrice>();
        AvailableProductsController.ProductWithPrice pwp = new AvailableProductsController.ProductWithPrice();
        pwp.id = prd.id;
        pwp.name = 'TestProd';
        pwp.quantity = 1;
        pwp.unitPrice = 50;
        pwp.totalPrice = 50;
        pwpList.add(pwp);
        
        Boolean isInserted = OrderProductsController.getActivateOrder(pwpList, ord.id);
        Test.stopTest();

        System.assertEquals(true, isInserted);
    }
}