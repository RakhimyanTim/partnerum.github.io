import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final bool isSwitched;
  final Map offerAccepts;
  final Map orderAccepts;
  final Timestamp orderArrivelDate;
  final String orderCityName;
  final String orderComissionSize;
  final String orderCustomerPhone;
  final Timestamp orderDepartureDate;
  final String orderDistanceTime;
  final int orderEndPrice;
  final String orderId;
  final String orderInfoField;
  final List orderMetroStantion;
  final List orderRoomsCount;
  final int orderStartPrice;
  final String timestamp;
  final String userId;
  final String userName;

  const Order(
      {this.isSwitched,
        this.offerAccepts,
        this.orderAccepts,
        this.orderArrivelDate,
        this.orderCityName,
        this.orderComissionSize,
        this.orderCustomerPhone,
        this.orderDepartureDate,
        this.orderDistanceTime,
        this.orderEndPrice,
        this.orderId,
        this.orderInfoField,
        this.orderMetroStantion,
        this.orderRoomsCount,
        this.orderStartPrice,
        this.timestamp,
        this.userId,
        this.userName});

  factory Order.fromDocument(DocumentSnapshot document) {
    return Order(
      isSwitched: document['isSwitched'],
      offerAccepts: document['offerAccepts'],
      orderAccepts: document['orderAccepts'],
      orderArrivelDate: document['orderArrivelDate'],
      orderCityName: document['orderCityName'],
      orderComissionSize: document['orderComissionSize'],
      orderCustomerPhone: document['orderCustomerPhone'],
      orderDepartureDate: document['orderDepartureDate'],
      orderDistanceTime: document['orderDistanceTime'],
      orderEndPrice: document['orderEndPrice'],
      orderId: document.documentID,
      orderInfoField: document['orderInfoField'],
      orderMetroStantion: document['orderMetroStantion'],
      orderRoomsCount: document['orderRoomsCount'],
      orderStartPrice: document['orderStartPrice'],
      timestamp: document['timestamp'],
      userId: document['userId'],
      userName: document['userName']);
  }
}