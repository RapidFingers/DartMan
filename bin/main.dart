import '../lib/dartman_lib.dart';

main(List<String> arguments) async {
  var dartman = new Dartman();
  await dartman.process(arguments);
}
