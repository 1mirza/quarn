plugins {
    id "com.android.application"
    id "kotlin-android"
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id "dev.flutter.flutter-gradle-plugin"
}

// --- اضافه شده: بارگذاری فایل تنظیمات امضا ---
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
// ---------------------------------------------

android {
    namespace = "com.example.quran_sheshom_mirza"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.quran_sheshom_mirza"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // --- اضافه شده: پیکربندی امضای دیجیتال ---
    signingConfigs {
        release {
            // مقادیر را از فایل key.properties می‌خواند (که در گیت‌هاب اکشن ساخته می‌شود)
            keyAlias = keystoreProperties['keyAlias']
            keyPassword = keystoreProperties['keyPassword']
            storeFile = keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword = keystoreProperties['storePassword']
        }
    }
    // ----------------------------------------

    buildTypes {
        release {
            // --- تغییر مهم: استفاده از کانفیگ release به جای debug ---
            signingConfig = signingConfigs.release
            
            // گزینه‌های بهینه‌سازی (اختیاری)
            minifyEnabled false 
            shrinkResources false
        }
    }
}

flutter {
    source = "../.."
}