# Branch Conventions

| Branch     | Version | Java | Checkstyle | directory-maven-plugin-hazendaz | git-commit-id-maven-pluginn | Logback  | Spotbugs | TestNG    |
|------------|---------|------|------------|---------------------------------|-----------------------------|----------|----------|-----------|
| jdk26      | 0.7.x   | 26   | v13.x +    | v1.2.x +                        | v10.x +                     | v1.5.x + | 4.9.x +  | v7.12.x + |
| main,jdk25 | 0.6.x   | 25   | v13.x +    | v1.2.x +                        | v10.x +                     | v1.5.x + | 4.9.x +  | v7.12.x + |
| jdk21      | 0.5.x   | 21   | v13.x      | v1.2.x +                        | v10.x +                     | v1.5.x + | 4.9.x +  | v7.12.x + |
| jdk17      | 0.4.x   | 17   | v11.x      | v1.2.x +                        | v10.x +                     | v1.5.x + | 4.9.x +  | v7.12.x + |
| jdk11      | 0.3.x   | 11   | v10.x      | v1.2.x +                        | v10.x +                     | v1.5.x + | 4.9.x +  | v7.12.x + |
| jdk8       | 0.2.x   | 8    | v9.3       | v1.1.3                          | v4.9.9                      | v1.3.x   | 4.8.x    | v7.5.1    |

Other Notes:
- Java8 maven-compiler-plugin only supports `source` and `target` configuration properties while Java11 adds `release` property