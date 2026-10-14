# MediaPipe (via flutter_gemma) references optional classes that aren't
# shipped; R8 fails the release build on them unless told to ignore them.
-dontwarn com.google.auto.value.extension.memoized.Memoized
-dontwarn com.google.mediapipe.proto.CalculatorProfileProto$CalculatorProfile
-dontwarn com.google.mediapipe.proto.GraphTemplateProto$CalculatorGraphTemplate
