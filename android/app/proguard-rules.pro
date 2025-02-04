# Keep all ML Kit classes
-keep class com.google.mlkit.** { *; }
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }

# Keep Firebase-related classes
-keep class com.google.firebase.** { *; }
-keep class com.google.gms.** { *; }

# Prevent obfuscation of model classes
-keep class * implements android.os.Parcelable { *; }
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}
