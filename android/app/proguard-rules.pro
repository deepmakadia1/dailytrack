# R8 keep rules for the prod release (feature 012 research R2). Only what the
# plugins don't ship as consumer rules; each section names its plugin.

# flutter_local_notifications: scheduled notifications are stored with Gson,
# which needs the generic type information R8 would strip (plugin README).
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken

# Flutter embedding: references Play Core deferred components, which the app
# doesn't use.
-dontwarn com.google.android.play.core.**
