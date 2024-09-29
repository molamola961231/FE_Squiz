import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConstForChat {
  static final String OPEN_AI_KEY = dotenv.env['OPEN_AI_KEY']!;
  static final String GPT_API_URL = dotenv.env['GPT_API_URL']!;
  static final String OPEN_AI_ORGANIZATION_addr =
      dotenv.env['OPEN_AI_ORGANIZATION_addr']!;
}
