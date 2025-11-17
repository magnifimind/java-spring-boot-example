plugins {
    java
    id("org.springframework.boot") version "3.2.1"
    id("io.spring.dependency-management") version "1.1.4"
    id("org.openapi.generator") version "7.2.0"
    id("com.diffplug.spotless") version "6.23.3"
}

group = "com.example"
version = "0.0.1-SNAPSHOT"

java {
    sourceCompatibility = JavaVersion.VERSION_21
}

repositories {
    mavenCentral()
}

dependencies {
    // Spring Boot
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation("org.springframework.boot:spring-boot-starter-validation")

    // OpenAPI/Swagger
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:2.3.0")
    implementation("io.swagger.core.v3:swagger-annotations:2.2.20")
    implementation("org.openapitools:jackson-databind-nullable:0.2.6")

    // Jackson for JSON processing
    implementation("com.fasterxml.jackson.core:jackson-databind")
    implementation("com.fasterxml.jackson.datatype:jackson-datatype-jsr310")

    // Testing
    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("org.assertj:assertj-core:3.25.1")
}

tasks.withType<Test> {
    useJUnitPlatform()
}

// OpenAPI Generator configuration
openApiGenerate {
    generatorName.set("spring")
    inputSpec.set("$projectDir/src/main/resources/openapi/api-spec.yaml")
    outputDir.set("${layout.buildDirectory.get()}/generated")
    apiPackage.set("com.example.springbootexample.api")
    modelPackage.set("com.example.springbootexample.model")
    configOptions.set(
        mapOf(
            "dateLibrary" to "java8",
            "interfaceOnly" to "true",
            "useTags" to "true",
            "useSpringBoot3" to "true",
            "skipDefaultInterface" to "true",
            "performBeanValidation" to "true",
            "useBeanValidation" to "true",
        ),
    )
}

// Make sure generated sources are available
sourceSets {
    main {
        java {
            srcDir("${layout.buildDirectory.get()}/generated/src/main/java")
        }
    }
}

// Generate code before compiling
tasks.compileJava {
    dependsOn(tasks.openApiGenerate)
}

tasks.named<Jar>("jar") {
    enabled = false
}

// Spotless configuration for code formatting
spotless {
    java {
        target("src/*/java/**/*.java")
        // Exclude generated code
        targetExclude("build/generated/**")

        // Use Google Java Format
        googleJavaFormat("1.19.1")

        // Remove unused imports
        removeUnusedImports()

        // Format imports - no wildcards allowed
        importOrder()

        // Custom rule to prevent wildcard imports
        custom("noWildcardImports") {
            if (it.contains("import ") && it.contains(".*")) {
                throw RuntimeException("Wildcard imports are not allowed. Found: ${it.trim()}")
            }
            it
        }

        // Remove trailing whitespace
        trimTrailingWhitespace()

        // Ensure files end with a newline
        endWithNewline()
    }

    // Format Kotlin build files
    kotlinGradle {
        target("*.gradle.kts")
        ktlint()
    }
}
