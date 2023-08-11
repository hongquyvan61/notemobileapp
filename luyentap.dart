import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text('Siuuuu'),
        ),
        body:  const Center(
          child: Widgetful(false),
          ),
      ),
    ),

    debugShowCheckedModeBanner: false,
  ));
}

class Widgetless extends StatelessWidget {
  final bool loading;

  const Widgetless(this.loading, {super.key});

  @override
  Widget build(BuildContext context) {
    return loading ? const CircularProgressIndicator() : const Text('ahihi');
  }

}

class Widgetful extends StatefulWidget {

  final bool loading;

  const Widgetful(this.loading, {super.key});

  @override
  State<StatefulWidget> createState() {
      return WidgetfulState();
  }

}

class WidgetfulState extends State<Widgetful> {

  late bool localloading;

  @override
  void initState() {
    localloading = widget.loading;
  }
  
  @override
  Widget build(BuildContext context) {
    return localloading ? const CircularProgressIndicator() : FloatingActionButton(onPressed: clicknut);
  }

  void clicknut(){
    setState(() {
      localloading = true;
    });
  }

}