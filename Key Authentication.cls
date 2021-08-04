@future(callout=true) #if calling from a trigger
public class KeyAuthCallout {
    public void basicAuthCallout(Id recordId){
        String endpoint = System.Label.XYZ;
        String key = System.Label.XYX_Key
        
        Account accRec = {Select Id, Name, ShippingState, ShippingStreet, ShippingCode, zipCode, Latitude, Longitude where Id =:recordId}
        String address = accRec.ShippingStreet+','+accRec.ShippingCode+','+accRec.ShippingState;
        String encodedString = EncodingUtil.urlEncode(address, 'UTF-8');
        String finalendpoint = endpoint+'&key='+key+'&q='+encodedString+'&Limit=1&pretty=1';

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json')
        req.setMethod('GET');
        req.setEndpoint(finalendpoint);
        
        
        
        try{
            HTTPResponse response = http.send(req);
            if(response.getStatusCode() == 200)
            {
                System.debug();
                system.debug(System.LoggingLevel.DEBUG, 'Body '+response.getBody());
                JSONWrapper responseWrapper = JSONWrapper.parse(response.getBody());
                System.debug('Zip Code -> ' + responseWrapper.zipCode);
                list<responseWrapper.blogs> results = responseWrapper.blogs;
                if(results!=null && !results.isEmpty()) 
                {
                    JSONWrapper.results result = results.get(0);
                    System.debug('Latitude -> ' + result.Latitude);
                    System.debug('Longitude -> ' + result.Longitude);
                    accRec.Latitude = result.Latitude;
                    accRec.Longitude = result.Longitude;
                    update accRec;
                }        
        }
        catch(System.Exception e)
        {
        if(String.Valueof(e.getMessage()).startsWith('Unauthorized Endpoint')){
            errorMessage = 'Unauthorized endpoint: An Administrator must go to setup -> Administer -> Security Control -> Remote Site Settings and add '
            + endpoint +' Endpoint';            
        }
        else{
            errorMessage = 'Unexpected Error while communicating with XYZ. '+ 'Status '+ response.getStatus() +'and Status Code'+response.getStatusCode();
        }
        system.debug(System.LoggingLevel.DEBUG, 'Exception Executed '+errorMessage);
        }
        
        
        
        
    }
}
public class JSONWrapper 
{
    public class results 
    {
        public String Latitude;
        public String Longitude;
    }

    public String zipCode;
    public List<results> results;

    public static JSONWrapper parse(String json) 
    {
        return (JSONWrapper)System.JSON.deserialize(json, JSONWrapper.class);
    }
}
