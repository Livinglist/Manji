import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../resource/google_api_provider.dart';

part 'text_extraction_state.dart';

class TextExtractionCubit extends Cubit<TextExtractionState> {
  TextExtractionCubit(TextExtractionState initialState) : super(initialState);

  void detect(String imgStr) {
    GoogleApiProvider.extractTextFromImage(imgStr).then(
      (text) => emit(
        state.copyWith(text: text),
      ),
    );
  }

  void reset() {
    emit(state.copyWith(text: ''));
  }
}
