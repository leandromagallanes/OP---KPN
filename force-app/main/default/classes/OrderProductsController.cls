/**********************************************************
Apex Class Name    : OrderProductsController
Created Date       : July 24, 2023
@description       : Created to handle the OrderProducts component
@author            : Leandro Magallanes
Modification Log:
Ver   Date         Author                               Modification
1.0   24-07-2023   Leandro Magallanes                  Initial Version
**********************************************************/
public with sharing class OrderProductsController {
    /**********************************************************
    @Method Name    : getActivateOrder
    @author         : Leandro Magallanes
    @description    : Activates the order
    @param          : List<AvailableProductsController.ProductWithPrice> pwpList, Id orderId
    @return         : Boolean
    *********************************************************/
    @auraEnabled(cacheable=false)
    public static Boolean getActivateOrder(List<AvailableProductsController.ProductWithPrice> pwpList, Id orderId){
        List<OrderItem> orderItemList = new List<OrderItem>();
        Order ord = [SELECT id, pricebook2Id, status, name, orderNumber, account.name, account.accountNumber, type FROM order WHERE id =: orderId];
        PriceBook2 pb2Standard = [select Id from Pricebook2 where isStandard=true];

        Map<Id,PricebookEntry> pricebookEntryByPricebookId = new Map<Id,PricebookEntry>();

        List<pricebookentry> pbeList = [select id, Pricebook2.id from pricebookentry];
        for(pricebookentry pbe : pbeList){
            pricebookEntryByPricebookId.put(pbe.pricebook2.id, pbe);
        }
        Map<Id,Product2> productById = new Map<id,product2>([SELECT id, ProductCode, Name FROM Product2]);

        for(AvailableProductsController.ProductWithPrice pwp : pwpList){
            Id standardPriceBookId = pb2Standard.Id;
        
            if (ord.Pricebook2Id == null) {
                ord.Pricebook2Id = standardPriceBookId;
            }
            
            OrderItem oi = new OrderItem();
            oi.PricebookEntryId = pricebookEntryByPricebookId.get(ord.Pricebook2Id).id;
            oi.product2 = productById.get(pwp.id);
            oi.unitPrice = pwp.unitPrice;
            oi.quantity = pwp.quantity;
            oi.orderId = orderId;
            orderItemList.add(oi);
        }
        
        update ord;
        insert orderItemList;
        ord.status = 'Activated';
        update ord;

        Database.SaveResult[] srList = Database.update(orderItemList, false);
 
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                String requestBody = createRequestBody(ord, orderItemList);
                sendRequest(requestBody);
                return true;
            }
        }
            return false;
    }

    /**********************************************************
    @Method Name    : createRequestBody
    @author         : Leandro Magallanes
    @description    : Creates the body from serializing the populated wrapper
    @param          : Order ord, List<OrderItem> orderItemList
    @return         : String
    *********************************************************/
    private static String createRequestBody(Order ord, List<OrderItem> orderItemList){
        OrderProductsController.OrderWithProducts owp = new OrderProductsController.OrderWithProducts();
        owp.accountNumber = ord.Account.AccountNumber;
        owp.orderNumber = ord.OrderNumber;
        owp.status = ord.Status;
        owp.type = ord.Type;
        List<OrderProductsController.OrderProduct> opList = new List<OrderProductsController.OrderProduct>();
        for(OrderItem oi : orderItemList){
            OrderProductsController.OrderProduct op = new OrderProductsController.OrderProduct();
            op.code = oi.Product2.ProductCode;
            op.name = oi.Product2.Name;
            op.unitPrice = oi.UnitPrice.setScale(2);
            op.quantity = oi.Quantity.intValue();
            opList.add(op);
        }
        owp.orderProducts = opList;
        return JSON.serialize(owp);
    }

    /**********************************************************
    @Method Name    : getIsOrderActivated
    @author         : Leandro Magallanes
    @description    : Returns if the order has the Activated status
    @param          : Id orderId
    @return         : Boolean
    *********************************************************/
    @auraEnabled(cacheable=true)
    public static Boolean getIsOrderActivated(Id orderId){
        Order order = [SELECT status from Order where id =: orderId];
        return order.status == 'Activated';

    }

    /**********************************************************
    @Method Name    : sendRequest
    @author         : Leandro Magallanes
    @description    : Sends the order to requestCatcher
    @param          : Order ord
    *********************************************************/
    @Future(callout=true)
    public static void sendRequest(String requestBody){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://op-kpn.requestcatcher.com');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        request.setBody(requestBody);
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }
    }

    /**********************************************************
    Apex Class Name    : OrderWithProducts
    Created Date       : July 24, 2023
    @description       : Inner Wrapper class to set the product with the unitprice from the standard pricebook
    @author            : Leandro Magallanes
    Modification Log:
    Ver   Date         Author                               Modification
    1.0   26-07-2023   Leandro Magallanes                  Initial Version
    **********************************************************/
    public with sharing class OrderWithProducts {
        public String accountNumber;
        public String orderNumber;
        public String type;
        public String status;
        public List<OrderProductsController.OrderProduct> orderProducts;
    }
    /**********************************************************
    Apex Class Name    : OrderProduct
    Created Date       : July 24, 2023
    @description       : Inner Wrapper class with the orderProduct details
    @author            : Leandro Magallanes
    Modification Log:
    Ver   Date         Author                               Modification
    1.0   26-07-2023   Leandro Magallanes                  Initial Version
    **********************************************************/
    public with sharing class OrderProduct {
        public String name;
        public String code;
        public Decimal unitPrice;
        public Integer quantity;
    }
}
