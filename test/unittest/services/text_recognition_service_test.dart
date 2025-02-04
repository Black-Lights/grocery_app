import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:grocery/services/text_recognition_service.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

// Correctly annotate the mock generation
@GenerateMocks([TextRecognitionService])
import 'text_recognition_service_test.mocks.dart'; // Ensure this is below the annotation

void main() {
  late MockTextRecognitionService mockTextRecognitionService;

  setUp(() {
    mockTextRecognitionService = MockTextRecognitionService(); // Use the mock instance
  });

  test('Should correctly extract barcode from an image', () async {
    // Simulate the barcode scanner returning a barcode
    when(mockTextRecognitionService.processImage(any))
        .thenAnswer((_) async => ProductDetails(barcode: '1234567890123'));

    final result = await mockTextRecognitionService.processImage('test_image.jpg');

    expect(result.barcode, '1234567890123');
  });

  test('Should correctly recognize text from an image', () async {
    // Simulate text recognition returning extracted text
    when(mockTextRecognitionService.processImage(any))
        .thenAnswer((_) async => ProductDetails(rawText: 'Expiry Date: 12/2025'));

    final result = await mockTextRecognitionService.processImage('test_image.jpg');

    expect(result.rawText, contains('Expiry Date: 12/2025'));
  });

  test('Should correctly parse expiry date from text', () async {
    // Simulate date recognition
    when(mockTextRecognitionService.processImage(any))
        .thenAnswer((_) async => ProductDetails(expiryDate: DateTime(2025, 12, 1)));

    final result = await mockTextRecognitionService.processImage('test_image.jpg');

    expect(result.expiryDate, DateTime(2025, 12, 1));
  });

  test('Should fetch product details from API using barcode', () async {
    // Simulate API response
    when(mockTextRecognitionService.processImage(any)).thenAnswer(
      (_) async => ProductDetails(name: 'Test Product', brand: 'Test Brand'),
    );

    final result = await mockTextRecognitionService.processImage('test_image.jpg');

    expect(result.name, 'Test Product');
    expect(result.brand, 'Test Brand');
  });
}
