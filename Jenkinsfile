import groovy.json.JsonSlurper

def getFtpPublishProfile(def publishProfilesJson) {
  def pubProfiles = new JsonSlurper().parseText(publishProfilesJson)
  for (p in pubProfiles)
    if (p['publishMethod'] == 'FTP')
      return [url: p.publishUrl, username: p.userName, password: p.userPWD]
}

node {
    def server
    def rtMaven = Artifactory.newMavenBuild()
    def buildInfo

    stage ('Checkout'){
        git branch: 'main', url: 'https://josepmaia@dev.azure.com/josepmaia/devops/_git/devops'
    }

    stage ('Artifactory configuration') {
        // Obtain an Artifactory server instance, defined in Jenkins --> Manage Jenkins --> Configure System:
        server = Artifactory.server "jfrog-instance"

        // Tool name from Jenkins configuration
        rtMaven.tool = "maven3.8.6"
        rtMaven.deployer releaseRepo: "generic-local", server: server
        buildInfo = Artifactory.newBuildInfo()
    }

    stage ('Exec Maven') {
        rtMaven.run pom: 'pom.xml', goals: 'package', buildInfo: buildInfo
    }

    stage ('Publish Artifact and build info') {
        server.publishBuildInfo buildInfo
        rtMaven.deployer.deployArtifacts buildInfo
        
    }

    stage ('Download Artifact') {
        def downloadSpec = """{
            "files": [
        {
          "pattern": "generic-local/Artifact/ArtifactSample/0.0.1/*.war",
          "target": "./",
          "regexp": "true"
        }
            ]
         }"""
        server.download spec: downloadSpec, buildInfo: buildInfo
        
    }

     stage ('Publish Azure') {
        withEnv(['AZURE_SUBSCRIPTION_ID=695c0f2b-286f-495e-9c3d-e1de78d5e8e5',
        'AZURE_TENANT_ID=5fcc37a4-d54b-4f1f-9137-60487ab3b53f']) {

            def resourceGroup = 'myapp-rg'
            def webAppName = 'testecenas123'
            // login Azure
            withCredentials([usernamePassword(credentialsId: 'jenkins-principal-credential', passwordVariable: 'd5j8Q~BeI5o9hQ3Smc5HE7PCD67xa5g77ts-6aQW', usernameVariable: '3efeafa9-afa0-416f-91b4-1c87da9df9e7')]) {
            sh '''
                az login --service-principal -u 3efeafa9-afa0-416f-91b4-1c87da9df9e7 -p d5j8Q~BeI5o9hQ3Smc5HE7PCD67xa5g77ts-6aQW -t $AZURE_TENANT_ID
                az account set -s $AZURE_SUBSCRIPTION_ID
                '''
            }
            // get publish setting
            def pubProfilesJson = sh script: "az webapp deployment list-publishing-profiles -g $resourceGroup -n $webAppName", returnStdout: true
            def ftpProfile = getFtpPublishProfile pubProfilesJson
            // upload package
            
            sh "az webapp deploy --resource-group myapp-rg --name testecenas123 --type war --src-path /var/jenkins_home/workspace/mavenV2/Artifact/ArtifactSample/0.0.1/ArtifactSample-0.0.1.war --restart true"
             //sh "unzip -o Artifact/ArtifactSample/0.0.1/ArtifactSample-0.0.1.war -d Artifact/ArtifactSample/0.0.1/JavaSample"
             //sh "find /var/jenkins_home/workspace/mavenV2/Artifact/ArtifactSample/0.0.1/JavaSample -exec curl --ftp-create-dirs -T {} /var/jenkins_home/workspace/mavenV2/Artifact/ArtifactSample/0.0.1/JavaSample/ $ftpProfile.url/webapps/ -u '$ftpProfile.username:$ftpProfile.password' '\';"
             //sh "sh /var/jenkins_home/workspace/uploadPackage.sh $ftpProfile.url $ftpProfile.username $ftpProfile.password"
             // sh "curl -T /var/jenkins_home/workspace/mavenV2/Artifact/ArtifactSample/0.0.1/ROOT.war $ftpProfile.url/webapps/ -u '$ftpProfile.username:$ftpProfile.password'"
            // log out
            sh 'az logout'
        }       
    }
}