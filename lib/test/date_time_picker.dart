import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:notemobileapp/test/notifi_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notemobileapp/test/ttspeech_config.dart';

DateTime scheduleTime = DateTime.now();
Duration durationTime = const Duration();
FlutterTts flutterTts = FlutterTts();

class DatePickerTxt extends StatefulWidget {
  const DatePickerTxt({super.key});

  @override
  State<DatePickerTxt> createState() => _DatePickerTxtState();
}

class _DatePickerTxtState extends State<DatePickerTxt> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          DatePicker.showDateTimePicker(
            context,
            showTitleActions: true,
            onChanged: (date) => {scheduleTime = date},
            onConfirm: (date) {},
          );
        },
        child: const Text(
          "Select Date Time",
          style: TextStyle(color: Colors.blue),
        ));
  }
}

class ScheduleBtn extends StatelessWidget {
  const ScheduleBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          String hour = time_schedule().inHours.toString();
          String minute = time_schedule().inMinutes.toString();
          String second = time_schedule().inSeconds.toString();
          Fluttertoast.showToast(
              msg:
                  "Đã đặt thông báo nhắc nhở sau $hour giờ $minute phút $second giây",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);

          NotificationService().scheduleNotification(
              title: 'Scheduled Notification',
              body: 'Nội dung thông báo',
              scheduledNotificationDateTime: scheduleTime);

          Future.delayed(
              scheduleTime
                  .difference(DateTime.now().add(const Duration(seconds: -2))),
              () async => {
                    configTextToSpeech(flutterTts),
                    flutterTts.speak('$scheduleTime'),
                  });
        },
        child: const Text('Schedule notifications'));
  }
}

Duration time_schedule() {
  return durationTime = scheduleTime.difference(DateTime.now());
}
