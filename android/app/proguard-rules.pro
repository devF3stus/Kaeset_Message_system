# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# App Specific classes
-keep class com.kaeset.messagesystem.** { *; }

# Sqflite SQLite Database Keep Rules
-keep class com.tekartik.sqflite.** { *; }

# Prevent warnings
-dontwarn io.flutter.embedding.**
-dontwarn androidx.**
-dontwarn com.google.android.gms.**

# Preserve line numbers and file names for debugging crash reports
-keepattributes SourceFile,LineNumberTable
-keepattributes *Annotation*
