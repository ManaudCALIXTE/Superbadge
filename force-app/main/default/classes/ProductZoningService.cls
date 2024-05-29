@RestResource(urlMapping='/ProductZoning/*')
global with sharing class ProductZoningService {
    public static List<Product_Geo_Mapping__mdt> ProductGeoMappingWrapper;

    @HttpGet
    global static String getPermissibleFlyZone() {
        RestRequest req = RestContext.request;
        String countryCode = req.headers.get('CountryCode') != null ? req.headers.get('CountryCode') : 'US';
        
        // Extracting ProductCode from the URL path
        String productCode = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);

        if (productCode == null || productCode == '') {
            return 'ProductCode is missing or doesn\'t exist';
        }

        List<Product2> productList = [SELECT Family FROM Product2 WHERE ProductCode = :productCode LIMIT 1];
        if (productList.isEmpty() || productList[0].Family == null) {
            return 'Confirm with the local authorities';
        }

        String productFamily = productList[0].Family;

        List<Product_Geo_Mapping__mdt> mappingList;

        if (Test.isRunningTest() && ProductGeoMappingWrapper != null) {
            mappingList = ProductGeoMappingWrapper;
        } else {
            mappingList = [
                SELECT Product_Family__c, Country_Code__c, Permissible_Fly_Zone__c 
                FROM Product_Geo_Mapping__mdt 
                WHERE Product_Family__c = :productFamily AND Country_Code__c = :countryCode 
                LIMIT 1
            ];
        }

        if (mappingList.isEmpty()) {
            return 'Confirm with the local authorities';
        }

        Product_Geo_Mapping__mdt mapping = mappingList[0];

        if (mapping.Product_Family__c == productFamily && mapping.Country_Code__c == countryCode) {
            return mapping.Permissible_Fly_Zone__c;
        } else {
            return 'Confirm with the local authorities';
        }
    }
}
