# Moving from the Sonatype OSSRH artifact publishing process to the Central Repository artifact publishing

## Add a <server> section in settings.xml to configure the central server credentials

Publishing credentials obtained from the central repo portal need to be placed in a server configuration that can be
 references by the maven plugins involved in publishing the artifacts.  The value in the `<id>` element will be referred
 to by plugin configurations in the pom.xml file.

```
<server>
    <id>sonatype-central-portal</id>
    <username>CENTRAL_REPO_USERNAME</username>
    <password>CENTRAL_REPO_PASSWORD</password>
</server>
```

## Add a version property for the central publishing plugin

Add a central-publishing-maven-plugin.version property to the pom.xml file to hold a value for the central publishing
 maven plugin version.  This will be used by the plugin declaration elsewhere in the pom.xml file.

```
<properties>
    ...
    <central-publishing-maven-plugin.version>0.7.0</central-publishing-maven-plugin.version>
    ...
</properties>
```

## Add a plugin declaration to the plugin management section for the central publishing plugin

Add a plugin declaration to the plugin management section of the pom.xml file for central-publishing-maven-plugin.

```
<build>
    ...
    <pluginManagement>
        ...
        <plugins>
            ...
            <plugin>
                <groupId>org.sonatype.central</groupId>
                <artifactId>central-publishing-maven-plugin</artifactId>
                <version>${central-publishing-maven-plugin.version}</version>
                <extensions>true</extensions>
                <configuration>
                     <!-- publishing server id refers to <id> element in <server> section of settings.xml -->
                    <publishingServerId>sonatype-central</publishingServerId>
                </configuration>
            </plugin>
            ....
        </plugins>
        ...
    </pluginManagement>
    ...
</build>
```

## Add a plugin declaration to the plugins section for the central publishing plugin

While the declaration in the plugins management section provides a default configuration for the plugin, a separate
 plugin declaration is necessary in the plugins section to actually have the plugin active in a lifecycle.

```
<build>
    ...
    <plugins>
        ...
        <plugin>
            <groupId>org.sonatype.central</groupId>
            <artifactId>central-publishing-maven-plugin</artifactId>
        </plugin>
        ....
    </plugins>
    ...
</build>
```


# Modify maven-release-plugin config to remove the "sonatype-deployment" maven profile

For the OSSRH publishing, a profile named "sonatype-deployment" had been defined in the parent pom.xml file:
```
<profile>
    <id>sonatype-deployment</id>
    <distributionManagement>
        <snapshotRepository>
            <id>ossrh</id>
            <url>https://oss.sonatype.org/content/repositories/snapshots</url>
        </snapshotRepository>
        <repository>
            <id>ossrh</id>
            <url>https://oss.sonatype.org/service/local/staging/deploy/maven2/</url>
        </repository>
    </distributionManagement>
</profile>
```

This results in the maven deploy plugin publishing the artifacts to the repositories specified in the distribution
 management section of the pom.xml file.  With the Sonatype Central Repository publishing process, the repositories
 defined in a distribution management section are not used.  No profile is specifically needed for publishing with the
 new process.

# Retain the release-sign-artifacts maven profile

The release-sign-artifacts maven profile is still needed to handle signing with the gpg plugin and building the
 source/javadoc artifacts necessary for publishing to maven central.

# SNAPSHOT releases

The Sonatype Central Publishing Portal publishing namespaces section separates OSSRH namespaces from Central Portal
 namespaces.  Central Portal namespaces have an option to enable SNAPSHOTS which must be enabled in order to publish
 snapshot builds to the namespace.  The [snapshot repository](https://central.sonatype.com/repository/maven-snapshots/)
 may be browsed/navigated with a web browser.

# Notes for Luminosity Labs github repositories

The main.yml workflow files need to be updated
- The PROFILES env var needs to be modified to change the older OSSRH deployment profiles (`sonatype-staging` and
 `sonatype-releases`) to the newer Sonatype Central profiles (`sonatype-central-portal-deployment` and
 `sonatype-central-snapshots`)
- The env vars in the deploy step need to be changed from `OSSRHU` / `OSSRHT` to `SONATYPE_CENTRAL_PORTAL_REPO_USERNAME`
 / `SONATYPE_CENTRAL_PORTAL_REPO_PASSWORD`
- Values must be set in the github repo settings "Actions secrets and variables" section for the new secrets.
