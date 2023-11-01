class InviteReceive{
  late String _noteId;
  late Map<String, dynamic> _rules = {};

  InviteReceive.withValue(this._noteId, this._rules);
  InviteReceive();


  Map<String, dynamic> get rules => _rules;

  set rules(Map<String, dynamic> value) {
    _rules = value;
  }

  String get noteId => _noteId;

  set noteId(String value) {
    _noteId = value;
  }
}