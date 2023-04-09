enum ChatMessageType { user, bot }

class ChatMessage {
  String? text;
  ChatMessageType? type;
  ChatMessage({this.text, this.type});
}
