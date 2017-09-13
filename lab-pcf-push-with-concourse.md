# Lab - Push your App with Concourse

## High Level Objectives
* Learn how to continuously deploy an application to Pivotal Cloud Foundry

## Prerequisites
* Ensure you have a [Github](https://github.com) account
* Know the *api* endpoint for the Pivotal Cloud Foundry you are targeting. It will typically look like this: ```https://api.system.pcf.pcfonazure.com```, and will be referenced in this lab as [PCF-API endpoint]
* Know the Pivotal Cloud Foundry *Apps Manager* endpoint to view the status of your apps in your browser. It will typically look like this: ```https://apps.system.pcf.pcfonazure.com```, and will be referenced in this lab as [PCF Apps Manager endpoint]
* Know the Concourse URI. It will be referenced in this lab as [Concourse URI]
* Know your Concourse team name. It will be referenced in this lab as [Concourse team]
* Know your Concourse username. It will be referenced in this lab as [Concourse username]
* Know your Concourse users password. It will be referenced in this lab as [Concourse password]
* Know your Pivotal Cloud Foundry CI username. It will be referenced in this lab as [PCF CI username]
* Know your Pivotal Cloud Foundry CI users password. It will be referenced in this lab as [PCF CI password]

#### Steps

1. Add versioning through Concourse
  * We will be using Github releases in this lab. To do, that we need to update a version number for each build of the application. Eventually this should be retrofitted into the gradle build process for our app, but we will skip that for now
  * We will be using the [semver resource](https://github.com/concourse/semver-resource) to bump our version numbers
  * To use the git driver, we need to setup a special branch of our repository to hold the version number. We will use the steps outlined in this [Stark and Wayne](https://github.com/starkandwayne/concourse-tutorial/tree/master/20_versions_and_buildnumbers#setup-with-a-git-branch) tutorial.
  * At your command line, at the root of your *lab* application, use the following commands to create an orphaned branch to hold the version information:

    ```
    git checkout --orphan version
    git rm --cached -r .
    rm -rf *
    rm .gitignore
    rm -rf .gradle
    rm .gitattributes
    touch README.md
    git add .
    git commit -m "new versioning branch"
    git push origin version
    git checkout master
    ```

  * The semver resource will pull the latest version from our new branch, increment it, and then push the new number back. Each build of the app through the pipeline will result in a new release version saved to Github releases.
  * In order to accomplish this, the semver resource needs a private key to access Github (for the pushes). Please generate an ssh key and save it to your Github account by following [these](https://help.github.com/articles/connecting-to-github-with-ssh/) steps
    * Follow the [Generating a new SSH key...](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) link.
      * Name the key *concourse* and save it in a directory higher than your *lab* application directory
      * Make sure you hit *enter* (no passphrase) when asked to *Enter your passphrase*
      * Skip the *Adding your SSH key to the ssh-agent* part
    * Follow the [Adding a new SSH key to your Github account](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)
      * In the Title field, enter *Concourse versioning key* so you know the purpose of the key
    * If necessary, move the keys out of the *lab* application directory. We do not want to check those into a repository. You should have two keys, a public (\*.pub) and a private key
  * Add a semver resource to your ```pipeline.yml```. Update your ```pipeline.yml``` to look like this:

    ```
    resources:
      - name: git-repo
        type: git
        source:
          uri: {{git-repo}}
          branch: {{git-repo-branch}}

      - name: resource-version
        type: semver
        source:
          driver: git
          uri: {{git-repo-ssh-address}}
          branch: version
          file: version
          private_key: {{git-ssh-key}}
          git_user: {{git-user-email}}
          initial_version: 0.0.1

    jobs:
      - name: build
        plan:
          - get: git-repo
            trigger: true
          - get: resource-version
            params: {bump: patch}
          - task: build
            file: git-repo/ci/tasks/build.yml
          - put: resource-version
            params: {file: resource-version/version}
    ```

  * We also need to update our credential file for the new placeholders. In your concourse-config add the following, replacing the brackets with your information:

    ```
    git-repo: [URI-OF-GITHUB-REPO]
    git-repo-branch: master
    git-repo-ssh-address: [SSH-ADDRESS-OF-GITHUB-REPO]
    git-user-email: [PUT-GITHUB-EMAIL-HERE]
    git-ssh-key: |
      -----BEGIN RSA PRIVATE KEY-----
      YOUR
      MULTILINE
      GITHUB
      SSH
      KEY
      HERE
      -----END RSA PRIVATE KEY-----
    ```

    Make sure you copy your private key and indent each line 2 spaces. The SSH address can be found on the main Github page for your repo under *Clone or Download*
1. Push the new pipeline and try out the versioning
  * At your command line, from the root of your *lab* application. Execute the following command:

  ```
  fly -t ci set-pipeline -p lab-application -c ./ci/pipeline.yml -l ../concourse-config.yml
  ```

  * Go to your browser and click on the *build* box. In the upper right hand corner, you will see a **+** sign which will trigger the build. Press it
  * Go to your repo on Github and select the version branch
  * You should see a new file called *version* with 0.0.2 in it
  * Click the build box in Concourse a few times and see the version increment
1. Push your new commits to Github
  * Perform a ```git status```. Make sure your public and private keys have not made it into *lab* directory
  * Push your changes

  ```
  git add .
  git commit -m "Added semver to the pipeline"
  git push origin master
  ```

1. Push artifacts to Github releases
  * To push our artifacts to Github releases, we will use the [github-release](https://github.com/concourse/github-release-resource) resource
  * At the end of this step, we will have a versioned resource that we can push to Pivotal Cloud Foundry
  * This resource uses a Github API access key. Before we proceed we need to create one following [these](https://help.github.com/articles/creating-an-access-token-for-command-line-use/) steps
    * Name your token *Concourse release token*
    * Only grant the token *repo* scope
    * Copy the token to the clipboard and paste it locally outside of the *lab* directory. Once you leave the page, you will not be able to see the token again. If you lose the token, please delete the old one and create a new one
  * Modify your ```pipeline.yml``` file to include the new resource and reference it from the *build* job
    * The *put* task of the job will create the release for you from various files in your *artifact* directory. We will modify the ```build.sh``` after this to ensure those files are created
    * Your ```pipeline.yml``` should look like this:

      ```
      resources:
        - name: git-repo
          type: git
          source:
            uri: {{git-repo}}
            branch: {{git-repo-branch}}

        - name: resource-version
          type: semver
          source:
            driver: git
            uri: {{git-repo-ssh-address}}
            branch: version
            file: version
            private_key: {{git-ssh-key}}
            git_user: {{git-user-email}}
            initial_version: 0.0.1

        - name: gh-release
          type: github-release
          source:
            repository: {{git-repo-name}}
            user: {{git-user}}
            access_token: {{git-access-token}}

      jobs:
        - name: build
          plan:
            - get: git-repo
              trigger: true
            - get: resource-version
              params: {bump: patch}
            - task: build
              file: git-repo/ci/tasks/build.yml
            - put: resource-version
              params: {file: resource-version/version}
            - put: gh-release
              params:
                name: artifact/release_name.txt
                tag: resource-version/number
                body: artifact/release_notes.md
                commitish: artifact/release_commitish.txt
                globs:
                - artifact/lab*.jar
                - artifact/manifest.yml
      ```

    * We need to create some files for the *params* portion of the release push
      * ```release_name.txt``` - The release name
      * ```resource-version/number``` - This will pull in the bumped version number from the semver resource
      * ```release_notes.md``` - We can pass the commit notes to the release and they can act as our release notes
      * ```artifact/release_commitish.txt``` - The commit hash to associate with the release
      * *globs* - The files to push to Github
  * We also need to update our credential file for the new placeholders. In your concourse-config add the following, replacing the brackets with your information:

    ```
    git-repo: [URI-OF-GITHUB-REPO]
    git-repo-branch: master
    git-repo-ssh-address: [SSH-ADDRESS-OF-GITHUB-REPO]
    git-user-email: [PUT-GITHUB-EMAIL-HERE]
    git-ssh-key: |
      -----BEGIN RSA PRIVATE KEY-----
      YOUR
      MULTILINE
      GITHUB
      SSH
      KEY
      HERE
      -----END RSA PRIVATE KEY-----
    git-user: [GITHUB-USER-NAME]
    git-repo-name: [GITHUB-REPO-NAME]
    git-access-token: CREATE-A-GITHUB-ACCESS-TOKEN-AND-ADD-HERE
    ```

  * We need to modify our ```build.sh``` to create the files mentioned above. Modify your ```build.sh``` to look like this:

    ```
    #!/usr/bin/env bash

    set -e
    export TERM=${TERM:-dumb}

    echo "=============================================="
    echo "Beginning build of Spring Boot application"
    echo "$(java -version)"
    echo "$(gradle -version)"
    echo "=============================================="

    cd git-repo

    ./gradlew clean build

    ARTIFACT=$(cd ./build/libs && ls latlong-retrieval*.jar)
    COMMIT=$(git rev-parse HEAD)

    echo $ARTIFACT > ../artifact/release_name.txt
    echo $(git log --format=%B -n 1 $COMMIT) > ../artifact/release_notes.md
    echo $COMMIT > ../artifact/release_commitish.txt

    cp ./build/libs/$ARTIFACT ../artifact
    cp ./manifest.yml ../artifact

    echo "----------------------------------------------"
    echo "Build Complete"
    ls -lah ../artifact
    echo "----------------------------------------------"
    ```

1. Push your new commits to Github
  * Perform a ```git status```. Make sure your api key did not make it into the *lab* directory
  * Push your changes

  ```
  git add .
  git commit -m "Added git-release to the pipeline"
  git push origin master
  ```

1. Push the new pipeline and try out the release
  * At your command line, from the root of your *lab* application. Execute the following command:

  ```
  fly -t ci set-pipeline -p lab-application -c ./ci/pipeline.yml -l ../concourse-config.yml
  ```

  * Go to your browser and click on the *build* box. In the upper right hand corner, you will see a **+** sign which will trigger the build. Press it
  * Go to your repo on Github and click on on *release*
  * You should see a new release with the proper version, pushed to Github from your pipeline
  * Click the build box in Concourse a few times and see new releases appear
1. We need to create a new manifest for the release for our dev process.
  * When we pull the release artifacts back from Github, the JAR will be in the root of the directory. Our current manifest looks for the artifact in the ```buid/libs``` directory. We will create a new manifest called ```concourse-dev-manifest.yml``` and place it in the root of our *lab* directory.
  * Add the following content to the new file:

    ```
    ---
    applications:
    - name: lab-application
      random-route: true
      memory: 512M
      disk: 1G
      instances: 2
      path: ./lab-0.0.1-SNAPSHOT.jar
    ```

    A better solution will be to use a script to modify the manifest based on the name of the artifact. Right now we are keeping the name of the artifact consistent. As soon as we change the name of it, the manifests will break

  * We will replace the ```manifest.yml``` we copied in the ```build.sh``` with the new file. Update your ```build.sh``` with the following:

    ```
    #!/usr/bin/env bash

    set -e
    export TERM=${TERM:-dumb}

    echo "=============================================="
    echo "Beginning build of Spring Boot application"
    echo "$(java -version)"
    echo "$(gradle -version)"
    echo "=============================================="

    cd git-repo

    ./gradlew clean build

    ARTIFACT=$(cd ./build/libs && ls lab*.jar)
    COMMIT=$(git rev-parse HEAD)

    echo $ARTIFACT > ../artifact/release_name.txt
    echo $(git log --format=%B -n 1 $COMMIT) > ../artifact/release_notes.md
    echo $COMMIT > ../artifact/release_commitish.txt

    cp ./build/libs/$ARTIFACT ../artifact
    cp ./concourse-dev-manifest.yml ../artifact

    echo "----------------------------------------------"
    echo "Build Complete"
    ls -lah ../artifact
    echo "----------------------------------------------"
    ```

1. Now we will update the pipeline and introduce the [cf](https://github.com/concourse/cf-resource) resource
  * Add the resource and create a new job which will deploy to the development space
  * We will be using information specified in the setup to this Lab for accessing Pivotal Cloud Foundry
  * When we add the new deploy job, we will trigger it off of a successful build. We want this deploy to happen automatically once the build completes. Our future pushes to stage and prod will be triggered by a click
  * We will also set both jobs up in a serial group so that they will not kick off independently
  * Modify your ```pipeline.yml``` to look like this:

    ```
    resources:
      - name: git-repo
        type: git
        source:
          uri: {{git-repo}}
          branch: {{git-repo-branch}}

      - name: resource-version
        type: semver
        source:
          driver: git
          uri: {{git-repo-ssh-address}}
          branch: version
          file: version
          private_key: {{git-ssh-key}}
          git_user: {{git-user-email}}
          initial_version: 0.0.1

      - name: gh-release
        type: github-release
        source:
          repository: {{git-repo-name}}
          user: {{git-user}}
          access_token: {{git-access-token}}

      - name: deploy-dev
        type: cf
        source:
          api: {{cf-api}}
          username: {{cf-username}}
          password: {{cf-password}}
          organization: {{cf-org}}
          space: {{cf-dev-space}}
          skip_cert_check: true

    jobs:
      - name: build
        serial_groups: [resource-version]
        plan:
          - get: git-repo
            trigger: true
          - get: resource-version
            params: {bump: patch}
          - task: build
            file: git-repo/ci/tasks/build.yml
          - put: resource-version
            params: {file: resource-version/version}
          - put: gh-release
            params:
              name: artifact/release_name.txt
              tag: resource-version/number
              body: artifact/release_notes.md
              commitish: artifact/release_commitish.txt
              globs:
              - artifact/lab*.jar
              - artifact/concourse-dev-manifest.yml

      - name: deploy-dev
        serial_groups: [resource-version]
        plan:
          - aggregate:
            - get: gh-release
              trigger: true
              passed: [build]
          - put: deploy-dev
            params:
              manifest: gh-release/concourse-dev-manifest.yml
              current_app_name: lab-application
              path: gh-release
    ```

  * Update the credential file for the new placeholders. In your concourse-config add the following, replacing the brackets with your information:

    ```
    git-repo: [URI-OF-GITHUB-REPO]
    git-repo-branch: master
    git-repo-ssh-address: [SSH-ADDRESS-OF-GITHUB-REPO]
    git-user-email: [PUT-GITHUB-EMAIL-HERE]
    git-ssh-key: |
      -----BEGIN RSA PRIVATE KEY-----
      YOUR
      MULTILINE
      GITHUB
      SSH
      KEY
      HERE
      -----END RSA PRIVATE KEY-----
    git-user: [GITHUB-USER-NAME]
    git-repo-name: [GITHUB-REPO-NAME]
    git-access-token: [CREATE-A-GITHUB-ACCESS-TOKEN-AND-ADD-HERE]
    cf-api: [PCF-API endpoint]
    cf-username: [PCF CI username]
    cf-password: [PCF CI password]
    cf-org: [CLOUD-FOUNDRY-ORG]
    cf-dev-space: [CLOUD-FOUNDRY-DEV-SPACE-NAME]
    ```

1. Push your new commits to Github
  * Push your changes

  ```
  git add .
  git commit -m "Added push to Pivotal Cloud Foundry to the pipeline"
  git push origin master
  ```

1. Push the new pipeline and try out the push to Pivotal Cloud Foundry
  * At your command line, from the root of your *lab* application. Execute the following command:

  ```
  fly -t ci set-pipeline -p lab-application -c ./ci/pipeline.yml -l ../concourse-config.yml
  ```

  * Go to your browser and click on the *build* box. In the upper right hand corner, you will see a **+** sign which will trigger the build. Press it
  * Go to the Pivotal Cloud Foundry Apps Manager API [PCF Apps Manager endpoint] in your browser. Observe the uptime of your app to see that it has recently been modified. If you are monitoring your app in the Apps Manager while Concourse is deploying it, you might see 2 applications. This is because the *cf* resource will perform a blue-green deploy of your app
  * Try modifying the message your app displays in the *HelloController*. Push the change to Github, and watch the pipeline automatically pick up your change and deploy it.
1. Next we are going to add the steps to deploy to both staging and prod
  * These will not be triggered deploys, but will require you to click on the build in the pipeline to trigger them
  * You could automate this step through slack, or with Pivotal Tracker, but for this workshop, we will rely on manually clicking to push to stage and prod
  * We are also using the same manifests from dev for stage and prod. These could be customized for each environment. You would need to add a copy step for them to your ```build.sh```
  * Modify your ```pipeline.yml``` to look like this:

    ```
    resources:
      - name: git-repo
        type: git
        source:
          uri: {{git-repo}}
          branch: {{git-repo-branch}}

      - name: resource-version
        type: semver
        source:
          driver: git
          uri: {{git-repo-ssh-address}}
          branch: version
          file: version
          private_key: {{git-ssh-key}}
          git_user: {{git-user-email}}
          initial_version: 0.0.1

      - name: gh-release
        type: github-release
        source:
          repository: {{git-repo-name}}
          user: {{git-user}}
          access_token: {{git-access-token}}

      - name: deploy-dev
        type: cf
        source:
          api: {{cf-api}}
          username: {{cf-username}}
          password: {{cf-password}}
          organization: {{cf-org}}
          space: {{cf-dev-space}}
          skip_cert_check: true

      - name: deploy-stage
        type: cf
        source:
          api: {{cf-api}}
          username: {{cf-username}}
          password: {{cf-password}}
          organization: {{cf-org}}
          space: {{cf-stage-space}}
          skip_cert_check: true

      - name: deploy-prod
        type: cf
        source:
          api: {{cf-api}}
          username: {{cf-username}}
          password: {{cf-password}}
          organization: {{cf-org}}
          space: {{cf-prod-space}}
          skip_cert_check: true

    jobs:
      - name: build
        serial_groups: [resource-version]
        plan:
          - get: git-repo
            trigger: true
          - get: resource-version
            params: {bump: patch}
          - task: build
            file: git-repo/ci/tasks/build.yml
          - put: resource-version
            params: {file: resource-version/version}
          - put: gh-release
            params:
              name: artifact/release_name.txt
              tag: resource-version/number
              body: artifact/release_notes.md
              commitish: artifact/release_commitish.txt
              globs:
              - artifact/lab*.jar
              - artifact/concourse-dev-manifest.yml

      - name: deploy-dev
        serial_groups: [resource-version]
        plan:
          - aggregate:
            - get: gh-release
              trigger: true
              passed: [build]
          - put: deploy-dev
            params:
              manifest: gh-release/concourse-dev-manifest.yml
              current_app_name: lab-application
              path: gh-release

      - name: deploy-stage
        serial_groups: [resource-version]
        plan:
          - aggregate:
            - get: gh-release
              passed: [deploy-dev]
          - put: deploy-stage
            params:
              manifest: gh-release/concourse-dev-manifest.yml
              current_app_name: lab-application
              path: gh-release

      - name: deploy-prod
        serial_groups: [resource-version]
        plan:
          - aggregate:
            - get: gh-release
              passed: [deploy-stage]
          - put: deploy-prod
            params:
              manifest: gh-release/concourse-dev-manifest.yml
              current_app_name: lab-application
              path: gh-release
    ```

  * Update the credential file for the new placeholders. In your concourse-config add the following, replacing the brackets with your information:

    ```
    git-repo: [URI-OF-GITHUB-REPO]
    git-repo-branch: master
    git-repo-ssh-address: [SSH-ADDRESS-OF-GITHUB-REPO]
    git-user-email: [PUT-GITHUB-EMAIL-HERE]
    git-ssh-key: |
      -----BEGIN RSA PRIVATE KEY-----
      YOUR
      MULTILINE
      GITHUB
      SSH
      KEY
      HERE
      -----END RSA PRIVATE KEY-----
    git-user: [GITHUB-USER-NAME]
    git-repo-name: [GITHUB-REPO-NAME]
    git-access-token: [CREATE-A-GITHUB-ACCESS-TOKEN-AND-ADD-HERE]
    cf-api: [PCF-API endpoint]
    cf-username: [PCF CI username]
    cf-password: [PCF CI password]
    cf-org: [CLOUD-FOUNDRY-ORG]
    cf-dev-space: [CLOUD-FOUNDRY-DEV-SPACE-NAME]
    cf-stage-space: [CLOUD-FOUNDRY-STAGE-SPACE-NAME]
    cf-prod-space: [CLOUD-FOUNDRY-PROD-SPACE-NAME]
    ```

1. Push your new commits to Github
  * Push your changes

  ```
  git add .
  git commit -m "Added push to Pivotal Cloud Foundry stage and prod to the pipeline"
  git push origin master
  ```

1. Push the new pipeline and try out the push to Pivotal Cloud Foundry
  * At your command line, from the root of your *lab* application. Execute the following command:

  ```
  fly -t ci set-pipeline -p lab-application -c ./ci/pipeline.yml -l ../concourse-config.yml
  ```

  * Trigger your build manually through the web app, or by making a change to your code
  * In the Concourse Web App, you will see a dotted line connecting *deply-dev* and *deploy-stage* and *deploy-prod*. This means that you must manually trigger these jobs
  * Click on the build for *deploy-stage*. Once that is finished, click on the build for *deploy-prod*
  * Go to the Pivotal Cloud Foundry Apps Manager API [PCF Apps Manager endpoint] in your browser. Observe that the app has been pushed to each space/environment. These could easily be different orgs or even completely different foundries. Try out the urls for each
  * **Congratulations**, you now have a complete pipeline to continuously deliver your applications

    ![alt text](screenshots/pipeline-complete.png "Pipeline complete")
