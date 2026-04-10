import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum UnityBridgeAvailability { available, unavailable }

class UnityBridgeService {
  UnityBridgeService._();

  static const MethodChannel _channel = MethodChannel(
    'smart_campus/unity_bridge',
  );

  static Future<UnityBridgeAvailability> checkAvailability() async {
    try {
      final bool? ready = await _channel.invokeMethod<bool>('isUnityReady');
      debugPrint(
        '[UnityBridge] Availability check: ${ready == true ? 'AVAILABLE' : 'UNAVAILABLE'}',
      );
      return ready == true
          ? UnityBridgeAvailability.available
          : UnityBridgeAvailability.unavailable;
    } on PlatformException catch (e) {
      debugPrint(
        '[UnityBridge] PlatformException in checkAvailability: ${e.message}',
      );
      return UnityBridgeAvailability.unavailable;
    } on MissingPluginException catch (e) {
      debugPrint('[UnityBridge] MissingPluginException in checkAvailability: $e');
      return UnityBridgeAvailability.unavailable;
    } catch (e) {
      debugPrint('[UnityBridge] Unexpected error in checkAvailability: $e');
      return UnityBridgeAvailability.unavailable;
    }
  }

  static Future<bool> launchCampus({
    String? focusBuilding,
    String? focusRoom,
  }) async {
    try {
      debugPrint(
        '[UnityBridge] Launching campus with building=$focusBuilding, room=$focusRoom',
      );
      final bool? launched = await _channel.invokeMethod<bool>(
        'launchUnityCampus',
        <String, dynamic>{
          'focusBuilding': focusBuilding,
          'focusRoom': focusRoom,
        },
      );
      final result = launched == true;
      debugPrint('[UnityBridge] Launch result: $result');
      return result;
    } on PlatformException catch (e) {
      debugPrint('[UnityBridge] PlatformException in launchCampus: ${e.message}');
      return false;
    } on MissingPluginException catch (e) {
      debugPrint('[UnityBridge] MissingPluginException in launchCampus: $e');
      return false;
    } catch (e) {
      debugPrint('[UnityBridge] Unexpected error in launchCampus: $e');
      return false;
    }
  }
}
