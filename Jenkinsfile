node('docker') {
    stage('Init') {
        deleteDir()
        checkout scm
    }

    publish = false
    utils = load 'dev/jenkins/utils.groovy'

    magentoVersions = utils.getVersions('git://github.com/openmage/magento-mirror', env.MAGENTO_VERSION_CONSTRAINT ?: "1.[1].[1].[1]:latest")
    magento2Versions = utils.getVersions('https://github.com/magento/magento2', env.MAGENTO2_VERSION_CONSTRAINT ?: "2.[1].[1]:latest")

    pipeline = load 'dev/jenkins/build.groovy'
}

pipeline.pipeline()
