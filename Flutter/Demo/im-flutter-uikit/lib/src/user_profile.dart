import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/widgets/toast.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

import 'chat.dart';

class UserProfile extends StatefulWidget {
  final String userID;
  const UserProfile({Key? key, required this.userID}) : super(key: key);
  @override
  State<StatefulWidget> createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  final TIMUIKitProfileController _timuiKitProfileController =
      TIMUIKitProfileController();
  String? newUserMARK;

  _itemClick(String id, BuildContext context, V2TimConversation conversation) {
    switch (id) {
      case "sendMsg":
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Chat(
                selectedConversation: conversation,
              ),
            ));
        break;
      case "deleteFriend":
        _timuiKitProfileController.deleteFriend(widget.userID).then((res) {
          if (res == null) {
            throw Error();
          }
          if (res.resultCode == 0) {
            Toast.showToast(ToastType.success, imt("好友删除成功"), context);
            _timuiKitProfileController.loadData(widget.userID);
          } else {
            throw Error();
          }
        }).catchError((error) {
          Toast.showToast(ToastType.fail, imt("好友添加失败"), context);
        });
        break;
    }
  }

  _buildBottomOperationList(
      BuildContext context, V2TimConversation conversation) {
    final operationList = [
      {
        "label": imt("发送消息"),
        "id": "sendMsg",
      },
      // {
      //   "label": imt("语音通话"),
      //   "id": "audioCall",
      // },
      // {
      //   "label": imt("视频通话"),
      //   "id": "videoCall",
      // },
      {
        "label": imt("清除好友"),
        "id": "deleteFriend",
      }
    ];

    return operationList.map((e) {
      return InkWell(
        onTap: () {
          _itemClick(e["id"] ?? "", context, conversation);
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: hexToColor("E5E5E5")))),
          child: Text(
            e["label"] ?? "",
            style: TextStyle(
                color:
                    hexToColor(e["id"] != "deleteFriend" ? "147AFF" : "FF584C"),
                fontSize: 17),
          ),
        ),
      );
    }).toList();
  }

  _addFriend(BuildContext context) async {
    _timuiKitProfileController.addFriend(widget.userID).then((res) {
      if (res == null) {
        throw Error();
      }
      if (res.resultCode == 0) {
        Toast.showToast(ToastType.success, imt("好友添加成功"), context);
        _timuiKitProfileController.loadData(widget.userID);
      } else if (res.resultCode == 30539) {
        Toast.showToast(ToastType.success, imt("好友申请已发出"), context);
      } else if (res.resultCode == 30515) {
        // sdkInstance
        //     .getFriendshipManager()
        //     .deleteFromBlackList(userIDList: [userID]);
        Toast.showToast(ToastType.fail, imt("当前用户在黑名单"), context);
      } else {
        throw Error();
      }
    }).catchError((error) {
      Toast.showToast(ToastType.fail, imt("好友添加失败"), context);
    });
  }

  handleTapRemarkBar(BuildContext context) {
    _timuiKitProfileController.showTextInputBottomSheet(
        context, imt("修改备注"), imt("支持数字、英文、下划线"), (String remark) {
      newUserMARK = remark;
      _timuiKitProfileController.updateRemarks(widget.userID, remark);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.white,
        title: Text(
          imt("详细资料"),
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: hexToColor("EBF0F6"),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        leading: IconButton(
          padding: const EdgeInsets.only(left: 8),
          constraints: const BoxConstraints(),
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 18,
          ),
          onPressed: () {
            Navigator.pop(context, newUserMARK);
          },
        ),
      ),
      body: Container(
        color: hexToColor("F2F3F5"),
        child: TIMUIKitProfile(
          userID: widget.userID,
          controller: _timuiKitProfileController,
          operationListBuilder:
              (context, friendInfo, conversation, friendType) {
            final remark = friendInfo.friendRemark ?? imt("无");
            final isPined = conversation.isPinned ?? false;
            final userID = friendInfo.userID;
            final conversationId = conversation.conversationID;
            return friendType != 0
                ? Column(
                    children: [
                      TIMUIKitProfile.operationDivider(),
                      TIMUIKitProfile.remarkBar(remark, context,
                          handleTap: () => handleTapRemarkBar(context)),
                      TIMUIKitProfile.operationDivider(),
                      TIMUIKitProfile.addToBlackListBar(false, context, (value) {
                        _timuiKitProfileController.addUserToBlackList(
                            value, userID);
                      }),
                      TIMUIKitProfile.operationDivider(),
                      TIMUIKitProfile.pinConversationBar(isPined, context, (value) {
                        _timuiKitProfileController.pinedConversation(
                            value, conversationId);
                      }),
                      TIMUIKitProfile.operationDivider(),
                    ],
                  )
                : Column(
                    children: [
                      TIMUIKitProfile.operationDivider(),
                      Container(
                        alignment: Alignment.center,
                        // padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                bottom:
                                    BorderSide(color: hexToColor("E5E5E5")))),
                        child: Row(children: [
                          Expanded(
                            child: TextButton(
                                child: Text(imt("加为好友"),
                                    style: TextStyle(
                                        color: CommonColor.primaryColor,
                                        fontSize: 17)),
                                onPressed: () {
                                  _addFriend(context);
                                }),
                          )
                        ]),
                      )
                    ],
                  );
          },
          bottomOperationBuilder:
              (context, friendInfo, conversation, friendType) {
            return friendType != 0
                ? Column(
                    children: _buildBottomOperationList(context, conversation!))
                : Container();
          },
        ),
      ),
    );
  }
}
