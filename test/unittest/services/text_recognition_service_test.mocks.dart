// Mocks generated by Mockito 5.4.5 from annotations
// in grocery/test/unittest/services/text_recognition_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as _i3;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'
    as _i2;
import 'package:grocery/services/text_recognition_service.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeTextRecognizer_0 extends _i1.SmartFake
    implements _i2.TextRecognizer {
  _FakeTextRecognizer_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeBarcodeScanner_1 extends _i1.SmartFake
    implements _i3.BarcodeScanner {
  _FakeBarcodeScanner_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeProductDetails_2 extends _i1.SmartFake
    implements _i4.ProductDetails {
  _FakeProductDetails_2(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [TextRecognitionService].
///
/// See the documentation for Mockito's code generation for more information.
class MockTextRecognitionService extends _i1.Mock
    implements _i4.TextRecognitionService {
  MockTextRecognitionService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.TextRecognizer get textRecognizer =>
      (super.noSuchMethod(
            Invocation.getter(#textRecognizer),
            returnValue: _FakeTextRecognizer_0(
              this,
              Invocation.getter(#textRecognizer),
            ),
          )
          as _i2.TextRecognizer);

  @override
  _i3.BarcodeScanner get barcodeScanner =>
      (super.noSuchMethod(
            Invocation.getter(#barcodeScanner),
            returnValue: _FakeBarcodeScanner_1(
              this,
              Invocation.getter(#barcodeScanner),
            ),
          )
          as _i3.BarcodeScanner);

  @override
  _i5.Future<_i4.ProductDetails> processImage(String? imagePath) =>
      (super.noSuchMethod(
            Invocation.method(#processImage, [imagePath]),
            returnValue: _i5.Future<_i4.ProductDetails>.value(
              _FakeProductDetails_2(
                this,
                Invocation.method(#processImage, [imagePath]),
              ),
            ),
          )
          as _i5.Future<_i4.ProductDetails>);
}
