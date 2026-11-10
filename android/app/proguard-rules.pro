# 生产包 R8 规则（release 启用 isMinifyEnabled / isShrinkResources）
# 原则：只 keep 反射 / JNI / 平台通道 / 第三方 SDK 入口，业务 Dart 代码不受影响。
# 首次打 release 包后务必做一次真机回归（推送、地图、微信、登录、支付）。

# ---- Flutter / 引擎 ----
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class com.planstar.app.** { *; }

# ---- JNI / 序列化 / 反射通用 ----
-keepclasseswithmembernames class * { native <methods>; }
-keepclassmembers class * { @android.webkit.JavascriptInterface <methods>; }
-keepclassmembers,allowoptimization enum * { public static **[] values(); public static ** valueOf(java.lang.String); }
-keepclassmembers class * implements android.os.Parcelable { public static final ** CREATOR; }
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable { *; }

# ---- 第三方 SDK（反射/动态加载较多，整体保留）----
-keep class cn.jpush.** { *; }
-keep class cn.jiguang.** { *; }
-keep class com.baidu.** { *; }
-keep class com.tencent.** { *; }
-keep class com.alibaba.** { *; }
-keep class com.aliyun.** { *; }
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }
-keep class com.google.gson.** { *; }

# 第三方 SDK 自带 keep 规则缺失时不要因警告中断构建；上线后按日志逐条收紧。
-dontwarn cn.jpush.**
-dontwarn cn.jiguang.**
-dontwarn com.baidu.**
-dontwarn com.tencent.**
-dontwarn com.alibaba.**
-dontwarn okhttp3.**
-dontwarn retrofit2.**
