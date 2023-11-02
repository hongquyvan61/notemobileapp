class Invite{
  late String _noteId;
  late Map<String, String> _rules = {};

  Invite.withValue(this._noteId, this._rules);
  Invite();


  Map<String, String> get rules => _rules;

  set rules(Map<String, String> value) {
    _rules = value;
  }

  String get noteId => _noteId;

  set noteId(String value) {
    _noteId = value;
  }

  Map<String, dynamic> toMap(){
    return {
      'rules': _rules,
    };
  }
}