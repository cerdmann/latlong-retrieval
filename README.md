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
