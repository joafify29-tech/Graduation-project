class AppConfig {
  // WARNING: In a real production app, never hardcode API keys. 
  // You can pass it at build/run time using --dart-define=OPENAI_API_KEY=your_key
  static const String openAiApiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
}
