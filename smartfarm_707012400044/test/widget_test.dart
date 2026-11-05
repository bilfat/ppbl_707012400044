// Widget test for template_proyek_ppbl
import 'package:flutter_test/flutter_test.dart';
import 'package:template_proyek_ppbl/main.dart';

void main() {
  testWidgets('Template smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TemplateApp());
    expect(find.text('Uji Coba Template Offline PPBL'), findsOneWidget);
  });
}
