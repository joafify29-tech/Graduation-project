import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/config.dart';

class AiChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _systemPrompt = '''
You are a compassionate AI recovery companion for patients undergoing addiction and mental health recovery. 
Your role is to provide emotional support, motivation, and healthy coping strategies.

STRICT RULES:
- Do NOT prescribe, suggest, or discuss medications.
- Do NOT change or comment on any treatment plans.
- Do NOT provide medical diagnoses or medical advice.
- Do NOT replace or speak on behalf of any healthcare professional.
- Keep responses short, warm, and supportive (2-4 sentences max).

CRITICAL INSTRUCTION: You MUST respond in valid JSON format.
The JSON must have the following structure exactly:
{
  "chat_response": "Your supportive message to the patient",
  "mood_score": <integer from 1 to 100 representing the patient's current mood based on their message, where 100 is excellent and 1 is severe distress>,
  "risk_level": "<LOW, MEDIUM, or HIGH based on signs of relapse, self-harm, or severe emotional distress>",
  "risk_reason": "Brief explanation of why this risk level was chosen (leave empty if LOW)"
}
''';

  /// Sends a message to OpenAI and processes the AI response
  Future<void> sendMessage({
    required String patientId,
    required String sessionId,
    required String messageText,
    required List<Map<String, dynamic>> messageHistory,
  }) async {
    try {
      // 0. Manage Session Document (Create title if new)
      final sessionSnapshot = await _firestore
          .collection('chats')
          .doc(patientId)
          .collection('sessions')
          .doc(sessionId)
          .get();
          
      final currentTitle = sessionSnapshot.data()?['title'] ?? 'New Conversation';

      if (currentTitle == 'New Conversation') {
        String title = messageText;
        if (title.length > 30) {
          title = "${title.substring(0, 30)}...";
        }
        await _firestore
            .collection('chats')
            .doc(patientId)
            .collection('sessions')
            .doc(sessionId)
            .set({
          'title': title,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        await _firestore
            .collection('chats')
            .doc(patientId)
            .collection('sessions')
            .doc(sessionId)
            .update({
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // 1. Prepare messages for OpenAI
      List<Map<String, dynamic>> openAiMessages = [
        {"role": "system", "content": _systemPrompt}
      ];

      // Add recent history for context (last 10 messages to save tokens)
      final recentHistory = messageHistory.length > 10
          ? messageHistory.sublist(messageHistory.length - 10)
          : messageHistory;

      for (var msg in recentHistory) {
        openAiMessages.add({
          "role": msg['isUser'] == true ? "user" : "assistant",
          "content": msg['text'],
        });
      }

      // Add the current message
      openAiMessages.add({
        "role": "user",
        "content": messageText,
      });

      // 2. Call OpenAI API
      final String url = kIsWeb 
          ? 'https://corsproxy.io/?https://api.openai.com/v1/chat/completions'
          : 'https://api.openai.com/v1/chat/completions';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.openAiApiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'response_format': {'type': 'json_object'},
          'messages': openAiMessages,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiMessageContent = data['choices'][0]['message']['content'];

        // Parse the JSON response
        final aiJson = jsonDecode(aiMessageContent);
        
        final String chatResponse = aiJson['chat_response'] ?? "I'm here for you.";
        final int moodScore = aiJson['mood_score'] ?? 50;
        final String riskLevel = aiJson['risk_level'] ?? "LOW";
        final String riskReason = aiJson['risk_reason'] ?? "";

        // 3. Save AI message to Firestore session
        await _firestore
            .collection('chats')
            .doc(patientId)
            .collection('sessions')
            .doc(sessionId)
            .collection('messages')
            .add({
          'text': chatResponse,
          'isUser': false,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // 4. Update Analytics Report
        await _updateAnalytics(patientId, moodScore, riskLevel);

        // 5. Trigger Risk Alert if HIGH
        if (riskLevel == 'HIGH') {
          await _createRiskAlert(patientId, riskReason);
        }

      } else {
        debugPrint("OpenAI Error: ${response.body}");
        throw Exception("HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error in AiChatService: $e");
      // Fallback message in case of API failure
      await _firestore
          .collection('chats')
          .doc(patientId)
          .collection('sessions')
          .doc(sessionId)
          .collection('messages')
          .add({
        'text': "Connection Error: ${e.toString()}",
        'isUser': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _updateAnalytics(String patientId, int moodScore, String riskLevel) async {
    final docRef = _firestore.collection('ai_reports').doc(patientId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      
      if (!snapshot.exists) {
        // Create new report
        transaction.set(docRef, {
          'patientId': patientId,
          'currentMoodScore': moodScore,
          'currentRiskLevel': riskLevel,
          'moodHistory': [moodScore], // array of recent scores
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        // Update existing report
        List<dynamic> history = snapshot.data()?['moodHistory'] ?? [];
        history.add(moodScore);
        
        // Keep only last 7 scores for the 7-day trend
        if (history.length > 7) {
          history = history.sublist(history.length - 7);
        }
        
        transaction.update(docRef, {
          'currentMoodScore': moodScore,
          'currentRiskLevel': riskLevel,
          'moodHistory': history,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> _createRiskAlert(String patientId, String reason) async {
    await _firestore.collection('risk_alerts').add({
      'patientId': patientId,
      'alertType': 'AI Diagnostic Alert',
      'riskLevel': 'HIGH',
      'description': reason,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'UNRESOLVED', // So doctors know it needs attention
    });
  }
}
