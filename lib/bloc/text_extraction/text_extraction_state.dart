part of 'text_extraction_cubit.dart';

class TextExtractionState extends Equatable {
  final String text;

  TextExtractionState({required this.text});

  TextExtractionState copyWith({String? text}) {
    return TextExtractionState(text: text ?? this.text);
  }

  @override
  List<Object?> get props => [text];
}