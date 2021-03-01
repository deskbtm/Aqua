# storage_mount_listener

storage mount/unmount listener 

## only Android

## Getting Start

```dart 

StreamSubscription storageSubscription;

@override
initState(){
  storageSubscription = StorageMountListener.channel.receiveBroadcastStream().listen((event) {
    log(event); // mounted removed removal eject
  });
}

@override
dispose(){
  storageSubscription?.remove();
}

```
