import 'package:cloud_firestore/cloud_firestore.dart';

class Offer {
  final bool isSwitched;
  final Map orderAccepts;
  final Map offerAccepts;
  final String offerAddressName;
  final String offerCityName;
  final String offerDistance;
  final int offerEndPrice;
  final String offerGuestCount;
  final String offerId;
  final List offerImages;
  final List offerMetroStantion;
  final String offerRoomsCount;
  final int offerStartPrice;
  final String timestamp;
  final String userId;
  final String userName;


  const Offer(
      {
        this.isSwitched,
        this.orderAccepts,
        this.offerAccepts,
        this.offerAddressName,
        this.offerCityName,
        this.offerDistance,
        this.offerEndPrice,
        this.offerGuestCount,
        this.offerId,
        this.offerImages,
        this.offerMetroStantion,
        this.offerRoomsCount,
        this.offerStartPrice,
        this.timestamp,
        this.userId,
        this.userName,

      });

  factory Offer.fromDocument(DocumentSnapshot document) {
    return Offer(
      isSwitched: document['isSwitched'],
      orderAccepts: document['orderAccepts'],
      offerAccepts: document['offerAccepts'],
      offerAddressName: document['offerAddressName'],
      offerCityName: document['offerCityName'],
      offerDistance: document['offerDistance'],
      offerEndPrice: document['offerEndPrice'],
      offerGuestCount: document['offerGuestCount'],
      offerId: document.documentID,
      offerImages: document['offerImages'],
      offerMetroStantion: document['offerMetroStantion'],
      offerRoomsCount: document['offerRoomsCount'],
      offerStartPrice: document['offerStartPrice'],
      timestamp: document['timestamp'],
      userId: document['userId'],
      userName: document['userName'],

    );
  }
}