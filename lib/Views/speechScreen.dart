import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:text_to_speech/apiServices/apiServices.dart';
import 'package:text_to_speech/Views/chatModel.dart';
import 'package:velocity_x/velocity_x.dart';

import '../const/colors.dart';

class SpeechScreen extends StatefulWidget {
  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  FlutterTts flutterTts = FlutterTts();
  final askquestionController = TextEditingController();
  SpeechToText speechToText = SpeechToText();
  var isListening = false.obs;
  var text = "".obs;
  var textfieldEnable = false.obs;
  final List<ChatMessage> messages = [];
  var listen = false.obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: blackColor,
        appBar: AppBar(
          backgroundColor: greenColor,
          actions: [
            const Icon(
              Icons.settings_voice_rounded,
              color: whiteColor,
            ),
            Obx(() => Switch(
                activeColor: switchColor,
                value: listen.value,
                onChanged: (val) {
                  listen.value = val;
                }))
          ],
          centerTitle: true,
          title: const Text(
            "Your Assistent",
            style: TextStyle(color: whiteColor),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: Container(
                    color: blackColor,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: messages.length,
                      itemBuilder: (BuildContext context, index) {
                        var chat = messages[index];

                        return chatBubble(
                            textmessage: chat.text,
                            chatMessageType: chat.type!);
                      },
                    )),
              ),
              Obx(
                () => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        isListening.value == true
                            ? Expanded(
                                child: Center(
                                  child: Text(
                                    text.value,
                                    style: const TextStyle(color: whiteColor),
                                  ),
                                ),
                              )
                            : Expanded(
                                child: TextField(
                                  style: const TextStyle(color: whiteColor),
                                  controller: askquestionController,
                                  onChanged: (val) {
                                    askquestionController.text.isEmpty
                                        ? textfieldEnable.value = false
                                        : textfieldEnable.value = true;
                                  },
                                  decoration: const InputDecoration(
                                      hintText: "Ask me",
                                      hintStyle: TextStyle(color: whiteColor),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(40)),
                                          borderSide: BorderSide(
                                            color: whiteColor,
                                          )),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(40)),
                                          borderSide: BorderSide(
                                            color: whiteColor,
                                          ))),
                                ),
                              ),
                        textfieldEnable.value == false
                            ? AvatarGlow(
                                repeatPauseDuration:
                                    const Duration(milliseconds: 100),
                                endRadius: 30,
                                animate: isListening.value,
                                showTwoGlows: true,
                                duration: const Duration(milliseconds: 1000),
                                repeat: true,
                                glowColor: cyanColor,
                                child: FloatingActionButton(
                                  backgroundColor: greenColor,
                                  onPressed: () {},
                                  child: GestureDetector(
                                    onTapDown: (val) async {
                                      if (!isListening.value) {
                                        var available =
                                            await speechToText.initialize();
                                        if (available) {
                                          isListening.value = true;
                                          speechToText.listen(
                                              onResult: (result) {
                                            text.value = result.recognizedWords;
                                          });
                                        }
                                      }
                                    },
                                    onTapUp: (val) async {
                                      setState(() {
                                        isListening.value = false;
                                      });

                                      speechToText.stop();
                                      messages.add(ChatMessage(
                                          text: text.value,
                                          type: ChatMessageType.user));
                                      var msg = await ApiServices.sendMessage(
                                          message: text.value);

                                      setState(() {
                                        messages.add(ChatMessage(
                                            text: msg,
                                            type: ChatMessageType.bot));
                                      });
                                      if (listen.value == true) {
                                        await flutterTts.speak(msg);
                                      }
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: greenColor,
                                      child: Icon(
                                        isListening.value
                                            ? Icons.mic
                                            : Icons.mic_none,
                                        color: whiteColor,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : IconButton(
                                onPressed: () async {
                                  messages.add(ChatMessage(
                                      text: askquestionController.text,
                                      type: ChatMessageType.user));
                                  var msg = await ApiServices.sendMessage(
                                      message: askquestionController.text);

                                  setState(() {
                                    messages.add(ChatMessage(
                                        text: msg, type: ChatMessageType.bot));
                                  });
                                  askquestionController.clear();
                                  textfieldEnable.value = false;
                                  if (listen.value == true) {
                                    await flutterTts.speak(msg);
                                  }
                                },
                                icon: const CircleAvatar(
                                  backgroundColor: greenColor,
                                  child: Icon(
                                    Icons.send,
                                    color: whiteColor,
                                  ),
                                ),
                              )
                                .box
                                .color(greenColor)
                                .width(56)
                                .height(56)
                                .clip(Clip.antiAlias)
                                .roundedFull
                                .make(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget chatBubble(
      {required textmessage, required ChatMessageType chatMessageType}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: chatMessageType == ChatMessageType.user
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Visibility(
          visible: chatMessageType == ChatMessageType.bot ? true : false,
          child: const CircleAvatar(
            backgroundImage: AssetImage("images/logo.jpg"),
          ).box.color(cyanColor).width(40).height(40).roundedFull.make(),
        ),
        ChatBubble(
          clipper: ChatBubbleClipper1(
              type: chatMessageType == ChatMessageType.user
                  ? BubbleType.sendBubble
                  : BubbleType.receiverBubble),
          alignment: chatMessageType == ChatMessageType.user
              ? Alignment.topRight
              : Alignment.topLeft,
          margin: const EdgeInsets.only(top: 20),
          backGroundColor:
              chatMessageType == ChatMessageType.user ? whiteColor : greenColor,
          child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Text(
                textmessage,
                style: TextStyle(
                    color: chatMessageType == ChatMessageType.user
                        ? Colors.black
                        : Colors.white),
              )),
        ),
        Visibility(
          visible: chatMessageType == ChatMessageType.user ? true : false,
          child: const Icon(
            Icons.person,
            color: blackColor,
          ).box.color(whiteColor).width(40).height(40).roundedFull.make(),
        ),
      ],
    );
  }
}
