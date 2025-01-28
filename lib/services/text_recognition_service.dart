import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';

class ProductDetails {
  final String? name;
  final DateTime? expiryDate;
  final DateTime? manufacturingDate;
  final String? rawText;

  ProductDetails({
    this.name,
    this.expiryDate,
    this.manufacturingDate,
    this.rawText,
  });
}

class TextRecognitionService {
  final textRecognizer = TextRecognizer();

  Future<ProductDetails> processImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);

      String? productName;
      DateTime? expiryDate;
      DateTime? manufacturingDate;
      List<DateTime> foundDates = [];

      final text = recognizedText.text;
      print('Raw recognized text: $text');

      // Process each block of text
      for (TextBlock block in recognizedText.blocks) {
        final line = block.text.trim();
        print('Processing block: $line');

        // Look for dates in various formats
        final datePatterns = [
          // DD/MM/YYYY
          RegExp(r'(\d{2})/(\d{2})/(\d{4})'),
          // DD.MM.YY
          RegExp(r'(\d{2})\.(\d{2})\.(\d{2})'),
          // DD-MM-YYYY
          RegExp(r'(\d{2})-(\d{2})-(\d{4})'),
          // DD.MM.YYYY
          RegExp(r'(\d{2})\.(\d{2})\.(\d{4})'),
          // YYYY/MM/DD
          RegExp(r'(\d{4})/(\d{2})/(\d{2})'),
          // YYYY-MM-DD
          RegExp(r'(\d{4})-(\d{2})-(\d{2})'),
          // DD MM YY
          RegExp(r'(\d{2})\s+(\d{2})\s+(\d{2})'),
          // DD MM YYYY
          RegExp(r'(\d{2})\s+(\d{2})\s+(\d{4})'),
        ];
        
        for (var pattern in datePatterns) {
          final matches = pattern.allMatches(line);
          for (var match in matches) {
            try {
              DateTime? date;
              // Handle different date formats
              if (match.group(1)!.length == 4) {
                // YYYY format
                final year = int.parse(match.group(1)!);
                final month = int.parse(match.group(2)!);
                final day = int.parse(match.group(3)!);
                date = DateTime(year, month, day);
              } else {
                // DD format
                var day = int.parse(match.group(1)!);
                var month = int.parse(match.group(2)!);
                var year = int.parse(match.group(3)!);
                
                // Handle 2-digit year
                if (year < 100) {
                  year += 2000; // Assume 20xx for two-digit years
                }
                date = DateTime(year, month, day);
              }
              
              if (date != null) {
                foundDates.add(date);
                print('Found date: $date');
              }
            } catch (e) {
              print('Error parsing date: $e');
            }
          }
        }

        // Look for product name in the first few blocks
        if (productName == null && 
            !_containsDate(line) && 
            !_isCommonLabel(line) &&  
            line.length > 2) {
          productName = _cleanProductName(line);
          print('Found product name: $productName');
        }
      }

      // Sort dates and assign them
      if (foundDates.isNotEmpty) {
        foundDates.sort();
        final now = DateTime.now();
        
        for (var date in foundDates) {
          if (date.isAfter(now)) {
            if (expiryDate == null || date.isBefore(expiryDate)) {
              expiryDate = date;
              print('Set as expiry date: $date');
            }
          } else {
            if (manufacturingDate == null || date.isAfter(manufacturingDate)) {
              manufacturingDate = date;
              print('Set as manufacturing date: $date');
            }
          }
        }
      }

      return ProductDetails(
        name: productName,
        expiryDate: expiryDate,
        manufacturingDate: manufacturingDate ?? DateTime.now(),
        rawText: text,
      );
    } finally {
      textRecognizer.close();
    }
  }

  bool _containsDate(String text) {
    final datePatterns = [
      r'\d{2}[./-]\d{2}[./-]\d{2,4}',
      r'\d{4}[./-]\d{2}[./-]\d{2}',
      r'\d{2}\s+\d{2}\s+\d{2,4}',
    ];
    return datePatterns.any((pattern) => RegExp(pattern).hasMatch(text));
  }

  bool _isCommonLabel(String text) {
    final commonLabels = [
      'CATEGORIA',
      'PREIMBALLATO',
      'CONSERVARE',
      'PESO',
      'ORIGINE',
      'CALIBRO',
      'PREZZO',
      'IMPORTO',
      'INGREDIENTI',
      'VALORI',
      'ENERGIA',
      'GRASSI',
      'CARBOIDRATI',
      'PROTEINE',
      'SALE',
      'SCADENZA',
      'LOTTO',
      'PRODOTTO',
    ];
    
    return commonLabels.any((label) => 
      text.toUpperCase().contains(label) ||
      text.toUpperCase().startsWith(label)
    );
  }

  String _cleanProductName(String name) {
    return name
        .replaceAll(RegExp(r'\d+'), '')
        .replaceAll(RegExp(r'[./:*]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
