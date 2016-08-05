# MJVersionUpdate
Check and update  app's version for both AppStore &amp; Fir

### How to use

######1.Add Channel in info.plist
Now we only support two channels "AppStore" or "Fir", no channel or other channel are ignored.
![demo1](https://raw.githubusercontent.com/tenric/VersionUpdate/master/VersionUpdateDemo/Demo1.png)

######2.Include library use CocoaPods
    pod 'VersionUpdate', '~> 1.0.2'

######3.Call this when app launch

    MJVersionUpdate *versionUpdate = [MJVersionUpdate new];
    [versionUpdate addAppStoreChannelWithAppId:@"1114716391"];
    [versionUpdate addFirChannelWithAppId:@"5721b76e748aac3e6b000017" token:@"5e1272271c5f28a11c60ebd761203a9c" downloadUrl:@"http://fir.im/yanzheng"];
    [versionUpdate checkUpdate];

######4.If there has new version,just show alert which you can ignore or go to update.
![demo2](https://raw.githubusercontent.com/tenric/VersionUpdate/master/VersionUpdateDemo/Demo2.png)
