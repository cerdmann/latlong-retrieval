# Basic Spring Boot Web API Lab

## High Level Objectives
* Learn how to use [Spring Initializr](https://start.spring.io)
* Ensure you have git setup and have a [GitHub](https://github.com) account
* Create a simple Web API with Spring Boot
* Learn about the Application Metrics available to you with Spring Actuator

## Prerequisites

#### Helpful knowledge:
* Spring Framework/Core
* Spring Web
* git

#### Your local environment and supporting services:
* [Java](http://www.oracle.com/technetwork/java/javase/downloads/index.html) (Be sure to download and install the **JDK**, not the JRE.)
  * try ```java -version``` at a command prompt to see what you are running. Any 1.8 should allow you to complete this lab
* An IDE
  * [Atom](https://atom.io/)
* [Gradle](https://gradle.org/gradle-download/)
* [Chrome](https://www.google.com/chrome/)
  * [Postman Plugin](https://www.getpostman.com/docs/introduction)
  * [JSON Formatter Plugin](https://chrome.google.com/webstore/detail/json-formatter/bcjindcccaagfpapjjmafapmmgkkhgoa)* Download a code editor:
* Login or create a GitHub account at https://github.com

## Initial Project Creation

* Establish a new Spring Boot project at: https://start.spring.io/
  * Generate a : **Gradle Project**
  * with: **Java**
  * and Spring Boot **1.5.6**
  * Group: **com.example**
  * Artifact: **latlong-retrieval**
  * Dependencies: Web, Hateoas, Actuator, Lombok
  * Click **Generate Project** and unzip the file into a project directory
  * Navigate to your new directory


* Open up your folder in the Atom IDE

* Push our application to Github
  * Login to your Github account and create a new repository called ```latlong-retrieval```. Initialize it with a README.md and the appropriate license. Do not add a *.gitignore* as the Spring Initializer already created one for us
  * We need to ensure line endings are handled appropriately whether you are using windows, linux, or osx
    * At the root of your *Lab* directory, create a new file called ```.gitattributes```
    * Add the following contents to the file:

      ```
      # Handle line endings automatically for files detected as text
      # and leave all files detected as binary untouched.
      * text=auto

      #
      # The above will handle all files NOT found below
      #
      # These files are text and should be normalized (Convert crlf => lf)
      *.css           text
      *.df            text
      *.htm           text
      *.html          text
      *.java          text
      *.js            text
      *.json          text
      *.jsp           text
      *.jspf          text
      *.jspx          text
      *.properties    text
      *.sh            text
      *.tld           text
      *.txt           text
      *.tag           text
      *.tagx          text
      *.xml           text
      *.yml           text

      # These files are binary and should be left untouched
      # (binary is a macro for -text -diff)
      *.class         binary
      *.dll           binary
      *.ear           binary
      *.gif           binary
      *.ico           binary
      *.jar           binary
      *.jpg           binary
      *.jpeg          binary
      *.png           binary
      *.so            binary
      *.war           binary
      ```


* In the root of your application, execute the following command to initialize a git repo: ```git init```

* Replace your .gitignore file
  * Browse to https://www.gitignore.io/
  * In the text box enter the following and hit create:
    * vim
    * macos
    * windows
    * java
    * gradle
    * intellij
    * eclipse
  * Copy the resulting text from the web page and replace the existing contents in the **.gitignore** file in your directory


* We will now associate our local git repo with our newly create Github repo and check in our newly created project
  * Grab the https or ssh location from the **Clone or download** button on your Github repo page
  * Execute the following command at the root of your lab directory:

    ```
    git remote add origin [https or ssh location from the last step]
    ```

    i.e.

    ```
    git remote add origin https://github.com/cerdmann/latlong-retrieval```

  * Pull the README.md and license file from Github

    ```
    git pull origin master
      ```

    There should be no conflicts to merge.

  * Add our files to the Github repo
    * See the files that you will commit with ```git status```
    * Add the files to your commit with ```git add .``` (You can be more selective. This will add all the files to the commit)
    * Commit the files with ```git commit -m "Initial Commit"```
    * Push the files to Github: ```git push origin master```


* Add new latitude and longitude retrieval by zip code functionality
  * Edit the *build.gradle* file found in the root of the lab directory to replace this code:

    ```
    .
    .
    .
    apply plugin: 'org.springframework.boot'

    version = '0.0.1-SNAPSHOT'
    sourceCompatibility = 1.8
    .
    .
    .
    ```

    with this

    ```
    .
    .
    .
    apply plugin: 'org.springframework.boot'

    jar {
      baseName = 'latlong-retrieval'
      version = '0.0.1-SNAPSHOT'
    }

    sourceCompatibility = 1.8
    .
    .
    .
    ```
  * We are going to use [Zippopatam.us](http://www.zippopotam.us/) to grab the latitude and longitude for a zipcode. Browse to the site and **Try It Out**. Pay particular attention to the JSON return format. We will need to consume it:
    ```json
    {
      "post code": "90210",
      "country": "United States",
      "country abbreviation": "US",
      "places": [
        {
          "place name": "Beverly Hills",
          "longitude": "-118.4065",
          "state": "California",
          "state abbreviation": "CA",
          "latitude": "34.0901"
        }
      ]
    }
    ```

    Notice that *places* holds an array of objects. We will need to create a type to hold the inner data, and another type to hold the outer data
  * We'll need to create a few classes to use to deserialize the returned JSON.
  Under **src** -> **main** -> **java** -> **com** -> **example** -> **latlongretrieval**, create a new java class named *Place.java* to deserialize the inner array of the returned JSON.  
  * We will use [lombok](https://projectlombok.org/) in order to keep our code concise, and Jackson to handle the deserialization for us. Type or paste in the following code:
    ```java
    package com.example.latlongretrieval;

    import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
    import com.fasterxml.jackson.annotation.JsonProperty;
    import lombok.Data;

    @JsonIgnoreProperties(ignoreUnknown = true)
    @Data
    public class Place {

      @JsonProperty(value = "place name")
      private String name;

      @JsonProperty(value = "longitude")
      private double longitude;

      @JsonProperty(value = "state abbreviation")
      private String state;

      @JsonProperty(value = "latitude")
      private double latitude;
    }
    ```

  * We will use the same libraries to create a type for the outer JSON container. In the same folder as above, create another class named *PostCode.java*. Type or paste in the following code:
    ```java
    package com.example.latlongretrieval;

    import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
    import com.fasterxml.jackson.annotation.JsonProperty;
    import com.example.latlongretrieval.Place;
    import java.util.*;
    import lombok.Data;

    @JsonIgnoreProperties(ignoreUnknown = true)
    @Data
    public class PostCode{

      @JsonProperty(value = "post code")
      private String postCode;

      @JsonProperty(value = "country")
      private String country;

      @JsonProperty(value = "places")
      private List<Place> places;
    }
    ```
  * We also need a type to define our return json from our API. In the same folder as above, create another class named *LatLong.java*. Type or paste in the following code:
    ```java
    package com.example.latlongretrieval;

    import lombok.Data;

    @Data
    public class LatLong {

      private String city;
      private double longitude;
      private String state;
      private double latitude;
      private String zipcode;
      private String country;

      public LatLong( String city, double longitude, String state,
                      double latitude, String zipCode, String country) {
        this.city = city;
        this.longitude = longitude;
        this.state = state;
        this.latitude = latitude;
        this.zipcode = zipCode;
        this.country = country;
      }

    }
    ```
  * Finally, we need a controller to process the incoming request. We should probably break the call out to zippopotamus into a service, but i'll leave that as a follow on exercise for you. Create another class named *LatLongController.java*. Type or paste in the following code:
    ```java
    package com.example.latlongretrieval;

    import org.springframework.web.bind.annotation.PathVariable;
    import org.springframework.web.bind.annotation.RestController;
    import org.springframework.web.bind.annotation.RequestMapping;
    import org.springframework.web.client.RestTemplate;
    import org.springframework.http.ResponseEntity;
    import org.springframework.web.client.HttpStatusCodeException;
    import java.util.*;

    @RestController
    public class LatLongController {

      @RequestMapping("byzip/{zipcode}")
      public LatLong findByZipCode(@PathVariable("zipcode") String zipCode) {

        PostCode apiResponse = getZippopotamusResponse(zipCode);

        String zip = apiResponse.getPostCode();
        Optional<Place> optional = apiResponse.getPlaces().stream().findFirst();

        Place place = optional.orElse(new Place());

        return new LatLong(place.getName(), place.getLongitude(), place.getState(),
                           place.getLatitude(), apiResponse.getPostCode(),
                           apiResponse.getCountry());
      }

      private PostCode getZippopotamusResponse(String zipCode) {

        RestTemplate restTemplate = new RestTemplate();
        String url = "http://api.zippopotam.us/us/" + zipCode;

        PostCode apiResponse;

        try {
          apiResponse = restTemplate.getForObject(url, PostCode.class);
        } catch (HttpStatusCodeException exception) {

          List<Place> places = new ArrayList<Place>();
          places.add(new Place());

          apiResponse = new PostCode();
          apiResponse.setPostCode(zipCode);
          apiResponse.setPlaces(places);
        }

        return apiResponse;

      }
    }
    ```

    You can see that we are using a RestTemplate to get responses from our downstream zippopotamus service. We are also looking for any errors and returning an empty result so we can respond to our callers with a response.

  * Let's try out our new API
    * Open up a terminal window or command prompt and navigate to root of the directory you downloaded from Spring Initializer.
    * Depending on your operating system, perform one of the following to start the application:
      * Mac/Linux: ```./gradlew bootRun```
      * Windows: ```gradlew bootRun```
    * The Spring Initializer sets the port to 8080. Therefore, visit: [localhost:8080/byzip/12345](http://localhost:8080/byzip/12345) to view the output from your endpoint. You should see a response with the latitude and longitude of the zipcode.
    * Also try: [localhost:8080/byzip/99999](http://localhost:8080/byzip/99999) to view the output when you give a bogus zipCode.
* Once we've tested our application, let's push our new code to GitHub. Again, in the root of your *lab* application, execute the following commands to push your work:

  ```
  git add .
  ```

  On Windows, we need to ensure that the executable bit is flipped on a few of our files:
  ```
  git update-index --chmod=+x ci/scripts/build.sh
  git update-index --chmod=+x gradlew
  ```

  On either operating system, complete the following steps:

  ```
  git commit -m "Added build step to concourse pipeline."
  git push origin master
  ```
    
