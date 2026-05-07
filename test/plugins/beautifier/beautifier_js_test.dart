import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/plugins/beautifier/providers/beautifier_provider.dart';
import 'package:sqa_multitools/plugins/beautifier/widgets/beautifier_highlighter.dart';
import 'package:sqa_multitools/core/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  });

  group('JavaScript Formatter Tests', () {
    test('formats complex one-line JS snippet (User Example)', () {
      final notifier = container.read(beautifierProvider.notifier);
      notifier.setLanguage(BeautifierLanguage.javascript);

      const input =
          "const app={data:[],init(){for(let i=0;i<10;i++)this.data.push({id:i,val:Math.random()*100});this.process()},process(){this.data=this.data.map(x=>({...x,active:x.val>50}));this.render()},render(){console.log('Results:',this.data);const s=this.data.reduce((a,b)=>a+b.val,0);console.log('Total:',s)}};app.init();class Utils{static log(m){console.log(`[LOG \${new Date().toISOString()}] \${m}`)}}Utils.log('App Started');";
      notifier.updateInput(input);
      notifier.format();

      final state = container.read(beautifierProvider);

      // Verify structure
      expect(state.output, contains('const app = {'));
      expect(state.output, contains('  data: [],'));
      expect(state.output, contains('  init() {'));
      expect(state.output, contains('for (let i = 0; i < 10; i++)'));
      expect(state.output, contains('  process() {'));
      expect(state.output, contains('active: x.val > 50'));
      expect(state.output, contains('class Utils {'));
      expect(state.output, contains('static log(m) {'));
      expect(
        state.output,
        contains('`[LOG \${new Date().toISOString()}] \${m}`'),
      );
    });

    test('respects indentWidth for JS', () {
      final notifier = container.read(beautifierProvider.notifier);
      notifier.setLanguage(BeautifierLanguage.javascript);
      notifier.setIndentWidth(4);

      const input = 'function test(){console.log("hi");}';
      notifier.updateInput(input);
      notifier.format();

      final state = container.read(beautifierProvider);
      expect(
        state.output,
        contains('function test() {\n    console.log("hi");\n}'),
      );
    });
    group('JS Lexer Edge Cases', () {
      test('handles template literals and strings correctly', () {
        final notifier = container.read(beautifierProvider.notifier);
        notifier.setLanguage(BeautifierLanguage.javascript);

        const input = "const s = `multi\nline`; const s2 = 'don\\'t';";
        notifier.updateInput(input);
        notifier.format();

        final state = container.read(beautifierProvider);
        expect(state.output, contains("const s = `multi\nline`;"));
        expect(state.output, contains("const s2 = 'don\\'t';"));
      });
    });
  });
}
