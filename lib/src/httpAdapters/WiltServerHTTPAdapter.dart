/*
 * Packge : Wilt
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/06/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * Browser(dart:html) CouchDB HTTP adapter for Wilt.
 *  
 * This always returns a JSON Object the format of which is documented in
 * the Result Interface document
 *                      
 */

part of wiltServerClient;

class WiltServerHTTPAdapter implements WiltHTTPAdapter {


  /**
   * HTTP client
   */
  http.Client _client;

  /**
   *  Construction
   */
  WiltServerHTTPAdapter() {

    _client = new http.Client();
  }

  /**
   * Processes the HTTP request, returning the server's response
   * as a future
   */
  Future<jsonobject.JsonObject> httpRequest(String method, String url, [String
      data = null, Map headers = null]) {


    /**
     *  Initialise 
     */
    Completer completer = new Completer();


    /**
     * Successful completion
     */
    void onSuccess(http.Response response) {

      /**
       *  Process the success response, note that an error response from CouchDB is 
       *  treated as an error, not as a success with an 'error' field in it.
       */
      jsonobject.JsonObject jsonResponse = new jsonobject.JsonObject();
      jsonResponse.error = false;
      jsonResponse.errorCode = 0;
      jsonResponse.successText = null;
      jsonResponse.errorText = null;
      jsonResponse.allResponseHeader = null;
      jsonResponse.method = method;
      jsonResponse.responseText = response.body;

      /**
       * Check the header, if application/json try and decode it,
       * otherwise its just raw data, ie an attachment.
       */
      if (response.headers.containsValue('application/json')) {

        var couchResp;
        try {

          couchResp = JSON.decode(response.body);

        } catch (e) {

          jsonResponse.error = true;
          jsonobject.JsonObject errorAsJson = new jsonobject.JsonObject();
          errorAsJson.error = "JSON Decode Error";
          errorAsJson.reason = "None";
          jsonResponse.jsonCouchResponse = errorAsJson;
          /* Set the response headers */
          jsonResponse.allResponseHeaders = response.headers;
          /**
            * Complete the reequest
            */
          if (!completer.isCompleted) completer.complete(jsonResponse);

        }

        if ((couchResp is Map) && (couchResp.containsKey('error'))) {

          jsonResponse.error = true;
          jsonobject.JsonObject errorAsJson = new jsonobject.JsonObject();
          errorAsJson.error = "CouchDb Error";
          errorAsJson.reason = couchResp['reason'];
          jsonResponse.jsonCouchResponse = errorAsJson;
          /* Set the response headers */
          jsonResponse.allResponseHeaders = response.headers;
          /**
           * Complete the reequest
           */
          if (!completer.isCompleted) completer.complete(jsonResponse);

        }

        /**
         * Success response
         */
        if (method != Wilt.HEAD) {
          jsonobject.JsonObject successAsJson =
              new jsonobject.JsonObject.fromJsonString(response.body);
          jsonResponse.jsonCouchResponse = successAsJson;
        }


      } else {

        jsonobject.JsonObject successAsJson = new jsonobject.JsonObject();
        successAsJson.ok = true;
        successAsJson.contentType = response.headers['content-type'];
        jsonResponse.jsonCouchResponse = successAsJson;

      }


      /* Set the response headers */
      jsonResponse.allResponseHeaders = response.headers;
      /**
       * Complete the request
       */
      if (!completer.isCompleted) completer.complete(jsonResponse);


    }

    /**
     * Successful completion for Copy
    */
    void onCopySuccess(http.StreamedResponse response) {

      /**
       *  Process the success response, note that an error response from CouchDB is 
       *  treated as an error, not as a success with an 'error' field in it.
       */
      jsonobject.JsonObject jsonResponse = new jsonobject.JsonObject();
      jsonResponse.error = false;
      jsonResponse.errorCode = 0;
      jsonResponse.successText = null;
      jsonResponse.errorText = null;
      jsonResponse.allResponseHeader = null;
      jsonResponse.method = method;
      response.stream.bytesToString(UTF8).then((String text) {

        jsonResponse.responseText = text;

        /**
           * Check the header, if application/json try and decode it,
           * otherwise its just raw data, ie an attachment.
           */
        if (response.headers.containsValue('application/json')) {

          var couchResp;
          try {

            couchResp = JSON.decode(text);

          } catch (e) {

            jsonResponse.error = true;
            jsonobject.JsonObject errorAsJson = new jsonobject.JsonObject();
            errorAsJson.error = "JSON Decode Error";
            errorAsJson.reason = "None";
            jsonResponse.jsonCouchResponse = errorAsJson;
            /* Set the response headers */
            jsonResponse.allResponseHeaders = response.headers;
            /**
                * Complete the reequest
                */
            if (!completer.isCompleted) completer.complete(jsonResponse);

          }

          if ((couchResp is Map) && (couchResp.containsKey('error'))) {

            jsonResponse.error = true;
            jsonobject.JsonObject errorAsJson = new jsonobject.JsonObject();
            errorAsJson.error = "CouchDb Error";
            errorAsJson.reason = couchResp['reason'];
            jsonResponse.jsonCouchResponse = errorAsJson;
            /* Set the response headers */
            jsonResponse.allResponseHeaders = response.headers;
            /**
               * Complete the reequest
               */
            if (!completer.isCompleted) completer.complete(jsonResponse);

          }

          /**
             * Success response
             */
          if (method != Wilt.HEAD) {
            jsonobject.JsonObject successAsJson =
                new jsonobject.JsonObject.fromJsonString(text);
            jsonResponse.jsonCouchResponse = successAsJson;
          }


        } else {

          jsonobject.JsonObject successAsJson = new jsonobject.JsonObject();
          successAsJson.ok = true;
          successAsJson.contentType = response.headers['content-type'];
          jsonResponse.jsonCouchResponse = successAsJson;

        }


        /* Set the response headers */
        jsonResponse.allResponseHeaders = response.headers;
        
        /**
         * Complete the request
        */
        if (!completer.isCompleted) completer.complete(jsonResponse);

      });

    }

    /**
     * Error completion
     */
    void onError(HttpException response) {

      /* Process the error response */
      jsonobject.JsonObject jsonResponse = new jsonobject.JsonObject();
      jsonResponse.method = method;
      jsonResponse.error = true;
      jsonResponse.successText = null;
      jsonResponse.errorCode = 0;
      jsonobject.JsonObject errorAsJson = new jsonobject.JsonObject();
      errorAsJson.error = "Invalid HTTP response";
      errorAsJson.reason = response.message;
      jsonResponse.jsonCouchResponse = errorAsJson;

      /**
       * Complete the reequest
       */
      if (!completer.isCompleted) completer.complete(jsonResponse);

    }

    /**
     * Condition the input method string to get the HTTP method
     */
    List temp = method.split('_');
    String httpMethod = temp[0];

    /**
     * Set the content type header correctly
     */
    if (headers.containsKey('Content-Type')) {

      String contentType = headers['Content-Type'];
      headers.remove('Content-Type');
      headers['content-type'] = contentType;

    }
    /**
     *  Query CouchDB over HTTP 
     */
    if (httpMethod == "GET") {
      _client.get(url, headers: headers).then(onSuccess, onError: onError);
    } else if (httpMethod == "PUT") {
      _client.put(url, headers: headers, body: data).then(onSuccess, onError:
          onError);
    } else if (httpMethod == "POST") {
      _client.post(url, headers: headers, body: data).then(onSuccess, onError:
          onError);
    } else if (httpMethod == "HEAD") {
      _client.head(url, headers: headers).then(onSuccess, onError: onError);
    } else if (httpMethod == "DELETE") {
      _client.delete(url, headers: headers).then(onSuccess, onError: onError);
    } else if (httpMethod == "COPY") {
      Uri encodedUrl = Uri.parse(url);
      var request = new http.Request("COPY", encodedUrl);
      request.headers.addAll(headers);
      _client.send(request).then(onCopySuccess, onError: onError);
    }

    return completer.future;

  }

  /**
    *  Specialised get for change notifications
    */
  Future<String> getString(String url) {

    Completer completer = new Completer<String>();
    
    _client.get(url).then((response) {
      
      completer.complete(response.body);
      
    });

    return completer.future;
  }


}
