# Flutter and its plugins ship their own consumer rules; these cover the
# reflection-heavy Google and Firebase sign-in libraries.
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.play.core.**
