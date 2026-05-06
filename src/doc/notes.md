# Notes

## Commands used to increment version numbers

The version-maven-plugin is used to make modifications to pom.xml files for version manipulation.


### Set the version for the top-level project 

The following command uses maven wrapper to invoke maven, using the versions-maven-plugin's "set" goal to directly set
 the version of the top-level project.
```
./mvnw versions:set -DnewVersion=0.6.0-SNAPSHOT
```

Note: This will not recursively update the versions of any other projects/subprojects in the build.  Subsequent steps
 are used to handle the other projects/subprojects.

### Set the version for the other project(s) not defined as subprojects of the top-level project

The following command uses maven wrapper to invoke maven, using the versions-maven-plugin's "update-parent" goal to
 directly set the version of the parent project.
```
./mvnw versions:update-parent -f testing -DskipResolution=true -DparentVersion=0.6.0-SNAPSHOT
```

The `-f testing` portion of the command tells maven to work on the project contained within the
 testing directory.  This is a directory name containing a pom.xml file and does not necessarily correspond to the name
 of the project or artifactId in the pom.xml.

The `-DparentVersion=0.6.0-SNAPSHOT` portion of the command tells the plugin which version the parent project
 specification should be set to.

The `-DskipResolution=true` portion of the command tells the plugin NOT to look for existing versions of the parent
 project, but rather just use the version explicitly specified by the `parentVersion` property which must also be
 specified in the command.

### Set the versions of the subprojects

The following command uses the maven wrapper to invoke maven, using the version-maven-plugin's "update-child-modules"
 goal to recursively(?) set the versions of subprojects to the same version as their parent projects specifications.

```
./mvnw versions:update-child-modules -f testing
```

## TODO
- Modify justfile and shell scripts to be suitable for checking into main source code
- Modify docs to be suitable for checking into main source code
- Modify shell scripts in src/scripts to externalize configuration
