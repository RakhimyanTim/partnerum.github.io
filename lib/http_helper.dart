import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

class HttpHelper {
  /*
   * @param token:              Firebase token of device
   * @param dataBody:           Data you want to send inside body param
   * @param dataTitle:          Data you want to send inside title param
   * @param notificationTitle:  Notification title that user will see
   * @param notificationBody:   Notification body that user will see
   */
  static Future<http.Response> sendFCMNotification(
      String token,
      String dataBody,
      String dataTitle,
      String notificationTitle,
      String notificationBody) {
    // Add your FCM server key here
    var fcmServerKey =
        "AAAAKwnUfHY:APA91bGzNNr1-yR8JMMK1Vr9u2zWZNSGYkCav-Ka-KKIW4oInDwCnjtTEaeNALu2Az51u32ubfYyABgh3_XnWLs7wIfeC388ObNPXSebcHK190cob6v_Fw3AqKRKPnmjZ-5ExNDeZqpt";
    var headers = {
      "Authorization": "key=$fcmServerKey",
      "Content-Type": "application/json",
    };

    /*
    * Don't forget to add this as data in order to get onLaunch and onResume method called
    *     'click_action': 'FLUTTER_NOTIFICATION_CLICK'
    * */
    var data = {
      'to': token,
      'data': {
        'body': dataBody,
        'title': dataTitle,
        'click_action': 'FLUTTER_NOTIFICATION_CLICK'
      },
      'notification': {
        'body': notificationBody,
        'title': notificationTitle,
      },
    };

    var body = JSON.jsonEncode(data);

    var url = "https://fcm.googleapis.com/fcm/send";

    return http.post(url, headers: headers, body: body);
  }
}
