const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.newOrderNotification = functions.firestore
    .document("orders/{orderId}")
    .onCreate((snap, context) => {

        console.log('----------------start [New order notification] function--------------------')

        const orderUserId = snap.data()["userId"];
        const orderCityName = snap.data()["orderCityName"];
//        const orderArrivelDate = snap.data()["orderArrivelDate"];
//        const orderDepartureDate = snap.data()["orderDepartureDate"];
//        const orderStartPrice = snap.data()["orderStartPrice"].toString();
//        const orderEndPrice = snap.data()["orderEndPrice"].toString();
//        const orderInfoField = snap.data()["orderInfoField"];
//        const orderDistanceTime = snap.data()["orderDistanceTime"];
//        const orderRoomsCount = snap.data()["orderRoomsCount"];
//        const orderComissionSize = snap.data()["orderComissionSize"];



//        console.log("orderMetroStantion_list: ", snap.data()["orderMetroStantion"]);
//        console.log("orderMetroStantion_single: ", snap.data()["orderMetroStantion"][0]);

        return admin.firestore()
            .collection("offers")
            .where("isSwitched", '==', true)
            .where("offerCityName", '==', snap.data()["orderCityName"])
//            .where("userId", ">", snap.data()["userId"])
//            .where("userId", "<", snap.data()["userId"])
            .get().then((snap) => {

                    snap.forEach(doc => {

                        const offer = {
                            "userId": doc.data().userId,
                            "offerAddressName": doc.data().offerAddressName,
                            "offerToken": doc.data().offerToken,
                            "userName": doc.data().userName,
                            "offerId": doc.data().offerId
                        }

                        const tokens = [];

                        if (snap.empty) {
                            console.log("No Device");
                        } else if (offer.userId == orderUserId) {
                            console.log("Own Device");
                        } else {
                            tokens.push(offer.offerToken);

                                const payload = {
                                "notification": {
                                    "title": "Новая заявка",
                                    "body": "Для квартиры по адресу: " + offer.offerAddressName,
                                    "sound": 'default',
                                    "icon": "assets/images/logo.png",
                                    "click_action": "FLUTTER_NOTIFICATION_CLICK"
                                },
                                "data": {
                                    "type": "newOrderNotificationType",
//                                    "orderCityName": orderCityName,
//                                    "orderStartPrice": orderStartPrice,
//                                    "orderEndPrice": orderEndPrice,
//                                    "orderInfoField": orderInfoField,
//                                    "orderInfoField": orderInfoField,
//                                    "orderDistanceTime": orderDistanceTime,
//                                    "orderRoomsCount": orderRoomsCount,
//                                    "orderComissionSize": orderComissionSize
                                },
                                }
                                return admin.messaging().sendToDevice(tokens, payload).then((response) => {

                                    console.log("Pushed to: ", offer.userName);
                                }).catch((err) => {
                                    console.log(err);
                                });
                        }
                    });
                });


    });

exports.newOfferNotification = functions.firestore
    .document("offers/{offerId}/{orders}/{orderId}")
    .onCreate((snap, context) => {

        console.log('----------------start [New offer notification] function--------------------')

        // ref to the parent document
        const ref = admin.firestore().collection('offers').doc(snap.data()["offerId"])

        return ref.get().then(snapshot => {

//            const offer = {
//                "offerImages": snapshot.data().offerImages,
//                "offerAddressName": snapshot.data().offerAddressName,
//                "offerCityName": snapshot.data().offerCityName,
//                "offerDistanceTime": snapshot.data().offerDistanceTime,
//                "offerEndPrice": snapshot.data().offerEndPrice.toString(),
//                "offerStartPrice": snapshot.data().offerStartPrice.toString(),
//                "offerGuestsCount": snapshot.data().offerGuestsCount,
//                "offerId": snapshot.data().offerId,
//                "offerRoomsCount": snapshot.data().offerRoomsCount,
//                "timestamp": snapshot.data().timestamp,
//                "userId": snapshot.data().userId,
//                "userName": snapshot.data().userName
//            }

            return admin.firestore()
                        .collection("orders")
                        .where("isSwitched", '==', true)
                        .where("orderId", "==", snap.data()["orderId"])
                        .get().then((snap) => {

                                snap.forEach(doc => {

                                    const order = {
                                        "orderToken": doc.data().orderToken,
                                        "userName": doc.data().userName
                                    }

                                    const tokens = [];

                                    if (snap.empty) {
                                        console.log("No Device");
                                    } else {
                                        tokens.push(order.orderToken);

                                            const payload = {
                                            "notification": {
                                                "title": "Новая квартира",
                                                "body": "Для заявки: " + doc.data().arrivel + " - " + doc.data().departure,
                                                "sound": 'default',
                                                "icon": "assets/images/logo.png",
                                                "click_action": "FLUTTER_NOTIFICATION_CLICK"
                                            },
                                            "data": {
                                                "type": "newOfferNotificationType",
//                                                "offerImage": offer.offerImages[0],
//                                                "offerCityName": offer.offerCityName,
//                                                "offerAddressName": offer.offerAddressName,
//                                                "offerDistanceTime": offer.offerDistanceTime,
//                                                "offerStartPrice": offer.offerStartPrice,
//                                                "offerEndPrice": offer.offerEndPrice,
//                                                "offerGuestsCount": offer.offerGuestsCount,
//                                                "offerId": offer.offerId,
//                                                "offerRoomsCount": offer.offerRoomsCount,
//                                                "timestamp": offer.timestamp
                                            },
                                            }
                                            return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                                                console.log("Pushed to: ", order.userName);
                                            }).catch((err) => {
                                                console.log(err);
                                            });
                                    }
                                });

                        });

        });
    });

exports.newMessageNotification = functions.firestore
  .document('messages/{groupId1}/{groupId2}/{message}')
  .onCreate((snap, context) => {
    console.log('----------------start [New message notification] function--------------------')

    const doc = snap.data()
    console.log(doc)

    const idFrom = doc.idFrom
    const idTo = doc.idTo
    const contentMessage = doc.content

    // Get push token user to (receive)
    admin
      .firestore()
      .collection('users')
      .where('userId', '==', idTo)
      .get()
      .then(querySnapshot => {
        querySnapshot.forEach(userTo => {
          console.log(`Found user to: ${userTo.data().userName}`)
          if (userTo.data().pushToken && userTo.data().chattingWith !== idFrom) {
            // Get info user from (sent)
            admin
              .firestore()
              .collection('users')
              .where('userId', '==', idFrom)
              .get()
              .then(querySnapshot2 => {
                querySnapshot2.forEach(userFrom => {
                  console.log(`Found user from: ${userFrom.data().userName}`)
                  const payload = {

                    'notification': {
                      'title': `Новое сообщение от "${userFrom.data().userName}"`,
                      'body': contentMessage,
                      "sound": 'default'
                    },

                    "data": {
                        "type": "newMessageNotificationType",
                        "peerId": idTo,
                        "currentId": idFrom,
                        "peerName": userFrom.data().userName
                    },

                  }
                  // Let push to the target device
                  admin
                    .messaging()
                    .sendToDevice(userTo.data().pushToken, payload)
                    .then(response => {
                      console.log('Successfully sent message:', response)
                    })
                    .catch(error => {
                      console.log('Error sending message:', error)
                    })
                })
              })
          } else {
            console.log('Can not find pushToken target user')
          }
        })
      })
    return null
  })

exports.addPeerUserToCHats = functions.firestore
    .document('messages/{groupId1}/{groupId2}/{message}')
    .onCreate((snap, context) => {

        console.log('----------------start [Add peer user to chats] function--------------------')

        const doc = snap.data()

        const idFrom = doc.idFrom
        const idTo = doc.idTo
        const currentName = doc.currentName
        const peerName = doc.peerName
        const content = doc.content
        const timestamp = doc.timestamp

        // ref to the parent document
        const docRef = admin.firestore().collection('users').doc(idFrom).collection('chats').doc(idTo)

        return docRef.get().then(snap => {
          return docRef.set({
            "userId": idTo,
            'userName': peerName,
            "uid": idFrom,
            'userImage': '',
            'isConfirmed': false,
            'lastMessage': content,
            'timestamp': timestamp,
            'unReadCount': 0,
          }, {merge: true});
        })
});

exports.addCurrentUserToChats = functions.firestore
    .document('messages/{groupId1}/{groupId2}/{message}')
    .onCreate((snap, context) => {

        console.log('----------------start [Add current user to chats] function--------------------')

        const doc = snap.data()
        const idFrom = doc.idFrom
        const idTo = doc.idTo
        const currentName = doc.currentName
        const peerName = doc.peerName
        const content = doc.content
        const timestamp = doc.timestamp

         // ref to the parent document
        const docRef = admin.firestore().collection('users').doc(idTo).collection('chats').doc(idFrom)

        return docRef.get().then(snap => {
            return docRef.set({
                "userId": idFrom,
                'userName': currentName,
                "uid": idFrom,
                'userImage': '',
                'isConfirmed': false,
                'lastMessage': content,
                'timestamp': timestamp,
                'unReadCount': 0,
            }, {merge: true});
        })
});

exports.updateLastMessage1 = functions.firestore
    .document('messages/{groupId1}/{groupId2}/{message}')
    .onWrite((change, context) => {

        console.log('----------------start [Update last message 1] function--------------------')

        const newValue = change.after.data();

        const idFrom = newValue.idFrom;
        const idTo = newValue.idTo;
        const content = newValue.content;
        const timestamp = newValue.timestamp;

        const docRef = admin.firestore().collection('users').doc(idTo).collection('chats').doc(idFrom)

        return docRef.get().then(snap => {
            return docRef.update({
                'lastMessage': content,
                'timestamp': timestamp,

            }, {merge: true});
        })

    });

exports.updateLastMessage2 = functions.firestore
    .document('messages/{groupId1}/{groupId2}/{message}')
    .onWrite((change, context) => {

        console.log('----------------start [Update last message 2] function--------------------')

        const newValue = change.after.data();

        const idFrom = newValue.idFrom;
        const idTo = newValue.idTo;
        const content = newValue.content;
        const timestamp = newValue.timestamp;

        const docRef = admin.firestore().collection('users').doc(idFrom).collection('chats').doc(idTo)

        return docRef.get().then(snap => {
            return docRef.update({
                'lastMessage': content,
                'timestamp': timestamp,
            }, {merge: true});
        })

    });

//exports.updateUnReadCount = functions.firestore
//    .document('messages/{groupId1}/{groupId2}/{message}')
//    .onWrite((change, context) => {
//
//        console.log('----------------start [Update unread count] function--------------------')
//
//        const newValue = change.after.data();
//
//        const idFrom = newValue.idFrom;
//        const idTo = newValue.idTo;
//        const content = newValue.content;
//        const timestamp = newValue.timestamp;
//
//        const docRef = admin.firestore().collection('users').doc(idFrom).collection('chats').doc(idTo)
//
//
//        return docRef.get().then(snap => {
//                    snap.forEach(doc => {
//                          return ref.collection('chats').doc(doc.data()['userId']).update({
//                            'userName': userName,
//                          }, {merge: true});
//                    });
//
//                });
//
//
//        return docRef.get().then(snap => {
//            return docRef.update({
//                'lastMessage': content,
//                'timestamp': timestamp,
//            }, {merge: true});
//        })
//
//    });

exports.createUserProfile = functions.auth.user().onCreate((user) => {
    console.log('---createUserProfile--->', user);
  return admin.firestore().collection("users").doc(user.uid).set({
    'userId': user.uid,
    'userName': user.displayName,
    'userEmail': user.email,
    'userPhone': user.phoneNumber,
    'userImage': user.photoURL,
    'createdOn' : user.metadata.creationTime,
    'pushToken': 'Не указан',
    'userStatus': 'Новичок',
    'paymentStatus': false,
    'searchIndex': [],
    'userPasImage': '',
    'isConfirmed': false,

  }).then(() => {

    var splitList = user.phoneNumber.split(" ");
    var indexList = [];

    for (var i = 0; i < splitList.length; i++) {
        for (var y = 1; y < splitList[i].length + 1; y++) {
            indexList.push(splitList[i].substring(0, y).toLowerCase());
         }
    }

    const ref = admin.firestore().collection('users').doc(user.uid)

    console.log('------------searchIndex', indexList);

    return ref.get().then(() => {
        return ref.update({
           'searchIndex': indexList
        }, {merge: true});
    })

  });
});

exports.ChangeSupportUserName = functions.firestore
    .document('users/{userId}/{chats}/{chatId}')
    .onCreate((snap, context) => {

        console.log('----------------start [Change support user name] function--------------------')

        const doc = snap.data()

        const id = doc.id
        const userId = doc.userId
        const userName = doc.userName

         // ref to the parent document
        const docRef = admin.firestore().collection('users').doc(id).collection('chats').doc(userId)

        return docRef.get().then(snap => {
            return docRef.update({
                'userName': "Поддрежка"
            }, {merge: true});
        })
});

exports.AddSupportMessageToChat = functions.auth.user().onCreate((user) => {

    console.log('----------------start [Add 1-st support message to chat] function--------------------')

    const ref = admin.firestore().collection('messages').doc(`BTjfYFm6oVg7ykdJzZv8HTzc4513-${user.uid}`).collection(`BTjfYFm6oVg7ykdJzZv8HTzc4513-${user.uid}`).doc("1564942051122")

    return ref.get().then(snap => {
        return ref.set({
            "content": 'Привет! Я твой помощник. Так что можешь мне писать по любым вопросам.',
            'currentName': 'Поддержка',
            "idFrom": 'BTjfYFm6oVg7ykdJzZv8HTzc4513',
            "idTo": user.uid,
            "peerName": 'Нет имени',
            'isConfirmed': true,
            'lastMessage': 'Привет! Я твой помощник. Так что можешь мне писать по любым вопросам.',
            'timestamp': '1564942051122',
            "type": 0
        });
    });
});

exports.aggregateDeals = functions.firestore
    .document('offers/{offerId}/orders/{orderId}')
    .onCreate((snap, context) => {

        console.log('----------------start [aggregateDeals] function--------------------')

        const doc = snap.data()
        console.log(doc)

        const offerId = context.params.offerId;
        const orderId = doc.orderId;


        // ref to the parent document
        const docRef = admin.firestore().collection('offers').doc(offerId)


        return docRef.get().then(snap => {

            // get the total deals count and add one
            const count = snap.data()['dealsCount'] + 1;

            console.log('snap.data()', snap.data());

            console.log('snap.data().dealsCount', snap.data()['dealsCount']);

            // run update
            return docRef.update({'dealsCount': count});
         })

});


exports.updateUser = functions.firestore
    .document('users/{userId}')
    .onWrite((change, context) => {

        console.log('----------------start [Update user] function--------------------')

        const newValue = change.after.data();

        const userId = newValue.userId;
        const userName = newValue.userName;
        const userImage = newValue.userImage;
        const isConfirmed = newValue.isConfirmed;

        const docRef = admin.firestore().collection('users').doc(userId)

        return docRef.collection('chats').get().then(snap => {
            snap.forEach(doc => {

                const ref = admin.firestore().collection('users').doc(doc.data()['userId'])

                return ref.collection('chats').get().then(snapshot => {

                    snapshot.forEach(val => {

                        console.log('userName', val.data()['userName']);

                          return ref.collection('chats').doc(val.data()['userId']).update({
                            'userName': userName,
                            'userImage': userImage,
                            'isConfirmed': isConfirmed,
                          }, {merge: true});
                    });

                });
            });

        })

    });




