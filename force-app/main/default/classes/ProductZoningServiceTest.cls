@isTest
public class ProductZoningServiceTest {
    @isTest
    static void testPermissibleFlyZone() {
        // Setup test data
        Product2 product = new Product2(Name='Test Product', ProductCode='TP123', Family='Test Family');
        insert product;

        Product2 productWithoutFamily = new Product2(Name='Test Product 2', ProductCode='TP124');
        insert productWithoutFamily;

        // Simuler les métadonnées personnalisées avec des stubs
        List<Product_Geo_Mapping__mdt> mockData = new List<Product_Geo_Mapping__mdt>{
            new Product_Geo_Mapping__mdt(
                MasterLabel = 'Test Family US', 
                Product_Family__c = 'Test Family', 
                Country_Code__c = 'US', 
                Permissible_Fly_Zone__c = 'US Zone A'
            ),
            new Product_Geo_Mapping__mdt(
                MasterLabel = 'Test Family AU', 
                Product_Family__c = 'Test Family', 
                Country_Code__c = 'AU', 
                Permissible_Fly_Zone__c = 'Australia Zone B'
            )
        };

        // Inject the stub data
        ProductZoningService.ProductGeoMappingWrapper = mockData;

        Test.startTest();

        // Test valid scenario for US without CountryCode header
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ProductZoning/TP123';
        req.httpMethod = 'GET';
        RestContext.request = req;

        String result = ProductZoningService.getPermissibleFlyZone();
        System.assertEquals('US Zone A', result);

        // Test missing ProductCode
        req = new RestRequest();
        req.requestURI = '/services/apexrest/ProductZoning/';
        req.httpMethod = 'GET';
        RestContext.request = req;

        result = ProductZoningService.getPermissibleFlyZone();
        System.assertEquals('ProductCode is missing or doesn\'t exist', result);

        // Test with invalid ProductCode
        req = new RestRequest();
        req.requestURI = '/services/apexrest/ProductZoning/INVALID';
        req.httpMethod = 'GET';
        RestContext.request = req;

        result = ProductZoningService.getPermissibleFlyZone();
        System.assertEquals('Confirm with the local authorities', result);

        mockData.clear();
        mockData.add(new Product_Geo_Mapping__mdt(
            MasterLabel = 'Test Family AU', 
            Product_Family__c = 'Test Family', 
            Country_Code__c = 'AU', 
            Permissible_Fly_Zone__c = 'Australia Zone B'
        ));

        // Test valid scenario for AU
        req = new RestRequest();
        req.requestURI = '/services/apexrest/ProductZoning/TP123';
        req.httpMethod = 'GET';
        req.addHeader('CountryCode', 'AU');
        RestContext.request = req;

        result = ProductZoningService.getPermissibleFlyZone();
        System.assertEquals('Australia Zone B', result);

        mockData.clear();
        mockData.add(new Product_Geo_Mapping__mdt(
            MasterLabel = 'Test Family US', 
            Product_Family__c = 'Test Family', 
            Country_Code__c = 'US', 
            Permissible_Fly_Zone__c = 'US Zone A'
        ));

        // Test with product without family
        req = new RestRequest();
        req.requestURI = '/services/apexrest/ProductZoning/TP124';
        req.httpMethod = 'GET';
        RestContext.request = req;

        result = ProductZoningService.getPermissibleFlyZone();
        System.assertEquals('Confirm with the local authorities', result);

        // Test with no matching geo mapping
        mockData.clear();
        mockData.add(new Product_Geo_Mapping__mdt(
            MasterLabel = 'Another Family US', 
            Product_Family__c = 'Another Family', 
            Country_Code__c = 'US', 
            Permissible_Fly_Zone__c = 'Another Zone'
        ));

        ProductZoningService.ProductGeoMappingWrapper = mockData;
        
        req = new RestRequest();
        req.requestURI = '/services/apexrest/ProductZoning/TP123';
        req.httpMethod = 'GET';
        RestContext.request = req;

        result = ProductZoningService.getPermissibleFlyZone();
        System.assertEquals('Confirm with the local authorities', result);

        // Test with a valid ProductCode but no CountryCode header (default to US)
        mockData.clear();
        mockData.add(new Product_Geo_Mapping__mdt(
            MasterLabel = 'Test Family US', 
            Product_Family__c = 'Test Family', 
            Country_Code__c = 'US', 
            Permissible_Fly_Zone__c = 'US Zone A'
        ));
        ProductZoningService.ProductGeoMappingWrapper = mockData;

        req = new RestRequest();
        req.requestURI = '/services/apexrest/ProductZoning/TP123';
        req.httpMethod = 'GET';
        RestContext.request = req;

        result = ProductZoningService.getPermissibleFlyZone();
        System.assertEquals('US Zone A', result);

        Test.stopTest();
    }
}
